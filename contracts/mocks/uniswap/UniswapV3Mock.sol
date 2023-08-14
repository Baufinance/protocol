// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../../interfaces/IUniV3.sol";
import "./v3/BytesLib.sol";
import "./v3/Path.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapV3Mock is IUniV3 {
      using Path for bytes;

      uint256 rate;

      function exactInput(
        ExactInputParams calldata params
    ) override external payable returns (uint256 amountOut) {
      (address tokenA, address tokenB, uint256 fee) = params.path.decodeFirstPool();

      IERC20(tokenB).transfer(params.recipient, params.amountIn*rate / 10**18);
    }

    function setRate(uint256 _rate) external {
      rate = _rate;
    }
}
