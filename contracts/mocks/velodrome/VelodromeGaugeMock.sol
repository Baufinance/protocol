// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VelodromeGaugeMock {
    address public velo;
    address public lptoken;

    mapping(address => uint256) public balances;

    constructor(address _velo, address _lptoken) {
        velo = _velo;
        lptoken = _lptoken;
    }

    function deposit(uint256 amount) external {
        IERC20(lptoken).transferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
    }

    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }

    function withdraw(uint256 amount) external {
        IERC20(lptoken).transfer(msg.sender, amount);

        balances[msg.sender] -= amount;
    }

    function getReward(address account) external {
        uint256 earned = earned(account);
        IERC20(velo).transfer(msg.sender, earned);
    }

    function earned(address account) public view returns (uint256 rewards) {
        uint256 balance = balanceOf(account);
        uint256 rewards = (balance * block.number * 10 ** 18) / block.timestamp;
    }

    function stakingToken() external view returns (address) {
        return lptoken;
    }
}
