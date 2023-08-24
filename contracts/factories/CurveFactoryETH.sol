// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

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

contract CurveFactoryETH is Initializable, IFactoryAdapter {
    using SafeERC20 for IERC20;

    uint256 internal constant MAX_BPS = 10_000; //100%

    enum CurveType {
        NONE,
        METAPOOL3,
        COINS2,
        COINS3,
        COINS4
    }

    struct StrategyParams {
        address strategy;
        uint256 pid;
        string symbol;
    }

    struct Vault {
        address vaultAddress;
        address lptoken;
        CurveType poolType;
        address deposit;
        bool isLendingPool;
        bool isSUSD;
    }

    struct CustomPool {
        address deposit;
        bool isLendingPool;
        bool isSUSD;
    }

    mapping(address => CurveType) public curveRegistry;
    mapping(address => StrategyParams) public vaultStrategies;

    ///////////////////////////////////
    //
    //  Storage variables and setters
    //
    ////////////////////////////////////

    mapping(address => Vault) public deployedVaults; //for ZAP V1

    // pools, deposit contracts
    mapping(address => CustomPool) public customPools;

    IBooster public booster;

    address public owner;
    address internal pendingOwner;

    event NewVault(
        address indexed lpToken,
        address gauge,
        address indexed vault,
        address strategy,
        uint8 poolType
    );

    error VaultDoesntExist();
    error BalanceIsZero();

    mapping(address => ICurveFi) public zapContract;

    event Log(address test);
    event LogUint8(uint8 v);
    event LogUint(uint256 v);

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
        address _owner,
        address _convexPoolManager,
        address _booster
    ) public initializer {
        registry = IRegistry(_registry);

        owner = _owner;

        depositLimit = 10_000_000_000_000 * 1e18; // some large number

        keeper = _keeper;

        treasury = _owner;

        guardian = _owner;

        management = _owner;

        governance = _owner;

        convexPoolManager = _convexPoolManager;

        booster = IBooster(_booster);

        depositFee = 50;

        zapFee = 5;

        initCustomPools();
    }

    function initCustomPools() internal {
        //----------------------------------------------------------------------
        // LENDING POOLS
        //NEW API
        //AAVE
        /*customPools[0xFd2a8fA60Abd58Efe3EeE34dd494cD491dC14900] = CustomPool(
            0xDeBF20617708857ebe4F679508E7b7863a8A8EeE,
            true,
            false
        );

        // IRON BANK
        customPools[0x5282a4eF67D9C33135340fB3289cc1711c13638C] = CustomPool(
            0x2dded6Da1BF5DBdF597C45fcFaa3194e53EcfeAF,
            true,
            false
        );

        //OLD API
        // BUSD
        customPools[0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B] = CustomPool(
            0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB,
            true,
            false
        );

        //compound
        customPools[0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2] = CustomPool(
            0xeB21209ae4C2c9FF2a86ACA31E123764A3B6Bc06,
            true,
            false
        );

        //PAX

        customPools[0xD905e2eaeBe188fc92179b6350807D8bd91Db0D8] = CustomPool(
            0xA50cCc70b6a011CffDdf45057E39679379187287,
            true,
            false
        );

        //USDT

        customPools[0x9fC689CCaDa600B6DF723D9E47D84d76664a1F23] = CustomPool(
            0xac795D2c97e60DF6a99ff1c814727302fD747a80,
            true,
            false
        );

        //yDAI

        customPools[0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8] = CustomPool(
            0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3,
            true,
            false
        );

        //----------------------------------------------------------------------
        //SUSD

        customPools[0xC25a3A3b969415c80451098fa907EC722572917F] = CustomPool(
            0xFCBa3E75865d2d561BE8D220616520c171F12851,
            false,
            true
        );

        // 3CRV
        customPools[0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490] = CustomPool(
            0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7,
            false,
            true
        );*/

        //GUSD POOL
        /*zapContract[CurveType.METAPOOL3_3CRV] = ICurveFi(
            0xA79828DF1850E8a3A3064576f380D90aECDD3359
        );
        zapContract[] = ICurveFi(
            0x7AbDBAf29929e7F8621B757D2a7c04d78d633834
        );
        */
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

        address lptoken = ICurveGauge(_gauge).lp_token();

        CurveType poolType = curveRegistry[lptoken];

        require(poolType != CurveType.NONE);

        uint256 pid = _getConvexPid(_gauge);

        vault = _createVault(lptoken);

        _recordVault(vault, poolType, lptoken);

        strategy = _createStrategy(lptoken, pid, _swapPath);


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

        if (
            _poolType != CurveType.METAPOOL3 &&
            customPools[_lptoken].deposit == address(0x0)
        ) {
            if (checkLatestCurveAPI(_lptoken)) {
                deposit = _lptoken;
            } else {
                deposit = ICurveFi(_lptoken).minter();
            }
        }

        if (customPools[_lptoken].deposit != address(0x0)) {
            deposit = customPools[_lptoken].deposit;
            isLendingPool = customPools[_lptoken].isLendingPool;
        }

        deployedVaults[_lptoken] = Vault(
            _vault,
            _lptoken,
            _poolType,
            deposit,
            isLendingPool,
            customPools[_lptoken].isSUSD
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
        emit Log(governance);
        v.setManagement(management);
        v.setGovernance(governance);
        v.setDepositLimit(depositLimit);
        v.setDepositFee(depositFee);
    }

    function _createStrategy(
        address _lptoken,
        uint256 _pid,
        bytes memory _swapPath
    ) internal returns (address strategy) {
        Vault memory v = deployedVaults[_lptoken];

        string memory symbol = IDetails(_lptoken).name();

        symbol = string(abi.encodePacked("bauConvex", symbol));

        StrategyParams memory params = StrategyParams({
            strategy: address(0),
            pid: _pid,
            symbol: symbol
        });

        vaultStrategies[v.vaultAddress] = params;

        strategy = _deployStrategy(_lptoken, _swapPath);

        vaultStrategies[v.vaultAddress].strategy = strategy;
    }

    function _deployStrategy(
        address _lptoken,
        bytes memory _swapPath
    ) internal returns (address strategy) {
        Vault memory v = deployedVaults[_lptoken];

        strategy = IStrategy(convexStratImplementation[v.poolType]).clone(
            v.vaultAddress,
            management,
            treasury,
            keeper,
            address(this),
            _swapPath
        );

        if (
            v.poolType == CurveType.METAPOOL3
        ) {
            require(address(zapContract[_lptoken]) != address(0x0), "wrong zap");

            IStrategy(strategy).setZapContract(
                address(zapContract[_lptoken])
            );
        }
    }

    function _addStrategyToVault(address _vault, address _strategy) internal {
        IVault v = IVault(_vault);

        v.addStrategy(_strategy, 10_000, 0, type(uint256).max);
        emit Log(_strategy);
    }

    ///////////////////////////////////
    //
    // Adapter
    //
    ////////////////////////////////////

    // get target coin for add liquidity

    // add liquidity for targetAmount with targetCoin, global targetCoin index variable

    function vaultAddress(
        address _lptoken
    ) external view returns (address vault) {
        Vault storage v = deployedVaults[_lptoken];
        vault = v.vaultAddress;
    }

    function targetCoin(
        address _lptoken
    ) public view returns (address token, uint256 index) {
        Vault memory v = deployedVaults[_lptoken];
        StrategyParams memory s = vaultStrategies[v.vaultAddress];

        token = IStrategy(s.strategy).targetCoin();
        index = IStrategy(s.strategy).targetCoinIndex();
    }

    function deposit(
        address _lptoken,
        uint256 _targetAmount,
        address _recipient
    ) external override {
        Vault memory v = deployedVaults[_lptoken];

        address vault = v.vaultAddress;

        if (v.poolType == CurveType.NONE) {
            revert VaultDoesntExist();
        }

        uint256 tokenBalanceBefore = IERC20(_lptoken).balanceOf(address(this));

        (address targetToken, uint256 index) = targetCoin(_lptoken);

        IERC20(targetToken).transferFrom(
            msg.sender,
            address(this),
            _targetAmount
        );


        if (v.poolType == CurveType.METAPOOL3) {
            IERC20(targetToken).approve(
                address(zapContract[_lptoken]),
                _targetAmount
            );
        } else {
            IERC20(targetToken).approve(
                v.deposit,
                _targetAmount
            );
        }
        if (
            v.poolType == CurveType.METAPOOL3
        ) {
            _depositToMETAPOOL3(
                _lptoken,
                targetToken,
                index,
                _targetAmount
            );
        } else if (v.poolType == CurveType.COINS2) {
            _depositTo2Pool(v.deposit, targetToken, index, _targetAmount);
        } else if (v.poolType == CurveType.COINS3) {
            _depositTo3Pool(v.deposit, targetToken, index, _targetAmount);
        } else if (v.poolType == CurveType.COINS4) {
            _depositTo4Pool(v.deposit, targetToken, index, _targetAmount);
        }

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

    function _depositToMETAPOOL3(
        address _token,
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


        zapContract[_token].add_liquidity(_token, coins, 0);
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

    function withdraw(
        address _lptoken,
        uint256 _shareAmount,
        address _recipient
    ) external override {
        Vault memory v = deployedVaults[_lptoken];

        (address targetToken, uint256 index) = targetCoin(_lptoken);

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
            _lptoken,
            _shareAmount
        );

        _withdrawFromProtocol(
            _lptoken,
            targetToken,
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

        if (vaultTokenBalanceAfter > 0) {
            IERC20(_vault).safeTransfer(msg.sender, vaultTokenBalanceAfter);
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
            v.poolType == CurveType.METAPOOL3
        ) {
            _withdrawFromMETAPOOL3(
                _token,
                _index,
                _lptokenAmount,
                _recipient
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

    function _withdrawFromMETAPOOL3(
        address _token,
        uint256 _index,
        uint256 _shareAmount,
        address _recipient
    ) internal {

        (bool success,) = address(zapContract[_token]).call(abi.encodeWithSignature("remove_liquidity_one_coin(address,address,int128, uint256, address)", _token,
                _shareAmount,
                int128(int256(_index)),
                0,
                _recipient));

        if (!success) {
            zapContract[_token].remove_liquidity_one_coin(
                _token,
                _shareAmount,
                _index,
                0,
                _recipient
            );
        }
    }

    function _withdrawFromPool(
        address _minter,
        uint256 _index,
        uint256 _shareAmount
    ) internal {

        (bool success,) = _minter.call(abi.encodeWithSignature("remove_liquidity_one_coin(address,int128, uint256)", _shareAmount, int128(int256(_index)), 0));

        if (!success) {
            ICurveFi(_minter).remove_liquidity_one_coin(
                _shareAmount,
                _index,
                0
            );
        }
    }

    function _takeZapFee(
        address _token,
        uint256 _amount
    ) internal returns (uint256 targetAmount) {
        uint256 amountFee = (_amount * zapFee) / MAX_BPS;

        IERC20(_token).safeTransfer(treasury, amountFee);

        targetAmount = _amount - amountFee;
    }

    function setZapContract(
        address _lptoken,
        address _zapContract
    ) external {
        require(msg.sender == owner);

        zapContract[_lptoken] = ICurveFi(_zapContract);
    }

    function setCustomPool(
        address _lptoken,
        address _deposit,
        bool _isLendingPool,
        bool _isSUSD
    ) external {
        // CustomPools Map
        customPools[_lptoken] = CustomPool(_deposit, _isLendingPool, _isSUSD);
    }

    function checkLatestCurveAPI(
        address _contractAddress
    ) public view returns (bool) {
        bytes4 selector = bytes4(keccak256("A()"));
        bool success;
        bytes memory data = abi.encodeWithSelector(selector);

        assembly {
            success := staticcall(
                gas(), // gas remaining
                _contractAddress, // destination address
                add(data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
                mload(data), // input length (loaded from the first 32 bytes in the `data` array)
                0, // output buffer
                0 // output length
            )
        }
        return false;
    }

    function changeGovernanceForPending(address _lptoken, address _newGovernance) external {
        require(msg.sender == owner, "not owner");
        Vault storage v = deployedVaults[_lptoken];
        require(IVault(v.vaultAddress).governance() == msg.sender, "governance already changed");
        IVault(v.vaultAddress).setGovernance(_newGovernance);
    }
}
