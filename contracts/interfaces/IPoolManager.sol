// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IPoolManager {
    function addPool(address _gauge) external returns (bool);
}
