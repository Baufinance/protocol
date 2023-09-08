from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

  load_dotenv(find_dotenv())

  acct = accounts.load("bau")


  keeper = "0xc9f6Ce3D6C995E2a2040DD0cF49677C03E8bc512"
  registry = "0xD71FDBf189083Bdab8595BBFd57941483F66fCc4"

  pool_manager = "0x2abE2Af50B8876C77FBFAC16FE307689e3af17F8"

  booster = "0x3088982b8535cDC266048ae13a375B4C8B2701d6"

  proxy_admin = UtilProxyAdmin.deploy({"from":acct}, publish_source=True)

  factory_impl = CurveFactoryETH.deploy({"from": acct}, publish_source=True)

  proxy = UtilProxy.deploy(factory_impl, proxy_admin, {"from": acct}, publish_source=True)

  print("--Factory--")
  factory = Contract.from_abi(CurveFactoryETH._name, proxy.address, CurveFactoryETH.abi)

  print("factory", factory)

  tx = factory.initialize(registry, keeper, acct, pool_manager, booster, {"from": acct})

  tx.wait(1)