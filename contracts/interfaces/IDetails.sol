// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.6.12;

interface IDetails {
    // get details from curve
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
}
