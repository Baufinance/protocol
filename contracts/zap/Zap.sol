// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

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

    /**
     *  @notice 1Inch aggregation router v5
     */
    IAggregationRouterV5 private constant AGGREGATION_ROUTER_V5 =
        IAggregationRouterV5(0x1111111254EEB25477B68fb85Ed929f73A960582);

    address public owner;
    address internal pendingOwner;

    error InvalidToken(address token);
    error InvalidTokenAmount(uint256 tokenAmount);
    error InvalidReceiver(address receiver);

    function initialize(address _owner) public initializer {
        owner = _owner;
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

        (address factory, bool supported, ) = _getFactoryAddress(
            _poolToken,
            _srcToken
        );

        if (factory != address(0x0)) {
            IERC20(desc.srcToken).safeTransferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            );

            if (supported) {
                IERC20(_srcToken).approve(factory, _tokenAmount);
                IFactoryAdapter(factory).depositWithSupportedCoin(
                    _poolToken,
                    _srcToken,
                    _tokenAmount,
                    msg.sender
                );

                IERC20(_srcToken).approve(factory, 0);
            } else {
                if (_srcToken != address(desc.srcToken)) {
                    revert InvalidToken(_srcToken);
                }

                if (_tokenAmount != desc.amount) {
                    revert InvalidTokenAmount(_tokenAmount);
                }

                (address targetToken, , ) = IFactoryAdapter(factory).targetCoin(
                    _poolToken
                );

                if (targetToken != address(desc.dstToken)) {
                    revert InvalidToken(targetToken);
                }

                if (desc.dstReceiver != address(this)) {
                    revert InvalidReceiver(desc.dstReceiver);
                }

                IERC20(desc.srcToken).approve(
                    address(AGGREGATION_ROUTER_V5),
                    desc.amount
                );

                (uint256 amountOut, ) = AGGREGATION_ROUTER_V5.swap(
                    IAggregationExecutor(caller),
                    desc,
                    new bytes(0),
                    data
                );

                IERC20(targetToken).approve(factory, amountOut);

                IFactoryAdapter(factory).depositWithTargetCoin(
                    _poolToken,
                    amountOut,
                    msg.sender
                );

                IERC20(targetToken).approve(factory, 0);
            }
        }
    }

    function unzap(
        address _dstToken,
        address _poolToken,
        uint256 _shareAmount,
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

        (address factory, bool supported, address vault) = _getFactoryAddress(
            _poolToken,
            _dstToken
        );

        if (factory != address(0x0)) {
            IERC20(vault).safeTransferFrom(
                msg.sender,
                address(this),
                _shareAmount
            );

            IERC20(vault).approve(factory, _shareAmount);

            uint256 shareBalanceBefore = IERC20(vault).balanceOf(address(this));

            // transfer lp tokens
            if (supported) {
                IFactoryAdapter(factory).withdrawWithSupportedCoin(
                    _poolToken,
                    _dstToken,
                    _shareAmount,
                    msg.sender
                );

                //refund not burned tokens
            } else {
                if (_dstToken != address(desc.srcToken)) {
                    revert InvalidToken(_dstToken);
                }

                if (desc.dstReceiver != msg.sender) {
                    revert InvalidReceiver(desc.dstReceiver);
                }

                (address targetToken, , ) = IFactoryAdapter(factory).targetCoin(
                    _poolToken
                );

                uint256 targetTokenBalanceBefore = IERC20(targetToken)
                    .balanceOf(address(this));
                IFactoryAdapter(factory).withdrawWithTargetCoin(
                    _poolToken,
                    _shareAmount,
                    address(this)
                );
                uint256 targetTokenBalanceAfter = IERC20(targetToken).balanceOf(
                    address(this)
                );

                uint256 targetTokenBalance = targetTokenBalanceAfter -
                    targetTokenBalanceBefore;

                if (targetTokenBalance != desc.amount) {
                    desc.amount = targetTokenBalance;
                }

                IERC20(targetToken).approve(
                    address(AGGREGATION_ROUTER_V5),
                    desc.amount
                );

                (uint256 amountOut, ) = AGGREGATION_ROUTER_V5.swap(
                    IAggregationExecutor(caller),
                    desc,
                    new bytes(0),
                    data
                );
            }

            IERC20(vault).approve(factory, 0);

            // refund vault tokens
            uint256 shareBalanceAfter = IERC20(vault).balanceOf(address(this));

            uint256 withdrawShareBalance = shareBalanceBefore -
                shareBalanceAfter;

            if (withdrawShareBalance != _shareAmount) {
                uint256 refundBalance = _shareAmount - withdrawShareBalance;

                IERC20(vault).safeTransfer(msg.sender, refundBalance);
            }
        }
    }

    function _getFactoryAddress(
        address _poolToken,
        address _srcToken
    ) internal view returns (address factory, bool supported, address vault) {
        for (uint256 i = 0; i < _factories.length(); i++) {
            factory = _factories.at(i);

            if (IFactoryAdapter(factory).isVaultExists(_poolToken)) {
                // if pool doesnt exist it will be reverted
                (supported, , vault) = IFactoryAdapter(factory).supportedCoin(
                    _poolToken,
                    _srcToken
                );
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
}
