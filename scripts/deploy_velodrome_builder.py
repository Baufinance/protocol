from brownie import *


def main():
    acct = accounts.load("bau")
    print("account", acct)

    router = VelodromeRouterMock.deploy({"from":acct}, publish_source=True)

    velo = Token2.deploy("Velo", "Velo", 18, {"from":acct}, publish_source=True)

    VelodromeBuilderMock.deploy(router, velo, {"from":acct}, publish_source=True)
