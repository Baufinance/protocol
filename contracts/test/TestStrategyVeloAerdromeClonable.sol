// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../strategies/StrategyVeloAerodromeClonable.sol";



contract TestStrategyVeloAerdromeClonable is
    StrategyVeloAerodromeClonable
{
    function _initializeInternal() internal override {}

    function setInternal(
        address _healthCheck,
        address _baseFeeOracle
    ) external {
        healthCheck = _healthCheck;
        baseFeeOracle = _baseFeeOracle;
    }
}