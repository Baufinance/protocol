from brownie import *


def main():

    print(" -- Health Check --")
    healthCheck = CommonHealthCheck.deploy({"from": accounts[0]})

    print("Health Check ", healthCheck.address)

    print(" -- Keeper Wrapper --")
    keeperWrapper = KeeperWrapper.deploy({"from": accounts[0]})
    print("Keeper Wrapper ", keeperWrapper.address)

    print(" -- Base Fee Oracle --")

    baseFeeOracle = BaseFeeOracle.deploy({"from": accounts[0]})

    print("Base Fee Oracle ", baseFeeOracle.address)

    vault = Vault.deploy({"from": accounts[0]})
