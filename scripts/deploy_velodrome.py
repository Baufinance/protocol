from brownie import *


def main():
    acct = accounts.load("bau")

    print("account", acct)

    keeper = "0x1323Fa099cB2c54EDa59fD4A8BB8DC8c0913B050"
    registry = "0x5A7486e4fBfd2d956708A6627BaeA2C1Cb7068f2"
    velo = "0x204BC4c4A33DCeE4E52f0bC27F652Ee7466d5aEa"
    router = "0x402745D08AcF0cC79F457dA2D41276FA109a45A0"


    proxy_admin = "0xC3BDf65C61B93f451de9c26a80590E7046a8b5D0"

    factory_impl = VeloAerodromeFactory.deploy({"from": acct}, publish_source=True)

    proxy = UtilProxy.deploy(factory_impl, proxy_admin, {"from": acct}, publish_source=True)

    #print("--Factory--")
    factory = Contract.from_abi(VeloAerodromeFactory._name, proxy.address, VeloAerodromeFactory.abi)

    #print("factory", factory)


    strategy = SepoliaStrategyVeloAerodromeClonable.deploy({"from":acct}, publish_source=True)

    tx = factory.initialize(
        registry,
        strategy,
        keeper,
        acct,
        velo,
        router,
        {"from":acct}
    )

    #tx.wait(1)