// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.7.0;

interface NFT {
        function ownerOf(uint256 _tokenId) external view returns (address);
   
       function safeTransferFrom(address _from,address _to,uint256 _tokenId) external payable;
       
       function approveMArketOrGame(address from , address spender , uint256 tokenId) external payable;
}

contract nftAuction {
    struct finalDetails{
        address bidder;
        uint256 bidAmount;
    }

    NFT public nft;

    mapping(uint256 =>address payable) public beneficiary ;
    mapping(uint256 =>uint256) public auctionEndTime ;
    
    mapping( uint256 =>bool) public checkOwnerWantsBid;
    // Current state of the auction.
    mapping(uint256 => address payable) public highestBidder;
    mapping(uint256 => uint256) public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address =>mapping(uint256 => uint256)) pendingReturns;

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    mapping(uint256 => bool) ended; 
    
    mapping(uint256 => finalDetails) public finalBidder; 
     
    address public owner;
    address bidContractAddress;

    // Events that will be emitted on changes.
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    event AuctionStarted(uint _biddingTime ,address payable _beneficiary , uint256 _tokenId);
    
    constructor() public {
        owner = msg.sender;
    }
    
   function setNftAddress(address _address) public  {
        require(msg.sender == owner);
        //set NFT token contract address (ERC721)
        nft = NFT(_address);
    }
    
     function setBidAddress(address _address) public{
        require(msg.sender == owner);
        bidContractAddress = _address;
    }
    
    function listForBid(uint256 _tokenId) public {
        require(msg.sender == nft.ownerOf(_tokenId));
        checkOwnerWantsBid[_tokenId] = true;
        nft.approveMArketOrGame(msg.sender,bidContractAddress,_tokenId);
    }
    
    function startAuction(uint256 _biddingTime ,address payable _beneficiary,uint256 _tokenId) public{
        require(msg.sender == owner);
        require(checkOwnerWantsBid[_tokenId],"Owner doesn't wants to bid token");
        beneficiary[_tokenId] = _beneficiary;
        auctionEndTime[_tokenId] = now + _biddingTime;
        emit AuctionStarted(_biddingTime,_beneficiary,_tokenId);
    }

    // bid on auction with given value..
    function bid(uint256 _tokenId) public payable {
        // Revert the call if the bidding
        // period is over.
        require(
            now <= auctionEndTime[_tokenId],
            "Auction already ended."
        );
    // Auction is revoked
        require(
            !ended[_tokenId] ,
            "Auction revoked."
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
            // before `send` returns.
            pendingReturns[msg.sender][_tokenId] = 0;

            if (!msg.sender.send(amount)) {
                // No need to call throw here, just reset the amount owing
                pendingReturns[msg.sender][_tokenId] = amount;
                return false;
            }
        }
        return true;
    }
    
    //bidder and the bid amount at which bid closes..
    function detailsAfterBid(uint256 _tokenId) public view returns(uint256,address) {
        require(now>auctionEndTime[_tokenId],"Auction not ended or no auction for this token");
        return(finalBidder[_tokenId].bidAmount,finalBidder[_tokenId].bidder);
    }


    function revoke(uint256 _tokenId) public{                // this should be called by the owner of token to revoke the bid.
          require(msg.sender == nft.ownerOf(_tokenId));
          highestBidder[_tokenId].transfer(highestBid[_tokenId]);     
          highestBid[_tokenId] = 0;
          highestBidder[_tokenId] = address(0);
          ended[_tokenId] = true;
    }


    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd(uint256 _tokenId) public {
        require(msg.sender==owner);
        require(now >= auctionEndTime[_tokenId], "Auction not yet ended.");
        require(!ended[_tokenId], "auctionEnd has already been called.");
        
        
        ended[_tokenId] = true;
        emit AuctionEnded(highestBidder[_tokenId], highestBid[_tokenId]);
        
        beneficiary[_tokenId].transfer(highestBid[_tokenId]);
        nft.safeTransferFrom(nft.ownerOf(_tokenId),highestBidder[_tokenId],_tokenId);
        finalBidder[_tokenId].bidder = highestBidder[_tokenId];
        finalBidder[_tokenId].bidAmount = highestBid[_tokenId];
        highestBid[_tokenId] = 0;
        highestBidder[_tokenId] = address(0);
    }
}
