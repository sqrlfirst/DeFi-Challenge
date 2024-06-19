// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IAirVault {
    // lock tokens in the AirVault contract
    function deposit(uint256 amount) external returns (bool);

    // withdraw deposited tokens
    function withdraw(uint256 amount) external returns (bool);

    // provides how many tokens a specific address has deposited
    function lockedBalanceOf(address account) external view returns (uint256);
}
