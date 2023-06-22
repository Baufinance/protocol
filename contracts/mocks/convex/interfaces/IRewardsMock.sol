// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

interface IRewardsMock {

  function getReward(address _account) external;

  function rewardToken() external view returns(address);
}