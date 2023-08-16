// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../../interfaces/IAggregationRouterV5.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AggregationRouterV5Mock is IAggregationRouterV5 {


    function swap(
        IAggregationExecutor caller,
        SwapDescription calldata desc,
        bytes calldata permit,
        bytes calldata data
    ) external override payable returns (uint256 returnAmount, uint256 spentAmount) {
      IERC20(desc.srcToken).transferFrom(desc.srcReceiver, address(this), desc.amount);
      IERC20(desc.dstToken).transfer(desc.dstReceiver, desc.minReturnAmount);
    }

    function encodeData(SwapDescription calldata desc) view public returns (bytes memory data) {
      data = abi.encode(msg.sender, desc, 0x0, 0x0);
    }
}