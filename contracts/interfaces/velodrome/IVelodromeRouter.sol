// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface IVelodromeRouter {
    struct Routes {
        address from;
        address to;
        bool stable;
        address factory;
    }

    function addLiquidity(
        address,
        address,
        bool,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Routes[] memory routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function quoteStableLiquidityRatio(
        address token0,
        address token1,
        address factory
    ) external view returns (uint256 ratio);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}
