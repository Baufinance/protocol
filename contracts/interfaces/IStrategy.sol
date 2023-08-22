// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStrategy {
     function clone(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _factory
    ) external virtual returns (address newStrategy);


    function setHealthCheck(address) external;

    function targetCoin() external view returns (address);

    function targetCoinIndex() external view returns (uint256);

    function setZapContract(address _zapContract) external;

    function setOptimalTargetCoinIndex(
        uint256 _targetCoinIndex,
        bytes memory _swapPath
    ) external;

    function initializeConvexBase(
        IERC20 _crv,
        IERC20 _convexToken,
        IERC20 _weth,
        address _sushiswap,
        address _depositContract
    ) external;
}
