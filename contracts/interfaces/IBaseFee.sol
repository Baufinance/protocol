// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

interface IBaseFee {
    function isCurrentBaseFeeAcceptable() external view returns (bool);
}
