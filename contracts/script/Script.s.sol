// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

import {AirVault} from "../src/AirVault.sol";
import {FUD} from "../src/FUD.sol";
import {WIN} from "../src/WIN.sol";

contract MyScript is Script {
    /// @dev 5% of reward
    uint64 constant percent = 500;
    /// @dev deposited every 100 blocks
    uint64 constant interval = 100;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address minter = vm.envAddress("MINTER");
        vm.startBroadcast(deployerPrivateKey);

        FUD fud = new FUD();
        WIN win = new WIN(minter);
        AirVault airVault = new AirVault(
            address(fud),
            address(win),
            percent,
            interval
        );

        vm.stopBroadcast();
    }
}
