// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Auction {
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    enum State {Started, Running, Ended, Cancelled}
    State public auctionState; 

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping(address => uint) public bids;

    uint bidIncrement; 

    constructor(){
        owner = payable(msg.sender);
        auctionState = State.Running;
        // a new block is generated approx every 15 seconds
        startBlock = block.number;
        // if duration is 7 days, divide number of seconds in 7 days by 15 (i.e. seconds per block)
        endBlock = startBlock + 40320;
        ipfsHash = "";
        bidIncrement = 1 ether;
    }

    function getHighestBindingBid() view public  returns(uint){
        return highestBindingBid;
    }

    modifier notOwner{
        require(msg.sender != owner);
        _;
    }

    modifier afterStart() {
        require(block.number >= startBlock);
        _;
    }

    modifier beforeEnd() {
        require(block.number <= endBlock);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function min(uint a, uint b) pure internal returns(uint){
        if (a > b) {
            return a;
        }
        else {
            return b;
        }
    }


    function cancelAuction() public onlyOwner{
        auctionState = State.Cancelled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd {
        require(auctionState == State.Running);
        require(msg.value >= 100);

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);

        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        }
        else {
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }

    }

        function finaliseAuction() public {
            require(auctionState == State.Cancelled || block.number > endBlock);
            require(msg.sender == owner || bids[msg.sender] > 0);

            address payable recipient;
            uint value;

            if(auctionState == State.Cancelled){ // auction was cancelled 
                recipient = payable(msg.sender);
                value = bids[msg.sender];
            }
            else{ // auction ended, not canceleld
                if(msg.sender == owner) { // this is the owner
                    recipient = owner;
                    value = highestBindingBid;
                }
                else{ // this is a bidder calling the finaliseAuction function to receive back eth
                    if(msg.sender == highestBidder){ // the highest bidder – gets difference between highest bid and binding bid
                        recipient = highestBidder;
                        value = bids[highestBidder] - highestBindingBid;
                    }
                    else{ // another bidder receives their full bid amount back
                        recipient = payable(msg.sender);
                        value = bids[msg.sender];
                    }
                }
            }
        
            recipient.transfer(value);

        }


}