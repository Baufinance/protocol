from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

  load_dotenv(find_dotenv())

  vault_template = os.getenv("VAULT_TEMPLATE")
  token_template = os.getenv("TOKEN_TEMPLATE")
  curve_pool_template = os.getenv("CURVE_POOL_TEMPLATE")
  pid_template = os.getenv("PID_TEMPLATE")

  keeper = os.getenv("KEEPER")
  owner= os.getenv("OWNER")
  registry = owner = os.getenv("REGISTRY")

  print("--Proxy Admin--")
  proxyAdmin = UtilProxyAdmin.deploy({"from": accounts[0]})
  print("proxy admin", proxyAdmin.address)


  print("--Strategy--")
  strategy_template = "0x92C78461fE26C2e27A2fd6Db62ce93c75C07A9a4" #StrategyConvex3CrvRewardsClonable.deploy(vault_template, pid_template, curve_pool_template, "Convex Pool", {"from": accounts[0]}, publish_source=True)

  print("strategy", strategy_template)

  factory_impl = Factory.deploy({"from": accounts[0]})

  proxy = UtilProxy.deploy(factory_impl, proxyAdmin, {"from": accounts[0]})

  print("--Factory--")
  factory = Contract.from_abi(Factory._name, proxy.address, Factory.abi)

  print("factory", factory)

  tx = factory.initialize(registry, strategy_template, keeper, owner, {"from": accounts[0]})

  tx.wait(1)
