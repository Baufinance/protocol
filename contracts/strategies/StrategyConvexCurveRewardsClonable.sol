// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

import "../interfaces/ICurve.sol";
import "../abstract/StrategyCurveBase.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StrategyConvexCurveRewardsClonable is StrategyCurveBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // Curve stuff
    ICurveFi public curve; // Curve Token, this is our pool specific to this vault

    bool isETHPool;
    bool public isWETHPool;
    bool public isCRVPool;
    bool public isCVXPool;
    bool public isUseUnderlying;

    uint256 nCoins;

    address eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 public targetCoinIndex;

    bytes public swapPath;

    error InvalidNCoins();

    constructor(
        address _vault,
        uint256 _pid,
        address _curvePool,
        bytes memory _swapPath,
        string memory _name,
        uint256 _nCoins,
        bool _isUseUnderlying
    ) StrategyCurveBase(_vault, _pid, _name) {
      _initializeStrat(_curvePool, _nCoins, _swapPath, _isUseUnderlying);
    }

    receive() external payable {}
    function initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        uint256 _pid,
        address _curvePool,
        bytes memory _swapPath,
        string memory _name,
        uint256 _nCoins,
        bool _isUseUnderlying
    ) public {
        _initialize(_vault, _strategist, _rewards, _keeper);
        _initializeStratBase(_pid, _name);
        _initializeStrat(_curvePool, _nCoins, _swapPath, _isUseUnderlying);
    }

    function _initializeStrat(address _curvePool, uint256 _nCoins, bytes memory _swapPath, bool _isUseUnderlying) internal {

        if (_nCoins < 2) {
          revert InvalidNCoins();
        }
        for (uint256 i; i < _nCoins; i++) {
          address coin = ICurveFi(_curvePool).coins(i);

          targetCoinIndex = i;

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

        address targetCoin = ICurveFi(_curvePool).coins(targetCoinIndex);

        IERC20(targetCoin).approve(_curvePool, type(uint256).max);

        curve = ICurveFi(_curvePool);

        nCoins = _nCoins;

        swapPath = _swapPath;

        isUseUnderlying = _isUseUnderlying;
    }


     // we use this to clone our original strategy to other vaults
    function cloneConvexCurveRewards(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        uint256 _pid,
        address _curvePool,
        bytes memory _swapPath,
        string memory _name,
        uint256 _nCoins,
        bool _isUseUnderlying
    ) external returns (address newStrategy) {
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

        StrategyConvexCurveRewardsClonable(payable(newStrategy)).initialize(
            _vault,
            _strategist,
            _rewards,
            _keeper,
            _pid,
            _curvePool,
            _swapPath,
            _name,
            _nCoins,
            _isUseUnderlying
        );

        emit Cloned(newStrategy);
    }

        /* ========== MUTATIVE FUNCTIONS ========== */

    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {
        // this claims our CRV, CVX, and any extra tokens like SNX or ANKR. no harm leaving this true even if no extra rewards currently.
        rewardsContract.getReward(address(this), true);

        uint256 crvBalance = crv.balanceOf(address(this));
        uint256 convexBalance = convexToken.balanceOf(address(this));

        uint256 _sendToVoter = crvBalance.mul(keepCRV).div(FEE_DENOMINATOR);
        if (_sendToVoter > 0) {
            crv.safeTransfer(voter, _sendToVoter);
            crvBalance = crv.balanceOf(address(this));
        }

        uint256 _cvxToKeep = convexBalance.mul(keepCVX).div(FEE_DENOMINATOR);
        if (_cvxToKeep > 0) {
            convexToken.safeTransfer(keepCVXDestination, _cvxToKeep);
            convexBalance = convexToken.balanceOf(address(this));
        }

        // claim and sell our rewards if we have them
        if (hasRewards) {
            uint256 _rewardsBalance =
                IERC20(rewardsToken).balanceOf(address(this));
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
    function _sellCrvAndCvx(uint256 _crvAmount, uint256 _convexAmount)
        internal
    {
        if (_convexAmount > 1e17 && !isCVXPool) {
            // don't want to swap dust or we might revert
            cvxeth.exchange(1, 0, _convexAmount, 0, false);
        }

        if (_crvAmount > 1e17 && !isCRVPool) {
            // don't want to swap dust or we might revert
            crveth.exchange(1, 0, _crvAmount, 0, false);
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

    function _depositToCurve() internal {

      address targetCoin = curve.coins(targetCoinIndex);

      uint256 targetBalance = IERC20(targetCoin).balanceOf(address(this));

      if (targetCoin == eth) {
        targetBalance = address(this).balance;
      }
      uint256[2] memory coins2;
      uint256[3] memory coins3;
      uint256[4] memory coins4;

      for (uint256 i; i < nCoins; i++) {
        if (i ==  targetCoinIndex) {
          if (nCoins == 2) {
            coins2[i] = targetBalance;
          } else if (nCoins == 3) {
            coins3[i] = targetBalance;
          } else {
            coins4[i] = targetBalance;
          }
        } else {
          if (nCoins == 2) {
            coins2[i] = 0;
          } else if (nCoins == 3) {
            coins3[i] = 0;
          } else {
            coins4[i] = 0;
          }
        }
      }

      if (isUseUnderlying) {
        if (nCoins == 2) {
          curve.add_liquidity(coins2, 0, true);
        } else if (nCoins == 3) {
          curve.add_liquidity(coins3, 0, true);
        } else {
          curve.add_liquidity(coins4, 0, true);
        }
      } else {
        if (isETHPool) {
          if (nCoins == 2) {
            curve.add_liquidity{value: targetBalance}(coins2, 0);
          } else if (nCoins == 3) {
            curve.add_liquidity{value: targetBalance}(coins3, 0);
          } else {
            curve.add_liquidity{value: targetBalance}(coins4, 0);
          }
        } else {
          if (nCoins == 2) {
            curve.add_liquidity(coins2, 0);
          } else if (nCoins == 3) {
            curve.add_liquidity(coins3, 0);
          } else {
            curve.add_liquidity(coins4, 0);
          }
        }
      }
    }

    function updateSwapPath(bytes memory _swapPath) external onlyVaultManagers {
      swapPath = _swapPath;
    }

    function setOptimalTargetCoinIndex(uint256 _targetCoinIndex) external onlyVaultManagers {
      address targetCoin = curve.coins(targetCoinIndex);

      IERC20(targetCoin).approve(address(curve), 0);

      targetCoinIndex = _targetCoinIndex;

      targetCoin = curve.coins(targetCoinIndex);

      IERC20(targetCoin).approve(address(curve), type(uint256).max);
    }
}