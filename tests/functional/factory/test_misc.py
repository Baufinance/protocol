import pytest
from brownie import Vault, Curve2PoolMock, GaugeMock, BaseRewardPoolMock, Curve2PoolMock, Curve3PoolMock, Curve4PoolMock, CurveMetaPoolMock, CurveZapMetaPoolMock, LPToken, Token, TestStrategyConvex2CoinsRewardsClonable

DAY = 86400  # seconds

@pytest.fixture
def common_health_check(gov, CommonHealthCheck):
    yield gov.deploy(CommonHealthCheck)

def test_create_2_coins_strategy(chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
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

  factory.setCurvePoolToRegistry(lp_token, 2, {"from": gov})

  swap_path = univ3_mock.setPath(weth, token1)

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  factory.createNewVaultsAndStrategies(gauge, swap_path)

  crvethpath = univ3_mock.setPath(weth, token1)

  cvx_token = gov.deploy(LPToken, 18)

  cvxweth = gov.deploy(Curve2PoolMock, [weth, cvx], cvx_token)

  weth.mint(10_000*10**18, {"from":gov})
  cvx.mint(10_000*10**18, {"from":gov})

  weth.approve(cvxweth, 10_000*10**18, {"from":gov})
  cvx.approve(cvxweth, 10_000*10**18, {"from":gov})

  cvxweth.add_liquidity([1_000*10**18, 1_000*10**18], 0, {"from": gov})

  weth.mint(10_000*10**18, univ3_mock, {"from":gov})
  cvx.mint(10_000*10**18, univ3_mock, {"from":gov})

  v = factory.deployedVaults(lp_token)

  vault_address = v[0]

  s = factory.vaultStrategies(vault_address)

  strategy_address = s[0]

  strategy = TestStrategyConvex2CoinsRewardsClonable.at(strategy_address)

  strategy.initializeStep2(
    common_health_check,
    base_fee_oracle,
    cvxweth,
    univ3_mock,
    crv,
    cvx,
    weth,
    univ2_mock,
    booster,
    crvethpath,
    {"from":gov}
  )

  strategy.setRewardTreshold(10**2, {"from": gov})

  vault = Vault.at(vault_address)

  curve_pool = Curve2PoolMock.at(pool_address)

  token1.mint(10_000*10**18, {"from":gov})
  token2.mint(10_000*10**18, {"from":gov})

  token1.approve(curve_pool, 1_000*10**18, {"from":gov})
  token2.approve(curve_pool, 1_000*10**18, {"from":gov})

  curve_pool.add_liquidity([1_000*10**18, 0], 0, {"from": gov})

  lp_token_balance_before = lp_token.balanceOf(gov)

  assert lp_token_balance_before > 0

  lp_token.approve(vault, 10_000*10**18, {"from":gov})

  vault.deposit({"from": gov})

  vault_token_balance  = vault.balanceOf(gov)

  vault_token_balance > 0

  lp_token_vault_balance = lp_token.balanceOf(vault)

  assert lp_token_vault_balance > 0

  strategy.harvest({"from":gov})

  lp_token_vault_balance = lp_token.balanceOf(vault)

  assert lp_token_vault_balance == 0

  pool_info = booster.poolInfo(0)

  rewards_contract_address = pool_info[3];

  rewards_contract = BaseRewardPoolMock.at(rewards_contract_address)

  assert strategy.rewardsContract() == rewards_contract

  lp_token_balance_booster_before = lp_token.balanceOf(booster)
  assert lp_token_balance_booster_before > 0

  assert rewards_contract.operator() == booster

  assert rewards_contract.lptoken() == lp_token


  staked_balance_before = strategy.stakedBalance()

  assert staked_balance_before > 0


  crv.mint(10_000*10**18, rewards_contract, {"from":gov})
  cvx.mint(10_000*10**18, rewards_contract, {"from":gov})


  assert rewards_contract.rewardToken() == crv
  assert rewards_contract.convexToken() == cvx

  assert crv.balanceOf(rewards_contract) > 0
  assert cvx.balanceOf(rewards_contract) > 0

  tx = strategy.harvest({"from":gov})

  assert crv.balanceOf(rewards_contract) > 0
  assert cvx.balanceOf(rewards_contract) > 0

  assert lp_token.balanceOf(vault) > 0

  chain.mine(timestamp=chain.time() + DAY)

  vault.withdraw({"from": gov})

  lp_token_balance_after = lp_token.balanceOf(gov)
  assert lp_token_balance_after > lp_token_balance_before




def test_create_2_coins_strategy_with_deposit_withdraw_in_target_coin(chain, treasury, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
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

  factory.setCurvePoolToRegistry(lp_token, 2, {"from": gov})

  swap_path = univ3_mock.setPath(weth, token1)

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  factory.createNewVaultsAndStrategies(gauge, swap_path)

  crvethpath = univ3_mock.setPath(weth, token1)

  cvx_token = gov.deploy(LPToken, 18)

  cvxweth = gov.deploy(Curve2PoolMock, [weth, cvx], cvx_token)

  weth.mint(10_000*10**18, {"from":gov})
  cvx.mint(10_000*10**18, {"from":gov})

  weth.approve(cvxweth, 10_000*10**18, {"from":gov})
  cvx.approve(cvxweth, 10_000*10**18, {"from":gov})

  cvxweth.add_liquidity([1_000*10**18, 1_000*10**18], 0, {"from": gov})

  weth.mint(10_000*10**18, univ3_mock, {"from":gov})
  cvx.mint(10_000*10**18, univ3_mock, {"from":gov})

  v = factory.deployedVaults(lp_token)

  vault_address = v[0]

  s = factory.vaultStrategies(vault_address)

  strategy_address = s[0]

  strategy = TestStrategyConvex2CoinsRewardsClonable.at(strategy_address)

  strategy.initializeStep2(
    common_health_check,
    base_fee_oracle,
    cvxweth,
    univ3_mock,
    crv,
    cvx,
    weth,
    univ2_mock,
    booster,
    crvethpath,
    {"from":gov}
  )

  strategy.setRewardTreshold(10**2, {"from": gov})

  vault = Vault.at(vault_address)

  curve_pool = Curve2PoolMock.at(pool_address)

  token1.mint(10_000*10**18, {"from":gov})
  token2.mint(10_000*10**18, {"from":gov})

  token1.approve(factory, 1_000*10**18, {"from":gov})
  token2.approve(factory, 1_000*10**18, {"from":gov})

  factory.setTreasury(treasury)

  factory.deposit(lp_token, 1_000*10**18, gov, {"from":gov})

  token_balance_before = token1.balanceOf(gov)

  vault_token_balance  = vault.balanceOf(gov)

  assert vault_token_balance > 0

  treasury_vault_token_balance = vault.balanceOf(treasury)

  assert treasury_vault_token_balance > 0

  strategy.harvest({"from":gov})

  lp_token_vault_balance = lp_token.balanceOf(vault)

  assert lp_token_vault_balance == 0

  pool_info = booster.poolInfo(0)

  rewards_contract_address = pool_info[3];

  rewards_contract = BaseRewardPoolMock.at(rewards_contract_address)

  assert strategy.rewardsContract() == rewards_contract

  lp_token_balance_booster_before = lp_token.balanceOf(booster)
  assert lp_token_balance_booster_before > 0

  assert rewards_contract.operator() == booster

  assert rewards_contract.lptoken() == lp_token


  staked_balance_before = strategy.stakedBalance()

  assert staked_balance_before > 0


  crv.mint(10_000*10**18, rewards_contract, {"from":gov})
  cvx.mint(10_000*10**18, rewards_contract, {"from":gov})


  assert rewards_contract.rewardToken() == crv
  assert rewards_contract.convexToken() == cvx

  assert crv.balanceOf(rewards_contract) > 0
  assert cvx.balanceOf(rewards_contract) > 0

  tx = strategy.harvest({"from":gov})

  assert crv.balanceOf(rewards_contract) > 0
  assert cvx.balanceOf(rewards_contract) > 0

  assert lp_token.balanceOf(vault) > 0

  chain.mine(timestamp=chain.time() + DAY)

  vault.approve(factory, vault_token_balance, {"from": gov})
  factory.withdraw(lp_token, vault_token_balance, gov, {"from":gov})

  token_balance_after = token1.balanceOf(gov)

  assert token_balance_after > token_balance_before
