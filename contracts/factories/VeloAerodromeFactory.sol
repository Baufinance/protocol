// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IDetails.sol";
import "../interfaces/IVault.sol";
import "../interfaces/IFactoryAdapter.sol";
import "../interfaces/IRegistry.sol";
import "../interfaces/Velodrome/IVelodromeRouter.sol";
import "../interfaces/Velodrome/IVelodromePool.sol";
import "../interfaces/Velodrome/IVelodromeGauge.sol";
import "../interfaces/Velodrome/IStrategy.sol";

contract VeloAerodromeFactory is Initializable, IFactoryAdapter {
    using SafeERC20 for IERC20;

    uint256 internal constant MAX_BPS = 10_000; //100%

    struct Vault {
        address vaultAddress;
        address lptoken;
        bytes32 latestRelease;
    }

    mapping(address => IVelodromeRouter.Routes[]) public veloRegistryForToken0;
    mapping(address => IVelodromeRouter.Routes[]) public veloRegistryForToken1;

    /// @notice This is a list of all vaults deployed by this factory.
    mapping(address => Vault) public deployedVaults; //for ZAP V1

    address public velodromeStratImplementation;

    IRegistry public registry;

    address owner;

    address pendingOwner;

    address keeper;

    address governance;

    address guardian;

    address treasury;

    address management;

    address velo;

    uint256 depositFee;

    uint256 zapFee;

    uint256 depositLimit;

    IVelodromeRouter public router;

    event NewVault(
        address indexed lpToken,
        address gauge,
        address indexed vault,
        address strategy
    );

    error VaultDoesntExist();
    error BalanceIsZero();

    function initialize(
        address _registry,
        address _velodromeStratImplementation,
        address _keeper,
        address _owner,
        address _velo,
        address _router
    ) public initializer {
        registry = IRegistry(_registry);
        velodromeStratImplementation = _velodromeStratImplementation;

        owner = _owner;

        depositLimit = 10_000_000_000_000 * 1e18; // some large number

        keeper = _keeper;

        treasury = _owner;

        guardian = _owner;

        management = _owner;

        governance = _owner;

        velo = _velo;

        depositFee = 50;

        zapFee = 5;

        router = IVelodromeRouter(_router);
    }

    function isVaultExists(address _lptoken) external view returns (bool) {
        Vault storage v = deployedVaults[_lptoken];

        if (v.vaultAddress != address(0x0)) {
            return true;
        }
    }

    function targetCoin(
        address _lptoken
    ) public view returns (address coin, uint256 index) {
        IVelodromePool pool = IVelodromePool(_lptoken);

        return (pool.token0(), 0);
    }

    function vaultAddress(address _lptoken) external view returns (address vault) {
        Vault storage v = deployedVaults[_lptoken];
        vault = v.vaultAddress;
    }

    function createNewVaultsAndStrategies(
        address _gauge
    ) external returns (address vault, address strategy) {
        return _createNewVaultsAndStrategies(_gauge);
    }

    function _createNewVaultsAndStrategies(
        address _gauge
    ) internal returns (address vault, address strategy) {
        address lptoken = IVelodromeGauge(_gauge).stakingToken();

        Vault memory v = deployedVaults[lptoken];

        bytes32 latestRelease = keccak256(abi.encode(registry.latestRelease()));

        require(
            v.latestRelease != latestRelease,
            "vault with this verion already exists"
        );

        vault = _createVault(lptoken);

        _recordVault(vault, lptoken, latestRelease);

        strategy = _createStrategy(vault, _gauge, lptoken);


        _addStrategyToVault(vault, strategy);
        emit NewVault(lptoken, _gauge, vault, strategy);
    }

    function _createVault(address _lptoken) internal returns (address vault) {
        //now we create the vault, endorses it from governance after
        vault = registry.newFactoryVault(
            _lptoken,
            address(this),
            guardian,
            treasury,
            string.concat(
                "Velodrome ",
                IDetails(address(_lptoken)).symbol(),
                " bauVault"
            ),
            string.concat("bauVelo", IDetails(address(_lptoken)).symbol()),
            0
        );

        IVault v = IVault(vault);

        v.setManagement(management);
        v.setGovernance(governance);
        v.setDepositLimit(depositLimit);
        v.setDepositFee(depositFee);
    }

    function _createStrategy(
        address _vault,
        address _gauge,
        address _lptoken
    ) internal returns (address strategy) {
        strategy = IStrategy(velodromeStratImplementation).clone(
            _vault,
            management,
            treasury,
            keeper,
            _gauge,
            veloRegistryForToken0[_lptoken],
            veloRegistryForToken1[_lptoken],
            IVelodromeRouter(router),
            IERC20(velo)
        );
    }

    function _recordVault(
        address _vault,
        address _lptoken,
        bytes32 _latestRelease
    ) internal {
        deployedVaults[_lptoken] = Vault(_vault, _lptoken, _latestRelease);
    }

    function _addStrategyToVault(address _vault, address _strategy) internal {
        IVault v = IVault(_vault);

        v.addStrategy(_strategy, 10_000, 0, type(uint256).max);
    }

    // add liquidity for targetAmount
    function deposit(
        address _lptoken,
        uint256 _targetAmount,
        address _recipient
    ) external {
        Vault memory v = deployedVaults[_lptoken];

        address vault = v.vaultAddress;

        uint256 tokenBalanceBefore = IERC20(_lptoken).balanceOf(address(this));

        (address targetToken, uint256 index) = targetCoin(_lptoken);

        IERC20(targetToken).safeTransferFrom(
            msg.sender,
            address(this),
            _targetAmount
        );

        _depositToProtocol(_lptoken, targetToken, _targetAmount, _recipient);


        uint256 tokenBalanceAfter = IERC20(_lptoken).balanceOf(address(this));

        uint256 tokenBalance = tokenBalanceAfter - tokenBalanceBefore;

        if (tokenBalance == 0) {
            revert BalanceIsZero();
        }

        IERC20(_lptoken).approve(vault, tokenBalance);

        uint256 vaultBalanceBefore = IERC20(vault).balanceOf(address(this));
        IVault(vault).deposit(tokenBalance, address(this));
        uint256 vaultBalanceAfter = IERC20(vault).balanceOf(address(this));

        uint256 vaultBalance = vaultBalanceAfter - vaultBalanceBefore;

        vaultBalance = _takeZapFee(vault, vaultBalance);

        IERC20(vault).safeTransfer(_recipient, vaultBalance);
    }

    function withdraw(
        address _lptoken,
        uint256 _shareAmount,
        address _recipient
    ) external {
        Vault memory v = deployedVaults[_lptoken];

        (address targetToken, uint256 index) = targetCoin(_lptoken);

        IERC20(v.vaultAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _shareAmount
        );

        uint256 lptokenAmount = _withdrawFromVault(
            v.vaultAddress,
            _lptoken,
            _shareAmount
        );

        _withdrawFromProtocol(_lptoken, targetToken, lptokenAmount, _recipient);
    }

    function _takeZapFee(
        address _token,
        uint256 _amount
    ) internal returns (uint256 targetAmount) {
        uint256 amountFee = (_amount * zapFee) / MAX_BPS;

        IERC20(_token).safeTransfer(treasury, amountFee);

        targetAmount = _amount - amountFee;
    }

    function _depositToProtocol(
        address _lptoken,
        address _targetCoin,
        uint256 _targetAmount,
        address _recipient
    ) internal {
        IVelodromePool pool = IVelodromePool(address(_lptoken));
        bool isStablePool = pool.stable();
        bool isToken0Target;

        address factory = pool.factory();

        address poolToken0 = pool.token0();
        address poolToken1 = pool.token1();

        if (poolToken0 == _targetCoin) {
            isToken0Target = true;
        }

        IVelodromeRouter.Routes memory route;

        //build route
        route = IVelodromeRouter.Routes({
            from: _targetCoin,
            to: isToken0Target ? poolToken1 : poolToken0,
            stable: isStablePool,
            factory: factory
        });

        uint256 amountToSwapTargetCoin = _targetAmount / 2;

        if (isStablePool) {
            uint256 ratio = router.quoteStableLiquidityRatio(
                address(poolToken0),
                address(poolToken1),
                factory
            );

            amountToSwapTargetCoin = isToken0Target
                ? (_targetAmount * ratio) / 1e18
                : _targetAmount - ((_targetAmount * ratio) / 1e18);
        }

        IERC20(poolToken0).approve(address(router), _targetAmount);
        IERC20(poolToken1).approve(address(router), _targetAmount);

        IVelodromeRouter.Routes[] memory routes = new IVelodromeRouter.Routes[](
            1
        );

        routes[0] = route;

        uint256 balanceToken0Before = IERC20(poolToken0).balanceOf(
            address(this)
        );
        uint256 balanceToken1Before = IERC20(poolToken1).balanceOf(
            address(this)
        );

        router.swapExactTokensForTokens(
            amountToSwapTargetCoin,
            0,
            routes,
            address(this),
            block.timestamp
        );

        IERC20(poolToken0).approve(address(router), 0);
        IERC20(poolToken1).approve(address(router), 0);

        // get actual balances and check that we have balance after swap
        uint256 balanceToken0 = isToken0Target
            ? _targetAmount - amountToSwapTargetCoin
            : IERC20(poolToken0).balanceOf(address(this)) - balanceToken0Before;
        uint256 balanceToken1 = isToken0Target
            ? IERC20(poolToken1).balanceOf(address(this)) - balanceToken1Before
            : _targetAmount - amountToSwapTargetCoin;

        IERC20(poolToken0).approve(address(router), balanceToken0);
        IERC20(poolToken1).approve(address(router), balanceToken1);

        balanceToken0Before = balanceToken0;
        balanceToken1Before = balanceToken1;

        (balanceToken0, balanceToken1, ) = router.addLiquidity(
            poolToken0,
            poolToken1,
            isStablePool,
            balanceToken0,
            balanceToken1,
            0,
            0,
            address(this),
            block.timestamp
        );


        balanceToken0 = balanceToken0Before - balanceToken0;
        balanceToken1 = balanceToken1Before - balanceToken1;

        //refund rest
        if (balanceToken0 > 0) {
            IERC20(poolToken0).transfer(_recipient, balanceToken0);
        }

        if (balanceToken1 > 0) {
            IERC20(poolToken1).transfer(_recipient, balanceToken1);
        }
    }



    function _withdrawFromVault(
        address _vault,
        address _token,
        uint256 _shareAmount
    ) internal returns (uint256 lptokenAmount) {
        IERC20(_token).approve(_vault, _shareAmount);

        uint256 vaultTokenBalanceBefore = IERC20(_vault).balanceOf(
            address(this)
        );

        uint256 lpTokenBalanceBefore = IERC20(_token).balanceOf(address(this));

        IVault(_vault).withdraw(_shareAmount, address(this), 1);

        uint256 vaultTokenBalanceAfter = IERC20(_vault).balanceOf(
            address(this)
        );
        uint256 lpTokenBalanceAfter = IERC20(_token).balanceOf(address(this));

        if (vaultTokenBalanceAfter > 0) {
            IERC20(_vault).safeTransfer(msg.sender, vaultTokenBalanceAfter);
        }

        lptokenAmount = lpTokenBalanceAfter - lpTokenBalanceBefore;
    }

    function _withdrawFromProtocol(
        address _lptoken,
        address _targetCoin,
        uint256 _lptokenAmount,
        address _recipient
    ) internal {
        IVelodromePool pool = IVelodromePool(address(_lptoken));

        IERC20(_lptoken).approve(address(router), _lptokenAmount);

        bool isStablePool = pool.stable();
        bool isToken0Target;

        address factory = pool.factory();

        address poolToken0 = pool.token0();
        address poolToken1 = pool.token1();

        if (poolToken0 == _targetCoin) {
            isToken0Target = true;
        }

        uint256 balanceToken0 = IERC20(poolToken0).balanceOf(address(this));
        uint256 balanceToken1 = IERC20(poolToken1).balanceOf(address(this));


        router.removeLiquidity(
            poolToken0,
            poolToken1,
            isStablePool,
            _lptokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );


        balanceToken0 =
            IERC20(poolToken0).balanceOf(address(this)) -
            balanceToken0;

        balanceToken1 =
            IERC20(poolToken1).balanceOf(address(this)) -
            balanceToken1;



        IVelodromeRouter.Routes memory route;

        //build route
        route = IVelodromeRouter.Routes({
            from: isToken0Target ? poolToken1 : poolToken0,
            to: _targetCoin,
            stable: isStablePool,
            factory: factory
        });

        uint256 amountToSwapTargetCoin = isToken0Target
            ? balanceToken1
            : balanceToken0;

        IERC20(poolToken0).approve(address(router), amountToSwapTargetCoin);
        IERC20(poolToken1).approve(address(router), amountToSwapTargetCoin);

        IVelodromeRouter.Routes[] memory routes = new IVelodromeRouter.Routes[](
            1
        );

        routes[0] = route;

        router.swapExactTokensForTokens(
            amountToSwapTargetCoin,
            0,
            routes,
            address(this),
            block.timestamp
        );


        uint256 balanceOfTarget = isToken0Target
            ? IERC20(poolToken0).balanceOf(address(this)) - balanceToken0
            : IERC20(poolToken1).balanceOf(address(this)) - balanceToken1;

        _sendTargetCoin(_targetCoin, balanceOfTarget, _recipient);
    }

    function _sendTargetCoin(
        address _targetCoin,
        uint256 _amount,
        address _recipient
    ) internal {
        IERC20(_targetCoin).safeTransfer(_recipient, _amount);
    }

    function setOwner(address newOwner) external {
        require(msg.sender == owner);
        pendingOwner = newOwner;
    }

    function acceptOwner() external {
        require(msg.sender == pendingOwner);
        owner = pendingOwner;
    }

    function setRegistry(address _registry) external {
        require(msg.sender == owner);
        registry = IRegistry(_registry);
    }

    function setGovernance(address _governance) external {
        require(msg.sender == owner);
        governance = _governance;
    }

    function setManagement(address _management) external {
        require(msg.sender == owner);
        management = _management;
    }

    function setGuardian(address _guardian) external {
        require(msg.sender == owner);
        guardian = _guardian;
    }

    function setTreasury(address _treasury) external {
        require(msg.sender == owner);
        treasury = _treasury;
    }

    function setKeeper(address _keeper) external {
        require(msg.sender == owner || msg.sender == management);
        keeper = _keeper;
    }

    function setDepositLimit(uint256 _depositToProtocolLimit) external {
        require(msg.sender == owner || msg.sender == management);
        depositLimit = _depositToProtocolLimit;
    }

    function setVelodromeStratImplementation(
        address _velodromeStratImplementation
    ) external {
        require(msg.sender == owner);
        velodromeStratImplementation = _velodromeStratImplementation;
    }

    function setDepositFee(uint256 _depositToProtocolFee) external {
        require(msg.sender == owner);
        require(_depositToProtocolFee <= 10_000);
        depositFee = _depositToProtocolFee;
    }

    function setZapFee(uint256 _zapFee) external {
        require(msg.sender == owner);
        require(_zapFee <= 10_000);
        zapFee = _zapFee;
    }

    function setVeloPoolToRegistry(
        address _lptoken,
        IVelodromeRouter.Routes[] memory _swapRouteForToken0,
        IVelodromeRouter.Routes[] memory _swapRouteForToken1
    ) external {
        require(msg.sender == owner);

        for (uint i; i < _swapRouteForToken0.length; ++i) {
            veloRegistryForToken0[_lptoken].push(_swapRouteForToken0[i]);
        }

        for (uint i; i < _swapRouteForToken1.length; ++i) {
            veloRegistryForToken1[_lptoken].push(_swapRouteForToken1[i]);
        }

        IVelodromePool pool = IVelodromePool(_lptoken);

        address poolToken0 = pool.token0();
        address poolToken1 = pool.token1();

        // check our swap paths end with our correct token, but only if it's not VELO
        if (
            poolToken0 != velo &&
            poolToken0 != _swapRouteForToken0[_swapRouteForToken0.length - 1].to
        ) {
            revert("token0 route error");
        }

        if (
            poolToken1 != velo &&
            poolToken1 != _swapRouteForToken1[_swapRouteForToken0.length - 1].to
        ) {
            revert("token1 route error");
        }
    }
}
