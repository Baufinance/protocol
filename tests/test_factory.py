import brownie
from brownie import Contract
from brownie import config
import math

def test_factory(pm, factory, strategist, toke_gauge, strategy, StrategyConvex3CrvRewardsClonable):
  print(factory)

  f = factory.createNewVaultsAndStrategies(toke_gauge, False, {"from": strategist})

  (vault, strat) = f.return_value

  print(vault, strat)

  Vault = pm(config["dependencies"][0]).Vault

  v = Vault.at(vault)

  v.acceptGovernance({"from": strategist})
  strat = StrategyConvex3CrvRewardsClonable.at(strat)

  assert strat.vault() == v
  assert v.token() == strat.want()
  assert v.token() == strat.curve()
