// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface IVault {
    function setGovernance(address) external;

    function governance() external view returns (address);

    function setManagement(address) external;

    function setDepositFee(uint256) external;

    function setDepositLimit(uint256) external;

    function addStrategy(address, uint256, uint256, uint256) external;

    function deposit(uint256 _amount, address _recipient) external;

    function withdrawalQueue(uint256 index) external view returns (address);

    function withdraw(
        uint256 maxShares,
        address _recipient,
        uint256 _maxLoss
    ) external;
}
