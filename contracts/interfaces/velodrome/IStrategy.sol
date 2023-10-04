// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "./IVelodromeRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStrategy {
    function clone(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _gauge,
        IVelodromeRouter.Routes[] memory _velodromeSwapRouteForToken0,
        IVelodromeRouter.Routes[] memory _velodromeSwapRouteForToken1,
        IVelodromeRouter _router,
        IERC20 _velo
    ) external returns (address newStrategy);
}
