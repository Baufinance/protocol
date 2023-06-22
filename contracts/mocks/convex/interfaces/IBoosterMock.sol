// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

interface IBoosterMock {
  function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool);
}