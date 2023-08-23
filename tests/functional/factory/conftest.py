import pytest
from brownie import Vault, CurveFactoryETH, BoosterMock, RewardsMock, RewardFactoryMock, Token, ConvexPoolManagerMock, GaugeMock,  RewardsMock, CurveMockBuilder, AggregationRouterV5Mock,UniswapV2Mock, UniswapV3Mock



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
def treasury(accounts):
    yield accounts[4]

def create_token(gov):
    def create_token(decimal=18):
        return gov.deploy(Token, decimal)

    yield create_token

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

@pytest.fixture
def weth(create_token):
    yield create_token()

@pytest.fixture
def curve_mock_builder(weth, gov):
    builder = gov.deploy(CurveMockBuilder, weth)
    yield builder


@pytest.fixture
def aggregation_router_mock(gov):
    inch = gov.deploy(AggregationRouterV5Mock)
    yield inch

@pytest.fixture
def univ2_mock(gov):
    univ2 = gov.deploy(UniswapV2Mock)
    yield univ2

@pytest.fixture
def univ3_mock(gov):
    univ3 = gov.deploy(UniswapV3Mock)
    yield univ3



@pytest.fixture
def factory(CurveFactoryETH, booster, registry, gov, pool_manager):
    factory = gov.deploy(CurveFactoryETH)
    factory.initialize(registry, gov, gov, pool_manager,booster)
    yield factory

@pytest.fixture
def vault_template(gov):
    vault = gov.deploy(Vault)
    yield vault
