// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

interface IFactoryAdapter {
    // get target coin for add liquidity

    function isVaultExists(address _token) external view returns (bool);

    function supportedCoin(
        address _token,
        address _targetToken
    ) external view returns (bool supported, uint256 index, address vault);

    function targetCoin(
        address _token
    ) external view returns (address coin, uint256 index, address vault);

    // add liquidity for targetAmount
    function depositWithTargetCoin(
        address _token,
        uint256 _targetAmount,
        address _recipient
    ) external;

    function depositWithSupportedCoin(
        address _token,
        address _targetToken,
        uint256 _targetAmount,
        address _recipient
    ) external;

    function withdrawWithTargetCoin(
        address _token,
        uint256 _shareAmount,
        address _recipient
    ) external;

    function withdrawWithSupportedCoin(
        address _token,
        address _targetCoin,
        uint256 _shareAmount,
        address _recipient
    ) external;
}
