// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "./IVelodromeRouter.sol";
interface IStrategy {
    function clone(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _gauge,
        IVelodromeRouter.Routes[] memory _velodromeSwapRouteForToken0,
        IVelodromeRouter.Routes[] memory _velodromeSwapRouteForToken1
    ) external returns (address newStrategy);
}