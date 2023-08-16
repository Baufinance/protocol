// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../../interfaces/IUniV3.sol";
import "./v3/BytesLib.sol";
import "./v3/Path.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapV3Mock is IUniV3 {
    using Path for bytes;

    uint256 rate = 1 ether;

    function exactInput(
        ExactInputParams calldata params
    ) external payable override returns (uint256 amountOut) {
        (address tokenA, address tokenB, uint256 fee) = params
            .path
            .decodeFirstPool();
        IERC20(tokenA).transferFrom(msg.sender, address(this), params.amountIn);

        IERC20(tokenB).transfer(
            params.recipient,
            (params.amountIn * rate) / 10 ** 18
        );
    }

    function setRate(uint256 _rate) external {
        rate = _rate;
    }

    function setPath(
        address token1,
        address token2
    ) external view returns (bytes memory path) {
        path = bytes.concat(
            bytes20(address(token1)),
            bytes3(uint24(60)),
            bytes20(address(token2))
        );
    }
}
