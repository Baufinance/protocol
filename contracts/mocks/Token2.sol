// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token2 is ERC20 {
    mapping(address => bool) public _blocked;
    uint8 private immutable _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals_) ERC20(name, symbol) {
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

    function mint(uint256 _amount, address _recipient) public {
        _mint(_recipient, _amount);
    }

    function mint(uint256 _amount) public {
        _mint(msg.sender, _amount);
    }
}