// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface IFactoryAdapter {
    // get target coin for add liquidity

    function isVaultExists(address _token) external view returns (bool);

    function targetCoin(
        address _token
    ) external view returns (address coin, uint256 index);

    function vaultAddress(address lptoken) external view returns (address);

    // add liquidity for targetAmount
    function deposit(
        address _token,
        uint256 _targetAmount,
        address _recipient
    ) external;

    function withdraw(
        address _token,
        uint256 _shareAmount,
        address _recipient
    ) external;
}
