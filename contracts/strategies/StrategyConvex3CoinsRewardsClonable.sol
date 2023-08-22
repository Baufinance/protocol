// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../abstract/StrategyConvexCurveRewardsBase.sol";

contract StrategyConvex3CoinsRewardsClonable is StrategyConvexCurveRewardsBase {
    constructor() {}

    function _depositToCurve() internal override {
        uint256 targetBalance = IERC20(targetCoin).balanceOf(address(this));

        if (targetCoin == eth) {
            targetBalance = address(this).balance;
        }

        uint256[3] memory coins;

        uint256 _nCoins = nCoins();
        for (uint256 i; i < _nCoins; i++) {
            if (i == targetCoinIndex) {
                coins[i] = targetBalance;
            } else {
                coins[i] = 0;
            }
        }

        if (isLendingPool) {
            curve.add_liquidity(coins, 0, true);
        } else {
            if (isETHPool) {
                curve.add_liquidity{value: targetBalance}(coins, 0);
            } else {
                curve.add_liquidity(coins, 0);
            }
        }
    }

    function nCoins() public view virtual override returns (uint256) {
        return 3;
    }
}
