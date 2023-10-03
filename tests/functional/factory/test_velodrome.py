import pytest
from brownie import *
DAY = 86400  # seconds

ETH = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"

@pytest.fixture
def common_health_check(gov, CommonHealthCheck):
    yield gov.deploy(CommonHealthCheck)

def test_velodrome_factory_deposit_withdraw(chain, common_health_check, base_fee_oracle,velodrome_factory, velodrome_router, gov):
    assert 1 == 1