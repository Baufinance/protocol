// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IBaseFee {
    function isCurrentBaseFeeAcceptable() external view returns (bool);
}