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

        address coin = ICurveFi(pool).coins(0);

        IERC20(coin).transferFrom(msg.sender, address(this), amounts[0]);
        for (uint256 i =0; i < 4; i++) {

            if (amounts[i] > 0) {
                meta_amounts[0] = amounts[i];
                break;
            }
        }
        ICurveFi(pool).add_liquidity(meta_amounts, min_mint_amount);
        IERC20(pool).transfer(
            msg.sender,
            IERC20(pool).balanceOf(address(this))
        );
    }

    function addPool(address token, address pool) external {
        pools[token] = pool;
    }
}
