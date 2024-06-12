# Chandigarh University Summer Internship With Metacrafters ETH+Avax Intermediate Project 01

## Project Introduction 

The code represents a Solidity smart contract named Exception that showcases exception handling using require(), assert(), and revert() statements. Overall The main objective of this smart contract is to demonstrate different ways of handling exceptions and errors in Solidity.

| Statement | Purpose | Behavior | Gas Refund | Error Message |
| --- | --- | --- | --- | --- |
| `require` | Validate user input, access control, and conditions | If condition is false, revert transaction and refund gas | ✅ | Customizable error message |
| `revert` | Revert transaction and refund gas | Immediately revert transaction and refund gas | ✅ | Customizable error message |
| `assert` | Check for internal errors, invariant conditions | If condition is false, terminate contract execution and consume all gas | ❌ | "Assertion failed" |


## Contract Explanation 

```solidity
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.26;

contract SecureContract {
    
    address private owner;
    mapping (address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function transfer(address _recipient, uint256 _amount) public {
        require(_recipient != address(0), "Receiver Address is wrong");
        require(balances[msg.sender] >= _amount, "Not Enough Balance");
        require(_amount > 0, "Transfer amount must be greater than zero");

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
    }

    function assertBalance(address _account) public view returns (uint256) {
        assert(balances[_account] >= 0);
        return balances[_account];
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Withdrawal amount must be greater than zero");
        require(balances[msg.sender] >= _amount, "Not Enough Balance");

        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function emergencyWithdraw() public {
        require(msg.sender == owner, "Only Owner Can use this function");

        uint256 balance = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }

    function revertTransfer(address _recipient, uint256 _amount) public {

    if (_recipient != address(0) && balances[_recipient] >= _amount) {
        balances[_recipient] -= _amount;
        balances[msg.sender] += _amount;
    } else {
        revert("Receiver Address is wrong or Balance is not enough");
    }
    }
}
```

This contract, named SecureContract, is a simple banking system that allows users to deposit, transfer, and withdraw Ether. The contract has an owner, who is the address that deployed the contract, and maintains a mapping of user addresses to their respective balances. The contract has five main functions: deposit, which allows users to add Ether to their balance; transfer, which enables users to send Ether to another address; assertBalance, which returns the balance of a specified address; withdraw, which allows users to remove Ether from their balance; and emergencyWithdraw, which allows the owner to withdraw all Ether from their balance in case of an emergency.

Additionally, there is a revertTransfer function that allows users to revert a previous transfer if the recipient's address is valid and they have sufficient balance. The contract includes various require statements to ensure that invalid transactions are prevented, such as transferring to the zero address or attempting to withdraw more Ether than is available.
