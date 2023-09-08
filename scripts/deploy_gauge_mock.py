from brownie import *


def main():
    acct = accounts.load("bau")

    print("account", acct)

    gauge2 = GaugeMock.deploy("0x0e88960b4099F0355239EaB08ca8D5f1db370930", {"from":acct}, publish_source=True)

    gauge3 =  GaugeMock.deploy("0x63Cca15fcdAC8774dE8b44FAdF910855F841b55a", {"from":acct}, publish_source=True)

    gauge4 = GaugeMock.deploy("0x39b830636d9147aCA5173bBbA4c8525721194eED", {"from":acct}, publish_source=True)

    gaugemeta = GaugeMock.deploy("0xa03105D5ADFf94C6e43F91bb5362ee07e8Fc8ac8", {"from":acct}, publish_source=True)