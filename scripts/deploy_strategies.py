from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

    acct = accounts.load("bau")

    strategy2 = GoerliStrategyConvex2CoinsRewardsClonable.deploy({"from":acct}, publish_source=True)

    strategy3 = GoerliStrategyConvex3CoinsRewardsClonable.deploy({"from":acct}, publish_source=True)

    strategy4 = GoerliStrategyConvex4CoinsRewardsClonable.deploy({"from":acct}, publish_source=True)

    strategy_meta = GoerliStrategyConvexMetaPoolRewardsClonable.deploy({"from":acct}, publish_source=True)