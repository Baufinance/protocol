// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../IToken.sol";



contract CurvePlain2PoolMock  {
    using SafeERC20 for IERC20;
    address[2] public  coins;
    address public token;

    constructor(address[2] memory _coins, address _token) {
        coins = _coins;
        token = _token;
    }

    function add_liquidity(
        uint256[2] calldata amounts,
        uint256 min_mint_amount
    ) external payable {

        uint256 amount;
        for (uint256 i=0; i < 2; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];
                break;
            }
        }
        IToken(msg.sender).mint(amount);
    }
}