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

    uint256 internal constant MAX_BPS = 10_000; //100%

    address internal constant SUSD = 0xC25a3A3b969415c80451098fa907EC722572917F;

    enum CurveType {
        NONE,
        METAPOOL_3CRV,
        COINS2,
        COINS3,
        COINS4,
        METAPOOL_SBTC
    }

    struct PoolParams {
        Vault vault;
        uint256 pid;
        bytes swapPath;
        string symbol;
    }

    mapping(address => CurveType) public curveRegistry;

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
        address deposit;
        bool isLendingPool;
        bool depositContract;
    }

    error VaultDoesntExist();
    error BalanceIsZero();

    ///////////////////////////////////
    //
    //  Storage variables and setters
    //
    ////////////////////////////////////

    mapping(address => Vault) public deployedVaults; //for ZAP V1

    // pools, deposit contracts
    mapping(address => address) public depositContracts;

    address public constant eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public constant cvx = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    uint256 public constant category = 0; // 0 for curve

    IBooster public booster;

    address public owner;
    address internal pendingOwner;

    IERC20 internal constant usdt =
        IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    mapping(CurveType => ICurveFi) public zapContract;

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

    function setDepositFee(uint256 _depositFee) external {
        require(msg.sender == owner);
        require(_depositFee <= 10_000);
        depositFee = _depositFee;
    }

    uint256 public zapFee = 5;

    function setZapFee(uint256 _zapFee) external {
        require(msg.sender == owner);
        require(_zapFee <= 10_000);
        zapFee = _zapFee;
    }

    bool public allowDuplicate;

    function setAllowDuplicate(bool _allowDuplicate) external {
        require(msg.sender == owner);

        allowDuplicate = _allowDuplicate;
    }

    function setCurvePoolToRegistry(
        address _lptoken,
        CurveType _poolType
    ) external {
        require(msg.sender == owner);

        curveRegistry[_lptoken] = _poolType;
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

        // depositContracts map

        // BUSD
        depositContracts[
            0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B
        ] = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB;

        //compound
        depositContracts[
            0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2
        ] = 0xeB21209ae4C2c9FF2a86ACA31E123764A3B6Bc06;

        //PAX

        depositContracts[
            0xD905e2eaeBe188fc92179b6350807D8bd91Db0D8
        ] = 0xA50cCc70b6a011CffDdf45057E39679379187287;

        //USDT

        depositContracts[
            0x9fC689CCaDa600B6DF723D9E47D84d76664a1F23
        ] = 0xac795D2c97e60DF6a99ff1c814727302fD747a80;

        //yDAI

        depositContracts[
            0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8
        ] = 0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;

        //SUSD

        depositContracts[
            0xC25a3A3b969415c80451098fa907EC722572917F
        ] = 0xFCBa3E75865d2d561BE8D220616520c171F12851;

        //3CRV

        //GUSD POOL

        zapContract[CurveType.METAPOOL_3CRV] = ICurveFi(
            0xA79828DF1850E8a3A3064576f380D90aECDD3359
        );
        zapContract[CurveType.METAPOOL_SBTC] = ICurveFi(
            0x7AbDBAf29929e7F8621B757D2a7c04d78d633834
        );

        depositFee = 50;

        zapFee = 5;
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

    function isVaultExists(address _token) external view returns (bool) {
        Vault storage v = deployedVaults[_token];

        if (v.vaultAddress != address(0x0)) {
            return true;
        }
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
        bytes calldata _swapPath
    ) external returns (address vault, address convexStrategy) {
        //require(msg.sender == owner || msg.sender == management);

        return _createNewVaultsAndStrategies(_gauge, _swapPath);
    }

    function _createNewVaultsAndStrategies(
        address _gauge,
        bytes calldata _swapPath
    ) internal returns (address vault, address strategy) {
        if (!allowDuplicate) {
            require(
                canCreateVaultPermissionlessly(_gauge),
                "Vault already exists"
            );
        }
        address lptoken = ICurveGauge(_gauge).lp_token();

        uint256 pid = _getConvexPid(_gauge);

        vault = _createVault(lptoken);

        CurveType poolType = curveRegistry[lptoken];

        require(poolType != CurveType.NONE);

        _recordVault(vault, poolType, lptoken);

        _createStrategy(lptoken, pid, _swapPath);

        _addStrategyToVault(vault, strategy);

        emit NewVault(lptoken, _gauge, vault, strategy, uint8(poolType));
    }

    function _recordVault(
        address _vault,
        CurveType _poolType,
        address _lptoken
    ) internal {
        bool isLendingPool = false;

        address deposit = _lptoken;

        bool depositContract = false;

        if (
            _poolType != CurveType.METAPOOL_3CRV &&
            depositContracts[_lptoken] == address(0x0)
        ) {
            deposit = ICurveFi(_lptoken).minter();
        }

        if (depositContracts[_lptoken] != address(0x0)) {
            deposit = depositContracts[_lptoken];
            isLendingPool = true;
            depositContract = true;
        }

        deployedVaults[_lptoken] = Vault(
            _vault,
            _poolType,
            deposit,
            isLendingPool,
            depositContract
        );
    }

    function _getConvexPid(address _gauge) internal returns (uint256 pid) {
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
        bytes calldata _swapPath
    ) internal returns (address strategy) {
        Vault memory v = deployedVaults[_lptoken];

        string memory symbol = IDetails(_lptoken).name();

        symbol = string(abi.encodePacked("bauConvex", symbol));

        PoolParams memory params = PoolParams({
            vault: v,
            pid: _pid,
            swapPath: _swapPath,
            symbol: symbol
        });

        //now we create the convex strat
        if (
            v.poolType == CurveType.METAPOOL_3CRV ||
            v.poolType == CurveType.METAPOOL_SBTC
        ) {
            strategy = _createStrategyMETAPOOL(params);
        } else {
            strategy = _createStrategyPool(params);
        }
    }

    function _createStrategyMETAPOOL(
        PoolParams memory params
    ) internal returns (address strategy) {
        Vault memory v = params.vault;

        strategy = IStrategy(convexStratImplementation[v.poolType]).clone(
            v.vaultAddress,
            management,
            treasury,
            keeper,
            params.pid,
            v.deposit,
            params.symbol
        );
    }

    function _createStrategyPool(
        PoolParams memory params
    ) internal returns (address strategy) {
        Vault memory v = params.vault;

        address minter;

        if (v.depositContract) {
            minter = ICurveFi(v.deposit).curve();
        } else {
            minter = v.deposit;
        }

        strategy = IStrategy(convexStratImplementation[v.poolType]).clone(
            v.vaultAddress,
            management,
            treasury,
            keeper,
            params.pid,
            v.deposit,
            params.swapPath,
            params.symbol,
            uint8(v.poolType),
            v.isLendingPool,
            v.depositContract
        );
    }

    function _addStrategyToVault(address _vault, address _strategy) internal {
        IVault v = IVault(_vault);

        v.addStrategy(_strategy, 10_000, 0, type(uint256).max);
    }

    ///////////////////////////////////
    //
    // Adapter
    //
    ////////////////////////////////////

    // get target coin for add liquidity
    function targetCoin(
        address _token
    )
        public
        view
        override
        returns (address coin, uint256 index, address vault)
    {
        index = 0;
        Vault memory v = deployedVaults[_token];

        if (v.poolType == CurveType.NONE) {
            revert VaultDoesntExist();
        }

        vault = v.vaultAddress;

        if (
            v.poolType == CurveType.METAPOOL_3CRV ||
            v.poolType == CurveType.METAPOOL_SBTC
        ) {
            coin = ICurveFi(_token).coins(0);
        } else {
            address minter = v.deposit;

            if (v.depositContract) {
                if (_token == SUSD) {
                    coin = ICurveFi(minter).underlying_coins(uint256(0));
                } else {
                    coin = ICurveFi(minter).underlying_coins(int128(int256(0)));
                }

                //
            } else if (v.isLendingPool) {
                coin = ICurveFi(minter).underlying_coins(uint256(0));

                if (coin == eth) {
                    index += 1;
                    coin = ICurveFi(minter).underlying_coins(index);
                }
            } else {
                coin = ICurveFi(minter).coins(0);

                if (coin == eth) {
                    index += 1;
                    coin = ICurveFi(minter).coins(index);
                }
            }
        }
    }

    function supportedCoin(
        address _token,
        address _targetToken
    )
        public
        view
        override
        returns (bool supported, uint256 index, address vault)
    {
        Vault memory v = deployedVaults[_token];

        require(_token != eth);

        if (v.poolType == CurveType.NONE) {
            revert VaultDoesntExist();
        }

        vault = v.vaultAddress;

        if (
            v.poolType == CurveType.METAPOOL_3CRV ||
            v.poolType == CurveType.METAPOOL_SBTC
        ) {
            for (uint256 i; i < 2; i++) {
                address coin = ICurveFi(_token).coins(i);

                if (_targetToken == coin) {
                    supported = true;
                    index = i;
                }
            }
        } else if (v.poolType == CurveType.COINS2) {
            for (uint256 i; i < 2; i++) {
                address coin;

                if (v.isLendingPool) {
                    coin = ICurveFi(_token).underlying_coins(int128(int256(i)));
                } else {
                    coin = ICurveFi(_token).coins(i);
                }

                if (_targetToken == coin) {
                    supported = true;
                    index = i;
                }
            }
        } else if (v.poolType == CurveType.COINS3) {
            for (uint256 i; i < 2; i++) {
                address coin;

                if (v.isLendingPool) {
                    coin = ICurveFi(_token).underlying_coins(int128(int256(i)));
                } else {
                    coin = ICurveFi(_token).coins(i);
                }

                if (_targetToken == coin) {
                    supported = true;
                    index = i;
                }
            }
        } else if (v.poolType == CurveType.COINS4) {
            for (uint256 i; i < 4; i++) {
                address coin;

                if (v.isLendingPool) {
                    coin = ICurveFi(_token).underlying_coins(int128(int256(i)));
                } else {
                    coin = ICurveFi(_token).coins(i);
                }

                if (_targetToken == coin) {
                    supported = true;
                    index = i;
                }
            }
        }
    }

    // add liquidity for targetAmount with targetCoin, global targetCoin index variable

    function depositWithTargetCoin(
        address _token,
        uint256 _targetAmount,
        address _recipient
    ) external override {
        Vault memory v = deployedVaults[_token];

        address vault = v.vaultAddress;

        if (v.poolType == CurveType.NONE) {
            revert VaultDoesntExist();
        }

        uint256 tokenBalanceBefore = IERC20(_token).balanceOf(address(this));

        (address targetToken, uint256 index, ) = targetCoin(_token);

        IERC20(targetToken).transferFrom(
            msg.sender,
            address(this),
            _targetAmount
        );
        IERC20(targetToken).approve(
            address(zapContract[v.poolType]),
            _targetAmount
        );

        if (
            v.poolType == CurveType.METAPOOL_3CRV ||
            v.poolType == CurveType.METAPOOL_SBTC
        ) {
            _depositToMETAPOOL(
                _token,
                targetToken,
                index,
                _targetAmount,
                v.poolType
            );
        } else if (v.poolType == CurveType.COINS2) {
            _depositTo2Pool(v.deposit, targetToken, index, _targetAmount);
        } else if (v.poolType == CurveType.COINS3) {
            _depositTo3Pool(v.deposit, targetToken, index, _targetAmount);
        } else if (v.poolType == CurveType.COINS4) {
            _depositTo4Pool(v.deposit, targetToken, index, _targetAmount);
        }

        uint256 tokenBalanceAfter = IERC20(_token).balanceOf(address(this));

        uint256 tokenBalance = tokenBalanceAfter - tokenBalanceBefore;

        if (tokenBalance == 0) {
            revert BalanceIsZero();
        }

        IERC20(_token).approve(vault, tokenBalance);

        uint256 vaultBalanceBefore = IERC20(vault).balanceOf(address(this));
        IVault(vault).deposit(tokenBalance, address(this));
        uint256 vaultBalanceAfter = IERC20(vault).balanceOf(address(this));

        uint256 vaultBalance = vaultBalanceAfter - vaultBalanceBefore;

        vaultBalance = _takeZapFee(vault, vaultBalance);

        IERC20(vault).safeTransfer(_recipient, vaultBalance);
    }

    function depositWithSupportedCoin(
        address _token,
        address _targetToken,
        uint256 _targetAmount,
        address _recipient
    ) external override {
        Vault memory v = deployedVaults[_token];

        address vault = v.vaultAddress;

        if (v.poolType == CurveType.NONE) {
            revert VaultDoesntExist();
        }

        uint256 tokenBalanceBefore = IERC20(_token).balanceOf(address(this));

        (bool supported, uint256 index, ) = supportedCoin(_token, _targetToken);

        require(supported, "");

        _targetAmount = _takeZapFee(_targetToken, _targetAmount);

        IERC20(_targetToken).transferFrom(
            msg.sender,
            address(this),
            _targetAmount
        );

        IERC20(_targetToken).approve(v.deposit, _targetAmount);

        if (
            v.poolType == CurveType.METAPOOL_3CRV ||
            v.poolType == CurveType.METAPOOL_SBTC
        ) {
            _depositToMETAPOOL(
                _token,
                _targetToken,
                index,
                _targetAmount,
                v.poolType
            );
        } else if (v.poolType == CurveType.COINS2) {
            _depositTo2Pool(v.deposit, _targetToken, index, _targetAmount);
        } else if (v.poolType == CurveType.COINS3) {
            _depositTo3Pool(v.deposit, _targetToken, index, _targetAmount);
        } else if (v.poolType == CurveType.COINS4) {
            _depositTo4Pool(v.deposit, _targetToken, index, _targetAmount);
        }

        uint256 tokenBalanceAfter = IERC20(_token).balanceOf(address(this));

        uint256 tokenBalance = tokenBalanceAfter - tokenBalanceBefore;

        if (tokenBalance == 0) {
            revert BalanceIsZero();
        }

        IERC20(_token).approve(vault, tokenBalance);

        uint256 vaultBalanceBefore = IERC20(vault).balanceOf(address(this));

        IVault(vault).deposit(tokenBalance, _recipient);
    }

    function _depositToMETAPOOL(
        address _token,
        address _targetCoin,
        uint256 _index,
        uint256 _targetAmount,
        CurveType _poolType
    ) internal {
        uint256[4] memory coins;

        for (uint256 i; i < 4; i++) {
            if (i == _index) {
                coins[i] = _targetAmount;
            } else {
                coins[i] = 0;
            }
        }

        zapContract[_poolType].add_liquidity(_token, coins, 0);
    }

    function _depositTo2Pool(
        address _minter,
        address _targetCoin,
        uint256 _index,
        uint256 _targetAmount
    ) internal {
        uint256[2] memory coins;

        for (uint256 i; i < 2; i++) {
            if (i == _index) {
                coins[i] = _targetAmount;
            } else {
                coins[i] = 0;
            }
        }

        ICurveFi(_minter).add_liquidity(coins, 0);
    }

    function _depositTo3Pool(
        address _minter,
        address _targetCoin,
        uint256 _index,
        uint256 _targetAmount
    ) internal {
        uint256[3] memory coins;

        for (uint256 i; i < 3; i++) {
            if (i == _index) {
                coins[i] = _targetAmount;
            } else {
                coins[i] = 0;
            }
        }

        ICurveFi(_minter).add_liquidity(coins, 0);
    }

    function _depositTo4Pool(
        address _minter,
        address _targetCoin,
        uint256 _index,
        uint256 _targetAmount
    ) internal {
        uint256[4] memory coins;

        for (uint256 i; i < 4; i++) {
            if (i == _index) {
                coins[i] = _targetAmount;
            } else {
                coins[i] = 0;
            }
        }

        ICurveFi(_minter).add_liquidity(coins, 0);
    }

    function withdrawWithTargetCoin(
        address _token,
        uint256 _shareAmount,
        address _recipient
    ) external override {
        Vault memory v = deployedVaults[_token];

        address vault = v.vaultAddress;

        (address targetToken, uint256 index, ) = targetCoin(_token);

        if (v.poolType == CurveType.NONE) {
            revert VaultDoesntExist();
        }

        IERC20(v.vaultAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _shareAmount
        );

        uint256 lptokenAmount = _withdrawFromVault(
            v.vaultAddress,
            _token,
            _shareAmount
        );

        _withdrawFromProtocol(
            _token,
            targetToken,
            index,
            lptokenAmount,
            _recipient
        );
    }

    function withdrawWithSupportedCoin(
        address _token,
        address _targetCoin,
        uint256 _shareAmount,
        address _recipient
    ) external override {
        Vault memory v = deployedVaults[_token];

        address vault = v.vaultAddress;

        if (v.poolType == CurveType.NONE) {
            revert VaultDoesntExist();
        }

        (bool supported, uint256 index, ) = supportedCoin(_token, _targetCoin);

        require(supported, "");

        IERC20(v.vaultAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _shareAmount
        );

        uint256 lptokenAmount = _withdrawFromVault(
            v.vaultAddress,
            _token,
            _shareAmount
        );

        _withdrawFromProtocol(
            _token,
            _targetCoin,
            index,
            lptokenAmount,
            _recipient
        );
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

        uint256 diffVToken = vaultTokenBalanceAfter - vaultTokenBalanceBefore;

        if (diffVToken > 0) {
            IERC20(_vault).safeTransfer(msg.sender, diffVToken);
        }

        lptokenAmount = lpTokenBalanceAfter - lpTokenBalanceBefore;
    }

    function _withdrawFromProtocol(
        address _token,
        address _targetCoin,
        uint256 _index,
        uint256 _lptokenAmount,
        address _recipient
    ) internal {
        Vault memory v = deployedVaults[_token];

        if (
            v.poolType == CurveType.METAPOOL_3CRV ||
            v.poolType == CurveType.METAPOOL_SBTC
        ) {
            _withdrawFromMETAPOOL(
                _token,
                _index,
                _lptokenAmount,
                _recipient,
                v.poolType
            );
        } else {
            uint256 targetTokenBalanceBefore = IERC20(_targetCoin).balanceOf(
                address(this)
            );
            _withdrawFromPool(v.deposit, _index, _lptokenAmount);
            uint256 targetTokenBalanceAfter = IERC20(_targetCoin).balanceOf(
                address(this)
            );

            uint256 balance = targetTokenBalanceAfter -
                targetTokenBalanceBefore;

            IERC20(_targetCoin).safeTransfer(_recipient, balance);
        }
    }

    function _withdrawFromMETAPOOL(
        address _token,
        uint256 _index,
        uint256 _shareAmount,
        address _recipient,
        CurveType _poolType
    ) internal {
        zapContract[_poolType].remove_liquidity_one_coin(
            _token,
            _shareAmount,
            int128(int256(_index)),
            0,
            _recipient
        );
    }

    function _withdrawFromPool(
        address _minter,
        uint256 _index,
        uint256 _shareAmount
    ) internal {
        ICurveFi(_minter).remove_liquidity_one_coin(
            _shareAmount,
            int128(int256(_index)),
            0
        );
    }

    function _takeZapFee(
        address _token,
        uint256 _amount
    ) internal returns (uint256 targetAmount) {
        uint256 amountFee = (_amount * zapFee) / MAX_BPS;

        IERC20(_token).safeTransfer(treasury, amountFee);

        targetAmount = _amount - amountFee;
    }
}
