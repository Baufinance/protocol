import pytest
from brownie import *
import brownie

DAY = 86400  # seconds

ETH = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"

@pytest.fixture
def common_health_check(gov, CommonHealthCheck):
    yield gov.deploy(CommonHealthCheck)


def test_cannot_add_gauge_twice(chain, treasury, common_health_check, base_fee_oracle,velodrome_factory, velodrome_router, gov, velo, registry, vault_template):
    token0 = gov.deploy(Token, 18)
    token1 = gov.deploy(Token, 18)

    pool = gov.deploy(VelodromePoolMock, False, token0, token1)
    velodrome_router.addPool(token0, token1, pool, False)

    token0.mint(1_000_000_000*10**18, velodrome_router)
    token1.mint(1_000_000_000*10**18, velodrome_router)
    velo.mint(1_000_000_000*10**18, velodrome_router)

    registry.newRelease(vault_template)

    gauge = gov.deploy(VelodromeGaugeMock, velo, pool)

    velo.mint(1_000_000_000*10**18, gauge)


    pool_velo_token0 = gov.deploy(VelodromePoolMock, False, velo, token0)
    pool_velo_token1 = gov.deploy(VelodromePoolMock, False, velo, token1)

    velodrome_router.addPool(velo, token0, pool_velo_token0, False)
    velodrome_router.addPool(velo, token1, pool_velo_token1, False)

    velodrome_factory.setVeloPoolToRegistry(
      pool,
      [[velo, token0, False, gov]],
      [[velo, token1, False, gov]],
    )

    velodrome_factory.createNewVaultsAndStrategies(gauge)

    with brownie.reverts():
      velodrome_factory.createNewVaultsAndStrategies(gauge)


def test_can_add_pool_twice_with_new_release(patch_vault_version, chain, treasury, common_health_check, base_fee_oracle,velodrome_factory, velodrome_router, gov, velo, registry, vault_template):
    token0 = gov.deploy(Token, 18)
    token1 = gov.deploy(Token, 18)

    pool = gov.deploy(VelodromePoolMock, False, token0, token1)
    velodrome_router.addPool(token0, token1, pool, False)

    token0.mint(1_000_000_000*10**18, velodrome_router)
    token1.mint(1_000_000_000*10**18, velodrome_router)
    velo.mint(1_000_000_000*10**18, velodrome_router)

    registry.newRelease(vault_template)

    gauge = gov.deploy(VelodromeGaugeMock, velo, pool)

    velo.mint(1_000_000_000*10**18, gauge)


    pool_velo_token0 = gov.deploy(VelodromePoolMock, False, velo, token0)
    pool_velo_token1 = gov.deploy(VelodromePoolMock, False, velo, token1)

    velodrome_router.addPool(velo, token0, pool_velo_token0, False)
    velodrome_router.addPool(velo, token1, pool_velo_token1, False)

    velodrome_factory.setVeloPoolToRegistry(
      pool,
      [[velo, token0, False, gov]],
      [[velo, token1, False, gov]],
    )

    velodrome_factory.createNewVaultsAndStrategies(gauge)

    with brownie.reverts():
      velodrome_factory.createNewVaultsAndStrategies(gauge)

    vault_template_2 = VaultT.deploy({"from": gov})

    registry.newRelease(vault_template_2)

    velodrome_factory.createNewVaultsAndStrategies(gauge)





def test_add_to_registry_only_from_owner(chain, treasury, common_health_check, base_fee_oracle,velodrome_factory, velodrome_router, gov, velo, registry, vault_template):
    token0 = gov.deploy(Token, 18)
    token1 = gov.deploy(Token, 18)

    pool = gov.deploy(VelodromePoolMock, False, token0, token1)
    velodrome_router.addPool(token0, token1, pool, False)

    token0.mint(1_000_000_000*10**18, velodrome_router)
    token1.mint(1_000_000_000*10**18, velodrome_router)
    velo.mint(1_000_000_000*10**18, velodrome_router)

    registry.newRelease(vault_template)

    gauge = gov.deploy(VelodromeGaugeMock, velo, pool)

    velo.mint(1_000_000_000*10**18, gauge)


    pool_velo_token0 = gov.deploy(VelodromePoolMock, False, velo, token0)
    pool_velo_token1 = gov.deploy(VelodromePoolMock, False, velo, token1)

    velodrome_router.addPool(velo, token0, pool_velo_token0, False)
    velodrome_router.addPool(velo, token1, pool_velo_token1, False)

    with brownie.reverts():
      velodrome_factory.setVeloPoolToRegistry(
        pool,
        [[velo, token0, False, gov]],
        [[velo, token1, False, gov]],
        {"from":treasury}
      )


def test_add_set_implementation_only_from_owner(treasury, gov, velodrome_factory):
    strategy_2 = gov.deploy(TestStrategyVeloAerdromeClonable)

    with brownie.reverts():
      velodrome_factory.setVelodromeStratImplementation(strategy_2, {"from": treasury})




def test_set_fees_only_from_owner(treasury, chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 2 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(2, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve2PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy2coins = gov.deploy(TestStrategyConvex2CoinsRewardsClonable)

  with brownie.reverts():
    factory.setZapFee(10, {"from":treasury})

  with brownie.reverts():
    factory.setDepositFee(10, {"from":treasury})

  with brownie.reverts():
    factory.setDepositLimit(10, {"from":treasury})




def test_change_addresses_from_owner(treasury, chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 2 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(2, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve2PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy2coins = gov.deploy(TestStrategyConvex2CoinsRewardsClonable)

  with brownie.reverts():
    factory.setOwner(treasury, {"from":treasury})

  with brownie.reverts():
    factory.acceptOwner({"from":treasury})

  with brownie.reverts():
    factory.setConvexPoolManager(treasury, {"from":treasury})

  with brownie.reverts():
    factory.setRegistry(treasury, {"from":treasury})

  with brownie.reverts():
    factory.setGovernance(treasury, {"from":treasury})


  with brownie.reverts():
    factory.setManagement(treasury, {"from":treasury})

  with brownie.reverts():
    factory.setGuardian(treasury, {"from":treasury})

  with brownie.reverts():
    factory.setTreasury(treasury, {"from":treasury})

  with brownie.reverts():
    factory.setKeeper(treasury, {"from":treasury})


def test_zap_operations_from_owner(zap, treasury):
  with brownie.reverts():
    zap.setOwner(treasury, {"from":treasury})

  with brownie.reverts():
    zap.acceptOwner({"from":treasury})

  with brownie.reverts():
    zap.setAggregationRouterV5Address(treasury, {"from":treasury})

  with brownie.reverts():
    zap.addFactory(treasury, {"from":treasury})

  with brownie.reverts():
    zap.removeFactory(treasury, {"from":treasury})
