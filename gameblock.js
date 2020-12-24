const { Param } = require('@nestjs/common');
var TX = require('ethereumjs-tx');
const { async } = require('rxjs');
const Web3 = require('web3')
//const web3 = new Web3('')
var providerURL = "https://rinkeby.infura.io/v3/e72daeeafa5f4e8cae0110b45fed3645"
const web3 = new Web3(new Web3.providers.HttpProvider(providerURL));

var gameContractAddress = '0x3628552339b265c45D52809865326F2c5c4A8c39'
var nftContractAddress = '0x38a7338Fb3D19a253566C22f75c057f82C085A3C'
var starsContractAddress = '0x186ccb664c0f8683c07Bc80ebe1EB0fd5B336706'
var marketPlaceContractAddress = '0xa18C493221576c564dD38999D453Ed8a39CF85B8'
//Game interface
const interface = [
	{
		"constant": true,
		"inputs": [],
		"name": "stars",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "tokenID1",
				"type": "uint256"
			},
			{
				"name": "tokenID2",
				"type": "uint256"
			},
			{
				"name": "status",
				"type": "bool"
			}
		],
		"name": "clearTokens",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "nft_add",
				"type": "address"
			}
		],
		"name": "set_nft_address",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "value",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "token_add",
				"type": "address"
			}
		],
		"name": "set_token_address",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "nft",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "setValue",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_of",
				"type": "address"
			}
		],
		"name": "TotalCards",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "player1",
				"type": "address"
			},
			{
				"name": "player2",
				"type": "address"
			},
			{
				"name": "token1",
				"type": "uint256"
			},
			{
				"name": "token2",
				"type": "uint256"
			}
		],
		"name": "playGame",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_of",
				"type": "address"
			}
		],
		"name": "remainingScissor",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_of",
				"type": "address"
			}
		],
		"name": "remainingPaper",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "card1",
				"type": "uint256"
			},
			{
				"name": "card2",
				"type": "uint256"
			}
		],
		"name": "decide",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_stars",
				"type": "uint256"
			}
		],
		"name": "setStars",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_amount",
				"type": "uint256"
			}
		],
		"name": "setToken",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_of",
				"type": "address"
			}
		],
		"name": "showStars",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "starCount",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "player",
				"type": "address"
			},
			{
				"name": "_amount",
				"type": "uint256"
			}
		],
		"name": "transferBack",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "player",
				"type": "address"
			}
		],
		"name": "signUp",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "NoOfTokens",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "user",
				"type": "address"
			},
			{
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "cardDetails",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			},
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_of",
				"type": "address"
			},
			{
				"name": "_count",
				"type": "uint256"
			}
		],
		"name": "blockStars",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_of",
				"type": "address"
			}
		],
		"name": "remainingRock",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	}
]
var _interface = new web3.eth.Contract((interface) , gameContractAddress); //deployed address 


//NFT interface
const interface_nft = [
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "supply",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "approved",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "operator",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "bool",
				"name": "approved",
				"type": "bool"
			}
		],
		"name": "ApprovalForAll",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "approval",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "baseURI",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_supply",
				"type": "uint256"
			}
		],
		"name": "changeSeason",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "playeraddress",
				"type": "address"
			}
		],
		"name": "countMakeUp",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "playeraddress",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "cardtype",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "createToken",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "currentSeason",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "playerAddress",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_tokenId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "purchasedValue",
				"type": "uint256"
			}
		],
		"name": "freeCardOrPurchased",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "getApproved",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			}
		],
		"name": "isApprovedForAll",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "minted_supply_token",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "minted_tokens",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "ownToken",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "ownerOf",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "player",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "cardtype",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "free",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "playersTokenCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "returnAllDetails",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "returnOwnedToken",
		"outputs": [
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "returnSeason",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "typ",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "_totalcount",
				"type": "bool"
			}
		],
		"name": "returnTokenCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "safeTransferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "_data",
				"type": "bytes"
			}
		],
		"name": "safeTransferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "approved",
				"type": "bool"
			}
		],
		"name": "setApprovalForAll",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "contractAddress",
				"type": "address"
			}
		],
		"name": "setGameContractAddress",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "setMarketAddress",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes4",
				"name": "interfaceId",
				"type": "bytes4"
			}
		],
		"name": "supportsInterface",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "tokenByIndex",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_tokenId",
				"type": "uint256"
			}
		],
		"name": "tokenDetails",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "tokenOfOwnerByIndex",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "tokenOwners",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "tokenURI",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "token_Id",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "total_supply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "unminted_tokens",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
var _interact = new web3.eth.Contract((interface_nft) , nftContractAddress);


//Stars interface 
const interface_stars = [
	{
		"constant": true,
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_spender",
				"type": "address"
			},
			{
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [
			{
				"name": "success",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			},
			{
				"name": "",
				"type": "uint256"
			},
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "allowance",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_from",
				"type": "address"
			},
			{
				"name": "_to",
				"type": "address"
			},
			{
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [
			{
				"name": "success",
				"type": "bool"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "decimals",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "gameContractAddress",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_newaddress",
				"type": "address"
			}
		],
		"name": "changeowner",
		"outputs": [
			{
				"name": "success",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "request",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "returnSeason",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "ownerAddress",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_reduceSupply",
				"type": "uint256"
			}
		],
		"name": "DecreaseSupply",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_to",
				"type": "address"
			},
			{
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [
			{
				"name": "success",
				"type": "bool"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "currentSeason",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "changeSeason",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			},
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "balances",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_newSupply",
				"type": "uint256"
			}
		],
		"name": "IncreaseSupply",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "_initialSupply",
				"type": "uint256"
			},
			{
				"name": "_gameContractAddress",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "_from",
				"type": "address"
			},
			{
				"indexed": true,
				"name": "_to",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "_owner",
				"type": "address"
			},
			{
				"indexed": true,
				"name": "_spender",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	}
]
var star = new web3.eth.Contract(interface_stars, starsContractAddress);
 
 
 
//////////////////////////////////////////////////////////////////////////////////////////////////////////ACCOUNTS USED////////////

const account1  = '0xC6EBFdb69A29D77EefdeaaeaB2288Ad2Ee86EEB8'
const account2  = '0xF7C17c02428CcC44a35725DfDe473cCA2c4393ff'
const account3  = '0xf158F22ec9ef60A64F83Cf2BD59F6b5554E9caC4'
const account4 = '0x63580a35A6B6Da5c13c1Bf9c62C51FbCe64c806F';
const transferacc = '0xFcb269E2798C48CF4B93aAeCDF8CEc143AcC29b4';




const privateKey1 = new  Buffer.from('df41f70a767fce3d45fafe4b3b9cd5aa856ab304a17728c50ed99f43c7bac186' , 'hex');
const privateKey2 = new  Buffer.from('60d4a93d45c1b890b340db0fbc9ce48afedcee22f71433812828e5c8e8f7774c' , 'hex');
const privateKey3 = new  Buffer.from('1d74031771cabab38b07d31937bdcf279c712f0e2f358c1072bc0cf27898e004' , 'hex');
const privateKey4 = new Buffer.from('7958cb545ad3be8ad142a8f632c7c7cc5c8bc18bdd098f69998ee026e4fa525a' , 'hex');
const privatekeymine = new Buffer.from('f8e9cf0d026ae4b1eb8b38c717ba090a37576dbfa9dbd51e0f2542e12c573e57' , 'hex');
//const privatekeyhritik  = new Buffer.from('df41f70a767fce3d45fafe4b3b9cd5aa856ab304a17728c50ed99f43c7bac186' , 'hex');
//////////////////////////////////////////////////////////transcation function for game////////////////////////////////////////////
async function runCode(data , account , privateKey,  deployedAddress){
        
        var count = await web3.eth.getTransactionCount(account); 

        var Price =  await web3.eth.getGasPrice();
        
       
        var txData = {

                nonce: web3.utils.toHex(count),
                

                gasLimit: web3.utils.toHex(2500000),
                
                gasPrice: web3.utils.toHex(Price * 1.40),
                
                to: deployedAddress,                    
       
                from: account,  
                
                data: data
        
        };
                
        var run_code = new TX(txData, {'chain': 'rinkeby'});
        
       run_code.sign(privateKey); //change here 
        
        const serialisedrun_code =   run_code.serialize().toString('hex');
        
        const result = await  web3.eth.sendSignedTransaction('0x' + serialisedrun_code);
        console.log(result);
      
};




//////////////////////////////////////////////////////////////////////////////interact with game functions //////////////////////////////////////////
async function setNftAddress(_nftAddress , account , privateKey , deployedAddress){    ///function to link nft with game contract ///not to be used, it's already set
        try{
                var data = _interface.methods.set_nft_address(_nftAddress).encodeABI();
                runCode(data , account , privateKey , deployedAddress);
        }
        catch{
                throw{message: "ERROR: cann't set nft contract address"};
        }
        
}
async function setERC20Contractaddress(starContract_address ,  account , privateKey , deployedAddress){ ///function to link stars conttract with game contract //not to be used , already set
        try{
                var data = _interface.methods.set_token_address(starContract_address).encodeABI();
                runCode(data , account , privateKey , deployedAddress);
        }
        catch{
                throw{message: "ERROR: cann't set token contract address"};
        }
         
}
async function setOwner(owner_address , account , privateKey , deployedAddress){ /////function to set the owner of the game contract , not to be used already set
        try{
                var data = _interface.methods.setOwner(owner_address).encodeABI();
                runCode(data , account , privateKey , deployedAddress);
        }
        catch{
                throw{message: "ERROR: cann't set owner address"};
        }
}
async function setStars(_stars ,account , privateKey , deployedAddress ){ //////set initial stars to be  given to player, not to be used already set
        try{
                var data = _interface.methods.setStars(_stars).encodeABI();
                runCode(data , account , privateKey , deployedAddress);
        }
        catch{
                throw{message: "ERROR: cann't set star ammount"};
        }        
}
async function setValue(_value , account , privateKey , deployedAddress){///////set initial card value to be supplied to player , already set not to be used
        try{
                var data = _interface.methods.setValue(_value).encodeABI();
                runCode(data , account , privateKey , deployedAddress);
        }
        catch{
                throw{message: "ERROR: cann't set value of each nft"};
        }
        
}
async function setToken(_amount , account , privateKey , deployedAddress){   ////set token count (supply_ not be used already set)
        try{
                var data = await _interface.methods.setToken(_amount).encodeABI();
                runCode(data , account , privateKey , deployedAddress);
        }
        catch{
                throw{message: "ERROR: cann't set token ammount"};
        }
}
	async function signUP(player , account , privateKey , deployedAddress){ //// takes 4 argumets for signup , account of player  
	try{
			try
			{																//// , account, private key to be used for transaction and game contract addresss
			var data = await _interface.methods.signUp(player).encodeABI(); 
			await runCode(data , account , privateKey , deployedAddress); 
			return 1
			}
			catch(e)
			{
				return 0
			}
			
		}
        catch{
                throw{message: "ERROR: cann't signup"};
        }
	}									
async function totalCards( _of ){ //// argument : address returns : total cards given account address is holding
        try{
                var data = await _interface.methods.TotalCards(_of).call();
                //run_code(data);
                console.log(data);
                return data;
        }
        catch{
                throw{message: "ERROR: cann't show total cards this account is holding"};
        }
}

async function showStars(_of){   //  argument: address returns : total stars given account is holding
        try{
                var data = await _interface.methods.showStars(_of).call(); 
                //run_code(data);
                console.log(data);
                return data;
        }
        catch{
                throw{message: "ERROR: cann't show how many stars this address is holding "};
        }
}
async function remainingRock(_of){/////argument : address   returns: total rock cards of account
        try{
                var data= await _interface.methods.remainingRock(player);
                console.log(data);
                return data;
        }
        catch{
                throw{message: "rock doesn't exist"};

        }   

}
async function remainingPaper(_of){//////argumets : address    returns: totak paper cards of account
        try{
                var data= await _interface.methods.remainingPaper(player);
                console.log(data);
                return data;
        }
        catch{
                throw{message: "rock doesn't exist"};

        }   

}

async function remainingScissor(_of){ //////arguments: address  return: total scissor cards account is holding
        try{
                var data= await _interface.methods.remainingScissor(player);
                console.log(data);
                return data;
        }
        catch{
                throw{message: "rock doesn't exist"};

        }   

}



///////////////////////////////////////////////////////////////////nft functions//////////////////////////////////////////////////////////
     
      async function burn(tokenId , account , privateKey , deployedAddress){  ///burns the card , and card will no longer be accessible 
         try{
                 let cardDelete = await _interact.methods.burn(tokenId).encodeABI();
                runCode(cardDelete , account , privateKey , deployedAddress);
         }
          catch (e){
                throw{ message : "Token not burn"};
          }
	   }
	   
	   async function createNewToken(playerAddress,cardType,value, account , privateKey , deployedAddress){  ///burns the card , and card will no longer be accessible 
		try{
				let cardCreate = await _interact.methods.createToken(playerAddress,cardType,value).encodeABI();
			   runCode(cardCreate , account , privateKey , deployedAddress);
		}
		 catch (e){
			   throw{ message : "Token not Created"};
		 }
		}
       async function details(tokeId){ ////argument : tokenID   returns: card type ie rock . paper or scissor and card value
        try{
                var cardType;
                cardType = await _interact.methods.tokenDetails(tokeId).call();
                //It will return both type and value both respectively
                //console.log(cardType);
                return (cardType);
        }
        catch (e) {
                 throw{ message : "Token details not given"};
        }
      }
      
      async function returnOwnedToken(_address){ //// argument : address   returns : array of Ids given account address is holding
        try{
                let tokenList = await _interact.methods.returnOwnedToken(_address).call();
				console.log(tokenList);
				return tokenList;
                
        }
        catch(e){
                throw{message : "Owner not returned"};
        }
      }
      
   
       async function ownerOf(tokeId){////argument : tokenId    returns: account address of the owner of given tokenID
         try{
                let cardOwner = await _interact.methods.ownerOf(tokeId).call();
				//transaction(trx);
				console.log(cardOwner);
                return cardOwner;
         }
         catch (e){
                throw{ message : "Does not return owner"};
         }
      }
      
      async function transfer(_address,tokeId , account , privateKey , deployedAddress){/////trasnfer token from self to other account
        try{
		
                let transfer = await _interact.methods.transfer(_address,tokeId).encodeABI();
                runCode(transfer , account , privateKey , deployedAddress);
        }
        catch(e){
          throw{ message : "Transfer not successfull"};
        }
      }
      
      async function safeTransferFrom(_address, __address, tokenId , account , privateKey , deployedAddress){/////transfer token from other account to someone else account // requires approval
        try{
                let transfer = await _interact.methods.safeTransferFrom(_address, __address, tokenId).encodeABI();
                runCode(transfer , account , privateKey , deployedAddress);
        }
        catch(e){
          throw{message : "Transfer not successfull"};
        }
      }    
///////////////////////////////////////////////////////////stars contract functions/////////////////////////////////

async function Transfer(_to,value, account , privateKey , deployedAddress){ ///transfer stars from self to other
	try{

		console.log("this is address" + _to +"amount" + value + "account"+ account)
                var data = await star.methods.transfer(_to,value).encodeABI();
                runCode(data , account , privateKey , deployedAddress);
        }catch(err){
	        throw{ message : "ERROR : Token not transferred using transfer"};
}
}

async function totalCards_ofeachtype( _of ){ //// argument : address returns : total cards given account address is holding
	try{
			var data = {};
			data["ROCK"] = await _interface.methods.remainingRock(_of).call();
			data["PAPER"] = await _interface.methods.remainingPaper(_of).call();
			data["SCISSOR"] = await _interface.methods.remainingScissor(_of).call();
			console.log(data);
			return data;
	}
	catch{
			throw{message: "ERROR: cann't show total cards this account is holding"};
	}
}

async function TransferFrom(_from,_to,value , account , privateKey , deployedAddress){////transfer stars from other to someone else account ///approval needed 
        try{
                 var Transferred = await star.methods.transferFrom(account1,"0xFcb269E2798C48CF4B93aAeCDF8CEc143AcC29b4",70).encodeABI();
                runCode(Transferred , account , privateKey , deployedAddress);
        }
        catch(err){
                throw{ message : "ERROR : Token not transferred using transferFrom"};
        }
}

async function getbalance(_address){ //// argument: address returns : total stars account is holding
	try{
                balance = await star.methods.balanceOf(_address).call();
                console.log(balance);
                return balance;
        }catch(err){
                throw{ message : "ERROR : Balance not retrieved"};
        }
}


async function getAllDetails(address){
	const obj = {};
	const x = await returnOwnedToken(address);
	const y = x.toString().split(',');
	for(let i = 0 ; i < y.length ; ++i)
	{
		const z =  await details(y[i]);
		if(z[0] == '1') obj[y[i]] = 'rock';
		else if (z[0] == '2') obj[y[i]] = 'paper';
		else obj[y[i]] = 'scissor';
	}
	return obj;
}
async function approve(spender,value, account , privatekey,deployedAddress){
	try{
	var _approval = await star.methods.approve(spender,value);
	runCode(_approval , account , privatekey , deployedAddress);
	}
	catch(err){
		throw{ message : "ERROR : Account not Approved"};
}
}

var sign_up = async function(address,gameContractAddress) { return await signUP(address,account1,privateKey1,gameContractAddress); }
var show_stars = async function(address) { return await showStars(address);}
var total_cards = async function (address) { return await totalCards(address); }
var returnownedTokens = async function(playerAddress) { return await returnOwnedToken(playerAddress) }
var detailOfCard = async function(tokenId) { return await details(tokenId)}
var ownerof = async function(tokenId) { return await ownerOf(tokenId)}
var transferstar = async function(_to,value,account,gameContractAddress) { await Transfer(_to,value,account,privatekeyhritik,gameContractAddress)}
var transferfrom = async function(_from,_to,value, gameContractAddress) {await TransferFrom(_from,_to,value , account2 , privateKey2 , gameContractAddress)}
var burn = async function(tokenId,gameContractAddress) {  await burn(tokenId,account1,privateKey1,gameContractAddress)}
var getalldetails = async function(address) { await getAllDetails(address) }
// var _approve = async function(spender,value, account) { await approve(spender,value, account , privatekeyhritik,"0x0A27A7370D14281152f7393Ed6bE963C2019F5fe")}

// transferstar(transferacc,1,account1,privateKey1,"0x0A27A7370D14281152f7393Ed6bE963C2019F5fe").then((data)=>{
// 	console.log(data);
// });

// transferfrom("0x984C21390376b2CB0cE40fA80CCa2cFBd86C14B7",transferacc, 1,"0x0A27A7370D14281152f7393Ed6bE963C2019F5fe").then((data)=>{
// 	console.log(data);
// },
// (err)=>{
// 	console.log("error")
// });

module.exports = {
        sign_up:sign_up,
        show_stars:show_stars,
        total_cards:total_cards,
		returnownedTokens:returnownedTokens,
		detailOfCard:detailOfCard,
		ownerof:ownerof,
		Transfer:Transfer,
		burn:burn,
		getalldetails:getalldetails.apply,
		transferstars:transferstar,
		transferFrom:transferfrom,
}
 
//  for(var i=1;i<5;i++) 
//  {
//var d = createNewToken("0xFcb269E2798C48CF4B93aAeCDF8CEc143AcC29b4",3,40,account1,privateKey1,nftContractAddress);
//   }
returnOwnedToken("0xFcb269E2798C48CF4B93aAeCDF8CEc143AcC29b4");
//  console.log(show_stars("0xC6EBFdb69A29D77EefdeaaeaB2288Ad2Ee86EEB8"));
