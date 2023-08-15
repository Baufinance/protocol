// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../IToken.sol";

contract Curve4PoolMock {

    address public constant eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    using SafeERC20 for IERC20;
    address[4] public coins;
    address[4] public underlying;
    address public token;


    constructor(address[4] memory _coins, address _token) {
        coins = _coins;
        underlying = _coins;
        token = _token;
    }

    function add_liquidity(
        uint256[4] calldata amounts,
        uint256 min_mint_amount
    ) external payable {
        uint256 amount;

        for (uint256 i = 0; i < 4; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];

                if (coins[i] != eth) {
                    IERC20(coins[i]).transferFrom(msg.sender, address(this), amount);
                }

                break;
            }
        }

        IToken(token).mint(amount, msg.sender);
    }

    function add_liquidity(
        uint256[4] calldata amounts,
        uint256 min_mint_amount,
        bool _use_underlying
    ) external payable {
        uint256 amount;
        for (uint256 i = 0; i < 4; i++) {
            if (amounts[i] > 0) {

                amount = amounts[i];
                break;
            }
        }
        IToken(token).mint(amount, msg.sender);
    }

    function underlying_coins(uint256 i) external view returns (address) {
        return underlying[i];
    }

    function underlying_coins(int128 i) external view returns (address) {
        return underlying[uint256(int256(i))];
    }
}
