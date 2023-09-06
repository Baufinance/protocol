import pytest
from brownie import *
DAY = 86400  # seconds

ETH = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"

@pytest.fixture
def common_health_check(gov, CommonHealthCheck):
    yield gov.deploy(CommonHealthCheck)


def test_create_3_coins_strategy(chain, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 3 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(3, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve3PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))
  token3 = Token.at(pool.coins(2))

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy3coins = gov.deploy(TestStrategyConvex3CoinsRewardsClonable)

  factory.setConvexStratImplementation(3, strategy3coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 3, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  crvethpath = univ3_mock.setPath(crv, weth)

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

  vault = Vault.at(vault_address)

  strategy_address = vault.withdrawalQueue(0)

  strategy = TestStrategyConvex3CoinsRewardsClonable.at(strategy_address)

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

  curve_pool = Curve3PoolMock.at(pool_address)

  token1.mint(10_000*10**18, {"from":gov})
  token2.mint(10_000*10**18, {"from":gov})
  token3.mint(10_000*10**18, {"from":gov})

  token1.approve(curve_pool, 1_000*10**18, {"from":gov})
  token2.approve(curve_pool, 1_000*10**18, {"from":gov})
  token3.approve(curve_pool, 1_000*10**18, {"from":gov})

  curve_pool.add_liquidity([1_000*10**18, 0, 0], 0, {"from": gov})

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




def test_create_3_coins_strategy_with_deposit_withdraw_in_target_coin(chain, treasury, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 2 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(3, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve3PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy3coins = gov.deploy(TestStrategyConvex3CoinsRewardsClonable)


  factory.setConvexStratImplementation(3, strategy3coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 3, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  crvethpath = univ3_mock.setPath(crv, weth)

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

  vault = Vault.at(vault_address)

  strategy_address = vault.withdrawalQueue(0)

  strategy = TestStrategyConvex3CoinsRewardsClonable.at(strategy_address)

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

  curve_pool = Curve3PoolMock.at(pool_address)

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



def test_create_3_coins_strategy_with_deposit_withdraw_in_target_coin_and_vault_deposit_fee(chain, rewards, treasury, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 2 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(3, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve3PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy3coins = gov.deploy(TestStrategyConvex3CoinsRewardsClonable)

  factory.setConvexStratImplementation(3, strategy3coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 3, swap_path, {"from": gov})

  tx = factory.createNewVaultsAndStrategies(gauge)

  crvethpath = univ3_mock.setPath(crv, weth)

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

  vault = Vault.at(vault_address)

  strategy_address = vault.withdrawalQueue(0)

  strategy = TestStrategyConvex3CoinsRewardsClonable.at(strategy_address)

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

  curve_pool = Curve3PoolMock.at(pool_address)

  token1.mint(10_000*10**18, {"from":gov})
  token2.mint(10_000*10**18, {"from":gov})

  token1.approve(factory, 1_000*10**18, {"from":gov})
  token2.approve(factory, 1_000*10**18, {"from":gov})

  vault.acceptGovernance({"from":gov})

  vault.setDepositFee(100, {"from": gov})

  vault.setRewards(rewards, {"from": gov})

  factory.setTreasury(treasury)

  factory.deposit(lp_token, 1_000*10**18, gov, {"from":gov})

  token_balance_before = token1.balanceOf(gov)

  vault_token_balance  = vault.balanceOf(gov)

  vault_token_balance_rewards = vault.balanceOf(rewards)

  assert vault_token_balance_rewards > 0

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


def test_create_3_coins_strategy_with_deposit_withdraw_in_target_coin_and_vault_deposit_fee_and_zap_unzap_unsupported_coin(zap, aggregationRouter, chain, rewards, treasury, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 3 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(3, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve3PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))


  token1.mint(10_000*10**18, aggregationRouter, {"from": gov})
  token2.mint(10_000*10**18, aggregationRouter, {"from": gov})

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy3coins = gov.deploy(TestStrategyConvex3CoinsRewardsClonable)

  factory.setConvexStratImplementation(3, strategy3coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 3, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  crvethpath = univ3_mock.setPath(crv, weth)

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

  vault = Vault.at(vault_address)

  strategy_address = vault.withdrawalQueue(0)

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

  token1.mint(10_000*10**18, {"from":gov})
  token2.mint(10_000*10**18, {"from":gov})

  token_balance_before_1 = token2.balanceOf(gov)

  token1.approve(factory, 1_000*10**18, {"from":gov})
  token2.approve(factory, 1_000*10**18, {"from":gov})

  vault.acceptGovernance({"from":gov})

  vault.setDepositFee(100, {"from": gov})

  vault.setRewards(rewards, {"from": gov})

  factory.setTreasury(treasury)

  zap.addFactory(factory, {"from":gov})


  token2.approve(zap, 1_000*10**18, {"from":gov})

  data = aggregationRouter.encodeData([token2, token1, gov, zap, 500*10**18, 1000*10**18, 1])

  zap.zap(token2, lp_token, 500*10**18, data)

  assert token1.balanceOf(zap) == 0

  assert token2.balanceOf(zap) == 0

  token_balance_before_2 = token2.balanceOf(gov)

  assert token_balance_before_1 - token_balance_before_2 == 500*10**18

  vault_token_balance  = vault.balanceOf(gov)

  vault_token_balance_rewards = vault.balanceOf(rewards)

  assert vault_token_balance_rewards > 0

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


  vault.approve(zap, vault_token_balance, {"from": gov})

  data = aggregationRouter.encodeData([token1, token2, gov, zap, vault_token_balance, 500*10**18, 1])

  tx = zap.unzap(token2, lp_token, vault_token_balance, data)

  token_balance_after_3 = token2.balanceOf(gov)

  assert token_balance_after_3 > token_balance_before_2

  assert token1.balanceOf(zap)  == 0
  assert token2.balanceOf(zap)  == 0


def test_create_3_coins_strategy_with_deposit_withdraw_in_target_coin_and_vault_deposit_fee_and_zap_unzap_targetcoin(zap, aggregationRouter, chain, rewards, treasury, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 2 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(3, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve3PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))


  token1.mint(10_000*10**18, aggregationRouter, {"from": gov})
  token2.mint(10_000*10**18, aggregationRouter, {"from": gov})

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy3coins = gov.deploy(TestStrategyConvex3CoinsRewardsClonable)

  factory.setConvexStratImplementation(3, strategy3coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 3, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  crvethpath = univ3_mock.setPath(crv, weth)

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

  vault = Vault.at(vault_address)

  strategy_address = vault.withdrawalQueue(0)

  strategy = TestStrategyConvex3CoinsRewardsClonable.at(strategy_address)

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

  token1.mint(10_000*10**18, {"from":gov})
  token2.mint(10_000*10**18, {"from":gov})

  token_balance_before_1 = token1.balanceOf(gov)

  token1.approve(factory, 1_000*10**18, {"from":gov})
  token2.approve(factory, 1_000*10**18, {"from":gov})

  vault.acceptGovernance({"from":gov})

  vault.setDepositFee(100, {"from": gov})

  vault.setRewards(rewards, {"from": gov})

  factory.setTreasury(treasury)

  zap.addFactory(factory, {"from":gov})


  token1.approve(zap, 1_000*10**18, {"from":gov})

  data = aggregationRouter.encodeData([token1, token2, gov, zap, 500*10**18, 1000*10**18, 1])

  zap.zap(token1, lp_token, 500*10**18, data)

  token_balance_before_2 = token1.balanceOf(gov)

  assert token_balance_before_1 - token_balance_before_2 == 500*10**18

  vault_token_balance  = vault.balanceOf(gov)

  vault_token_balance_rewards = vault.balanceOf(rewards)

  assert vault_token_balance_rewards > 0

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


  vault.approve(zap, vault_token_balance, {"from": gov})

  data = aggregationRouter.encodeData([token1, token2, gov, gov, vault_token_balance, 500*10**18, 1])

  zap.unzap(token1, lp_token, vault_token_balance, data)

  token_balance_after_3 = token1.balanceOf(gov)

  assert token1.balanceOf(zap)  == 0
  assert token2.balanceOf(zap)  == 0

  assert token_balance_after_3 > token_balance_before_2



def test_create_3_coins_strategy_with_deposit_withdraw_in_target_coin_and_change_target_coin(chain, treasury, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 2 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(3, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve3PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  token2.mint(1000*10**18, univ3_mock, {"from": gov})

  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy2coins = gov.deploy(TestStrategyConvex3CoinsRewardsClonable)

  factory.setConvexStratImplementation(3, strategy2coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 3, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  crvethpath = univ3_mock.setPath(crv, weth)

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

  vault = Vault.at(vault_address)

  strategy_address = vault.withdrawalQueue(0)

  strategy = TestStrategyConvex3CoinsRewardsClonable.at(strategy_address)

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

  swap_path = univ3_mock.setPath(weth, token2)

  #target coin - token 2
  strategy.setOptimalTargetCoinIndex(1, swap_path, {"from":gov})

  assert strategy.targetCoin() == token2

  strategy.setRewardTreshold(10**2, {"from": gov})

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

  strategy.harvest({"from":gov})

  assert crv.balanceOf(rewards_contract) > 0
  assert cvx.balanceOf(rewards_contract) > 0

  assert lp_token.balanceOf(vault) > 0

  chain.mine(timestamp=chain.time() + DAY)

  vault.approve(factory, vault_token_balance, {"from": gov})

  token2_balance_before = 0

  assert token2_balance_before == 0

  factory.withdraw(lp_token, vault_token_balance, gov, {"from":gov})

  token2_balance_after = token2.balanceOf(gov)

  assert token2_balance_after > 0

def test_create_3_coins_strategy_with_deposit_withdraw_in_target_coin_as_eth(chain, treasury, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 2 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(3, True)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)


  pool = Curve3PoolMock.at(pool_address)


  token2 = Token.at(pool.coins(1))


  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  assert  pool.coins(0) == ETH

  token2.mint(1000*10**18, univ3_mock, {"from": gov})

  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy3coins = gov.deploy(TestStrategyConvex3CoinsRewardsClonable)

  factory.setConvexStratImplementation(3, strategy3coins, {"from": gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token2)

  factory.setCurvePoolToRegistry(lp_token, 3, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  crvethpath = univ3_mock.setPath(crv, weth)

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

  vault = Vault.at(vault_address)

  strategy_address = vault.withdrawalQueue(0)

  strategy = TestStrategyConvex3CoinsRewardsClonable.at(strategy_address)

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


  assert strategy.targetCoin() == token2

  swap_path = univ3_mock.setPath(weth, token2)

  #target coin - token 2
  strategy.setOptimalTargetCoinIndex(1, swap_path, {"from":gov})

  assert strategy.targetCoin() == token2

  strategy.setRewardTreshold(10**2, {"from": gov})

  token2.mint(10_000*10**18, {"from":gov})

  token2.approve(factory, 1_000*10**18, {"from":gov})

  factory.setTreasury(treasury)

  factory.deposit(lp_token, 1_000*10**18, gov, {"from":gov})

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

  strategy.harvest({"from":gov})

  assert crv.balanceOf(rewards_contract) > 0
  assert cvx.balanceOf(rewards_contract) > 0

  assert lp_token.balanceOf(vault) > 0

  chain.mine(timestamp=chain.time() + DAY)

  vault.approve(factory, vault_token_balance, {"from": gov})

  token2_balance_before = 0

  assert token2_balance_before == 0

  factory.withdraw(lp_token, vault_token_balance, gov, {"from":gov})

  token2_balance_after = token2.balanceOf(gov)

  assert token2_balance_after > 0



def test_create_3_coins_strategy_with_deposit_withdraw_in_target_coin_lending_pool_susd(chain, treasury, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 2 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(3, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve2PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy3coins = gov.deploy(TestStrategyConvex3CoinsRewardsClonable)

  factory.setConvexStratImplementation(3, strategy3coins, {"from": gov})

  factory.setCustomPool(lp_token, pool_address, True, False, {"from":gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 3, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  crvethpath = univ3_mock.setPath(crv, weth)

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

  vault = Vault.at(vault_address)

  strategy_address = vault.withdrawalQueue(0)

  strategy = TestStrategyConvex3CoinsRewardsClonable.at(strategy_address)

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

  strategy.harvest({"from":gov})

  assert crv.balanceOf(rewards_contract) > 0
  assert cvx.balanceOf(rewards_contract) > 0

  assert lp_token.balanceOf(vault) > 0

  chain.mine(timestamp=chain.time() + DAY)

  vault.approve(factory, vault_token_balance, {"from": gov})
  factory.withdraw(lp_token, vault_token_balance, gov, {"from":gov})

  token_balance_after = token1.balanceOf(gov)

  assert token_balance_after > token_balance_before

def test_create_3_coins_strategy_with_deposit_withdraw_in_target_coin_lending_pool(chain, treasury, common_health_check, base_fee_oracle,  cvx, crv, factory, curve_mock_builder, gov, weth, univ3_mock, univ2_mock, rewards_factory, booster, registry, vault_template):
  # try to build 2 pool with erc 20 tokens with plain and lending liquidity
  curve_mock_builder.build(3, False)

  pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

  pool = Curve3PoolMock.at(pool_address)

  token1 = Token.at(pool.coins(0))
  token2 = Token.at(pool.coins(1))

  lp_token = LPToken.at(pool.token())

  lp_token.setMinter(pool_address, {"from":gov})
  gauge = gov.deploy(GaugeMock, lp_token)

  token1.mint(1000*10**18, univ3_mock, {"from": gov})
  weth.mint(1000*10**18, univ3_mock, {"from": gov})

  strategy3coins = gov.deploy(TestStrategyConvex3CoinsRewardsClonable)

  factory.setConvexStratImplementation(3, strategy3coins, {"from": gov})

  factory.setCustomPool(lp_token, pool_address, True, True, {"from":gov})

  booster.setRewardFactory(rewards_factory)

  registry.newRelease(vault_template)

  swap_path = univ3_mock.setPath(weth, token1)

  factory.setCurvePoolToRegistry(lp_token, 3, swap_path, {"from": gov})

  factory.createNewVaultsAndStrategies(gauge)

  crvethpath = univ3_mock.setPath(crv, weth)

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

  vault = Vault.at(vault_address)

  strategy_address = vault.withdrawalQueue(0)

  strategy = TestStrategyConvex3CoinsRewardsClonable.at(strategy_address)

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


  strategy.harvest({"from":gov})

  assert crv.balanceOf(rewards_contract) > 0
  assert cvx.balanceOf(rewards_contract) > 0

  assert lp_token.balanceOf(vault) > 0

  chain.mine(timestamp=chain.time() + DAY)

  vault.approve(factory, vault_token_balance, {"from": gov})
  factory.withdraw(lp_token, vault_token_balance, gov, {"from":gov})

  token_balance_after = token1.balanceOf(gov)

  assert token_balance_after > token_balance_before
