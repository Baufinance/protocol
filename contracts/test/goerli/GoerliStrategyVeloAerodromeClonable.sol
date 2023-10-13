// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../../strategies/StrategyVeloAerodromeClonable.sol";

contract GoerliStrategyVeloAerodromeClonable is
    StrategyVeloAerodromeClonable
{
  function _initializeInternal() override internal {
      healthCheck = 0xF939E44d0C9FF5da316D1Caca163BBc56b88445b;
      baseFeeOracle = 0x1323Fa099cB2c54EDa59fD4A8BB8DC8c0913B050;
  }
}