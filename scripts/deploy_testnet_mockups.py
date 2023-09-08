from brownie import *


def main():
    acct = accounts.load("bau")

    print("account", acct)


    cvx = "0x402745D08AcF0cC79F457dA2D41276FA109a45A0"
    weth = "0xb8D3DbecA88a5Aa37979999de6F921F521E53E9E"

    mockBuilder = CurveMockBuilder.deploy(weth, {"from":acct}, publish_source=True)

    cvx_token = LPToken.deploy(18, {"from":acct}, publish_source=True)
    cvxweth = Curve2PoolMock.deploy([weth, cvx], cvx_token, {"from":acct}, publish_source=True)

    print("cvxweth", cvxweth)

    print("mockbuilder ", mockBuilder)

    tx1 = mockBuilder.build(1, False, {"from":acct})

    tx1.wait(1)

    tx2 = mockBuilder.build(2, False, {"from":acct})

    tx2.wait(1)

    tx3 =mockBuilder.build(3, False, {"from":acct})
    tx3.wait(1)

    tx4 = mockBuilder.build(4, False, {"from":acct})
    tx4.wait(1)
