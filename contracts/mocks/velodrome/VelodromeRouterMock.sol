// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMint {
    function mint(uint256 _amount, address _recipient) external;

    function mint(uint256 _amount) external;
}

contract VelodromeRouterMock {

   address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    mapping(address => mapping(address => address)) public pools;

    mapping(address => bool) public isStablePool;

    struct Routes {
        address from;
        address to;
        bool stable;
        address factory;
    }

    function addLiquidity(
        address token0,
        address token1,
        bool isStablePool,
        uint256 balanceToken0,
        uint256 balanceToken1,
        uint256,
        uint256,
        address recipient,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        address pool = pools[token0][token1];
        uint256 ratio;

        if (isStablePool) {
            ratio = 9 * 10 ** 17;
        } else {
            ratio = 7 * 10 ** 17;
        }

        balanceToken1 = ((balanceToken0 * ratio) / 10** 18);

        IERC20(token0).transferFrom(msg.sender, address(this), balanceToken0);
        IERC20(token1).transferFrom(msg.sender, address(this), balanceToken1);

        IMint(pool).mint(balanceToken1, recipient);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Routes[] memory routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
      Routes memory route0 = routes[0];
      Routes memory route1 = routes[routes.length - 1];

      address token0 = route0.from;
      address token1 = route1.to;

      IERC20(token0).transferFrom(msg.sender, address(this), amountIn);

      uint256 ratio = 7 * 10 ** 17;

      IERC20(token1).transfer(to, amountIn * 10**18 / ratio);
    }

    function quoteStableLiquidityRatio(
        address token0,
        address token1,
        address factory
    ) external view returns (uint256 ratio) {
        address pool = pools[token0][token1];
        bool  stable = isStablePool[pool];
        if (stable) {
            ratio = 9 * 10 ** 17;
        } else {
            ratio = 7 * 10 ** 17;
        }
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool isStablePool,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB) {
        address pool = pools[tokenA][tokenB];
        uint256 ratio;

        if (isStablePool) {
            ratio = 9 * 10 ** 17;
        } else {
            ratio = 7 * 10 ** 17;
        }

        amountA = liquidity;

        amountB = (amountA * 10 ** 18) / ratio;

        IERC20(tokenA).transfer(to, amountA);
        IERC20(tokenA).transfer(to, amountB);

        IERC20(pool).transferFrom(msg.sender, DEAD, liquidity);
    }

    function addPool(
        address token0,
        address token1,
        address pool,
        bool stable
    ) external {
        pools[token0][token1] = pool;

        isStablePool[pool] = stable;
    }
}
