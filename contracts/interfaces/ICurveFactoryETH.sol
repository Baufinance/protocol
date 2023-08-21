// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface ICurveFactory {
    enum CurveType {
        NONE,
        METAPOOL_3CRV,
        COINS2,
        COINS3,
        COINS4,
        METAPOOL_SBTC
    }

    struct StrategyParams {
        address strategy;
        uint256 pid;
        bytes swapPath;
        string symbol;
    }

    struct CustomPool {
        address deposit;
        bool isLendingPool;
        bool isSUSD;
    }

    struct Vault {
        address vaultAddress;
        address lptoken;
        CurveType poolType;
        address deposit;
        bool isLendingPool;
    }

    function deployedVaults(address _vault) external view returns (Vault memory);

    function vaultStrategies(address _vault) external view returns (StrategyParams memory);

    function customPools(address _lpToken) external view returns (CustomPool memory);
}