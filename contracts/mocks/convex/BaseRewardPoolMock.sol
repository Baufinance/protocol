// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IRewardsMock.sol";
import "./interfaces/IDepositMock.sol";

contract BaseRewardPoolMock {
    using SafeERC20 for IERC20;


    address[] public extraRewards;
    IERC20 public rewardToken;
    IERC20 public convexToken;

    address public operator;
    uint256 public pid;

    uint256 public periodFinish;

    uint256 public constant duration = 7 days;


    constructor(uint256 _pid, address _rewardToken, address _convexToken, address _operator) {

      rewardToken = IERC20(_rewardToken);
      convexToken = IERC20(_convexToken);
      operator = _operator;
      pid = _pid;
    }


     // strategy's staked balance in the synthetix staking contract
    function balanceOf(address account) external view returns (uint256) {

    }

    // read how much claimable CRV a strategy has
    function earned(address account) public view returns (uint256) {
        return 2* block.number * 10**18 / block.timestamp;
    }

    // withdraw to a convex tokenized deposit, probably never need to use this
    function withdraw(uint256 _amount, bool _claim) external returns (bool) {

    }

    // withdraw directly to curve LP token, this is what we primarily use
    function withdrawAndUnwrap(uint256 amount, bool claim) public returns(bool){

        //also withdraw from linked rewards
        for(uint i=0; i < extraRewards.length; i++){
            //IRewards(extraRewards[i]).withdraw(msg.sender, amount);
        }

        //tell operator to withdraw from here directly to user
        IDepositMock(operator).withdrawTo(pid, amount, msg.sender);

        //get rewards too
        if(claim){
            getReward(msg.sender,true);
        }
        return true;
    }


    function getReward(
        address _account,
        bool _claimExtras
    ) public returns (bool) {
      uint256 reward = earned(_account);

      if (reward > 0) {
           rewardToken.safeTransfer(_account, reward);
           uint256 convexReward = block.number * 10**18 / block.timestamp;

           convexToken.safeTransfer(_account, convexReward);
        }

        //also get rewards from linked rewards
        if(_claimExtras){
            for(uint i=0; i < extraRewards.length; i++){
                IRewardsMock(extraRewards[i]).getReward(_account);
            }
        }

        return true;
    }

    function extraRewardsLength() external view returns (uint256) {
        return extraRewards.length;
    }

    function addExtraReward(address _reward) external returns(bool){
        require(_reward != address(0),"!reward setting");

        extraRewards.push(_reward);
        return true;
    }

    function updateReward() external {
        periodFinish = block.timestamp + duration;
    }
}