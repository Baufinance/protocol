// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../strategies/StrategyConvexMetaPoolRewardsClonable.sol";

contract TestStrategyConvexMetaPoolRewardsClonable is
    StrategyConvexMetaPoolRewardsClonable
{
    function _initializeStratBase(
        uint256 _pid,
        string memory _name
    ) internal override {
        pid = _pid; // this is the pool ID on convex, we use this to determine what the reweardsContract address is

        // set our strategy's name
        stratName = _name;
    }

    function initializeStep2(
        address _healthCheck,
        address _baseFeeOracle,
        address _cvxeth,
        address _uniswapv3,
        address _crv,
        address _convexToken,
        address _weth,
        address _sushiswap,
        address _depositContract,
        bytes memory _crvethPath
    ) external {
        // You can set these parameters on deployment to whatever you want
        maxReportDelay = 21 days; // 21 days in seconds, if we hit this then harvestTrigger = True
        healthCheck = _healthCheck;
        baseFeeOracle = _baseFeeOracle;
        creditThreshold = 1e6 * 1e18;

        crvethPath = _crvethPath;
        cvxeth = ICurveFi(_cvxeth); // use curve's new CVX-ETH crypto pool to sell our CVX

        // we use these to deposit to our curve pool

        uniswapv3 = _uniswapv3;

        crv = IERC20(_crv);
        convexToken = IERC20(_convexToken);
        weth = IERC20(_weth);
        sushiswap = _sushiswap;
        depositContract = _depositContract;

        // want = Curve LP
        want.approve(address(depositContract), type(uint256).max);
        convexToken.approve(address(cvxeth), type(uint256).max);
        crv.approve(address(uniswapv3), type(uint256).max);
        weth.approve(uniswapv3, type(uint256).max);

        // setup our rewards contract
        (address lptoken, , , address _rewardsContract, , ) = IConvexDeposit(
            depositContract
        ).poolInfo(pid);

        // set up our rewardsContract
        rewardsContract = IConvexRewards(_rewardsContract);

        // check that our LP token based on our pid matches our want
        require(address(lptoken) == address(want));
    }
}
