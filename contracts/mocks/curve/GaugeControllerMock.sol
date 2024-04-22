// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract GaugeControllerMock {
  event NewGauge (address addr, int128 gauge_type, uint256 weight);

  function addGauge(address _gauge) external {
    emit NewGauge(_gauge, 0, 0);
  }
}
