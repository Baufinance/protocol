from brownie import *


def main():
    acct = accounts.load("bau")

    print("account", acct)


    # deploy common contracts
    print(" -- Health Check --")
    healthCheck = CommonHealthCheck.deploy({"from": acct})

    print("Health Check ", healthCheck.address)

    print(" -- Keeper Wrapper --")
    keeperWrapper = KeeperWrapper.deploy({"from": acct})
    print("Keeper Wrapper ", keeperWrapper.address)

    print(" -- Base Fee Oracle --")

    baseFeeOracle = BaseFeeOracle.deploy({"from": acct})


    tx1 = baseFeeOracle.setBaseFeeProvider("0xf8d0Ec04e94296773cE20eFbeeA82e76220cD549", {"from": acct})
    tx1.wait(1)

    tx2 = baseFeeOracle.setMaxAcceptableBaseFee(25000000000, {"from": acct})
    tx2.wait(1)
    print("Base Fee Oracle ", baseFeeOracle.address)

    # deploy crv, cvx, ldo
    print(" -- tokens --")
    crv = Token.deploy(18, {"from": acct})
    cvx = Token.deploy(18, {"from": acct})
    ldo = Token.deploy(18, {"from": acct})
    weth = Token.deploy(18, {"from": acct})

    print("Crv ", crv)
    print("Cvx ", cvx)
    print("Ldo ", ldo)
    print("weth ", weth)

    print("--- mocks ---")
    booster = BoosterMock.deploy(crv, {"from": acct})
    print("Booster ", booster)
    rewards_factory = RewardFactoryMock.deploy(crv, cvx, booster, {"from":acct})
    print("Rewards Factory ", rewards_factory)

    booster.setRewardFactory(rewards_factory)


    pool_manager = ConvexPoolManagerMock.deploy(booster, {"from":acct})
    print("Pool Manager ", pool_manager)

    inch = AggregationRouterV5Mock.deploy({"from":acct})
    print("Inch ", inch)

    univ2 = UniswapV2Mock.deploy({"from":acct})
    print("UniV2 ", univ2)

    univ3 = UniswapV3Mock.deploy({"from":acct})
    print("UniV3 ", univ3)
