// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import {IAggregationRouterV5, IAggregationExecutor} from "../interfaces/IAggregationRouterV5.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IFactoryAdapter.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Zap is Initializable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet internal _factories;

    address public owner;
    address internal pendingOwner;
    address public aggregationRouterV5;

    error InvalidToken(address token);
    error InvalidTokenAmount(uint256 tokenAmount);
    error InvalidReceiver(address receiver);

    function initialize(
        address _owner,
        address _aggregationRouterV5
    ) public initializer {
        owner = _owner;
        aggregationRouterV5 = _aggregationRouterV5;
    }

    function setOwner(address newOwner) external {
        require(msg.sender == owner);
        pendingOwner = newOwner;
    }

    function acceptOwner() external {
        require(msg.sender == pendingOwner);
        owner = pendingOwner;
    }

    function addFactory(address _factory) external {
        require(msg.sender == owner);
        _factories.add(_factory);
    }

    function removeFactory(address _factory) external {
        require(msg.sender == owner);
        _factories.remove(_factory);
    }

    function zap(
        address _srcToken,
        address _poolToken,
        uint256 _tokenAmount,
        bytes memory swapData
    ) external {
        // Get aggregation executor, swap params and the encoded calls for the executor from 1inch API call
        (
            address caller,
            IAggregationRouterV5.SwapDescription memory desc /* permit */,
            ,
            bytes memory data
        ) = abi.decode(
                swapData,
                (address, IAggregationRouterV5.SwapDescription, bytes, bytes)
            );

        (
            address factory,
            bool supported,
            address vault,
            address targetCoin
        ) = _getFactoryAddress(_poolToken, address(desc.srcToken));

        if (factory != address(0x0)) {
            IERC20(desc.srcToken).safeTransferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            );

            if (!supported) {
                if (_srcToken != address(desc.srcToken)) {
                    revert InvalidToken(_srcToken);
                }

                if (_tokenAmount != desc.amount) {
                    revert InvalidTokenAmount(_tokenAmount);
                }

                if (targetCoin != address(desc.dstToken)) {
                    revert InvalidToken(targetCoin);
                }

                if (desc.dstReceiver != address(this)) {
                    revert InvalidReceiver(desc.dstReceiver);
                }

                if (desc.srcReceiver != msg.sender) {
                    revert InvalidReceiver(msg.sender);
                }

                IERC20(desc.srcToken).approve(
                    address(aggregationRouterV5),
                    desc.amount
                );

                uint256 dstTokenBalanceBefore = IERC20(targetCoin).balanceOf(
                    address(this)
                );
                (uint256 amountOut, ) = IAggregationRouterV5(
                    aggregationRouterV5
                ).swap(IAggregationExecutor(caller), desc, new bytes(0), data);

                uint256 dstTokenBalance = IERC20(targetCoin).balanceOf(
                    address(this)
                ) - dstTokenBalanceBefore;

                require(dstTokenBalance > 0, "wrong swap");

                IERC20(desc.dstToken).approve(factory, dstTokenBalance);

                IFactoryAdapter(factory).deposit(
                    _poolToken,
                    dstTokenBalance,
                    msg.sender
                );

                IERC20(desc.dstToken).approve(factory, 0);
            } else {
                IERC20(_srcToken).approve(factory, _tokenAmount);
                IFactoryAdapter(factory).deposit(
                    _poolToken,
                    _tokenAmount,
                    msg.sender
                );

                IERC20(_srcToken).approve(factory, 0);
            }
        }
    }

    function unzap(
        address _dstToken,
        address _poolToken,
        uint256 _shareAmount,
        bytes memory swapData
    ) external {
        uint256 dstTokenBefore = IERC20(_dstToken).balanceOf(address(this));
        // Get aggregation executor, swap params and the encoded calls for the executor from 1inch API call
        (
            address caller,
            IAggregationRouterV5.SwapDescription memory desc /* permit */,
            ,
            bytes memory data
        ) = abi.decode(
                swapData,
                (address, IAggregationRouterV5.SwapDescription, bytes, bytes)
            );

        (
            address factory,
            bool supported,
            address vault,
            address targetCoin
        ) = _getFactoryAddress(_poolToken, address(_dstToken));

        if (factory != address(0x0)) {
            uint256 targetCoinBalance = _withdrawFromVault(
                vault,
                _poolToken,
                factory,
                targetCoin,
                _shareAmount
            );

            // transfer lp tokens
            if (!supported) {
                if (_dstToken != address(desc.dstToken)) {
                    revert InvalidToken(_dstToken);
                }

                if (desc.dstReceiver != address(this)) {
                    revert InvalidReceiver(desc.dstReceiver);
                }

                if (desc.srcReceiver != msg.sender) {
                    revert InvalidReceiver(msg.sender);
                }

                if (targetCoinBalance != desc.amount) {
                    desc.amount = targetCoinBalance;
                }

                IERC20(targetCoin).approve(aggregationRouterV5, desc.amount);

                (uint256 amountOut, ) = IAggregationRouterV5(
                    aggregationRouterV5
                ).swap(IAggregationExecutor(caller), desc, new bytes(0), data);
            }

            require(
                IERC20(_dstToken).balanceOf(address(this)) - dstTokenBefore > 0,
                "wrong swap"
            );

            IERC20(_dstToken).safeTransfer(
                msg.sender,
                IERC20(_dstToken).balanceOf(address(this)) - dstTokenBefore
            );
        }
    }

    function _withdrawFromVault(
        address _vault,
        address _poolToken,
        address _factory,
        address _targetCoin,
        uint256 _shareAmount
    ) internal returns (uint256 targetCoinBalance) {
        IERC20(_vault).safeTransferFrom(
            msg.sender,
            address(this),
            _shareAmount
        );

        IERC20(_vault).approve(_factory, _shareAmount);

        uint256 targetCoinBalanceBefore = IERC20(_targetCoin).balanceOf(
            address(this)
        );

        IFactoryAdapter(_factory).withdraw(
            _poolToken,
            _shareAmount,
            address(this)
        );

        uint256 targetCoinBalanceAfter = IERC20(_targetCoin).balanceOf(
            address(this)
        );

        targetCoinBalance = targetCoinBalanceAfter - targetCoinBalanceBefore;

        IERC20(_vault).approve(_factory, 0);

        // refund vault tokens
        uint256 shareBalanceAfter = IERC20(_vault).balanceOf(address(this));

        if (shareBalanceAfter > 0) {
            IERC20(_vault).safeTransfer(msg.sender, shareBalanceAfter);
        }
    }

    function _getFactoryAddress(
        address _poolToken,
        address _srcToken
    )
        internal
        view
        returns (
            address factory,
            bool supported,
            address vault,
            address targetCoin
        )
    {
        supported = true;

        for (uint256 i = 0; i < _factories.length(); i++) {
            factory = _factories.at(i);

            if (IFactoryAdapter(factory).isVaultExists(_poolToken)) {
                vault = IFactoryAdapter(factory).vaultAddress(_poolToken);

                // if pool doesnt exist it will be reverted
                (targetCoin, ) = IFactoryAdapter(factory).targetCoin(
                    _poolToken
                );

                if (_srcToken != targetCoin) {
                    supported = false;
                }
                break;
            }
        }
    }

    function sweepTokens(address _token, address _receiver) external {
        require(msg.sender == owner);

        uint256 balance = IERC20(_token).balanceOf(address(this));

        if (balance > 0) {
            IERC20(_token).safeTransfer(_receiver, balance);
        }
    }

    function setAggregationRouterV5Address(
        address _aggregationRouterV5
    ) external {
        require(msg.sender == owner);

        aggregationRouterV5 = _aggregationRouterV5;
    }
}
