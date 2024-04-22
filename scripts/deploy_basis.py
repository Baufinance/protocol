from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

  load_dotenv(find_dotenv())

  acct = accounts.load("bau")

  print("--Proxy Admin--")
  proxy_admin = UtilProxyAdmin.deploy({"from":acct}, publish_source=True)

  print("proxy admin", proxy_admin)


  print("--Registry--")
  registry = Registry.deploy({"from":acct}, publish_source=True)

  print("registry", registry)
