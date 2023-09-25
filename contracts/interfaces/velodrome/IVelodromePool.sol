// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface IVelodromePool {
    function stable() external view returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function factory() external view returns (address);

    function getAmountOut(
        uint256 amountIn,
        address tokenIn
    ) external view returns (uint256 amount);
}