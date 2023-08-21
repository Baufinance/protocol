// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../interfaces/ICurve.sol";
import "../interfaces/ICurveFactoryETH.sol";
import "../abstract/StrategyCurveBase.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract StrategyConvexCurveRewardsBase is StrategyCurveBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Curve stuff
    ICurveFi public curve; // Curve Token, this is our pool specific to this vault

    bool isETHPool;
    bool public isWETHPool;
    bool public isCRVPool;
    bool public isCVXPool;
    bool public isUseUnderlying;

    bool public isSUSD;


    address eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public targetCoin;
    uint256 public targetCoinIndex;

    bytes public swapPath;

    error InvalidNCoins();

    constructor(
        address _vault,
        uint256 _pid,
        address _curvePool,
        bytes memory _swapPath,
        string memory _name,
        bool _isLendingPool,
        bool _isSUSD
    ) StrategyCurveBase(_vault, _pid, _name) {
        _initializeStrat(
            _curvePool,
            _swapPath,
            _isLendingPool,
            _isSUSD
        );
    }

    receive() external payable {}

    function initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _factory
    ) public {
        _initialize(_vault, _strategist, _rewards, _keeper);
        ICurveFactory.Vault memory v = ICurveFactory(_factory).deployedVaults(_vault);
        ICurveFactory.StrategyParams memory s = ICurveFactory(_factory).vaultStrategies(_vault);
        ICurveFactory.CustomPool memory p = ICurveFactory(_factory).customPools(v.lptoken);


        _initializeStratBase(s.pid, s.symbol);
        _initializeStrat(
            v.deposit,
            s.swapPath,
            v.isLendingPool,
            p.isSUSD
        );
    }

    function _initializeStrat(
        address _curvePool,
        bytes memory _swapPath,
        bool _isLendingPool,
        bool _isSUSD
    ) internal {
        uint256 _nCoins = nCoins();
        for (uint256 i; i < _nCoins; i++) {
            address coin;

            if (_isLendingPool) {
                if (_isSUSD) {
                    coin = ICurveFi(_curvePool).underlying_coins(
                        int128(int256(i))
                    );
                } else {
                    coin = ICurveFi(_curvePool).underlying_coins(i);
                }
            } else {
                coin = ICurveFi(_curvePool).coins(i);
            }

            if (coin == eth) {
                isETHPool = true;
                break;
            }

            if (coin == address(crv)) {
                isCRVPool = true;
                break;
            }

            if (coin == address(convexToken)) {
                isCVXPool = true;
                break;
            }

            if (coin == address(weth)) {
                isWETHPool = true;
                break;
            }
        }

        if (_isLendingPool) {
            targetCoin = ICurveFi(_curvePool).underlying_coins(
                int128(int256(targetCoinIndex))
            );
        } else {
            targetCoin = ICurveFi(_curvePool).coins(targetCoinIndex);
        }

        IERC20(targetCoin).approve(_curvePool, type(uint256).max);

        curve = ICurveFi(_curvePool);

        swapPath = _swapPath;

        isUseUnderlying = _isLendingPool;

        isSUSD = _isSUSD;
    }

    // we use this to clone our original strategy to other vaults
    function clone(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _factory
    ) external virtual returns (address newStrategy) {
        require(isOriginal);
        // Copied from https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactorysol
        bytes20 addressBytes = bytes20(address(this));
        assembly {
            // EIP-1167 bytecode
            let clone_code := mload(0x40)
            mstore(
                clone_code,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(
                add(clone_code, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            newStrategy := create(0, clone_code, 0x37)
        }

        StrategyConvexCurveRewardsBase(payable(newStrategy)).initialize(
            _vault,
            _strategist,
            _rewards,
            _keeper,
            _factory
        );

        emit Cloned(newStrategy);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function prepareReturn(
        uint256 _debtOutstanding
    )
        internal
        override
        returns (uint256 _profit, uint256 _loss, uint256 _debtPayment)
    {
        // this claims our CRV, CVX, and any extra tokens like SNX or ANKR. no harm leaving this true even if no extra rewards currently.
        rewardsContract.getReward(address(this), true);

        uint256 crvBalance = crv.balanceOf(address(this));
        uint256 convexBalance = convexToken.balanceOf(address(this));

        // claim and sell our rewards if we have them
        if (hasRewards) {
            uint256 _rewardsBalance = IERC20(rewardsToken).balanceOf(
                address(this)
            );
            if (_rewardsBalance > 0) {
                _sellRewards(_rewardsBalance);
            }
        }

        // do this even if we have zero balances so we can sell WETH from rewards
        _sellCrvAndCvx(crvBalance, convexBalance);

        _depositToCurve();

        // debtOustanding will only be > 0 in the event of revoking or if we need to rebalance from a withdrawal or lowering the debtRatio
        if (_debtOutstanding > 0) {
            uint256 _stakedBal = stakedBalance();
            if (_stakedBal > 0) {
                rewardsContract.withdrawAndUnwrap(
                    Math.min(_stakedBal, _debtOutstanding),
                    claimRewards
                );
            }
            uint256 _withdrawnBal = balanceOfWant();
            _debtPayment = Math.min(_debtOutstanding, _withdrawnBal);
        }

        // serious loss should never happen, but if it does (for instance, if Curve is hacked), let's record it accurately
        uint256 assets = estimatedTotalAssets();
        uint256 debt = vault.strategies(address(this)).totalDebt;

        // if assets are greater than debt, things are working great!
        if (assets > debt) {
            _profit = assets.sub(debt);
            uint256 _wantBal = balanceOfWant();
            if (_profit.add(_debtPayment) > _wantBal) {
                // this should only be hit following donations to strategy
                liquidateAllPositions();
            }
        }
        // if assets are less than debt, we are in trouble
        else {
            _loss = debt.sub(assets);
        }

        // we're done harvesting, so reset our trigger if we used it
        forceHarvestTriggerOnce = false;
    }

    // Sells our CRV and CVX on Curve, then WETH -> stables together on UniV3
    function _sellCrvAndCvx(
        uint256 _crvAmount,
        uint256 _convexAmount
    ) internal {
        bool isSwapToETH = isETHPool;

        if (_convexAmount > 1e17 && !isCVXPool) {
            // don't want to swap dust or we might revert
            cvxeth.exchange(1, 0, _convexAmount, 0, isSwapToETH);
        }

        if (_crvAmount > 1e17 && !isCRVPool) {
            // don't want to swap dust or we might revert
            crveth.exchange(1, 0, _crvAmount, 0, isSwapToETH);
        }

        if (!isWETHPool && !isETHPool) {
            uint256 _wethBalance = weth.balanceOf(address(this));
            if (_wethBalance > 1e15) {
                // don't want to swap dust or we might revert
                IUniV3(uniswapv3).exactInput(
                    IUniV3.ExactInputParams(
                        swapPath,
                        address(this),
                        block.timestamp,
                        _wethBalance,
                        uint256(1)
                    )
                );
            }
        }
    }

    function _depositToCurve() internal virtual {}

    function updateSwapPath(bytes memory _swapPath) external onlyVaultManagers {
        swapPath = _swapPath;
    }

    function setOptimalTargetCoinIndex(
        uint256 _targetCoinIndex,
        bytes memory _swapPath
    ) external virtual onlyVaultManagers {
        IERC20(targetCoin).approve(address(curve), 0);

        targetCoinIndex = _targetCoinIndex;

        //DEV move to factory
        if (isUseUnderlying) {
            if (isSUSD) {
                targetCoin = curve.underlying_coins(
                    int128(int256(targetCoinIndex))
                );
            } else {
                targetCoin = curve.underlying_coins(targetCoinIndex);
            }
        } else {
            targetCoin = curve.coins(targetCoinIndex);
        }

        IERC20(targetCoin).approve(address(curve), type(uint256).max);

        swapPath = _swapPath;
    }

    function nCoins() public virtual view returns (uint256) {}
}
