// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {IUniswapV2Router02} from "../interfaces/IUniV2.sol";

import "../interfaces/IOracle.sol";
import "../interfaces/IUniV3.sol";
import "../interfaces/IConvexRewards.sol";
import "../interfaces/IConvexDeposit.sol";
import "../interfaces/ICurve.sol";
import "./StrategyConvexBase.sol";

abstract contract StrategyCurveBase is StrategyConvexBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */
    // these will likely change across different wants.

    // rewards token info. we can have more than 1 reward token but this is rare, so we don't include this in the template
    IERC20 public rewardsToken;
    bool public hasRewards;
    address[] internal rewardsPath;

    // use Curve to sell our CVX and CRV rewards to WETH

    ICurveFi public cvxeth; // use curve's new CVX-ETH crypto pool to sell our CVX
    bytes public crvethPath; // use curve's new CRV-ETH crypto pool to sell our CRV

    // we use these to deposit to our curve pool

    address public uniswapv3;
    IERC20 public usdt;

    // check for cloning
    bool internal isOriginal = true;

    bool public checkEarmark; // this determines if we should check if we need to earmark rewards before harvesting

    uint256 rewardTreshold;

    /* ========== CLONING ========== */

    event Cloned(address indexed clone);

    function _initializeStratBase(uint256 _pid, string memory _name) internal virtual {
        // make sure that we haven't initialized this before
        require(address(rewardsContract) == address(0)); // already initialized.

        // You can set these parameters on deployment to whatever you want
        maxReportDelay = 21 days; // 21 days in seconds, if we hit this then harvestTrigger = True
        healthCheck = 0xF939E44d0C9FF5da316D1Caca163BBc56b88445b;
        baseFeeOracle = 0x1323Fa099cB2c54EDa59fD4A8BB8DC8c0913B050;
        creditThreshold = 1e6 * 1e18;

        //crvethPath = add crvethpath
        cvxeth = ICurveFi(0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4); // use curve's new CVX-ETH crypto pool to sell our CVX

        // we use these to deposit to our curve pool

        uniswapv3 = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
        usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

        crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
        convexToken = IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
        weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        sushiswap = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
        depositContract = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;

        // want = Curve LP
        want.approve(address(depositContract), type(uint256).max);
        convexToken.approve(address(cvxeth), type(uint256).max);
        crv.approve(address(uniswapv3), type(uint256).max);
        weth.approve(uniswapv3, type(uint256).max);

        // setup our rewards contract
        pid = _pid; // this is the pool ID on convex, we use this to determine what the reweardsContract address is
        (address lptoken, , , address _rewardsContract, , ) = IConvexDeposit(
            depositContract
        ).poolInfo(_pid);

        // set up our rewardsContract
        rewardsContract = IConvexRewards(_rewardsContract);

        // check that our LP token based on our pid matches our want
        require(address(lptoken) == address(want));

        // set our strategy's name
        stratName = _name;

        rewardTreshold = 1e17;
    }

    // migrate our want token to a new strategy if needed, make sure to check claimRewards first
    // also send over any CRV or CVX that is claimed; for migrations we definitely want to claim
    function prepareMigration(address _newStrategy) internal override {
        uint256 _stakedBal = stakedBalance();
        if (_stakedBal > 0) {
            rewardsContract.withdrawAndUnwrap(_stakedBal, claimRewards);
        }
        crv.safeTransfer(_newStrategy, crv.balanceOf(address(this)));
        convexToken.safeTransfer(
            _newStrategy,
            convexToken.balanceOf(address(this))
        );
    }

    // Sells our harvested reward token into the selected output.
    function _sellRewards(uint256 _amount) internal {
        IUniswapV2Router02(sushiswap).swapExactTokensForTokens(
            _amount,
            uint256(0),
            rewardsPath,
            address(this),
            block.timestamp
        );
    }

    /* ========== KEEP3RS ========== */
    // use this to determine when to harvest
    function harvestTrigger(
        uint256 callCostinEth
    ) public view override returns (bool) {
        if (!isActive()) {
            return false;
        }

        if (!isBaseFeeAcceptable()) {
            return false;
        }

        // trigger if we want to manually harvest, but only if our gas price is acceptable
        if (forceHarvestTriggerOnce) {
            return true;
        }

        // harvest our credit if it's above our threshold
        if (vault.creditAvailable() > creditThreshold) {
            return true;
        }

        // otherwise, we don't harvest
        return false;
    }

    // convert our keeper's eth cost into want, we don't need this anymore since we don't use baseStrategy harvestTrigger
    function ethToWant(
        uint256 _ethAmount
    ) public view override returns (uint256) {}

    /// @notice True if someone needs to earmark rewards on Convex before keepers harvest again
    function needsEarmarkReward() public view returns (bool needsEarmark) {
        // check if there is any CRV we need to earmark
        uint256 crvExpiry = rewardsContract.periodFinish();
        if (crvExpiry < block.timestamp) {
            return true;
        } else if (hasRewards) {
            // check if there is any bonus reward we need to earmark
            uint256 rewardsExpiry = IConvexRewards(virtualRewardsPool)
                .periodFinish();
            return rewardsExpiry < block.timestamp;
        }


        if (checkEarmark) {
            // don't harvest if we need to earmark convex rewards
            if (needsEarmarkReward()) {
                return false;
            }
        }
    }

    /// @notice Use to update, add, or remove extra rewards tokens.
    function updateRewards(
        bool _hasRewards,
        uint256 _rewardsIndex
    ) external onlyGovernance {
        if (
            address(rewardsToken) != address(0) &&
            address(rewardsToken) != address(convexToken)
        ) {
            rewardsToken.approve(sushiswap, uint256(0));
        }
        if (_hasRewards == false) {
            hasRewards = false;
            rewardsToken = IERC20(address(0));
            virtualRewardsPool = address(0);
        } else {
            // update with our new token. get this via our virtualRewardsPool
            virtualRewardsPool = rewardsContract.extraRewards(_rewardsIndex);
            address _rewardsToken = IConvexRewards(virtualRewardsPool)
                .rewardToken();
            rewardsToken = IERC20(_rewardsToken);

            // approve, setup our path, and turn on rewards
            rewardsToken.approve(sushiswap, type(uint256).max);
            rewardsPath = [address(rewardsToken), address(weth)];
            hasRewards = true;
        }
    }

    function setCheckEarmark(bool _checkEarmark) external onlyVaultManagers()  {
        // this determines if we should check if we need to earmark rewards before harvesting)
        checkEarmark = _checkEarmark;
    }

    function setRewardTreshold(uint256 _rewardTreshold) external onlyVaultManagers {
        rewardTreshold = _rewardTreshold;
    }
}
