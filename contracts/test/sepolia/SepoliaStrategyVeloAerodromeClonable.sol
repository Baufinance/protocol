// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../../strategies/StrategyVeloAerodromeClonable.sol";

contract SepoliaStrategyVeloAerodromeClonable is
    StrategyVeloAerodromeClonable
{
  function _initializeInternal() override internal {
      healthCheck = 0xc9f6Ce3D6C995E2a2040DD0cF49677C03E8bc512;
      baseFeeOracle = 0xE3ba8503294e110b0A7DAAf6a1DdddF0A2CBF2a7;
  }
}