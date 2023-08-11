// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../IToken.sol";
import "../../interfaces/ICurve.sol";

contract CurveZapMetaPoolMock {
    mapping(address => address) public pools;

    constructor() {}

    function add_liquidity(
        // 3Crv Metapools
        address pool,
        uint256[4] calldata amounts,
        uint256 min_mint_amount
    ) external {

        uint256[2] memory meta_amounts;

        for (uint256 i =0; i < 4; i++) {

            if (amounts[i] > 0) {
                meta_amounts[0] = amounts[i];
                break;
            }
        }
        ICurveFi(pools[pool]).add_liquidity(meta_amounts, min_mint_amount);
        IERC20(pools[pool]).transfer(
            msg.sender,
            IERC20(pools[pool]).balanceOf(address(this))
        );
    }

    function addPool(address token, address pool) external {
        pools[token] = pool;
    }
}
