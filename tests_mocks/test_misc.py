import brownie
from brownie import BaseRewardPoolMock, Curve2PoolMock, Curve3PoolMock, Curve4PoolMock, Token

def test_add_pool(pool_manager, gauge, rewards_factory, booster, lp_token):
    pool_manager.addPool(gauge)

    pool_info = booster.poolInfo(0)

    assert pool_info[0] == lp_token

    assert pool_info[2] == gauge


def test_deposit_and_withdraw_lp_token_from_pool(pool_manager, gauge, rewards_factory, booster, lp_token, gov, account2, cvx, crv):

    crv.transfer(account2, 1_000_000, {"from": gov})

    cvx.transfer(account2, 1_000_000, {"from": gov})

    pool_manager.addPool(gauge)

    lp_token.transfer(account2, 1_000, {"from": gov})

    lp_token.approve(booster, 1_000, {"from": account2})

    booster.deposit(0, 1_000, False, {"from": account2})

    pool_info = booster.poolInfo(0)

    assert pool_info[0] == lp_token

    assert pool_info[2] == gauge

    reward_pool = BaseRewardPoolMock.at(pool_info[3])


    balance_crv_before = lp_token.balanceOf(account2)

    reward_pool.withdrawAndUnwrap(1_000, False, {"from": account2})

    balance_crv_after = lp_token.balanceOf(account2)

    assert balance_crv_after >  balance_crv_before




def test_deposit_and_withdraw_lp_token_from_pool_with_claim_rewards(pool_manager, gauge, rewards_factory, booster, lp_token, gov, account2, cvx, crv):

    pool_manager.addPool(gauge)

    lp_token.transfer(account2, 1_000, {"from": gov})

    lp_token.approve(booster, 1_000, {"from": account2})

    booster.deposit(0, 1_000, False, {"from": account2})

    pool_info = booster.poolInfo(0)

    assert pool_info[0] == lp_token

    assert pool_info[2] == gauge

    reward_pool = BaseRewardPoolMock.at(pool_info[3])

    crv.transfer(reward_pool, 10 * 10**18, {"from": gov})

    cvx.transfer(reward_pool, 10 * 10**18, {"from": gov})

    balance_crv_before = crv.balanceOf(account2)

    balance_cvx_before = cvx.balanceOf(account2)

    reward_pool.withdrawAndUnwrap(1_000, True, {"from": account2})

    balance_crv_after = crv.balanceOf(account2)

    balance_cvx_after = cvx.balanceOf(account2)

    assert balance_crv_after >  balance_crv_before
    assert balance_cvx_after >  balance_cvx_before


def test_deposit_and_withdraw_lp_token_from_pool_with_claim_rewards_with_extra(pool_manager, gauge, rewards_factory, booster, lp_token, gov, account2, cvx, crv, ldo, ldo_rewards):

    pool_manager.addPool(gauge)

    lp_token.transfer(account2, 1_000, {"from": gov})

    lp_token.approve(booster, 1_000, {"from": account2})

    booster.deposit(0, 1_000, False, {"from": account2})

    pool_info = booster.poolInfo(0)

    assert pool_info[0] == lp_token

    assert pool_info[2] == gauge

    reward_pool = BaseRewardPoolMock.at(pool_info[3])

    reward_pool.addExtraReward(ldo_rewards, {"from": gov})

    crv.transfer(reward_pool, 10 * 10**18, {"from": gov})

    cvx.transfer(reward_pool, 10 * 10**18, {"from": gov})

    ldo.transfer(ldo_rewards, 100 * 10**18, {"from": gov})

    balance_crv_before = crv.balanceOf(account2)

    balance_cvx_before = cvx.balanceOf(account2)

    balance_ldo_before = ldo.balanceOf(account2)

    reward_pool.withdrawAndUnwrap(1_000, True, {"from": account2})

    balance_crv_after = crv.balanceOf(account2)

    balance_cvx_after = cvx.balanceOf(account2)

    balance_ldo_after = ldo.balanceOf(account2)

    assert balance_crv_after >  balance_crv_before
    assert balance_cvx_after >  balance_cvx_before
    assert balance_ldo_after > balance_crv_before


def test_curve_builder_can_build_2_pool(curve_mock_builder, gov):

    # try to build 2 pool with erc 20 tokens with plain and lending liquidity
    curve_mock_builder.build(2, False)

    pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

    pool = Curve2PoolMock.at(pool_address)

    token1 = Token.at(pool.coins(0))
    token2 = Token.at(pool.coins(1))


    with brownie.reverts():
        pool.coins(2)

    token1.mint(3_000*10**18, {"from": gov})
    token2.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    token1_balance_before = token1.balanceOf(gov)

    token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    token1_balance_after = token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert token1_balance_before - token1_balance_after  ==  1_000*10**18


    #lending liquidity

    pool.add_liquidity([1_000*10**18, 0], 0, True, {"from": gov})


    underlying_token1 = Token.at(pool.underlying_coins['int128'](0))
    underlying_token2 = Token.at(pool.underlying_coins['int128'](1))


    with brownie.reverts():
        pool.underlying_coins['int128'](2)

    underlying_token1.mint(3_000*10**18, {"from": gov})
    underlying_token2.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    underlying_token1_balance_before = token1.balanceOf(gov)

    underlying_token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    underlying_token1_balance_after = underlying_token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert underlying_token1_balance_before - underlying_token1_balance_after  ==  1_000*10**18

    #exchange

    token1.mint(3_000*10**18, pool,  {"from": gov})
    token2.mint(3_000*10**18, pool, {"from": gov})

    token1_balance_before = token1.balanceOf(gov)
    token2_balance_before = token2.balanceOf(gov)

    pool.exchange(0,
        1,
        1_000*10**18,
        0,
        False,
        {"from": gov}
    )

    token1_balance_after = token1.balanceOf(gov)
    token2_balance_after = token2.balanceOf(gov)

    assert token1_balance_before - token1_balance_after == 1_000*10**18
    assert token2_balance_after - token2_balance_before == 1_000*10**18

    pool.setRate(2*10**18, {"from": gov})
    token1.mint(3_000*10**18, pool,  {"from": gov})
    token2.mint(3_000*10**18, pool, {"from": gov})
    token2.approve(pool, 3_000*10**18, {"from": gov})

    token1_balance_before = token1.balanceOf(gov)
    token2_balance_before = token2.balanceOf(gov)

    pool.exchange(1,
        0,
        1_000*10**18,
        0,
        False,
        {"from": gov}
    )

    token1_balance_after = token1.balanceOf(gov)
    token2_balance_after = token2.balanceOf(gov)

    assert token2_balance_before - token2_balance_after == 1_000*10**18
    assert token1_balance_after - token1_balance_before == 2_000*10**18



def test_curve_builder_can_build_2_pool_with_eth(curve_mock_builder, gov):

    # try to build 2 pool with erc 20 tokens with plain and lending liquidity
    curve_mock_builder.build(2, True)

    pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

    pool = Curve2PoolMock.at(pool_address)

    token2 = Token.at(pool.coins(1))


    with brownie.reverts():
        pool.coins(2)

    token2.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    balance_before = gov.balance()

    pool.add_liquidity([1*10**18, 0], 0, {"from": gov, "value": 1*10**18})

    token_balance_after = token.balanceOf(gov)
    balance_after = gov.balance()

    assert token_balance_after - token_balance_before == 1*10**18
    assert balance_before - balance_after  >=  1*10**18

    #exchange

    token2.mint(3_000*10**18, pool, {"from": gov})

    balance_before = gov.balance()
    token2_balance_before = token2.balanceOf(gov)
    token2.approve(pool, 3_000*10**18, {"from": gov})

    pool.exchange(1,
        0,
        1*10**18,
        0,
        True,
        {"from": gov}
    )

    balance_after = gov.balance()

    token2_balance_after = token2.balanceOf(gov)

    assert balance_after - balance_before == 1*10**18

    assert token2_balance_before - token2_balance_after == 1*10**18



def test_curve_builder_can_build_2_pool_with_weth(curve_mock_builder, gov, weth):

    # try to build 2 pool with erc 20 tokens with plain and lending liquidity
    curve_mock_builder.buildWETH(2)

    pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

    pool = Curve2PoolMock.at(pool_address)

    token1 = Token.at(pool.coins(0))

    assert token1 == weth

    token2 = Token.at(pool.coins(1))

    with brownie.reverts():
        pool.coins(2)

    token1.mint(3_000*10**18, {"from": gov})
    token2.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    token1_balance_before = token1.balanceOf(gov)

    token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    token1_balance_after = token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert token1_balance_before - token1_balance_after  ==  1_000*10**18


    #lending liquidity

    pool.add_liquidity([1_000*10**18, 0], 0, True, {"from": gov})


    underlying_token1 = Token.at(pool.underlying_coins['int128'](0))
    underlying_token2 = Token.at(pool.underlying_coins['int128'](1))


    with brownie.reverts():
        pool.underlying_coins['int128'](2)

    underlying_token1.mint(3_000*10**18, {"from": gov})
    underlying_token2.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    underlying_token1_balance_before = token1.balanceOf(gov)

    underlying_token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    underlying_token1_balance_after = underlying_token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert underlying_token1_balance_before - underlying_token1_balance_after  ==  1_000*10**18

    #exchange

    token1.mint(3_000*10**18, pool,  {"from": gov})
    token2.mint(3_000*10**18, pool, {"from": gov})

    token1_balance_before = token1.balanceOf(gov)
    token2_balance_before = token2.balanceOf(gov)

    pool.exchange(0,
        1,
        1_000*10**18,
        0,
        False,
        {"from": gov}
    )

    token1_balance_after = token1.balanceOf(gov)
    token2_balance_after = token2.balanceOf(gov)

    assert token1_balance_before - token1_balance_after == 1_000*10**18
    assert token2_balance_after - token2_balance_before == 1_000*10**18

    pool.setRate(2*10**18, {"from": gov})
    token1.mint(3_000*10**18, pool,  {"from": gov})
    token2.mint(3_000*10**18, pool, {"from": gov})
    token2.approve(pool, 3_000*10**18, {"from": gov})

    token1_balance_before = token1.balanceOf(gov)
    token2_balance_before = token2.balanceOf(gov)

    pool.exchange(1,
        0,
        1_000*10**18,
        0,
        False,
        {"from": gov}
    )

    token1_balance_after = token1.balanceOf(gov)
    token2_balance_after = token2.balanceOf(gov)

    assert token2_balance_before - token2_balance_after == 1_000*10**18
    assert token1_balance_after - token1_balance_before == 2_000*10**18



def test_curve_builder_can_build_3_pool(curve_mock_builder, gov):

    # try to build 3 pool with erc 20 tokens with plain and lending liquidity
    curve_mock_builder.build(3, False)

    pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

    pool = Curve3PoolMock.at(pool_address)

    token1 = Token.at(pool.coins(0))
    token3 = Token.at(pool.coins(2))


    with brownie.reverts():
        pool.coins(3)

    token1.mint(3_000*10**18, {"from": gov})
    token3.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    token1_balance_before = token1.balanceOf(gov)

    token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    token1_balance_after = token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert token1_balance_before - token1_balance_after  ==  1_000*10**18


    #lending liquidity

    pool.add_liquidity([1_000*10**18, 0, 0], 0, True, {"from": gov})


    underlying_token1 = Token.at(pool.underlying_coins['int128'](0))
    underlying_token3 = Token.at(pool.underlying_coins['int128'](2))


    with brownie.reverts():
        pool.underlying_coins['int128'](3)

    underlying_token1.mint(3_000*10**18, {"from": gov})
    underlying_token3.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    underlying_token1_balance_before = token1.balanceOf(gov)

    underlying_token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    underlying_token1_balance_after = underlying_token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert underlying_token1_balance_before - underlying_token1_balance_after  ==  1_000*10**18

    #exchange

    token1.mint(3_000*10**18, pool,  {"from": gov})
    token3.mint(3_000*10**18, pool, {"from": gov})

    token1_balance_before = token1.balanceOf(gov)
    token3_balance_before = token3.balanceOf(gov)

    pool.exchange(0,
        2,
        1_000*10**18,
        0,
        False,
        {"from": gov}
    )

    token1_balance_after = token1.balanceOf(gov)
    token3_balance_after = token3.balanceOf(gov)

    assert token1_balance_before - token1_balance_after == 1_000*10**18
    assert token3_balance_after - token3_balance_before == 1_000*10**18

    pool.setRate(2*10**18, {"from": gov})
    token1.mint(3_000*10**18, pool,  {"from": gov})
    token3.mint(3_000*10**18, pool, {"from": gov})
    token3.approve(pool, 3_000*10**18, {"from": gov})

    token1_balance_before = token1.balanceOf(gov)
    token3_balance_before = token3.balanceOf(gov)

    pool.exchange(2,
        0,
        1_000*10**18,
        0,
        False,
        {"from": gov}
    )

    token1_balance_after = token1.balanceOf(gov)
    token3_balance_after = token3.balanceOf(gov)

    assert token3_balance_before - token3_balance_after == 1_000*10**18
    assert token1_balance_after - token1_balance_before == 2_000*10**18


def test_curve_builder_can_build_2_pool_with_eth(curve_mock_builder, gov):

    # try to build 3 pool with erc 20 tokens with plain and lending liquidity
    curve_mock_builder.build(3, True)

    pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

    pool = Curve3PoolMock.at(pool_address)

    token3 = Token.at(pool.coins(2))


    with brownie.reverts():
        pool.coins(3)

    token3.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    balance_before = gov.balance()

    pool.add_liquidity([1*10**18, 0, 0], 0, {"from": gov, "value": 1*10**18})

    token_balance_after = token.balanceOf(gov)
    balance_after = gov.balance()

    assert token_balance_after - token_balance_before == 1*10**18
    assert balance_before - balance_after  >=  1*10**18

    #exchange

    token3.mint(3_000*10**18, pool, {"from": gov})

    balance_before = gov.balance()
    token3_balance_before = token3.balanceOf(gov)
    token3.approve(pool, 3_000*10**18, {"from": gov})

    pool.exchange(2,
        0,
        1*10**18,
        0,
        True,
        {"from": gov}
    )

    balance_after = gov.balance()

    token3_balance_after = token3.balanceOf(gov)

    assert balance_after - balance_before == 1*10**18

    assert token3_balance_before - token3_balance_after == 1*10**18



def test_curve_builder_can_build_3_pool(curve_mock_builder, gov, weth):

    # try to build 3 pool with erc 20 tokens with plain and lending liquidity
    curve_mock_builder.buildWETH(3)

    pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

    pool = Curve3PoolMock.at(pool_address)

    token1 = Token.at(pool.coins(0))
    token3 = Token.at(pool.coins(2))

    assert token1 == weth

    with brownie.reverts():
        pool.coins(3)

    token1.mint(3_000*10**18, {"from": gov})
    token3.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    token1_balance_before = token1.balanceOf(gov)

    token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    token1_balance_after = token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert token1_balance_before - token1_balance_after  ==  1_000*10**18


    #lending liquidity

    pool.add_liquidity([1_000*10**18, 0, 0], 0, True, {"from": gov})


    underlying_token1 = Token.at(pool.underlying_coins['int128'](0))
    underlying_token3 = Token.at(pool.underlying_coins['int128'](2))


    with brownie.reverts():
        pool.underlying_coins['int128'](3)

    underlying_token1.mint(3_000*10**18, {"from": gov})
    underlying_token3.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    underlying_token1_balance_before = token1.balanceOf(gov)

    underlying_token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    underlying_token1_balance_after = underlying_token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert underlying_token1_balance_before - underlying_token1_balance_after  ==  1_000*10**18

    #exchange

    token1.mint(3_000*10**18, pool,  {"from": gov})
    token3.mint(3_000*10**18, pool, {"from": gov})

    token1_balance_before = token1.balanceOf(gov)
    token3_balance_before = token3.balanceOf(gov)

    pool.exchange(0,
        2,
        1_000*10**18,
        0,
        False,
        {"from": gov}
    )

    token1_balance_after = token1.balanceOf(gov)
    token3_balance_after = token3.balanceOf(gov)

    assert token1_balance_before - token1_balance_after == 1_000*10**18
    assert token3_balance_after - token3_balance_before == 1_000*10**18

    pool.setRate(2*10**18, {"from": gov})
    token1.mint(3_000*10**18, pool,  {"from": gov})
    token3.mint(3_000*10**18, pool, {"from": gov})
    token3.approve(pool, 3_000*10**18, {"from": gov})

    token1_balance_before = token1.balanceOf(gov)
    token3_balance_before = token3.balanceOf(gov)

    pool.exchange(2,
        0,
        1_000*10**18,
        0,
        False,
        {"from": gov}
    )

    token1_balance_after = token1.balanceOf(gov)
    token3_balance_after = token3.balanceOf(gov)

    assert token3_balance_before - token3_balance_after == 1_000*10**18
    assert token1_balance_after - token1_balance_before == 2_000*10**18



def test_curve_builder_can_build_4_pool(curve_mock_builder, gov):

    # try to build 3 pool with erc 20 tokens with plain and lending liquidity
    curve_mock_builder.build(4, False)

    pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

    pool = Curve4PoolMock.at(pool_address)

    token1 = Token.at(pool.coins(0))
    token4 = Token.at(pool.coins(3))


    with brownie.reverts():
        pool.coins(4)

    token1.mint(3_000*10**18, {"from": gov})
    token4.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    token1_balance_before = token1.balanceOf(gov)

    token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0, 0, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    token1_balance_after = token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert token1_balance_before - token1_balance_after  ==  1_000*10**18


    #lending liquidity

    pool.add_liquidity([1_000*10**18, 0, 0, 0], 0, True, {"from": gov})


    underlying_token1 = Token.at(pool.underlying_coins['int128'](0))
    underlying_token3 = Token.at(pool.underlying_coins['int128'](3))


    with brownie.reverts():
        pool.underlying_coins['int128'](4)

    underlying_token1.mint(3_000*10**18, {"from": gov})
    underlying_token3.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    underlying_token1_balance_before = token1.balanceOf(gov)

    underlying_token1.approve(pool, 3_000*10**18, {"from": gov})

    pool.add_liquidity([1_000*10**18, 0, 0, 0], 0, {"from": gov})

    token_balance_after = token.balanceOf(gov)
    underlying_token1_balance_after = underlying_token1.balanceOf(gov)

    assert token_balance_after - token_balance_before == 1_000*10**18
    assert underlying_token1_balance_before - underlying_token1_balance_after  ==  1_000*10**18


def test_curve_builder_can_build_4_pool_with_eth(curve_mock_builder, gov):

    # try to build 3 pool with erc 20 tokens with plain and lending liquidity
    curve_mock_builder.build(4, True)

    pool_address = curve_mock_builder.mocks(curve_mock_builder.length()-1)

    pool = Curve4PoolMock.at(pool_address)

    token4 = Token.at(pool.coins(3))


    with brownie.reverts():
        pool.coins(4)

    token4.mint(3_000*10**18, {"from": gov})

    token = Token.at(pool.token())

    token_balance_before = token.balanceOf(gov)
    balance_before = gov.balance()

    pool.add_liquidity([1*10**18, 0, 0, 0], 0, {"from": gov, "value": 1*10**18})

    token_balance_after = token.balanceOf(gov)
    balance_after = gov.balance()

    assert token_balance_after - token_balance_before == 1*10**18
    assert balance_before - balance_after  >=  1*10**18