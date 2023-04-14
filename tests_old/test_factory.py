import brownie
from brownie import Contract
from brownie import config
import math

def test_factory(pm, factory, strategist, toke_gauge, StrategyConvex3CrvRewardsClonable, tokenVault, whale, chain, keeper_wrapper,
        common_health_check,
        base_fee_oracle, registry, gasOracle):

  print(factory)

  f = factory.createNewVaultsAndStrategies(toke_gauge, False, {"from": strategist})

  v = factory.deployedVaults(0)

  Vault = pm(config["dependencies"][0]).Vault

  vault = Vault.at(v)

  vault.acceptGovernance({"from": strategist})

  strat =  vault.withdrawalQueue(0)

  strategy = StrategyConvex3CrvRewardsClonable.at(strat)


  assert strategy.vault() == vault
  assert vault.token() == strategy.want()
  assert vault.token() == strategy.curve()

  strategy.setBaseFeeOracle(gasOracle,{"from": strategist})

  tokenVault.approve(vault, 2 ** 256 - 1, {"from": whale})


  amount = 35_000e18

  vault.deposit(amount, {"from": whale})

  balance = tokenVault.balanceOf(vault)

  # change our optimal deposit asset
  strategy.setOptimal(0, {"from": strategist})

  strategy.updateRewards(True, 0, {"from": strategist})

  keeper_wrapper.harvestStrategy(strategy, {"from": strategist})


  balance2 = tokenVault.balanceOf(vault)

  assert balance2 == 0

  strategy_balance = strategy.stakedBalance()

  assert strategy_balance > 0
  keeper_wrapper.harvestStrategy(strategy, {"from": strategist})

  strategy_balance2 = strategy.stakedBalance()

  assert strategy_balance2 > 0
  strategy.setForceHarvestTriggerOnce(True, {"from": strategist})

  chain.sleep(1)
  keeper_wrapper.harvestStrategy(strategy, {"from": strategist})
  chain.sleep(1)
