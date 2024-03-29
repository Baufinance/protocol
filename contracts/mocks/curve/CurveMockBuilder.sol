// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "./Curve2PoolMock.sol";
import "./Curve3PoolMock.sol";
import "./Curve4PoolMock.sol";
import "./CurveMetaPoolMock.sol";
import "../LPToken.sol";


interface ILPToken {
    function mint(uint256 _amount, address _recipient) external;
}

contract CurveMockBuilder {
    address public constant eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    enum CurveType {
        NONE,
        METAPOOL,
        COINS2,
        COINS3,
        COINS4
    }

    address[] public mocks;

    address public weth;

    constructor(address _weth) {
        weth = _weth;
    }

    function build(
        CurveType _curveType,
        bool _isETH
    ) public returns (address mock) {
        address token1;

        if (_isETH) {
            token1 = eth;
        } else {
            token1 = address(new LPToken(18));
        }

        address lpToken = address(new LPToken(18));

        if (_curveType == CurveType.METAPOOL) {
            address token2 = address(new LPToken(18));
            address token3 = address(new LPToken(18));
            address crv3 = address(
                new Curve3PoolMock([token1, token2, token3], lpToken)
            );

            if (!_isETH) {
                ILPToken(token1).mint(1_000_000 ether, crv3);
            }

            ILPToken(token2).mint(1_000_000 ether, crv3);
            ILPToken(token3).mint(1_000_000 ether, crv3);

            address token4 = address(new LPToken(18));

            mock = address(new CurveMetaPoolMock([token4, crv3]));

            ILPToken(token4).mint(1_000_000 ether, mock);
            ILPToken(lpToken).mint(1_000_000 ether, mock);
        }

        if (_curveType == CurveType.COINS2) {
            address token2 = address(new LPToken(18));

            mock = address(new Curve2PoolMock([token1, token2], lpToken));

            if (!_isETH) {
                ILPToken(token1).mint(1_000_000 ether, mock);
            }

            ILPToken(token2).mint(1_000_000 ether, mock);
        }

        if (_curveType == CurveType.COINS3) {
            address token2 = address(new LPToken(18));
            address token3 = address(new LPToken(18));

            mock = address(
                new Curve3PoolMock([token1, token2, token3], lpToken)
            );

            if (!_isETH) {
                ILPToken(token1).mint(1_000_000 ether, mock);
            }

            ILPToken(token2).mint(1_000_000 ether, mock);
            ILPToken(token3).mint(1_000_000 ether, mock);
        }

        if (_curveType == CurveType.COINS4) {
            address token2 = address(new LPToken(18));
            address token3 = address(new LPToken(18));
            address token4 = address(new LPToken(18));

            mock = address(
                new Curve4PoolMock([token1, token2, token3, token4], lpToken)
            );

            if (!_isETH) {
                ILPToken(token1).mint(1_000_000 ether, mock);
            }

            ILPToken(token2).mint(1_000_000 ether, mock);
            ILPToken(token3).mint(1_000_000 ether, mock);
            ILPToken(token4).mint(1_000_000 ether, mock);
        }

        LPToken(lpToken).setMinter(mock);

        mocks.push(mock);
    }


    function length() external view returns (uint256) {
        return mocks.length;
    }
}
