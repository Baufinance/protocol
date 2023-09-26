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

    struct Vault {
        address vaultAddress;
        address lptoken;
        CurveType poolType;
        address deposit;
        bytes32 latestRelease;
        bool isLendingPool;
        bool isSUSD;
    }

    function deployedVaults(
        address _vault
    ) external view returns (Vault memory);

    function getVaultPoolPid(address _vault) external view returns (uint256);

    function getVaultSymbol(
        address _vault
    ) external view returns (string memory);
}
