// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface IRewardFactoryMock {
  function createCrvRewards(uint256 _pid) external returns (address);
}