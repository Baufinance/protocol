// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "./BaseRewardPoolMock.sol";

contract RewardFactoryMock {
    address public crvToken;
    address public convexToken;

    address public operator;

    constructor(address _crvToken, address _convexToken, address _operator) {
        crvToken = _crvToken;
        convexToken = _convexToken;
        operator = _operator;
    }

    //Create a Managed Reward Pool to handle distribution of all crv mined in a pool
    function createCrvRewards(uint256 _pid) external returns (address) {
        //operator = booster(deposit) contract so that new crv can be added and distributed
        //reward manager = this factory so that extra incentive tokens(ex. snx) can be linked to the main managed reward pool
        BaseRewardPoolMock rewardPool = new BaseRewardPoolMock(
            _pid,
            crvToken,
            convexToken,
            operator
        );
        return address(rewardPool);
    }
}
