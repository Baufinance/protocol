// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../LPToken.sol";

//METAPOOL SBTC, METAPOOL 3CRV

contract CurveMetaPoolMock is LPToken {
    address[2] public coins;

    constructor(address[2] memory _coins) LPToken(18) {
        coins = _coins;
    }

    function add_liquidity(
        uint256[2] calldata amounts,
        uint256 min_mint_amount
    ) external payable {
        uint256 amount;
        for (uint256 i = 0; i < 2; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];
                break;
            }
        }

        mint(amount, msg.sender);
    }
}
