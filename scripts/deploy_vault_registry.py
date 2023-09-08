from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

    acct = accounts.load("bau")

    print("account", acct)

    print(" -- Vault --")

    vault = Vault.deploy({"from":acct})

    print("vault template", vault.address)