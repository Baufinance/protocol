// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RewardsMock {

  using SafeERC20 for IERC20;

  IERC20 public rewardToken;


  constructor(address _rewardToken) {
    rewardToken = IERC20(_rewardToken);
  }

  function getReward(address _account) external {
    uint256 rewards = block.number * 10**18 / block.timestamp;
    rewardToken.safeTransfer(_account, rewards);
  }
}