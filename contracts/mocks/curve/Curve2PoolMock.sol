// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../IToken.sol";

contract Curve2PoolMock {
    using SafeERC20 for IERC20;
    address[2] public coins;
    address public token;
    address[2] public underlying;

    uint256 public rate = 1 ether;

    function setRate(uint256 _rate) external {
      rate = _rate;
    }

    constructor(address[2] memory _coins, address _token) {
        coins = _coins;
        underlying = _coins;
        token = _token;
    }

    function add_liquidity(
        uint256[2] calldata amounts,
        uint256 min_mint_amount
    ) external payable {
        uint256 amount;
        for (uint256 i = 0; i < 2; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];
                IERC20(coins[i]).transferFrom(msg.sender, address(this), amount);
                break;
            }
        }


        IToken(token).mint(amount, msg.sender);
    }

    function add_liquidity(
        uint256[2] calldata amounts,
        uint256 min_mint_amount,
        bool _use_underlying
    ) external payable {
        uint256 amount;
        for (uint256 i = 0; i < 2; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];
                IERC20(underlying[i]).transferFrom(msg.sender, address(this), amount);
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


    function exchange(uint256 from,
        uint256 to,
        uint256 _from_amount,
        uint256 _min_to_amount,
        bool use_eth)
        external {

        IERC20(coins[from]).transferFrom(msg.sender, address(this), _from_amount);


        if (use_eth) {
            (bool sent, bytes memory data) = msg.sender.call{value: _from_amount * rate / 10**18}("");
            require(sent, "Failed to send Ether");
        } else {
            IERC20(coins[to]).transfer(msg.sender, _from_amount * rate / 10**18);
        }
    }
}
