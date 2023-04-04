// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

interface IFactoryAdapter {
    // get target coin for add liquidity
    function targetCoin(address _token) external view returns (uint256);

    // add liquidity for targetAmount
    function deposit(address _token, uint256 _targetAmount) external;

    // add liquidity for targetAmount
    function deposit(address _token) external;

    function withdraw(address _token, uint256 _shareAmount) external;

    function withdraw(address _token) external;
}
