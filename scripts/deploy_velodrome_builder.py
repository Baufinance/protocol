from brownie import *


def main():
    acct = accounts.load("bau")
    print("account", acct)

    velo = "0xf09A8aFB1a4e38dfA96b06d5E9492D3373ECf38b"
    router = "0x0dF66c0252ceF9c28dB2Aac56c9fabfEBe6994CF"

    VelodromeBuilderMock.deploy(router, velo, {"from":acct}, publish_source=True)
