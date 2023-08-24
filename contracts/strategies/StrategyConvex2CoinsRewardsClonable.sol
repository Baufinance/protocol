// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../abstract/StrategyConvexCurveRewardsBase.sol";

contract StrategyConvex2CoinsRewardsClonable is StrategyConvexCurveRewardsBase {
    constructor() {}

    event Log(uint256 balance);

    function _depositToCurve() internal override {
        uint256 targetBalance = IERC20(targetCoin).balanceOf(address(this));

        if (targetCoin == eth) {
            targetBalance = address(this).balance;
        }

        uint256[2] memory coins;

        uint256 _nCoins = nCoins();
        for (uint256 i; i < _nCoins; i++) {
            if (i == targetCoinIndex) {
                coins[i] = targetBalance;
            } else {
                coins[i] = 0;
            }
        }

        coins[targetCoinIndex] = targetBalance;

        if (isLendingPool && !isSUSD) {
            curve.add_liquidity(coins, 0, true);
        } else {
            curve.add_liquidity(coins, 0);
        }
    }

    function nCoins() public view virtual override returns (uint256) {
        return 2;
    }
}
