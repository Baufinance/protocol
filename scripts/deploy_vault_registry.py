from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

    load_dotenv(find_dotenv())
    acct = accounts.load("yield2")
    # token address for vault template
    token_template = os.getenv("TOKEN_TEMPLATE")

    # owner of vault template
    owner = os.getenv("OWNER")

    print("account", acct)

    print(" -- Vault --")

    vault = Vault.deploy({"from":acct})

    tx1 = vault.initialize(token_template, owner, owner, "Yield Curve Frax-F", "YCF", owner, {"from": acct})

    tx1.wait(1)

    print("vault template", vault.address)

    print(" -- Registry --")

    registry = Registry.deploy({"from":acct})

    print("registry", registry.address)

    tx2 = registry.newRelease(vault, {"from": acct})

    tx2.wait(1)