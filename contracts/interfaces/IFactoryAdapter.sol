// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

interface IFactoryAdapter {
    // get target coin for add liquidity

    function supportedCoin(address _token, address _targetToken) external view returns (bool supported, uint256 index);

    function targetCoin(address _token) external view returns (address coin, uint256 index);

    // add liquidity for targetAmount
    function depositWithTargetCoin(address _token, uint256 _targetAmount,  address _recipient) external;

    function depositWithSupportedCoin(address _token, address _targetToken, uint256 _targetAmount,  address _recipient) external;

    function withdrawWithTargetCoin(address _token, uint256 _shareAmount) external;

    //function withdrawWithSupportedCoin(address _token, uint256 _targetAmount,  address _recipient) external;

}
