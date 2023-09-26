// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "../../strategies/StrategyConvex4CoinsRewardsClonable.sol";

contract GoerliStrategyConvex4CoinsRewardsClonable is
    StrategyConvex4CoinsRewardsClonable
{
    function _initializeStratBase(
        uint256 _pid,
        string memory _name
    ) internal override {
        pid = _pid; // this is the pool ID on convex, we use this to determine what the reweardsContract address is

        // set our strategy's name
        stratName = _name;
    }

    function _initializeInternal() internal override {
        // You can set these parameters on deployment to whatever you want
        maxReportDelay = 21 days; // 21 days in seconds, if we hit this then harvestTrigger = True
        healthCheck = 0xF939E44d0C9FF5da316D1Caca163BBc56b88445b;
        baseFeeOracle = 0x1323Fa099cB2c54EDa59fD4A8BB8DC8c0913B050;
        creditThreshold = 1e6 * 1e18;

        cvxeth = ICurveFi(0xB77A62019418F2D1411fC96adbfbc82792b580a3); // use curve's new CVX-ETH crypto pool to sell our CVX

        // we use these to deposit to our curve pool

        uniswapv3 = 0x4eEeb3f6AbD9365E550F8dd82ac51C20adB3De4b;

        crv = IERC20(0x6912C5FA16c9e9278a20234C00F3DEFbF21D77f6);
        convexToken = IERC20(0x402745D08AcF0cC79F457dA2D41276FA109a45A0);
        weth = IERC20(0xb8D3DbecA88a5Aa37979999de6F921F521E53E9E);
        sushiswap = 0x6FF1B80DB7b5c1b535db09A1b8a87248E64C7727;
        depositContract = 0x3088982b8535cDC266048ae13a375B4C8B2701d6;

        crvethPath = bytes.concat(
            bytes20(address(crv)),
            bytes3(uint24(60)),
            bytes20(address(weth))
        );

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
