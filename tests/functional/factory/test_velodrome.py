import pytest
from brownie import *
DAY = 86400  # seconds

ETH = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"

@pytest.fixture
def common_health_check(gov, CommonHealthCheck):
    yield gov.deploy(CommonHealthCheck)



def test_velodrome_vault_factory_deposit_withdraw(chain, common_health_check, base_fee_oracle,velodrome_factory, velodrome_router, gov, velo, registry, vault_template):
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

    v = velodrome_factory.deployedVaults(pool)

    vault_address = v[0]

    vault = Vault.at(vault_address)

    strategy_address = vault.withdrawalQueue(0)

    strategy = TestStrategyVeloAerdromeClonable.at(strategy_address)

    strategy.setInternal(
        common_health_check,
        base_fee_oracle,
        {
            "from":gov
        }
    )

    token0.approve(velodrome_router, 1_000_000_000*10**18, {"from":gov})
    token1.approve(velodrome_router, 1_000_000_000*10**18, {"from":gov})

    velodrome_router.addLiquidity(
        token0,
        token1,
        False,
        1000*10**18,
        1000*10**18,
        0,
        0,
        gov,
        10,
        {"from":gov}
    )

    pool_balance_before = pool.balanceOf(gov)

    assert pool_balance_before > 0

    pool.approve(vault, pool_balance_before, {"from":gov})

    vault.deposit({"from": gov})

    vault_token_balance  = vault.balanceOf(gov)

    vault_token_balance > 0

    lp_token_vault_balance = pool.balanceOf(vault)

    assert lp_token_vault_balance > 0

    strategy.harvest({"from":gov})

    lp_token_vault_balance = pool.balanceOf(vault)

    assert lp_token_vault_balance == 0

    gauge_pool_balance = pool.balanceOf(gauge)

    assert gauge_pool_balance > 0

    tx = strategy.harvest({"from":gov})

    print(tx.events)

    chain.mine(timestamp=chain.time() + DAY)

    vault.withdraw({"from": gov})

    pool_balance_after = pool.balanceOf(gov)
    assert pool_balance_after > pool_balance_before



def test_velodrome_factory_deposit_withdraw(chain, common_health_check, base_fee_oracle,velodrome_factory, velodrome_router, gov, velo, registry, vault_template, treasury):
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

    v = velodrome_factory.deployedVaults(pool)

    vault_address = v[0]

    vault = Vault.at(vault_address)

    strategy_address = vault.withdrawalQueue(0)

    strategy = TestStrategyVeloAerdromeClonable.at(strategy_address)

    strategy.setInternal(
        common_health_check,
        base_fee_oracle,
        {
            "from":gov
        }
    )

    token0.approve(velodrome_router, 1_000_000_000*10**18, {"from":gov})
    token1.approve(velodrome_router, 1_000_000_000*10**18, {"from":gov})

    velodrome_router.addLiquidity(
        token0,
        token1,
        False,
        1000*10**18,
        1000*10**18,
        0,
        0,
        gov,
        10,
        {"from":gov}
    )

    pool_balance_before = pool.balanceOf(gov)

    assert pool_balance_before > 0

    pool.approve(vault, pool_balance_before, {"from":gov})

    token0.approve(velodrome_factory, 1_000*10**18, {"from":gov})
    token1.approve(velodrome_factory, 1_000*10**18, {"from":gov})

    token0.mint(1_000*10**18, gov)
    token1.mint(1_000*10**18, gov)


    velodrome_factory.setTreasury(treasury)

    velodrome_factory.deposit(pool, 1_000*10**18, gov, {"from":gov})

    treasury_balance = vault.balanceOf(treasury)
    assert treasury_balance > 0

    vault_token_balance  = vault.balanceOf(gov)

    vault_token_balance > 0

    lp_token_vault_balance = pool.balanceOf(vault)

    assert lp_token_vault_balance > 0


    strategy.harvest({"from":gov})

    lp_token_vault_balance = pool.balanceOf(vault)

    assert lp_token_vault_balance == 0

    gauge_pool_balance = pool.balanceOf(gauge)

    assert gauge_pool_balance > 0

    tx = strategy.harvest({"from":gov})


    chain.mine(timestamp=chain.time() + DAY)

    vault.approve(velodrome_factory, pool_balance_before, {"from": gov})

    token0.mint(1_000_000_000*10**18, velodrome_router)
    token1.mint(1_000_000_000*10**18, velodrome_router)

    token0_balance_before = token0.balanceOf(gov)

    velodrome_factory.withdraw(pool, vault_token_balance, gov, {"from":gov})

    token0_balance_after = token0.balanceOf(gov)

    assert token0_balance_after - token0_balance_before
