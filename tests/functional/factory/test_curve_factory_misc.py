import pytest
from brownie import *
import brownie
DAY = 86400  # seconds

@pytest.fixture
def common_health_check(gov, CommonHealthCheck):
    yield gov.deploy(CommonHealthCheck)


def test_cannot_add_gauge_twice(chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
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

  factory.setConvexStratImplementation(2, strategy2coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 2, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  with brownie.reverts():
    factory.createNewVaultsAndStrategies(gauge)


def test_can_add_pool_twice_with_new_release(patch_vault_version, chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
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

  factory.setConvexStratImplementation(2, strategy2coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 2, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  vault_template_2 = patch_vault_version("2.0.0").deploy({"from": gov})

  registry.newRelease(vault_template_2)

  factory.createNewVaultsAndStrategies(gauge)


def test_add_to_registry_only_from_owner(treasury, chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
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

  factory.setConvexStratImplementation(2, strategy2coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  with brownie.reverts():
    factory.setCurvePoolToRegistry(lp_token, 2, swap_path, {"from": treasury})


def test_add_set_implementation_only_from_owner(treasury, chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
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
    factory.setConvexStratImplementation(2, strategy2coins, {"from": treasury})



def test_add_set_custom_pool_from_owner(treasury, chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
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
    factory.setCustomPool(lp_token, pool_address, True, False, {"from":treasury})


def test_add_set_zap_contract_from_owner(treasury, chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
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
    factory.setZapContract(lp_token, pool_address, {"from":treasury})


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
