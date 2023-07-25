import brownie
from brownie import BaseRewardPoolMock

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