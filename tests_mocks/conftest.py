import pytest
from brownie import BoosterMock, RewardsMock, RewardFactoryMock, Token, ConvexPoolManagerMock, GaugeMock, BaseRewardPoolMock, RewardsMock



@pytest.fixture
def gov(accounts):
    yield accounts[0]


@pytest.fixture
def account2(accounts):
    yield accounts[1]


@pytest.fixture
def account3(accounts):
    yield accounts[2]


@pytest.fixture
def account4(accounts):
    yield accounts[3]

@pytest.fixture
def crv(gov):
    token = gov.deploy(Token, 18)
    yield token

@pytest.fixture
def cvx(gov):
    token = gov.deploy(Token, 18)
    yield token

@pytest.fixture
def ldo(gov):
    token = gov.deploy(Token, 18)
    yield token

@pytest.fixture
def lp_token(gov):
    token = gov.deploy(Token, 18)
    yield token

@pytest.fixture
def booster(crv, gov):
    booster = gov.deploy(BoosterMock, crv)
    yield booster

@pytest.fixture
def rewards_factory(booster, crv, cvx, gov):
    factory = gov.deploy(RewardFactoryMock, crv, cvx, booster)
    booster.setRewardFactory(factory)
    yield factory

@pytest.fixture
def pool_manager(booster, gov):
    pool_manager = gov.deploy(ConvexPoolManagerMock, booster)
    yield pool_manager


@pytest.fixture
def gauge(lp_token, gov):
    gauge = gov.deploy(GaugeMock, lp_token)
    yield gauge

@pytest.fixture
def ldo_rewards(ldo, gov):
    ldo_rewards = gov.deploy(RewardsMock, ldo)
    yield ldo_rewards