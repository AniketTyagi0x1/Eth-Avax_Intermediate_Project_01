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
