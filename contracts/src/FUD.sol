// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FUD is ERC20 {
    constructor() ERC20("FUDToken", "FUD") {
        _mint(msg.sender, 15e5 * 10 ** decimals());
    }
}
