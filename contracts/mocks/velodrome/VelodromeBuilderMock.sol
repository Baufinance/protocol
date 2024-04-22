// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "./VelodromeGaugeMock.sol";
import "./VelodromePoolMock.sol";
import "./VelodromeRouterMock.sol";
import "../Token2.sol";

contract VelodromeBuilderMock {
  VelodromeRouterMock public router;
  Token2 public velo;

  constructor(VelodromeRouterMock _router, Token2 _velo) {
      router = _router;
      velo = _velo;
  }

  event NewToken(address token);
  event NewGauge(address gauge);
  event NewPool(address pool);
  event PoolCreated(address indexed token0, address indexed token1, bool indexed stable, address pool, uint256);

  event GaugeCreated(
    address indexed poolFactory,
    address indexed votingRewardsFactory,
    address indexed gaugeFactory,
    address pool,
    address bribeVotingReward,
    address feeVotingReward,
    address gauge,
    address creator
    );

  function build(address _token0, address _token1, bool _stable) external {
    address pool = address(new VelodromePoolMock(_stable, _token0, _token1));
    emit NewPool(pool);

    emit PoolCreated(_token0, _token1, _stable, pool, 100);

    address gauge = address(new VelodromeGaugeMock(address(velo), pool));

    velo.mint(1_000_000 ether, gauge);

    emit NewGauge(gauge);

    emit GaugeCreated(address(this), address(this), address(this),pool, address(this), address(this), gauge, address(this));

    router.addPool(_token0, _token1, pool, _stable);

    Token2(_token0).mint(100_000 ether);
    Token2(_token1).mint(100_000 ether);

    Token2(_token0).approve(address(router),100_000 ether);
    Token2(_token1).approve(address(router),100_000 ether);

    router.addLiquidity(_token0, _token1, _stable, 100_000 ether, 100_000 ether,10,10, msg.sender, block.timestamp+100);
  }

  function createToken(string memory _name) external {
    address token = address(new Token2(_name, _name, 18));

    emit NewToken(token);
  }
}