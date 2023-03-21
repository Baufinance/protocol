// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

import "../abstract/StrategyConvexCurveRewardsBase.sol";

contract StrategyConvexCoins4RewardsClonable is StrategyConvexCurveRewardsBase {

  constructor(
        address _vault,
        uint256 _pid,
        address _curvePool,
        bytes memory _swapPath,
        string memory _name,
        bool _isUseUnderlying
    ) StrategyConvexCurveRewardsBase(_vault, _pid, _curvePool, _swapPath, _name, 3, _isUseUnderlying) {

  }


  function _depositToCurve() override internal {
      address targetCoin = curve.coins(targetCoinIndex);

      uint256 targetBalance = IERC20(targetCoin).balanceOf(address(this));

      if (targetCoin == eth) {
        targetBalance = address(this).balance;
      }

      uint256[4] memory coins;

      for (uint256 i; i < nCoins; i++) {
        if (i ==  targetCoinIndex) {
          coins[i] = targetBalance;
        } else {
          coins[i] = 0;
        }
      }

      if (isUseUnderlying) {
          curve.add_liquidity(coins, 0, true);
      } else {
        if (isETHPool) {
          curve.add_liquidity{value: targetBalance}(coins, 0);
        } else {
            curve.add_liquidity(coins, 0);
        }
      }
  }
}