// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../IToken.sol";

contract Curve3PoolMock {
    using SafeERC20 for IERC20;
    address[3] public coins;
    address public token;
    address[4] public underlying;

    constructor(address[3] memory _coins, address _token) {
        coins = _coins;
        underlying = _coins;
        token = _token;
    }

    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount
    ) external payable {
        uint256 amount;
        for (uint256 i = 0; i < 3; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];
                break;
            }
        }
        IToken(msg.sender).mint(amount);
    }

    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount,
        bool _use_underlying
    ) external payable {
        uint256 amount;
        for (uint256 i = 0; i < 3; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];
                break;
            }
        }
        IToken(msg.sender).mint(amount);
    }

    function underlying_coins(uint256 i) external view returns (address) {
        return underlying[i];
    }

    function underlying_coins(int128 i) external view returns (address) {
        return underlying[uint256(int256(i))];
    }

    function exchange(uint256 from,
        uint256 to,
        uint256 _from_amount,
        uint256 _min_to_amount,
        bool use_eth)
        external {

        IERC20(coins[from]).transferFrom(msg.sender, address(this), _from_amount);


        if (use_eth) {
            (bool sent, bytes memory data) = msg.sender.call{value: _from_amount}("");
            require(sent, "Failed to send Ether");
        } else {
            IERC20(coins[to]).transfer(address(this), _from_amount);
        }
    }
}