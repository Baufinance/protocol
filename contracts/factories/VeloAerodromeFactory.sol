// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IFactoryAdapter.sol";
import "../interfaces/IRegistry.sol";
import "../interfaces/Velodrome/IVelodromeRouter.sol";
import "../interfaces/Velodrome/IVelodromePool.sol";

contract VeloAerodromeFactory is Initializable, IFactoryAdapter {

  mapping(address => IVelodromeRouter.Routes[]) public veloRegistryForToken0;
  mapping(address => IVelodromeRouter.Routes[]) public veloRegistryForToken1;


  /// @notice This is a list of all vaults deployed by this factory.
  address[] public deployedVaults;


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
        address _velo
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
  }

  function isVaultExists(address _token) external view returns (bool) {

  }

  function targetCoin(
        address _token
  ) external view returns (address coin, uint256 index) {

  }

  function vaultAddress(address lptoken) external view returns (address) {

  }


  function createNewVaultsAndStrategies(
        address _gauge
    ) external returns (address vault, address strategy) {
        return _createNewVaultsAndStrategies(_gauge);
  }

  function _createNewVaultsAndStrategies(address _gauge) internal returns(address vault, address strategy) {

  }

  // add liquidity for targetAmount
  function deposit(
      address _token,
      uint256 _targetAmount,
      address _recipient
  ) external {

  }

  function withdraw(
      address _token,
      uint256 _shareAmount,
      address _recipient
  ) external {

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

    function setDepositLimit(uint256 _depositLimit) external {
        require(msg.sender == owner || msg.sender == management);
        depositLimit = _depositLimit;
    }

    function setVelodromeStratImplementation(
        address _velodromeStratImplementation
    ) external {
        require(msg.sender == owner);
        velodromeStratImplementation = _velodromeStratImplementation;
    }

    function setDepositFee(uint256 _depositFee) external {
        require(msg.sender == owner);
        require(_depositFee <= 10_000);
        depositFee = _depositFee;
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
            poolToken0 !=
            _swapRouteForToken0[_swapRouteForToken0.length - 1].to
        ) {
            revert("token0 route error");
        }

        if (
            poolToken1 != velo &&
            poolToken1 !=
            _swapRouteForToken1[_swapRouteForToken0.length - 1].to
        ) {
            revert("token1 route error");
        }

    }
}