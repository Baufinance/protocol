from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

  acct = accounts.load("bau")

  router = AggregationRouterV5Mock.deploy({"from": acct}, publish_source=True)

  proxy_admin = "0x2abE2Af50B8876C77FBFAC16FE307689e3af17F8"

  zap_impl = Zap.deploy({"from": acct}, publish_source=True)

  proxy = UtilProxy.deploy(zap_impl, proxy_admin, {"from": acct}, publish_source=True)

  print("--Zap--")
  zap = Contract.from_abi(Zap._name, proxy.address, Zap.abi)

  print("zap", zap)

  tx = zap.initialize(acct, router, {"from": acct})

  tx.wait(1)