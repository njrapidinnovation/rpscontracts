// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.7.0;

contract nftAuction {

    mapping(uint256 =>address payable) public beneficiary ;
    mapping(uint256 =>uint256) public auctionEndTime ;
    
    // Current state of the auction.
    mapping(uint256 => address) public highestBidder;
    mapping(uint256 => uint256) public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address =>mapping(uint256 => uint256)) pendingReturns;

    // Set to true at the end, disallows any change.
    // By default initialized to false.
    mapping(uint256 => bool) ended;
    
    address public owner;

    // Events that will be emitted on changes.
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    
    constructor() public {
        owner = msg.sender;
    }

    function startAuction(uint256 _biddingTime ,address payable _beneficiary,uint256 _tokenId) public{
        require(msg.sender == owner);
        beneficiary[_tokenId] = _beneficiary;
        auctionEndTime[_tokenId] = now + _biddingTime;

    }

    // bid on auction with given value..
    function bid(uint256 _tokenId) public payable {
        // Revert the call if the bidding
        // period is over.
        require(
            now <= auctionEndTime[_tokenId],
            "Auction already ended."
        );

        // If the bid is not higher, send money back.
        require(
            msg.value > highestBid[_tokenId],
            "There already is a higher bid."
        );

        if (highestBid[_tokenId] != 0) {
            // Sending back the money by simply using
            // highestBidder.send(highestBid) is a security risk
            // because it could execute an untrusted contract.
            // It is always safer to let the recipients
            // withdraw their money themselves.
    
            pendingReturns[highestBidder[_tokenId] ][_tokenId] += highestBid[_tokenId];
        }
        highestBidder[_tokenId] = msg.sender;
        highestBid[_tokenId] = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// Withdraw a bid that was overbid.
    function withdraw(uint256 _tokenId) public returns (bool) {
        uint amount = pendingReturns[msg.sender][_tokenId];
        require(amount >0);
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before send returns.
            pendingReturns[msg.sender][_tokenId] = 0;

            if (!msg.sender.send(amount)) {
                // No need to call throw here, just reset the amount owing
                pendingReturns[msg.sender][_tokenId] = amount;
                return false;
            }
        }
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd(uint256 _tokenId) public {
        require(msg.sender==owner);
        // 1. Conditions
        require(now >= auctionEndTime[_tokenId], "Auction not yet ended.");
        require(!ended[_tokenId], "auctionEnd has already been called.");

        // 2. Effects
        ended[_tokenId] = true;
        emit AuctionEnded(highestBidder[_tokenId], highestBid[_tokenId]);

        // 3. Interaction
        beneficiary[_tokenId].transfer(highestBid[_tokenId]);
    }
}
