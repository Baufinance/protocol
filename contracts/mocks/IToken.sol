// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IToken {
    function mint(uint256 _amount, address _recipient) external;
}
