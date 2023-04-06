// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/IStrategy.sol";
import "../interfaces/IBooster.sol";
import "../interfaces/IDetails.sol";
import "../interfaces/IPoolManager.sol";
import "../interfaces/IRegistry.sol";
import "../interfaces/IVault.sol";
import "../interfaces/IFactoryAdapter.sol";
import {ICurveGauge, ICurveFi} from "../interfaces/ICurve.sol";

contract CurveFactory is Initializable, IFactoryAdapter {

    using SafeERC20 for IERC20;

    enum CurveType {
        NONE,
        METAPOOL,
        COINS2,
        COINS3,
        COINS4
    }

    event NewVault(
        address indexed lpToken,
        address gauge,
        address indexed vault,
        address strategy,
        uint8 poolType
    );

    struct Vault {
        address vaultAddress;
        CurveType poolType;
        bool isUseUnderlying;
    }

    error VaultDoesntExist();
    error BalanceIsZero();

    ///////////////////////////////////
    //
    //  Storage variables and setters
    //
    ////////////////////////////////////

    mapping(address => Vault) public deployedVaults; //for ZAP V1

    address eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public constant cvx = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    uint256 public constant category = 0; // 0 for curve

    IBooster public booster;

    // always owned by ychad
    address public owner;
    address internal pendingOwner;

    IERC20 internal constant usdt =
        IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    ICurveFi internal constant zapContract =
        ICurveFi(0xA79828DF1850E8a3A3064576f380D90aECDD3359);

    function setOwner(address newOwner) external {
        require(msg.sender == owner);
        pendingOwner = newOwner;
    }

    function acceptOwner() external {
        require(msg.sender == pendingOwner);
        owner = pendingOwner;
    }

    address public convexPoolManager;

    function setConvexPoolManager(address _convexPoolManager) external {
        require(msg.sender == owner);
        convexPoolManager = _convexPoolManager;
    }

    IRegistry public registry;

    function setRegistry(address _registry) external {
        require(msg.sender == owner);
        registry = IRegistry(_registry);
    }

    address public governance;

    function setGovernance(address _governance) external {
        require(msg.sender == owner);
        governance = _governance;
    }

    address public management;

    function setManagement(address _management) external {
        require(msg.sender == owner);
        management = _management;
    }

    address public guardian;

    function setGuardian(address _guardian) external {
        require(msg.sender == owner);
        guardian = _guardian;
    }

    address public treasury;

    function setTreasury(address _treasury) external {
        require(msg.sender == owner);
        treasury = _treasury;
    }

    address public keeper;

    function setKeeper(address _keeper) external {
        require(msg.sender == owner || msg.sender == management);
        keeper = _keeper;
    }

    uint256 public depositLimit;


    address public zapper;

    function setZepper(address _zapper) external {
        require(msg.sender == owner || msg.sender == management);
        zapper = _zapper;
    }

    function setDepositLimit(uint256 _depositLimit) external {
        require(msg.sender == owner || msg.sender == management);
        depositLimit = _depositLimit;
    }

    mapping(CurveType => address) public convexStratImplementation;

    function setConvexStratImplementation(
        CurveType _poolType,
        address _convexStratImplementation
    ) external {
        require(msg.sender == owner);
        convexStratImplementation[_poolType] = _convexStratImplementation;
    }

    uint256 public depositFee = 50;

    function setDespositFee(uint256 _depositFee) external {
        require(msg.sender == owner);
        require(_depositFee <= 1_000);
        depositFee = _depositFee;
    }

    ///////////////////////////////////
    //
    // Functions
    //
    ////////////////////////////////////

    function initialize(
        address _registry,
        address _keeper,
        address _owner
    ) public initializer {
        registry = IRegistry(_registry);

        owner = _owner;

        depositLimit = 10_000_000_000_000 * 1e18; // some large number

        keeper = _keeper;

        treasury = _owner;

        guardian = _owner;

        management = _owner;

        governance = _owner;

        convexPoolManager = 0xD1f9b3de42420A295C33c07aa5C9e04eDC6a4447;

        booster = IBooster(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
    }

    /// @notice Public function to check whether, for a given gauge address, its possible to permissionlessly create a vault for corressponding LP token
    /// @param _gauge The gauge address to find the latest vault for
    /// @return bool if true, vault can be created permissionlessly
    function canCreateVaultPermissionlessly(
        address _gauge
    ) public view returns (bool) {
        return latestDefaultOrAutomatedVaultFromGauge(_gauge) == address(0);
    }

    /// @dev Returns only the latest vault address for any DEFAULT/AUTOMATED type vaults
    /// @dev If no vault of either DEFAULT or AUTOMATED types exists for this gauge, 0x0 is returned from registry.
    function latestDefaultOrAutomatedVaultFromGauge(
        address _gauge
    ) internal view returns (address) {
        address lptoken = ICurveGauge(_gauge).lp_token();
        if (!registry.isRegistered(lptoken)) {
            return address(0);
        }

        address latest = latestVault(lptoken);

        return latest;
    }

    function latestVault(address _token) public view returns (address) {
        bytes memory data = abi.encodeWithSignature(
            "latestVault(address)",
            _token
        );
        (bool success, bytes memory returnBytes) = address(registry).staticcall(
            data
        );
        if (success) {
            return abi.decode(returnBytes, (address));
        }
        return address(0);
    }

    function getPid(address _gauge) public view returns (uint256 pid) {
        pid = type(uint256).max;

        if (!booster.gaugeMap(_gauge)) {
            return pid;
        }

        for (uint256 i = booster.poolLength(); i > 0; i--) {
            //we start at the end and work back for most recent
            (, , address gauge, , , ) = booster.poolInfo(i - 1);

            if (_gauge == gauge) {
                return i - 1;
            }
        }
    }

    // only permissioned users can deploy if there is already one endorsed
    function createNewVaultsAndStrategies(
        address _gauge,
        CurveType _poolType,
        bytes calldata _swapPath,
        bool _isUseUnderlying,
        bool _allowDuplicate
    ) external returns (address vault, address convexStrategy) {
        require(msg.sender == owner || msg.sender == management);

        return
            _createNewVaultsAndStrategies(
                _gauge,
                _poolType,
                _swapPath,
                _isUseUnderlying,
                _allowDuplicate
            );
    }

    function _createNewVaultsAndStrategies(
        address _gauge,
        CurveType _poolType,
        bytes calldata _swapPath,
        bool _isUseUnderlying,
        bool _allowDuplicate
    ) internal returns (address vault, address strategy) {
        if (!_allowDuplicate) {
            require(
                canCreateVaultPermissionlessly(_gauge),
                "Vault already exists"
            );
        }
        address lptoken = ICurveGauge(_gauge).lp_token();

        //get convex pid. if no pid create one
        uint256 pid = getPid(_gauge);
        if (pid == type(uint256).max) {
            //when we add the new pool it will be added to the end of the pools in convexDeposit.
            pid = booster.poolLength();
            //add pool
            require(
                IPoolManager(convexPoolManager).addPool(_gauge),
                "Unable to add pool to Convex"
            );
        }

        vault = _createVault(lptoken);

        deployedVaults[lptoken] = Vault(
            vault,
            _poolType,
            _isUseUnderlying
        );

        IVault v = IVault(vault);

        strategy = _createStrategy(lptoken, pid, _swapPath, _isUseUnderlying);

        v.addStrategy(strategy, 10_000, 0, type(uint256).max);

        emit NewVault(lptoken, _gauge, vault, strategy, uint8(_poolType));
    }

    function _createVault(address _lptoken) internal returns (address vault) {
        //now we create the vault, endorses it from governance after
        vault = registry.newExperimentalVault(
            _lptoken,
            address(this),
            guardian,
            treasury,
            string.concat(
                "Curve ",
                IDetails(address(_lptoken)).symbol(),
                " bauVault"
            ),
            string.concat("bauCurve", IDetails(address(_lptoken)).symbol()),
            0
        );

        IVault v = IVault(vault);
        v.setManagement(management);
        v.setGovernance(governance);
        v.setDepositLimit(depositLimit);
        v.setDepositFee(depositFee);
    }

    function _createStrategy(
        address _lptoken,
        uint256 _pid,
        bytes calldata _swapPath,
        bool _isUseUnderlying
    ) internal returns (address strategy) {
        Vault memory v = deployedVaults[_lptoken];

        //now we create the convex strat
        if (v.poolType == CurveType.METAPOOL) {
            strategy = IStrategy(convexStratImplementation[v.poolType]).clone(
                v.vaultAddress,
                management,
                treasury,
                keeper,
                _pid,
                _lptoken,
                string(
                    abi.encodePacked(
                        "yieldConvex",
                        IDetails(address(_lptoken)).symbol()
                    )
                )
            );
        } else {
            address minter = ICurveFi(_lptoken).minter();

            strategy = IStrategy(convexStratImplementation[v.poolType]).clone(
                v.vaultAddress,
                management,
                treasury,
                keeper,
                _pid,
                minter,
                _swapPath,
                string(
                    abi.encodePacked(
                        "yieldConvex",
                        IDetails(address(minter)).symbol()
                    )
                ),
                uint8(v.poolType),
                _isUseUnderlying
            );
        }
    }

    ///////////////////////////////////
    //
    // Adapter
    //
    ////////////////////////////////////

    // get target coin for add liquidity
    function targetCoin(
        address _token
    ) public view override returns (address coin) {
        Vault memory v = deployedVaults[_token];

        if (v.poolType == CurveType.NONE) {
            revert VaultDoesntExist();
        }

        if (v.poolType == CurveType.METAPOOL) {
            coin = address(usdt);
        } else {
            coin = ICurveFi(_token).coins(0);

            if (coin == eth) {
                coin = ICurveFi(_token).coins(1);
            }
        }
    }

    // add liquidity for targetAmount
    function deposit(address _token, uint256 _targetAmount, address _recipient) external override {
        require(msg.sender == zapper); //only zapper can call this function

        Vault memory v = deployedVaults[_token];

        address vault = v.vaultAddress;

        if (v.poolType == CurveType.NONE) {
            revert VaultDoesntExist();
        }

        if (v.poolType == CurveType.METAPOOL) {

            usdt.transferFrom(msg.sender, address(this), _targetAmount);

            usdt.approve(address(zapContract), _targetAmount);

            uint256 tokenBalanceBefore = IERC20(_token).balanceOf(address(this));
            zapContract.add_liquidity(
                _token,
                [0, 0, 0, _targetAmount],
                0
            );

            uint256 tokenBalanceAfter = IERC20(_token).balanceOf(address(this));

            uint256 tokenBalance = tokenBalanceAfter - tokenBalanceBefore;

            if (tokenBalance == 0) {
                revert BalanceIsZero();
            }

            IERC20(_token).approve(vault, tokenBalance);

            uint256 vaultBalanceBefore = IERC20(vault).balanceOf(address(this));

            IVault(vault).deposit(tokenBalance, _recipient);

        } else {

        }
    }


    function withdraw(address _token, uint256 _shareAmount) external override {
        require(msg.sender == zapper); //only zapper can call this function
    }
}
