// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../Token.sol";



//METAPOOL SBTC, METAPOOL 3CRV

contract CurveMetaPoolsMock is Token {
    address[] public  coins;

    constructor(address[] memory _coins) Token(18) {
        coins = _coins;
    }
}