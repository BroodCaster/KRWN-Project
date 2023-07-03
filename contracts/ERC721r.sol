// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import {LibPRNG} from "./LibPRNG.sol";
import './ERC721Enumerable.sol';
import "@openzeppelin/contracts/token/common/ERC2981.sol";

abstract contract ERC721r is ERC721Enumerable, ERC2981 {
    using LibPRNG for LibPRNG.PRNG;
    using Strings for uint256;
    
    error ContractsCannotMint();
    error MustMintAtLeastOneToken();
    error NotEnoughAvailableTokens();
    
    string private _name;
    string private _symbol;
    address public royaltyReceiver = 0x8624523c8ae280EbDF7F720332Cda62620fe1DaD;
    uint96 public fee = 500;
    uint256 public price = 20000000000000000;

    uint256[] reservedTokensPlatinum = [1, 4, 109, 106, 11, 14, 135, 138, 341, 348, 351, 358, 378, 373, 621, 626, 683, 684, 741, 796];
    uint256[] reservedTokensDiamond = [324, 326, 441, 446, 605, 608, 654, 821, 828, 653];
    
    mapping(uint256 => uint256) private _availableTokens;
    uint256 public remainingSupply;
    
    uint256 public immutable maxSupply;
    
    constructor(string memory name_, string memory symbol_, uint256 maxSupply_) {
        _name = name_;
        _symbol = symbol_;
        maxSupply = maxSupply_;
        remainingSupply = maxSupply_;
    }
    
    function totalSupply() public view override  virtual returns (uint256) {
        return maxSupply - remainingSupply;
    }
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    
    function numberMinted(address minter) public view virtual returns (uint32) {
        return uint32(ERC721._getAux(minter) >> 192);
    }

    function _mintRandom(address to, uint256 _numToMint) internal virtual {
        if (msg.sender != tx.origin) revert ContractsCannotMint();
        if (_numToMint == 0) revert MustMintAtLeastOneToken();
        if (remainingSupply < _numToMint) revert NotEnoughAvailableTokens();
        
        LibPRNG.PRNG memory prng = LibPRNG.PRNG(uint256(keccak256(abi.encodePacked(
            block.timestamp, block.prevrandao
        ))));
        
        uint256 updatedRemainingSupply = remainingSupply;
        
        for (uint256 i = 1; i <= _numToMint; ) {
            uint256 randomIndex = prng.uniform(updatedRemainingSupply);
            uint256 supply = totalSupply();

            uint256 tokenId = getAvailableTokenAtIndex(randomIndex, updatedRemainingSupply);
            while(isReservedToken(tokenId) == true){
                randomIndex = prng.uniform(updatedRemainingSupply);
                tokenId = getAvailableTokenAtIndex(randomIndex, updatedRemainingSupply);
            }
            
            _mint(to, tokenId);
            _setTokenRoyalty(i, royaltyReceiver, fee);
            
            --updatedRemainingSupply;
            if(supply+i == 1000 || supply+i == 2000 || supply+i == 3000 || supply+i == 4000 || supply+i == 5000 || supply+i == 6000 || supply+i == 7000 || supply+i == 8000){
                uint256 _price = price*110/100;
                _setTokenPrice(_price);
            }
            
            unchecked {++i;}
            
        }
        
        _incrementAmountMinted(to, uint32(_numToMint));
        remainingSupply = updatedRemainingSupply;
    }

    function _setTokenPrice(uint256 _price) internal{
        price = _price;
    }

    function isReservedToken(uint256 _tokenId) public view returns(bool){
        bool result;
        for(uint16 i = 0; i < 20; i++){
            if(_tokenId == reservedTokensPlatinum[i]){
                result = true;
                break; 
            }else{
                result = false;
            }
        }
        if(result == false){
            for(uint16 i = 0; i < 10; i++){
                if(_tokenId == reservedTokensDiamond[i]){
                    result = true;
                    break;
                }else{
                    result = false; 
                }
            }
        }
        return result;
    }
    
    // Must be called in descending order of index
    function _mintAtIndex(address to, uint256 index) internal virtual {
        if (msg.sender != tx.origin) revert ContractsCannotMint();
        if (remainingSupply == 0) revert NotEnoughAvailableTokens();
        
        uint256 tokenId = getAvailableTokenAtIndex(index, remainingSupply);
        
        --remainingSupply;
        _incrementAmountMinted(to, 1);
        
        _mint(to, tokenId);
    }

    // Implements https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle. Code taken from CryptoPhunksV2
    function getAvailableTokenAtIndex(uint256 indexToUse, uint256 updatedNumAvailableTokens)
        private
        returns (uint256 result)
    {
        uint256 valAtIndex = _availableTokens[indexToUse];
        uint256 lastIndex = updatedNumAvailableTokens - 1;
        uint256 lastValInArray = _availableTokens[lastIndex];
        
        result = valAtIndex == 0 ? indexToUse : valAtIndex;
        
        if (indexToUse != lastIndex) {
            _availableTokens[indexToUse] = lastValInArray == 0 ? lastIndex : lastValInArray;
        }
        
        if (lastValInArray != 0) {
            delete _availableTokens[lastIndex];
        }
    }
    
    function _setExtraAddressData(address minter, uint192 extraData) internal virtual {
        uint32 numMinted = numberMinted(minter);
        
        ERC721._setAux(
            minter,
            uint64((uint64(numMinted) << 192)) | uint64(extraData)
        );
    }
    
    function _getAddressExtraData(address minter) internal view virtual returns (uint192) {
        return uint192(ERC721._getAux(minter));
    }
    
    function _incrementAmountMinted(address minter, uint32 newMints) private {
        uint32 numMinted = numberMinted(minter);
        uint32 newMintNumMinted = numMinted + uint32(newMints);
        uint224 auxData = ERC721._getAux(minter);
        
        ERC721._setAux(
            minter,
            uint64(uint64(newMintNumMinted) << 192) | uint64(uint192(auxData))
        );
    }

  function supportsInterface(bytes4 interfaceId) public view virtual override (ERC721Enumerable, ERC2981) returns(bool){
      return super.supportsInterface(interfaceId);
  }
}