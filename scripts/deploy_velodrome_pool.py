from brownie import *


def main():
    acct = accounts.load("bau")
    print("account", acct)

    router = "0x0dF66c0252ceF9c28dB2Aac56c9fabfEBe6994CF"
    velo = "0xf09A8aFB1a4e38dfA96b06d5E9492D3373ECf38b"
    token0 = Token2.deploy("Token0 Pool 1", "TP1", 18, {"from":acct}, publish_source=True)
    token1 = Token2.deploy("Token1 Pool 1", "TP2", 18, {"from":acct}, publish_source=True)

    pool = VelodromePoolMock.deploy(False, token0, token1, {"from":acct}, publish_source=True)

    tx = token0.mint(1_000_000*10**18, acct, {"from":acct})

    tx.wait(1)

    tx = token1.mint(1_000_000*10**18, acct, {"from":acct})

    tx.wait(1)


    tx = token0.mint(1_000_000*10**18, router, {"from":acct})

    tx.wait(1)

    tx = token1.mint(1_000_000*10**18, router, {"from":acct})

    tx.wait(1)

    gauge = VelodromeGaugeMock.deploy(velo, pool, {"from":acct}, publish_source=True)