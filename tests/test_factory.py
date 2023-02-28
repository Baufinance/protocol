import brownie
from brownie import Contract
from brownie import config
import math

def test_factory(pm, factory, strategist, toke_gauge, StrategyConvex3CrvRewardsClonable, tokenVault, whaleF, chain, keeper_wrapper,
        common_health_check,
        base_fee_oracle):

  print(factory)

  f = factory.createNewVaultsAndStrategies(toke_gauge, False, {"from": strategist})

  (v, strat) = f.return_value

  Vault = pm(config["dependencies"][0]).Vault

  vault = Vault.at(v)

  vault.acceptGovernance({"from": strategist})
  strategy = StrategyConvex3CrvRewardsClonable.at(strat)

  strategy.setHealthCheck(common_health_check, {"from": strategist})
  strategy.setBaseFeeOracle(base_fee_oracle, {"from": strategist})

  assert strategy.vault() == vault
  assert vault.token() == strategy.want()
  assert vault.token() == strategy.curve()

  tokenVault.approve(vault, 2 ** 256 - 1, {"from": whaleF})
  amount = tokenVault.balanceOf(whaleF)

  vault.deposit(amount, {"from": whaleF})

  # change our optimal deposit asset
  strategy.setOptimal(0, {"from": strategist})
  keeper_wrapper.harvestStrategy(strategy, {"from": strategist})


  chain.sleep(3600)
  chain.mine(1)


  chain.sleep(1)
  keeper_wrapper.harvestStrategy(strategy, {"from": strategist})
  chain.sleep(1)
