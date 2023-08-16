// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract UniswapV2Mock {
    uint256 rate = 1 ether;

    function setRate(uint256 _rate) external {
      rate = _rate;
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
         address tokenB = path[1];

         IERC20(tokenB).transfer(to, amountIn*rate / 10**18);
    }
}