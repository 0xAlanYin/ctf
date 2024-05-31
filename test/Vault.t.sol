// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
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
        vault.openWithdraw();
        vm.stopPrank();

        vm.startPrank(palyer);

        attacker = new Attacker(address(vault), palyer);
        vm.stopPrank();
    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        attacker.attack{value: 0.1 ether}();

        require(vault.isSolve(), "solved");
        assertEq(0.2 ether, attacker.getBalance());
        vm.stopPrank();
    }
}
