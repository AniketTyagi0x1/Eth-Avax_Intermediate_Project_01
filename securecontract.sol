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


