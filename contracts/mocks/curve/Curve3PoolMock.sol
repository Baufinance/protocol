// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../IToken.sol";

contract Curve3PoolMock {
    address public constant eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    using SafeERC20 for IERC20;
    address[3] public coins;
    address public token;
    address[3] public underlying;

    uint256 public rate = 1 ether;

    function setRate(uint256 _rate) external {
        rate = _rate;
    }

    constructor(address[3] memory _coins, address _token) {
        coins = _coins;
        underlying = _coins;
        token = _token;
    }

    receive() external payable {}

    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount
    ) external payable {
        uint256 amount;
        for (uint256 i = 0; i < 3; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];

                if (coins[i] != eth) {
                    IERC20(coins[i]).transferFrom(
                        msg.sender,
                        address(this),
                        amount
                    );
                }
                break;
            }
        }

        IToken(token).mint(amount, msg.sender);
    }

    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount,
        bool _use_underlying
    ) external payable returns (uint256) {
        uint256 amount;
        for (uint256 i = 0; i < 3; i++) {
            if (amounts[i] > 0) {
                amount = amounts[i];
                IERC20(underlying[i]).transferFrom(
                    msg.sender,
                    address(this),
                    amount
                );
                break;
            }
        }
        IToken(token).mint(amount, msg.sender);

        return amount;
    }

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i,
        uint256 min_amount
    ) external {
        IERC20(underlying[i]).transfer(msg.sender, _token_amount);
    }

    function underlying_coins(uint256 i) external view returns (address) {
        return underlying[i];
    }

    function underlying_coins(int128 i) external view returns (address) {
        return underlying[uint256(int256(i))];
    }

    function exchange(
        uint256 from,
        uint256 to,
        uint256 _from_amount,
        uint256 _min_to_amount,
        bool use_eth
    ) external payable {
        IERC20(coins[from]).transferFrom(
            msg.sender,
            address(this),
            _from_amount
        );

        if (use_eth) {
            (bool sent, bytes memory data) = msg.sender.call{
                value: (_from_amount * rate) / 10 ** 18
            }("");
            require(sent, "Failed to send Ether");
        } else {
            IERC20(coins[to]).transfer(
                msg.sender,
                (_from_amount * rate) / 10 ** 18
            );
        }
    }
}