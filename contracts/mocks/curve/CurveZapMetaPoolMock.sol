// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../IToken.sol";
import "../../interfaces/ICurve.sol";


contract CurveZapMetaPoolMock  {

    mapping(address => address) public pools;
    constructor() {}

    function add_liquidity(
        // 3Crv Metapools
        address pool,
        uint256[4] calldata amounts,
        uint256 min_mint_amount
    ) external {
      ICurveFi(pools[pool]).add_liquidity(amounts,min_mint_amount);
      IERC20(pools[pool]).transfer(msg.sender, IERC20(pools[pool]).balanceOf(address(this)));
    }

    function addPool(address token, address pool) external {
      pools[token] = pool;
    }
}