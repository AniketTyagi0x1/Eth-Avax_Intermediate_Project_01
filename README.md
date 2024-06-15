# Chandigarh University Summer Internship With Metacrafters ETH+Avax Intermediate Project 01

## Project Introduction 

The code represents a Solidity smart contract named Exception that showcases exception handling using require(), assert(), and revert() statements. Overall The main objective of this smart contract is to demonstrate different ways of handling exceptions and errors in Solidity.

| Statement | Purpose | Behavior | Gas Refund | Error Message |
| --- | --- | --- | --- | --- |
| `require` | Validate user input, access control, and conditions | If condition is false, revert transaction and refund gas | ✅ | Customizable error message |
| `revert` | Revert transaction and refund gas | Immediately revert transaction and refund gas | ✅ | Customizable error message |
| `assert` | Check for internal errors, invariant conditions | If condition is false, terminate contract execution and consume all gas | ❌ | "Assertion failed" |

## Escrow Contract Explanation

An escrow contract is a type of smart contract that holds funds or assets on behalf of two or more parties involved in a transaction. The funds are released only when predefined conditions are met, ensuring that both parties fulfill their obligations.

#### Parties Involved

**Buyer:** The party depositing the funds or assets into the escrow.
**Seller:** The party receiving the funds or assets upon successful completion of the transaction.
**Arbiter:** A neutral third party who resolves disputes and can trigger the release or refund of the escrowed funds.

#### States and State Transitions:
**Created:** Initial state when the escrow contract is deployed and the funds are deposited.
**Locked:** State indicating that the conditions for holding the funds are in progress, and the funds are securely locked in the escrow.
**Released:** Final state where the funds are either transferred to the seller or refunded to the buyer.

## Contract Explanation 

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Escrow {
    
    enum EscrowState { Created, Locked, Released } 
    
    address payable public buyer;
    address payable public seller; 
    address public arbiter; 
    uint256 public amount; 
    EscrowState public state; 

    constructor(address payable _buyer, address payable _seller, address _arbiter) payable {
        require(msg.value > 0, "Invalid escrow amount"); 
        require(_buyer != address(0), "Invalid buyer address"); 
        require(_seller != address(0), "Invalid seller address"); 
        require(_arbiter != address(0), "Invalid arbiter address"); 
        
        buyer = _buyer; 
        seller = _seller; 
        arbiter = _arbiter;
        amount = msg.value; 
        state = EscrowState.Created; 
    }
    
    function lock() public {

        require(msg.sender == buyer || msg.sender == seller || msg.sender == arbiter, "Unauthorized");
        require(state == EscrowState.Created, "Invalid state transition"); 
        
        state = EscrowState.Locked; 
    }
    
    function releaseToSeller() public payable  {

        require(state == EscrowState.Locked, "Invalid state transition"); 
        require(msg.sender == buyer || msg.sender == arbiter, "Unauthorized"); 
        seller.transfer(amount); 
        state = EscrowState.Released; 
    }
    
    function refundToBuyer() public payable {

        require(state == EscrowState.Locked, "Invalid state transition"); 
        require(msg.sender == seller || msg.sender == arbiter, "Unauthorized"); 
        
        buyer.transfer(amount); 
        state = EscrowState.Released; 
    }
    
    function cancelEscrow() public {

        require(state == EscrowState.Created || state == EscrowState.Locked, "Invalid state transition");
        require(msg.sender == buyer || msg.sender == seller || msg.sender == arbiter, "Unauthorized");
        
        if (state == EscrowState.Locked) {
            seller.transfer(amount); 
        }
        
        state = EscrowState.Released; 
        revert("Escrow canceled"); 
    }
    
    function resetState() public {

        require(msg.sender == arbiter, "Only arbiter can reset state");
        
        state = EscrowState.Created;
    }

    function assertInvariant() public view {
        
        assert(state == EscrowState.Created || state == EscrowState.Locked || state == EscrowState.Released); 
        assert(amount > 0); 
        assert(buyer != address(0)); 
        assert(seller != address(0)); 
        assert(arbiter != address(0));
    }
}
```

An enum is a user-defined type that consists of a set of named values. Here, EscrowState is an enum with three possible states:
Created: Initial state when the escrow is created.
Locked: State when the funds are locked in escrow.
Released: State when the funds are released to the seller or refunded to the buyer.
Enums help in defining a clear set of states for the contract, making the code more readable and easier to manage.

**Variable **

these state variables store the essential data for the escrow contract:
buyer: The address of the buyer, who deposits the funds. It is payable, meaning it can receive funds.
seller: The address of the seller, who will receive the funds if the transaction completes successfully. It is also payable.
arbiter: The address of a neutral third party that can resolve disputes. It is not payable because the arbiter does not need to receive funds.
amount: The amount of funds held in escrow.
state: The current state of the escrow, using the EscrowState enum.

These variables are marked as public, which means they can be read from outside the contract.

**Constructor **

The constructor is a special function that is executed once when the contract is deployed. It initializes the state variables and sets up the initial state of the contract. Here's what each part does:

address payable _buyer, address payable _seller, address _arbiter: Parameters for initializing the buyer, seller, and arbiter addresses.
require(msg.value > 0, "Invalid escrow amount"): Ensures that the contract is deployed with a positive amount of Ether.
require(_buyer != address(0), "Invalid buyer address"): Ensures the buyer address is valid.
require(_seller != address(0), "Invalid seller address"): Ensures the seller address is valid.
require(_arbiter != address(0), "Invalid arbiter address"): Ensures the arbiter address is valid.
buyer = _buyer: Initializes the buyer state variable.
seller = _seller: Initializes the seller state variable.
arbiter = _arbiter: Initializes the arbiter state variable.
amount = msg.value: Sets the amount to the Ether sent with the transaction.
state = EscrowState.Created: Sets the initial state to Created.

**Lock Function**

The lock function transitions the state of the escrow from Created to Locked.

require(msg.sender == buyer || msg.sender == seller || msg.sender == arbiter, "Unauthorized"): Ensures that only the buyer, seller, or arbiter can call this function.
require(state == EscrowState.Created, "Invalid state transition"): Ensures that the current state is Created before transitioning to Locked.
state = EscrowState.Locked: Changes the state to Locked.

**Seller function **

The releaseToSeller function transfers the escrow funds to the seller. Here's the breakdown:
require(state == EscrowState.Locked, "Invalid state transition"): Ensures that the state is Locked before proceeding.
require(msg.sender == buyer || msg.sender == arbiter, "Unauthorized"): Ensures that only the buyer or arbiter can call this function.
seller.transfer(amount): Transfers the funds to the seller.
state = EscrowState.Released: Changes the state to Released.

**Buyer Seller **

The refundToBuyer function refunds the escrow funds to the buyer. Here's how it works:
require(state == EscrowState.Locked, "Invalid state transition"): Ensures that the state is Locked before proceeding.
require(msg.sender == seller || msg.sender == arbiter, "Unauthorized"): Ensures that only the seller or arbiter can call this function.
buyer.transfer(amount): Refunds the funds to the buyer.
state = EscrowState.Released: Changes the state to Released.

**Escrow function **

The cancelEscrow function cancels the escrow contract. Here's the detailed explanation:
require(state == EscrowState.Created || state == EscrowState.Locked, "Invalid state transition"): Ensures that the current state is either Created or Locked.
require(msg.sender == buyer || msg.sender == seller || msg.sender == arbiter, "Unauthorized"): Ensures that only the buyer, seller, or arbiter can call this function.
if (state == EscrowState.Locked) { seller.transfer(amount); }: If the state is Locked, transfers the funds to the seller.
state = EscrowState.Released: Changes the state to Released.
revert("Escrow canceled"): Reverts the transaction with the message "Escrow canceled". This is an explicit revert that provides feedback about the cancellation.

**assert function **

The assertInvariant function checks several conditions to ensure the contract's integrity. Here’s what it does:
assert(state == EscrowState.Created || state == EscrowState.Locked || state == EscrowState.Released): Asserts that the state is one of the valid states.
assert(amount > 0): Asserts that the escrow amount is greater than 0.
assert(buyer != address(0)): Asserts that the buyer address is valid.
assert(seller != address(0)): Asserts that the seller address is valid.
assert(arbiter != address(0)): Asserts that the arbiter address is valid.
This function uses assert to enforce these conditions, which helps in detecting logical errors during development and testing.
