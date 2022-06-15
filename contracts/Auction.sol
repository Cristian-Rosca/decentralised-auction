// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Migrations {
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
        bidIncrement = 100;
    }

}