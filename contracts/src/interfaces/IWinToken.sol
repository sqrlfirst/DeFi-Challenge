// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWinToken is IERC20 {
    // the WIN token is also mintable, so we include the following with the onlyMinter modifier
    function mint(address account, uint256 amount) external returns (bool);
}
