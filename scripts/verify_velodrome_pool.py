from brownie import *
import os
from dotenv import load_dotenv, find_dotenv

def main():

    acct = accounts.load("bau")

    pool = VelodromePoolMock.at("0x6350F028D32B04CFD1B94b0B043A5fdE697aD995")

    VelodromePoolMock.publish_source(pool)