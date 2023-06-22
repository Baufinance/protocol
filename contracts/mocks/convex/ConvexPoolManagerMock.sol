// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

import "../../interfaces/ICurveGauge.sol";
import "./interfaces/IBoosterMock.sol";

contract ConvexPoolManagerMock {

  address booster;

  constructor(address _booster) {
    booster = _booster;
  }
  function addPool(address _gauge) external {
    address lptoken = ICurveGauge(_gauge).lp_token();

    IBoosterMock(booster).addPool(lptoken, _gauge, 0);
  }
}