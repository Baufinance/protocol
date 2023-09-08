from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

    acct = accounts.load("bau")

    cvx = "0x402745D08AcF0cC79F457dA2D41276FA109a45A0"

    cvx_token = LPToken.deploy(18, {"from":acct}, publish_source=True)

    coins3 = Curve3PoolMock.deploy([cvx, cvx,cvx], cvx_token, {"from":acct}, publish_source=True)

    coins4 = Curve4PoolMock.deploy([cvx, cvx, cvx, cvx], cvx_token, {"from":acct}, publish_source=True)