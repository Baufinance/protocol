// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

import "./interfaces/IRewardFactoryMock.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract BoosterMock {

    using SafeERC20 for IERC20;

    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }

    //index(pid) -> pool
    PoolInfo[] public poolInfo;

    mapping(address => bool) public gaugeMap;

    address public crvToken;
    address public rewardFactory;

    constructor(address _crvToken, address _rewardFactory) {
        crvToken = _crvToken;
        rewardFactory = _rewardFactory;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    //create a new pool
    function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool){
        uint256 pid = poolInfo.length;
        address newRewardPool = IRewardFactoryMock(rewardFactory).createCrvRewards(pid);

         //add the new pool
        poolInfo.push(
            PoolInfo({
                lptoken: _lptoken,
                token: address(0x0),
                gauge: _gauge,
                crvRewards: newRewardPool,
                stash: address(0x0),
                shutdown: false
            })
        );
        gaugeMap[_gauge] = true;

        return true;
    }


    function deposit(uint256 _pid, uint256 _amount, bool _stake) public returns(bool) {
        PoolInfo storage pool = poolInfo[_pid];
        //send to proxy to stake
        address lptoken = pool.lptoken;
        IERC20(lptoken).safeTransferFrom(msg.sender, address(this), _amount);

    }


    function withdrawTo(uint256 _pid, uint256 _amount, address _to) external returns(bool){
        address rewardContract = poolInfo[_pid].crvRewards;
        require(msg.sender == rewardContract,"!auth");

        _withdraw(_pid,_amount,msg.sender,_to);
        return true;
    }

    function _withdraw(uint256 _pid, uint256 _amount, address _from, address _to) internal {
        PoolInfo storage pool = poolInfo[_pid];
        address lptoken = pool.lptoken;
        address gauge = pool.gauge;

        //remove lp balance
        address token = pool.token;

        //return lp tokens
        IERC20(lptoken).safeTransfer(_to, _amount);

    }

}