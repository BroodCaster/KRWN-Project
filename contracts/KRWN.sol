// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract KRWN is ERC721Enumerable, Ownable, ReentrancyGuard, ERC2981 {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public maxSupply = 891;
  uint256 public price = 20000000000000000;
  bool public paused = false;

  // Royalty and withdraw receiver adresses
  address public royaltyReceiver = 0x0c69B35eFe05ecEdA747dDb404825E367fD79D22;
  address public withdrawAddress = 0x2d558f2C83D509F3D1B857a36970BC0D0a80dAEC;
  // Royalty fee 5%
  uint96 public fee = 500;

  constructor(
    string memory _initBaseURI
  ) ERC721("KRWN Studio", "KRWN") {
    setBaseURI(_initBaseURI);
  }

  // Returns a link to IPFS storage
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // Returns a link to contract metadata
  function contractURI() public pure returns (string memory) {
        return "https://bafkreighdqctgobot4wdhrnrvqdvv3axhvfisllc5r55m2ajwwgvgvn7sq.ipfs.nftstorage.link/";
    }

  // Public mint
  function mint(uint256 tokenId) public payable nonReentrant{
    uint256 supply = totalSupply();
    require(!paused);
    require(supply+1 <= maxSupply);
    require(price <= msg.value, "Insufficient funds");
    
    _safeMint(msg.sender, tokenId);
    _setTokenRoyalty(tokenId, royaltyReceiver, fee);

  }

  // Returns the number of owner tokens
  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  // Token metadata
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI,"Hoodie%20", tokenId.toString(), baseExtension))
        : "";
  }

  // Returns current token price
  function getTokenPrice() public view returns(uint256) {
    return price;
  }

  // Sets token price
  function setTokenPrice(uint256 _price) public onlyOwner {
    price = _price;
  }

  // Sets IPFS link
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  // Sets Base Extension
  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  // Pause contract
  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
  
  // Returns "True" if the token exists, and "False" otherwise
  function exists(uint256 tokenId) public view returns(bool){
    return _exists(tokenId);
  }

  // Withdrawing contract balance to withdrawAddress
  function withdraw() public payable onlyOwner {
    (bool os, ) = payable(withdrawAddress).call{value: address(this).balance}("");
    require(os);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override (ERC721Enumerable, ERC2981) returns(bool){
      return super.supportsInterface(interfaceId);
  }

  // Burns token
  function _burn(uint256 tokenId) internal virtual override {
      super._burn(tokenId);
      _resetTokenRoyalty(tokenId);
    }

  function burnNFT(uint256 tokenId) public onlyOwner{
    _burn(tokenId);
  }
}