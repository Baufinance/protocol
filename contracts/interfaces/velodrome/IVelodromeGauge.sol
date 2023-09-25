// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface IVelodromeGauge {
    function deposit(uint256 amount) external;

    function balanceOf(address) external view returns (uint256);

    function withdraw(uint256 amount) external;

    function getReward(address account) external;

    function earned(address account) external view returns (uint256);

    function stakingToken() external view returns (address);
}
