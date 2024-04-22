from brownie import *


def main():
    acct = accounts.load("bau")

    print("account", acct)

    factory = Contract.from_abi(VeloAerodromeFactory._name, '0x9349b5D13AeF5CE6e3744Cf1763945f5E551efAf', VeloAerodromeFactory.abi)

    factory.setVeloPoolToRegistry("0x6350F028D32B04CFD1B94b0B043A5fdE697aD995", ['0x204BC4c4A33DCeE4E52f0bC27F652Ee7466d5aEa','0x7FA51656D6423d63a410697e7d9D5288e5E20B90',False,'0xb8D3DbecA88a5Aa37979999de6F921F521E53E9E'],['0x204BC4c4A33DCeE4E52f0bC27F652Ee7466d5aEa','0xc75B04a4b3f43755C9405Acc3d268815A3eA2D9d',False,'0xb8D3DbecA88a5Aa37979999de6F921F521E53E9E'], {"from":acct})