// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.17;

import {Test, Vm, console} from "forge-std/Test.sol";
import {AirVault} from "../src/AirVault.sol";
import {FUD} from "../src/FUD.sol";
import {WIN} from "../src/WIN.sol";

contract AirVaultTest is Test {
    address owner;
    address user;
    address minter;

    AirVault airVault;
    FUD fud;
    WIN win;

    /// @dev 5% of reward
    uint64 constant percent = 500;
    /// @dev deposited every 100 blocks
    uint64 constant interval = 100;

    function setUp() public {
        user = makeAddr("user");
        owner = makeAddr("owner");

        vm.startPrank(owner);
        fud = new FUD();
        win = new WIN(minter);
        airVault = new AirVault(address(fud), address(win), percent, interval);

        // send some fud tokens to user
        fud.transfer(user, 1000 * 10 ** fud.decimals());
        vm.stopPrank();
    }

    function test_deposit() public {
        uint256 amount = 100 * 10 ** fud.decimals();
        vm.startPrank(user);
        fud.approve(address(airVault), amount);
        airVault.deposit(amount);
        vm.stopPrank();
        assertEq(airVault.lockedBalances(user), amount);
    }

    function test_withdraw() public {
        uint256 amount = 100 * 10 ** fud.decimals();
        vm.startPrank(user);
        fud.approve(address(airVault), amount);
        airVault.deposit(amount);

        airVault.withdraw(amount);
        vm.stopPrank();
        assertEq(airVault.lockedBalances(owner), 0);
    }

    function test_minterMintsWINtouser() public {
        uint256 amount = 100 * 10 ** fud.decimals();
        vm.startPrank(user);
        fud.approve(address(airVault), amount);
        airVault.deposit(amount);
        vm.stopPrank();

        vm.roll(block.number + interval + 10);

        (uint256 amountXBlock, uint256 lastBlockDeposited) = airVault
            .getRewardData(user);
        uint256 amountDeposited = airVault.lockedBalances(user);
        uint256 roundedBlocksPassed = ((block.number - lastBlockDeposited) /
            airVault.rewardInterval()) * airVault.rewardInterval();
        uint256 reward = (((amountXBlock +
            amountDeposited *
            roundedBlocksPassed) / airVault.rewardInterval()) *
            airVault.rewardPercent()) / airVault.PRECISION();
        vm.prank(minter);
        win.mint(user, reward);
        assertEq(win.balanceOf(user), reward);
    }
}
