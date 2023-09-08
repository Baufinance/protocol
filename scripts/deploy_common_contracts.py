from brownie import *


def main():
    acct = accounts.load("bau")

    print("account", acct)

    print(" -- Health Check --")
    healthCheck = CommonHealthCheck.deploy({"from": acct}, publish_source=True)

    print("Health Check ", healthCheck.address)

    print(" -- Keeper Wrapper --")
    keeperWrapper = KeeperWrapper.deploy({"from": acct}, publish_source=True)
    print("Keeper Wrapper ", keeperWrapper.address)

    print(" -- Base Fee Oracle --")

    baseFeeOracle = BaseFeeOracle.deploy({"from": acct}, publish_source=True)


    tx1 = baseFeeOracle.setBaseFeeProvider("0xf8d0Ec04e94296773cE20eFbeeA82e76220cD549", {"from": acct})
    tx1.wait(1)

    tx2 = baseFeeOracle.setMaxAcceptableBaseFee(25000000000, {"from": acct})
    tx2.wait(1)
    print("Base Fee Oracle ", baseFeeOracle.address)
