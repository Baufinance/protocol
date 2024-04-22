from brownie import *


def main():
    acct = accounts.load("bau")
    print("account", acct)

    GaugeControllerMock.deploy({"from":acct}, publish_source=True)

    CurvexChainGaugeRegistryMock.deploy({"from":acct}, publish_source=True)