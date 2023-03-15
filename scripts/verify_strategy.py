from brownie import *
import os
from dotenv import load_dotenv, find_dotenv


def main():
  strategy = StrategyConvex3CrvRewardsClonable.at("0x74505Fb95D0636ddDf2545AECc8e8F4e2fC004D4")

  StrategyConvex3CrvRewardsClonable.publish_source(strategy)@yearnvaults