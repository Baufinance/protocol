// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface IDepositMock {
  function withdrawTo(uint256 _pid, uint256 _amount, address _to) external returns(bool);
}