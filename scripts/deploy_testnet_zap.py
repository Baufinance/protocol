from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

  acct = accounts.load("bau")

  router = "0x5A7486e4fBfd2d956708A6627BaeA2C1Cb7068f2"

  proxy_admin = "0xC3BDf65C61B93f451de9c26a80590E7046a8b5D0"

  zap_impl = Zap.deploy({"from": acct}, publish_source=True)

  proxy = UtilProxy.deploy(zap_impl, proxy_admin, {"from": acct}, publish_source=True)

  print("--Zap--")
  zap = Contract.from_abi(Zap._name, proxy.address, Zap.abi)

  print("zap", zap)

  tx = zap.initialize(acct, router, {"from": acct})

  tx.wait(1)