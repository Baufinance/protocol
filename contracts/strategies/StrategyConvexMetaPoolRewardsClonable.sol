// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../abstract/StrategyConvexCurveRewardsBase.sol";
import {ICurveFi} from "../interfaces/ICurve.sol";

contract StrategyConvexMetaPoolRewardsClonable is StrategyConvexCurveRewardsBase {

    address zapContract;

    constructor(
        address _vault,
        uint256 _pid,
        address _curvePool,
        bytes memory _swapPath,
        string memory _name,
        bool _isLendingPool,
        bool _isDepositContract
    )
        StrategyConvexCurveRewardsBase(
            _vault,
            _pid,
            _curvePool,
            _swapPath,
            _name,
            _isLendingPool,
            _isDepositContract
        )
    {}

    function _depositToCurve() internal override {
        uint256 targetBalance = IERC20(targetCoin).balanceOf(address(this));

        if (targetCoin == eth) {
            targetBalance = address(this).balance;
        }

        uint256[4] memory coins;

        uint256 _nCoins = nCoins();
        for (uint256 i; i < _nCoins; i++) {
            if (i == targetCoinIndex) {
                coins[i] = targetBalance;
            } else {
                coins[i] = 0;
            }
        }


        ICurveFi(zapContract).add_liquidity(
                address(curve),
                coins,
                0
        );
    }

    function nCoins() public virtual override view returns (uint256) {
        return 4;
    }

    function setZapContract(address _zapContract) external onlyVaultManagers {
        zapContract = _zapContract;
    }


    function setOptimalTargetCoinIndex(
        uint256 _targetCoinIndex,
        bytes memory _swapPath
    ) external virtual override onlyVaultManagers {
        IERC20(targetCoin).approve(address(zapContract), 0);

        targetCoinIndex = _targetCoinIndex;

        //DEV move to factory
        if (targetCoinIndex == 0) {
            targetCoin = curve.coins(targetCoinIndex);
        } else {
            address pool = curve.coins(1);

            targetCoin = ICurveFi(pool).coins(_targetCoinIndex - 1);
        }

        IERC20(targetCoin).approve(address(zapContract), type(uint256).max);

        swapPath = _swapPath;
    }
}
