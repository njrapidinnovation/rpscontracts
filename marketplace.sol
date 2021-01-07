// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.23;
interface NFT {
    
    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external payable;

    function tokenDetails(uint256 _tokenId) external view returns (uint256, uint256);

    function transfer(address, uint256) external payable;
    
    function freeCardOrPurchased(address playerAddress, uint256 _tokenId , uint256 purchasedValue ,
    string memory image_add,string memory ipfs_link,address sponsor) external ;
    
    function createToken(address,uint256,uint256) external payable returns (uint256);
    
    function SellerApproveMarket(address from , address spender , uint256 tokenId) external;
}


 contract MarketPlace {
    
    NFT public nft;
    
    using Strings for *;
    
    address public owner_address;
    
    string rock_image;  //address of image rock token
    
    string paper_image;  // address of image of paper token
    
    string scissor_image; //address of image of scissor token

    uint256[] tokenid_added;  //this array stores the token id which are availaible to sell ownership rights

    uint256 public available_token_count; //count of avaiable token for selling its ownership rights
    
    uint256 constant marketTokenPrice = 500; //token price of each token purchase from marketplace
    
    uint256 finite_game_commision = 5; //precentage commision of finite games

    mapping(uint256 => token_sell_information) public token_details;
    
    mapping(uint256 => biddingInformation) public bidderDetails;
    
    mapping(uint256 => string)  imagetype;
    
    struct token_sell_information {
        bool is_available;
        address buyer;
        address seller;
        uint256 price;
    }

    struct biddingInformation {
        bool is_available;
        address owner;
        address[] bidder;
        uint256 max_bid;
        uint256 reserve_price;
        address bid_winner;
        bool auction_stage; //true for complete false for running or not started
    }


    modifier onlyOwner {
        require(msg.sender == owner_address);
        _;
    }

    constructor() public {
        owner_address = msg.sender;
        imagetype[1] = rock_image;
        imagetype[2] = paper_image;
        imagetype[3] = scissor_image;
    }

    function setNftAddress(address _address) public onlyOwner {
        //set NFT token contract address (ERC721)
        nft = NFT(_address);
    }


    function changeFiniteGamesCommision(uint256 new_commision) public onlyOwner {
        finite_game_commision = new_commision;
    }

    function buyCardFromAdmin(uint token_type) public payable {        
        
        require(token_type == 1 || token_type == 2 || token_type == 3);
        uint256 tokenid = nft.createToken(owner_address,token_type,100);
        nft.SellerApproveMarket(owner_address,address(this),tokenid);
        require(msg.value >= marketTokenPrice); //check given value is greater or equal to token value
        nft.safeTransferFrom(owner_address,msg.sender, tokenid);
        nft.freeCardOrPurchased(msg.sender, tokenid,1, imagetype[token_type],"",address(0)); // this will make that the card is purchased card
        payable(owner_address).transfer(msg.value);
        
    }

    
    //Fixed Auction to sell card OwnerShip Rights
    function sell_Card_Ownership_At_FixedAmount(uint256 tokenid_,uint256 amount) public {
        
        require(nft.ownerOf(tokenid_) == msg.sender,"seller is not owner");
        require(token_details[tokenid_].is_available == false,"token already in selling");
        require(bidderDetails[tokenid_].is_available == false,"This token is avaiable for bidding"); 
        token_details[tokenid_].is_available = true;
        token_details[tokenid_].seller = msg.sender;
        token_details[tokenid_].buyer = address(0);
        token_details[tokenid_].price = amount;
        tokenid_added.push(tokenid_);
        available_token_count++;
        
    }
   
     //revoke card from fixed auction for Owner Rights
     function revokeCard(uint256 tokenid_) public payable {
        
        
        require(nft.ownerOf(tokenid_) == msg.sender,"seller is not owner");
        require(token_details[tokenid_].is_available == true,"token is not avaiable for selling");
        require(bidderDetails[tokenid_].is_available == false,"This token is avaiable for bidding"); 
        delete token_details[tokenid_];
        available_token_count--;
        for(uint256 i = 0;i<tokenid_added.length;i++){
            if(tokenid_added[i] == tokenid_){
                tokenid_added[i] = 0;
                break;
            }
        }
        
    }
   
    function buy_Card_Ownership(address payable seller,uint256 tokenid_,string memory ipfs_ownership_link) public payable {        
        
        
        address owner = nft.ownerOf(tokenid_);
        require(token_details[tokenid_].is_available == true,"token id not availaible for selling Ownership Rights");
        require(token_details[tokenid_].seller == seller,"provided seller is not seller of this token id");
        require(token_details[tokenid_].buyer == address(0),"card already purchased");
        require(owner == token_details[tokenid_].seller,"The person does not own this token"); 
        require(bidderDetails[tokenid_].is_available == false,"This token is avaiable for bidding"); 
        
        uint256 token_type;
        uint256 value;
        address payable finite_owner = payable(owner_address);
        
        
        (token_type, value) = nft.tokenDetails(tokenid_);
        require(msg.value >= token_details[tokenid_].price); //check given value is greater or equal to token value
        
        nft.freeCardOrPurchased(owner, tokenid_,2, imagetype[token_type],ipfs_ownership_link,msg.sender); // this will make that the card is purchased card
        
        uint temp_commision = (finite_game_commision * (msg.value))/100;
        
        finite_owner.transfer(temp_commision);
        seller.transfer(msg.value - temp_commision);
        
        token_details[tokenid_].is_available = false;
        token_details[tokenid_].buyer = msg.sender;
        available_token_count--;
        for(uint256 i = 0;i<tokenid_added.length;i++){
            if(tokenid_added[i] == tokenid_){
                tokenid_added[i] = 0;
                break;
            }
        }

    }
    
    

    
    function show_Available_Token_For_Selling_OwnerShip() public view returns (string[] memory available){
        // returns the array of token present in marketplace
        string[] memory available_token_for_sell = new string[](available_token_count);
        uint256 j;
        uint256 token_type;
        uint256 value;
        for (uint256 i = 0; i < tokenid_added.length; i++) {
            if (token_details[tokenid_added[i]].is_available == true) {
                (token_type, value) = nft.tokenDetails(tokenid_added[i]);
                available_token_for_sell[j] = string(abi.encodePacked(tokenid_added[i].uinttoString(),"@",token_type.uinttoString()));
                j++;
            }
        }
        return available_token_for_sell;
    }


/*-----------------------------------------------English Auction Part-----------------------------------------------------*/



    function makeTokenAvailableForEnglishAuction(uint256 tokenId,uint256 token_reserve_price) public {
        require(
            nft.ownerOf(tokenId) == msg.sender,
            "The token is not owned by the person"
        );
        require(bidderDetails[tokenId].is_available == false);
        bidderDetails[tokenId].is_available = true;
        bidderDetails[tokenId].owner = nft.ownerOf(tokenId);
        bidderDetails[tokenId].reserve_price = token_reserve_price;
    }
    
    function getBidStatus(uint256 tokenId) public view returns (bool,address) {
        return (bidderDetails[tokenId].is_available,bidderDetails[tokenId].bidder[bidderDetails[tokenId].bidder.length -1]);
    }
    
    function bidOnToken(uint256 token_id,uint256 amount) public {
        require(bidderDetails[token_id].is_available == true,"token not availaible for bidding");
        require(amount>bidderDetails[token_id].reserve_price && amount > bidderDetails[token_id].max_bid);
        bidderDetails[token_id].max_bid = amount;
        bidderDetails[token_id].bidder.push(msg.sender);
    }

    function closeBidding(uint256 tokenId) public {
        
        address tokenOwner = nft.ownerOf(tokenId);
        require(tokenOwner == msg.sender,"sender is not owner");
        require(bidderDetails[tokenId].is_available == true,"token is not in bidding");
        //nft.SellerApproveMarket(msg.sender,address(this),tokenId);
        bidderDetails[tokenId].is_available = false;
        bidderDetails[tokenId].auction_stage = true;
        bidderDetails[tokenId].owner = tokenOwner;
        bidderDetails[tokenId].bid_winner = bidderDetails[tokenId].bidder[bidderDetails[tokenId].bidder.length - 1];
        nft.SellerApproveMarket(msg.sender,address(this),tokenId);
        
    }
    
    function getbidwinner(uint tokenid) public view returns(address){
        require(bidderDetails[tokenid].auction_stage == true);
        return bidderDetails[tokenid].bid_winner;
    }
    
    function get_your_bidded_card(uint256 tokenId) public payable{
        require(bidderDetails[tokenId].is_available == false,"token is in bidding");
        require(msg.sender == bidderDetails[tokenId].bid_winner,"sender is not the bidder");
        require(msg.value >= bidderDetails[tokenId].max_bid,"insufficient fund");
        address payable seller = payable(bidderDetails[tokenId].owner);
        uint256 token_type;
        uint256 value;
        (token_type, value) = nft.tokenDetails(tokenId);
        address payable finite_owner = payable(owner_address);
        nft.safeTransferFrom(seller,msg.sender, tokenId);
        nft.freeCardOrPurchased(msg.sender, tokenId,2, imagetype[token_type],"",address(0)); // this will make that the card is purchased card
        
        uint temp_commision = (finite_game_commision * (msg.value))/100;
        
        finite_owner.transfer(temp_commision);
        seller.transfer(msg.value - temp_commision);
        
    }
}

library Strings {
    /* @dev Converts a uint256 to its ASCII string representation.
     */
     
     

     
function _toLower(string memory str) public pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
    function uinttoString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
     /*-------------------------To Compare two strings---------------------------*/
    function compare(string memory  _a, string memory _b) internal pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    function equal(string memory _a, string memory _b) internal pure returns (bool) {
        return compare(_a, _b) == 0;
    }
   function toString(address account) public pure returns(string memory) {
    return toString(abi.encodePacked(account));
}

function toString(uint256 value) public pure returns(string memory) {
    return toString(abi.encodePacked(value));
}

function toString(bytes32 value) public pure returns(string memory) {
    return toString(abi.encodePacked(value));
}

function toString(bytes memory data) public pure returns(string memory) {
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(2 + data.length * 2);
    str[0] = "0";
    str[1] = "x";
    for (uint i = 0; i < data.length; i++) {
        str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
        str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
    }
    return string(str);
}
}
