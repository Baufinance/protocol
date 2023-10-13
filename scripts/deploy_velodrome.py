from brownie import *


def main():
    acct = accounts.load("bau")

    print("account", acct)

    keeper = "0xc9f6Ce3D6C995E2a2040DD0cF49677C03E8bc512"
    registry = "0xD71FDBf189083Bdab8595BBFd57941483F66fCc4"

    router = VelodromeRouterMock.deploy({"from":acct}, publish_source=True)

    velo = Token2.deploy("Velo", "Velo", 18, {"from":acct}, publish_source=True)

    proxy_admin = "0xC3BDf65C61B93f451de9c26a80590E7046a8b5D0"

    factory_impl = VeloAerodromeFactory.deploy({"from": acct}, publish_source=True)

    proxy = UtilProxy.deploy(factory_impl, proxy_admin, {"from": acct}, publish_source=True)

    print("--Factory--")
    factory = Contract.from_abi(VeloAerodromeFactory._name, proxy.address, VeloAerodromeFactory.abi)

    print("factory", factory)


    strategy = GoerliStrategyVeloAerodromeClonable.deploy({"from":acct}, publish_source=True)

    tx = factory.initialize(
        registry,
        strategy,
        keeper,
        acct,
        velo,
        router,
        {"from":acct}
    )

    tx.wait(1)