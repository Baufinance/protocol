// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VelodromePoolMock is ERC20 {
    bool public stable;
    address public token0;
    address public token1;

    constructor(
        bool _stable,
        address _token0,
        address _token1
    ) ERC20("veloLPTest", "veloLPTest") {
        stable = _stable;
        token0 = _token0;
        token1 = _token1;
    }

    function factory() external view returns (address) {
        return address(this);
    }

    function getAmountOut(
        uint256 amountIn,
        address tokenIn
    ) external view returns (uint256 amount) {
        if (tokenIn == token0) {
            amount = (amountIn * 7) / 10;
        } else {
            amount = (amountIn * 10) / 7;
        }
    }

    function mint(uint256 _amount, address _recipient) public {
        _mint(_recipient, _amount);
    }

    function mint(uint256 _amount) public {
        _mint(msg.sender, _amount);
    }
}
