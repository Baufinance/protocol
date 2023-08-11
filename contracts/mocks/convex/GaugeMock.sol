// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

contract GaugeMock {
    address public lp_token;

    constructor(address _lp_token) {
        lp_token = _lp_token;
    }
}
