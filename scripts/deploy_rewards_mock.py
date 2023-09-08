from brownie import *


def main():
    acct = accounts.load("bau")

    print("account", acct)

    rewards = BaseRewardPoolMock.deploy(0,  "0x19b79B0fFD542cd7E26402d09B03133467B89033",  "0x19b79B0fFD542cd7E26402d09B03133467B89033", "0x19b79B0fFD542cd7E26402d09B03133467B89033",{"from":acct}, publish_source=True)