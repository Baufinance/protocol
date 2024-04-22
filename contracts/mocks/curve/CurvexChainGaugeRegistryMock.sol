// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract CurvexChainGaugeRegistryMock {


  event DeployedGauge(address indexed _implementation, address indexed _lp_token, address indexed _deployer, bytes32 _salt, address _gauge);

  function add(address _gauge, address _lpToken) external {
    emit DeployedGauge(address(this), _lpToken, address(this), keccak256(abi.encode(block.timestamp)), _gauge);
  }
}