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

interface erc20 {
    function transfer(address, uint256) external view returns (bool);

    function balanceOf(address) external view returns (uint256);

    function transferFrom(address,address,uint256) external payable returns (bool);
    
    function Seller_Approve_Market(address from , address spender ,uint256 _value) external payable ; 
}


 contract MarketPlace {
    
    erc20 public stars;

    NFT public nft;
    
    //address public escrow = 0x114dF342f9649f66E3e670bA29418b4693Fe3dA3;    
        
    address public owner_address;
    
    string rock_image;
    
    string paper_image;
    
    string scissor_image;

    uint256[] tokenid_added;

    uint256 public available_token_count;

    uint256 public totalAmount; //amount to be send by escrow to the seller of stars.

    uint256 public available_star_count;

    uint256 totalPool;

    uint256 starsPrice;
    
    uint256 finite_game_commision = 5; //precentage commision of finite games

    mapping(uint256 => token_sell_information) public token_details;

    mapping(address => stars_sell_information) public star_details;
    
    mapping(uint256 => biddingInformation) public bidderDetails;
    
    mapping(address => uint256) mappedPool;
    
    mapping(uint256 => string)  imagetype;
    
    struct token_sell_information {
        bool is_available;
        address buyer;
        address seller;
        uint256 price;
    }
    
     struct stars_sell_information {
        bool is_available;
        uint256 quantity_availaible;
    }

    struct biddingInformation {
        bool is_available;
        address owner;
        address bidder;
        uint256 value;
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

    function setErc20Address(address ___address) public onlyOwner {
        // set ERC20 address
        stars = erc20(___address);
    }

    
    function setStarsPrice(uint256 _price) public onlyOwner {
        // this is rresponsible for setting the star price
        starsPrice = _price;
    }
    
    function changeFiniteGamesCommision(uint256 new_commision) public onlyOwner {
        finite_game_commision = new_commision;
    }


    function increaseStarSupply(uint256 value) public payable onlyOwner {
        
        stars.Seller_Approve_Market(msg.sender,address(this),value);
        available_star_count = available_star_count + value;
        totalPool = totalPool + value;
        mappedPool[msg.sender] += value;
        star_details[msg.sender].is_available = true;
        star_details[msg.sender].quantity_availaible += value;
    }

    function decreaseStarSupply(uint256 value) public onlyOwner {                  //////only escrow account can call..
        // only admin will call this function. function is responsible for decrease stars count in market place
        
        available_star_count = available_star_count - value;
        totalPool = totalPool - value;
        mappedPool[msg.sender] -= value;
        if(value == star_details[msg.sender].quantity_availaible){
        delete star_details[msg.sender];
        }
        else{
        star_details[msg.sender].quantity_availaible -= value;
        }
    }

    
    function sellStars(uint256 count) public {
        require(stars.balanceOf(msg.sender) >= count);
        stars.Seller_Approve_Market(msg.sender,address(this),count);
        mappedPool[msg.sender] += count;
        star_details[msg.sender].is_available = true;
        star_details[msg.sender].quantity_availaible += count;
        totalPool = totalPool + count;
    }
   
   
    function buyStars(address payable seller,uint256 amount) public payable {             
        // this will be call by player who want to buy stars
        require(amount <= mappedPool[seller]);
        require(msg.value >= amount * starsPrice);
        stars.transferFrom(seller,msg.sender, amount);
        seller.transfer(msg.value);
        totalPool = totalPool - amount;
        if (amount == mappedPool[seller]) {
            delete (mappedPool[seller]);
            delete star_details[seller];
        } else {
            mappedPool[seller] -= amount;
            star_details[seller].quantity_availaible -= amount;
        }
    }
    
    function showTotalPool() public view returns (uint256) {
        // this will show the total pool size i.e stars available
        return totalPool;
    }
    
    
    
    
    function increaseTokenSupply(uint256 cardType, uint256 value) public payable onlyOwner
    {
        
        uint256 tokenid = nft.createToken(msg.sender, cardType, value);
        tokenid_added.push(tokenid);
        nft.SellerApproveMarket(msg.sender,address(this),tokenid);
        token_details[tokenid].is_available = true;
        token_details[tokenid].buyer = address(0);
        token_details[tokenid].seller = msg.sender;
        available_token_count++;
    
    }

    function decreaseTokenSupply(uint256 tokenId) public payable onlyOwner {
       require(nft.ownerOf(tokenId) == msg.sender,"seller is not owner");
        for(uint256 i=0; i<tokenid_added.length;i++){
            if(tokenid_added[i]==tokenId){
                tokenid_added[i] = 0;
                break;
            }
        }
        delete token_details[tokenId];
        available_token_count--;
    }
    
    
    
    function sellCard(uint256 tokenid_,uint256 amount) public {
        
        
        require(nft.ownerOf(tokenid_) == msg.sender,"seller is not owner");
        require(token_details[tokenid_].is_available == false,"token already in selling");
        require(bidderDetails[tokenid_].is_available == false,"This token is avaiable for bidding"); 
        nft.SellerApproveMarket(msg.sender,address(this),tokenid_);
        token_details[tokenid_].is_available = true;
        token_details[tokenid_].seller = msg.sender;
        token_details[tokenid_].buyer = address(0);
        token_details[tokenid_].price = amount;
        tokenid_added.push(tokenid_);
        available_token_count++;
        
    }
   
     function revokeCard(uint256 tokenid_) public {
        
        
        require(nft.ownerOf(tokenid_) == msg.sender,"seller is not owner");
        require(token_details[tokenid_].is_available == true,"token is not avaiable for selling");
        require(bidderDetails[tokenid_].is_available == false,"This token is avaiable for bidding"); 
        //Seller gives Approval of token id to address(0)
        nft.SellerApproveMarket(msg.sender,address(0),tokenid_);
        delete token_details[tokenid_];
        available_token_count--;
        for(uint256 i = 0;i<tokenid_added.length;i++){
            if(tokenid_added[i] == tokenid_){
                tokenid_added[i] = 0;
                break;
            }
        }
        
    }
   
    function buyCard(address payable seller,uint256 tokenid_) public payable {        
        
        
        address owner = nft.ownerOf(tokenid_);
        require(token_details[tokenid_].is_available == true,"token id not availaible for sell");
        require(token_details[tokenid_].seller == seller,"provided seller is not seller of this token id");
        require(token_details[tokenid_].buyer == address(0),"card already purchased");
        require(owner == token_details[tokenid_].seller,"The person does not own this token"); 
        require(bidderDetails[tokenid_].is_available != true,"This token is avaiable for bidding"); 
        
        uint256 token_type;
        uint256 value;
        address payable finite_owner = payable(owner_address);
        
        
        (token_type, value) = nft.tokenDetails(tokenid_);
        require(msg.value >= token_details[tokenid_].price); //check given value is greater or equal to token value
        
        nft.safeTransferFrom(seller,msg.sender, tokenid_);
        nft.freeCardOrPurchased(msg.sender, tokenid_,1, imagetype[token_type],"",address(0)); // this will make that the card is purchased card
        
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
    
    
    function showAvailableTokenForSelling() public view returns (string[] memory available){
        // returns the array of token present in marketplace
        string[] memory available_token_for_sell = new string[](available_token_count);
        uint256 j;
        uint256 token_type;
        uint256 value;
        for (uint256 i = 0; i < tokenid_added.length; i++) {
            if (token_details[tokenid_added[i]].is_available == true) {
                (token_type, value) = nft.tokenDetails(tokenid_added[i]);
                available_token_for_sell[j] = string(abi.encodePacked(tokenid_added[i],"@",token_type));
                j++;
            }
        }
        return available_token_for_sell;
    }


/*-----------------------------------------------Bidding Part-----------------------------------------------------*/



    function makeTokenAvailableForBidding(uint256 tokenId) public {
        require(
            nft.ownerOf(tokenId) == msg.sender,
            "The token is not owned by the person"
        );
        bidderDetails[tokenId].is_available = true;
        bidderDetails[tokenId].owner = nft.ownerOf(tokenId);
        bidderDetails[tokenId].bidder = address(0);
        bidderDetails[tokenId].value = 0;
    }
    
    function getBidStatus(uint256 tokenId) public view returns (bool) {
        return bidderDetails[tokenId].is_available;
    }

    function closeBidding(uint256 tokenId, address bidderAddress, uint256 amountOfBidding,
                         string memory image_Add,string memory ipfs,address sponsor) public {
        address tokenOwner = nft.ownerOf(tokenId);
        require(tokenOwner == msg.sender,"sender is not owner");
        require(bidderDetails[tokenId].is_available == true,"token is not in bidding");
        //nft.SellerApproveMarket(msg.sender,address(this),tokenId);
        bidderDetails[tokenId].is_available = false;
        bidderDetails[tokenId].owner = tokenOwner;
        bidderDetails[tokenId].bidder = bidderAddress;
        bidderDetails[tokenId].value = amountOfBidding;
        nft.freeCardOrPurchased(msg.sender, tokenId,2,image_Add,ipfs,sponsor);
    }
    
    // function get_your_bidded_card(uint256 tokenId) public payable{
    //     require(bidderDetails[tokenId].is_available == false,"token is in bidding");
    //     require(msg.sender == bidderDetails[tokenId].bidder,"sender is not the bidder");
    //     require(msg.value >= bidderDetails[tokenId].value,"insufficient fund");
    //     address payable lister = payable(bidderDetails[tokenId].owner);
    //     lister.transfer(msg.value);
    //     nft.safeTransferFrom(lister,msg.sender, tokenId);
    //     nft.freeCardOrPurchased(msg.sender, tokenId,2); // this will make that the card is bidded card
        
        
    // }
}
