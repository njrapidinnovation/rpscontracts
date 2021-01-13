// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../QuestCrypto/Context.sol";
import "../QuestCrypto/IERC721Metadata.sol";
import "../QuestCrypto/IERC721Enumerable.sol";
import "../QuestCrypto/IERC721Receiver.sol";
import "../QuestCrypto/ERC165.sol";
import "../QuestCrypto/Address.sol";
import "../QuestCrypto/EnumerableSet.sol";
import "../QuestCrypto/EnumerableMap.sol";

interface Finite_Games_MarketPlace {
      struct token_sell_information {
        bool is_available;
        address buyer;
        address seller;
        uint256 price;
    }
    
    struct biddingInformation {
        bool is_available;
        address owner;
        address bidder;
        uint256 value;
    }
    
    function token_details(uint256) external returns(token_sell_information calldata);
    
    function bidderDetails(uint256) external returns(biddingInformation calldata);
    
}  

contract RPS is Context, ERC165, IERC721Metadata, IERC721Enumerable {
    
    struct card {
        uint256 cardtype; //1: Rock , 2: Paper, 3 : Scissors
        uint256 value;
        uint256 free; //0 for free 1 for purchased 2 for bidded
        string image_address;
        string ipfs_contract_link;
        address sponsor;
    }
   
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;


    /*----------------------MAPPINGS START----------------------------*/

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;
    
    //Mapping from currentSeason to card type to total supply of each tokens
    mapping( uint256 => mapping(uint => uint)) public minted_supply_token;
    
    //Mapping from currentSeason to total supply of tokens
    mapping( uint256 => uint256) public total_supply;
    
    //Mapping from currentSeason to no. of minted tokens
    mapping(uint256 => uint256) public minted_tokens;
    
    //Mapping from currentSeason and token id to tokenowner address
    mapping(uint256 => mapping(uint256 => address)) public tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    
    //Mapping from playerAddress to currentSeason to tokenid to card structure(cardtype,value,free)
    mapping(address => mapping(uint256 => mapping(uint256 => card)))
    public player;

    //Mapping from playerAddress to currentSeason to cardtype(1,2,3) to no. of card of that type that it holds
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
    public playersTokenCount;
    
    //Mapping from playerAddress to currentSeason to array of cardids holded by player
    mapping(address => mapping(uint256 => uint256[])) public ownToken;
    
    //Mapping from currentSeason to tokenid to approved player to spend the cards
    mapping(uint256 => mapping(uint256 => address)) public approval;
    
    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;
    
    //Mapping from playerAddress to ccurrentSeason to a string(null@tokenid, "!", tokentype, "!", tokenvalue@tokenid, "!", tokentype, "!", tokenvalue)
    mapping(address => mapping(uint256 => string)) allDetails;

    /*----------------------MAPPINGS END----------------------------*/
   
    /*----------------------VARIABLES DECLARED----------------------------*/
    
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;
    
    // Token ID
    uint256 public token_Id = 0;

    //address of this contract owner
    address contractowner;
    
    //deployed address of game contract 
    address gameContractAddress;
    
    //current game season
    uint256 public currentSeason = 1;
    
    //deploed address of market contract
    address marketAddress;
    
    //MarketPlace interface address
    Finite_Games_MarketPlace finite_Address;
    
    //Store tokenIds with their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;
    
    //set supply of each token
    uint supply_of_each_token;
    
    // Base URI
    string private _baseURI;
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (uint256 supply) public {
        
        _name = "ROSHAMBO";
        _symbol = "ROSH";
        total_supply[currentSeason] = supply;
        supply_of_each_token = supply/3; 
        contractowner = msg.sender;
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }
    
    modifier onlyOwner() {
        require(msg.sender == contractowner);
        _;
    }
    
    function setGameContractAddress(address contractAddress) public payable {
        require(msg.sender == contractowner);
        gameContractAddress = contractAddress;
    }

    function setMarketAddress(address _address) public payable {
        require(msg.sender == contractowner);
        marketAddress = _address;
        finite_Address = Finite_Games_MarketPlace(_address);
    }

    function changeSeason(uint256 _supply) public payable onlyOwner {
        currentSeason += 1;
        total_supply[currentSeason] =_supply;
    }
    
    function SellerApproveMarket(address from , address spender , uint256 tokenId) public {
        
        require(msg.sender == marketAddress,"caller is not market");
        address owner = ownerOf(tokenId);
        require(spender != owner, "Both Owner And Spender is same");
        require(from == owner , "Approver is not owner");
         _tokenApprovals[tokenId] = spender;
        approval[currentSeason][tokenId] = spender;
        emit Approval(ownerOf(tokenId), spender, tokenId);
    }
    
    function createToken(
        address playeraddress,
        uint256 cardtype,
        uint256 _value
    ) public payable returns (uint256) {
        /* It will create the token at contractowner address */
    
        
        require(minted_tokens[currentSeason]<total_supply[currentSeason]);
        require(minted_supply_token[currentSeason][cardtype] < supply_of_each_token);    
        require(
            msg.sender == contractowner ||
            msg.sender == gameContractAddress ||
            msg.sender == marketAddress
        );
        
        player[playeraddress][currentSeason][++token_Id].cardtype = cardtype;
        player[playeraddress][currentSeason][token_Id].value = _value;
        ownToken[playeraddress][currentSeason].push(token_Id);
        playersTokenCount[playeraddress][currentSeason][cardtype] += 1;
        _tokenOwners.set(token_Id, playeraddress);
        _holderTokens[playeraddress].add(token_Id);
        string memory tempTok = "";
        string memory tempVal = "";
        string memory tempTyp = "";
        string memory fnl = "";
        tempTyp = uinttoString(cardtype);
        tempVal = uinttoString(_value);
        tempTok = uinttoString(token_Id);
        fnl = string(abi.encodePacked(tempTok, "!", tempTyp, "!", tempVal));
        allDetails[playeraddress][currentSeason] = string(
            abi.encodePacked(allDetails[playeraddress][currentSeason], "@", fnl)
        );
        emit Transfer(address(0),playeraddress,token_Id);
        tokenOwners[currentSeason][token_Id] = playeraddress;
        minted_tokens[currentSeason]++;
        minted_supply_token[currentSeason][cardtype]++;
        return token_Id;
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
    
     function returnAllDetails(address _user) public view returns (string memory) {
        return allDetails[_user][currentSeason];
    }

    function tokenDetails(uint256 _tokenId)
        public
        view
        returns (uint256, uint256)
    {
        /* Function to return the type of the token and its value*/
        require(
            tokenOwners[currentSeason][_tokenId] != address(0),
            "Not a valid token"
        );
        address _address = tokenOwners[currentSeason][_tokenId];
        return (
            (player[_address][currentSeason][_tokenId].cardtype),
            player[_address][currentSeason][_tokenId].value
        );
    }

    function returnOwnedToken(address owner) public view returns (uint256[] memory) {
        return ownToken[owner][currentSeason];
    }

    function returnTokenCount(
        address _address,
        uint256 typ,
        bool _totalcount
    ) public view returns (uint256) {
        /* Function to return the total count of the token*/
        if (_totalcount == true) {
            uint256 count = playersTokenCount[_address][currentSeason][1] +
                playersTokenCount[_address][currentSeason][2] +
                playersTokenCount[_address][currentSeason][3];
            return count;
        } else {
            return playersTokenCount[_address][currentSeason][typ];
        }
    }
 

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }


    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        // If there is no base URI, return the token URI.
        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(_baseURI, uinttoString(tokenId)));
    }

    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    /**  
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }
    

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_tokenApprovals[tokenId] == address(0));
        require(approval[currentSeason][tokenId] == address(0));

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(finite_Address.token_details(tokenId).is_available == false,"token is in selling");
        require(finite_Address.bidderDetails(tokenId).is_available == false,"token is in bidding");
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(approval[currentSeason][tokenId] == msg.sender);
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }





    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
    
         address token_address = ownerOf(tokenId);
        
         uint256 token_type = player[token_address][currentSeason][tokenId]
            .cardtype;

        tokenOwners[currentSeason][tokenId] = to;
        player[to][currentSeason][tokenId].cardtype = player[from][currentSeason][tokenId].cardtype;
        player[to][currentSeason][tokenId].value = player[from][currentSeason][tokenId].value;
        playersTokenCount[to][currentSeason][token_type] += 1;
        playersTokenCount[from][currentSeason][token_type] -= 1;
        for (
            uint256 i = 0;
            i < ownToken[from][currentSeason].length;
            i++
        ) {
            if (ownToken[from][currentSeason][i] == tokenId) {
                ownToken[from][currentSeason][i] = 0;
                break;
            }
        }
        ownToken[to][currentSeason].push(tokenId);
        delete (player[from][currentSeason][tokenId]);

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        approval[currentSeason][tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
    
    function returnSeason() public view returns (uint256) {
        return currentSeason;
    }
    
    function freeCardOrPurchased(address playerAddress, uint256 _tokenId , uint256 purchasedValue ,
    string memory image_add,string memory ipfs_link,address sponsor) public { // function to change the value of card from free card to purchsed card
     // this will be called from marketplace only as then it would become purchased card or a bidded card
     require(msg.sender == marketAddress);
     if(purchasedValue == 2){
         player[playerAddress][currentSeason][_tokenId].free=purchasedValue;
         player[playerAddress][currentSeason][_tokenId].image_address = image_add;
         player[playerAddress][currentSeason][_tokenId].ipfs_contract_link = ipfs_link;
         player[playerAddress][currentSeason][_tokenId].sponsor = sponsor;
     }
     else{
         player[playerAddress][currentSeason][_tokenId].free=purchasedValue;
         player[playerAddress][currentSeason][_tokenId].image_address = image_add;
     }

    }
    
    function unminted_tokens() public view returns(uint256){
        return total_supply[currentSeason] - minted_tokens[currentSeason];
    }
    
    function countMakeUp(address playeraddress) public payable{
        require(
            msg.sender == contractowner ||
            msg.sender == gameContractAddress ||
            msg.sender == marketAddress
        );
        uint256 count1 = returnTokenCount(playeraddress, 1,false); // count of Rock available
        uint256 count2 = returnTokenCount(playeraddress, 2,false); // count of Paper available
        uint256 count3 = returnTokenCount(playeraddress, 3,false); // count of Scissors available
        for(uint256 k=0 ; k < 3 ; k++){
            if( count1 < 10 && k == 0){
                count1 = 10 - count1;
                for(uint256 i=0; i< count1 ; i++){
                    createToken(playeraddress,1,20); // this will make the count of the Rock to 20 
                }
            }
            if( count2 < 10 && k == 1){
                count2 = 10 - count2;
                for(uint256 j=0; j< count2 ; j++){
                    createToken(playeraddress,2,20); // this will make the count of the Paper to 20 
                }
            }
            if( count3 < 10 && k == 2){
                count3 = 10 - count3;
                for(uint256 m=0; m< count1 ; m++){
                    createToken(playeraddress,3,20); // this will make the count of the Scissors to 20 
                }
            }
        }
    }
    
}
