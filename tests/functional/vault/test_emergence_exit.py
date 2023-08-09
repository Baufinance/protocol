import brownie
from brownie import Contract
from brownie import config
import math

def test_emergency_exit_from_vault(
    gov,
    token,
    vault,
    strategy,
    chain
):
    ## deposit to the vault after approving
    startingWhale = token.balanceOf(gov)
    token.approve(vault, 2 ** 256 - 1, {"from": gov})
    vault.deposit({"from": gov})
    chain.sleep(1)
    strategy.harvest({"from": gov})
    chain.sleep(1)



    chain.mine(1)
    strategy.harvest({"from": gov})

    # set emergency and exit, then confirm that the strategy has no funds
    vault.setEmergencyExit(True, {"from": gov})
    chain.sleep(1)
    strategy.harvest({"from": gov})
    chain.sleep(1)
    assert math.isclose(strategy.estimatedTotalAssets(), 0, abs_tol=5)

    # simulate a day of waiting for share price to bump back up
    chain.sleep(86400)
    chain.mine(1)

    # withdraw and confirm we made money, or at least that we have about the same
    with brownie.reverts():
        vault.withdraw({"from": gov})

    balance_before = token.balanceOf(gov)
    vault_balance = token.balanceOf(vault)

    vault.emergencyWithdraw({"from": gov})
    balance_after = token.balanceOf(gov)

    assert balance_after - balance_before == vault_balance