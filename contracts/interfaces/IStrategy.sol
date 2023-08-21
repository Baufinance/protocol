// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface IStrategy {
    function clone(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        uint256 _pid,
        address _curvePool,
        string memory _name
    ) external returns (address newStrategy);

    function clone(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _factory
    ) external returns (address newStrategy);

    function clone(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        uint256 _pid,
        address _curvePool,
        bytes memory _swapPath,
        string memory _name,
        uint256 _nCoins,
        bool _isLendingPool,
        bool _isDepositContract
    ) external returns (address newStrategy);

    function setHealthCheck(address) external;

    function targetCoin() external view returns (address);

    function targetCoinIndex() external view returns (uint256);

    function setZapContract(address _zapContract) external;

    function setOptimalTargetCoinIndex(
        uint256 _targetCoinIndex, bytes memory _swapPath) external;
}
