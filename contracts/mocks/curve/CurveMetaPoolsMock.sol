// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../Token.sol";



//METAPOOL SBTC, METAPOOL 3CRV

contract CurveMetaPoolsMock is Token {
    address[4] public  coins;

    constructor(address[4] memory _coins) Token(18) {
        coins = _coins;
    }

    function add_liquidity(
        uint256[4] calldata amounts,
        uint256 min_mint_amount
    ) external payable {
        uint256 amount;
        for (uint256 i=0; i < 4; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];
                break;
            }
        }

        mint(amount);
    }
}