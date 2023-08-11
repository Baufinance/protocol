// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    mapping(address => bool) public _blocked;
    uint8 private immutable _decimals;

    constructor(uint8 decimals_) ERC20("bau.finance test token", "TEST") {
        _decimals = decimals_;
    }

    function _setBlocked(address user, bool value) public virtual {
        _blocked[user] = value;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20) {
        require(
            !_blocked[to],
            "Token transfer refused. Receiver is on blacklist"
        );
        super._beforeTokenTransfer(from, to, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(uint256 _amount) public {
        _mint(msg.sender, _amount);
    }
}
