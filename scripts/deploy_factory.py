from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

  load_dotenv(find_dotenv())

  acct = accounts.load("yield2")

  vault_template = os.getenv("VAULT_TEMPLATE")
  token_template = os.getenv("TOKEN_TEMPLATE")
  curve_pool_template = os.getenv("CURVE_POOL_TEMPLATE")
  pid_template = os.getenv("PID_TEMPLATE")

  keeper = os.getenv("KEEPER")
  owner = acct #os.getenv("OWNER")
  registry = os.getenv("REGISTRY")

  proxy_admin = os.getenv("PROXY_ADMIN")

  gauge_template = os.getenv("CURVE_GAUGE_TEMPLATE")


  print("--Strategy--")
  strategy_template = StrategyConvex3CrvRewardsClonable.deploy(vault_template, pid_template, curve_pool_template, "Convex Pool", {"from": acct}, publish_source=True)

  print("strategy", strategy_template)

  factory_impl = Factory.deploy({"from": acct}, publish_source=True)

  proxy = UtilProxy.deploy(factory_impl, proxy_admin, {"from": acct}, publish_source=True)

  print("--Factory--")
  factory = Contract.from_abi(Factory._name, proxy.address, Factory.abi)

  print("factory", factory)

  tx = factory.initialize(registry, strategy_template, keeper, owner, {"from": acct})

  tx.wait(1)

  print("--Create Vault--")
  tx1 = factory.createNewVaultsAndStrategies(gauge_template, False, {"from": acct})

  tx1.wait(1)