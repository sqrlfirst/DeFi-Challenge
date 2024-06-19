// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IAirVault} from "./interfaces/IAirVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error UserBalanceIsLowerThanDepositAmount();
error UserAllowanceIsLowerThanDepositAmount();
error UserDepositIsLowerThanWithdrawAmount();

contract AirVault is Ownable {
    uint256 public constant PRECISION = 10e5;

    uint64 public rewardPercent;
    uint64 public rewardInterval;

    address public immutable fudToken;
    address public immutable winToken;

    struct userDeposit {
        uint256 amount;
        uint256 amountXBlock;
        uint256 lastBlockDeposited;
    }

    mapping(address => userDeposit) userDeposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(
        address _FudToken,
        address _WinToken,
        uint64 _rewardPercent,
        uint64 _rewardInterval
    ) Ownable(msg.sender) {
        fudToken = _FudToken;
        winToken = _WinToken;
        rewardPercent = _rewardPercent;
        rewardInterval = _rewardInterval;
    }

    // WIN tokens in airdrop = 0.05 * (# FUD tokens deposited) * (# blocks deposited) / ( total # blocks)
    /**
     *
     */
    function deposit(uint256 amount) external returns (bool) {
        if (IERC20(fudToken).balanceOf(msg.sender) < amount) {
            revert UserBalanceIsLowerThanDepositAmount();
        }
        if (IERC20(fudToken).allowance(msg.sender, address(this)) < amount) {
            revert UserAllowanceIsLowerThanDepositAmount();
        }

        IERC20(fudToken).transferFrom(msg.sender, address(this), amount);

        _updateAmountXBlocks();
        userDeposits[msg.sender].amount += amount;

        emit Deposit(msg.sender, amount);
        return true;
    }

    /**
     *
     */
    function withdraw(uint256 amount) external returns (bool) {
        if (userDeposits[msg.sender].amount < amount) {
            revert UserDepositIsLowerThanWithdrawAmount();
        }

        IERC20(fudToken).transfer(msg.sender, amount);

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

    function getRewardData(
        address account
    ) external view returns (uint256, uint256) {
        return (
            userDeposits[account].amountXBlock,
            userDeposits[account].lastBlockDeposited
        );
    }

    /**
     *
     */
    function _updateAmountXBlocks() internal {
        uint256 lastBlockDeposited = userDeposits[msg.sender]
            .lastBlockDeposited == 0
            ? block.number
            : userDeposits[msg.sender].lastBlockDeposited;
        uint256 blocksPassed = block.number - lastBlockDeposited;
        userDeposits[msg.sender].amountXBlock +=
            userDeposits[msg.sender].amount *
            blocksPassed;
        userDeposits[msg.sender].lastBlockDeposited = block.number;
    }
}
