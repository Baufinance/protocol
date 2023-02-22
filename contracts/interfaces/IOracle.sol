// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IOracle {
    function latestAnswer() external view returns (uint256);
}
