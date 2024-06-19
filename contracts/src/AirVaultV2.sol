// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IAirVault} from "./interfaces/IAirVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error WrongAmountForDeposit();

contract AirVaultV2 is Ownable {
    uint256 constant PRECISION = 10e5;

    uint64 public rewardPercent;
    uint64 public rewardInterval;

    address public immutable FudToken;
    address public immutable WinToken;

    struct userDeposit {
        uint256 amount;
        uint256 amountXBlock;
        uint256 lastBlockDeposited; // TODO change to smaller type as u256 for block is too much
        // uint256 lastBlockRewarded; likely
    }

    mapping(address => userDeposit) userDeposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _FudToken, address _WinToken) Ownable(msg.sender) {
        FudToken = _FudToken;
        WinToken = _WinToken;
    }

    // WIN tokens in airdrop = 0.05 * (# FUD tokens deposited) * (# blocks deposited) / ( total # blocks)
    /**
     *
     */
    function deposit(uint256 amount) external returns (bool) {
        require(
            IERC20(FudToken).balanceOf(msg.sender) >= amount,
            "user balance is lower than amount"
        );
        require(
            IERC20(FudToken).allowance(msg.sender, address(this)) >= amount,
            "user should approve tokens to AirVault before deposit"
        );

        IERC20(FudToken).transferFrom(msg.sender, address(this), amount);

        _updateAmountXBlocks();
        userDeposits[msg.sender].amount += amount;

        emit Deposit(msg.sender, amount);
        return true;
    }

    /**
     *
     */
    function withdraw(uint256 amount) external returns (bool) {
        require(
            userDeposits[msg.sender].amount >= amount,
            "amount is bigger than user deposit"
        );

        IERC20(FudToken).transfer(msg.sender, amount);

        _updateAmountXBlocks();
        userDeposits[msg.sender].amount -= amount;

        emit Withdraw(msg.sender, amount);
        return true;
    }

    /**
     *
     */
    function lockedBalances(address account) external view returns (uint256) {
        return userDeposits[account].amount;
    }

    /**
     *
     */
    function _updateAmountXBlocks() internal {
        uint256 blocksPassed = block.number -
            userDeposits[msg.sender].lastBlockDeposited;
        userDeposits[msg.sender].amountXBlock +=
            userDeposits[msg.sender].amount *
            blocksPassed;
        userDeposits[msg.sender].lastBlockDeposited = block.number;
    }
}
