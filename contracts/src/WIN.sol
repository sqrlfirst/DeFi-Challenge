// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract WIN is ERC20, Ownable {
    address public minter;

    event minterChanged(address minter);

    constructor(address _minter) ERC20("WINToken", "WIN") Ownable(msg.sender) {
        minter = _minter;
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "only minter can mint");
        _;
    }

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
        emit minterChanged(minter);
    }

    function mint(
        address account,
        uint256 amount
    ) external onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}
