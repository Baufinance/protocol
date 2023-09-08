from brownie import *


def main():
    acct = accounts.load("bau")

    CurveZapMetaPoolMock.deploy({"from":acct}, publish_source=True)
