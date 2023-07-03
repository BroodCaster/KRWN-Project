// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ERC721r.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract KRWN is ERC721r, Ownable, ReentrancyGuard {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 private platinumUpgradeCounter = 0;
  uint256 private diamondUpgradeCounter = 0;
  bool public paused = false;


  // Royalty and withdraw receiver adresses
  address public withdrawAddress = 0x3B715d4F5219510C7f77DB4388ebc0A1436B8430;
  // Royalty fee 5%

  constructor(
    string memory _initBaseURI
  ) ERC721r("KRWN", "KRWN", 8891) {
    setBaseURI(_initBaseURI);
  }

  // Returns a link to IPFS storage
  function _baseURI() internal view virtual returns (string memory) {
    return baseURI;
  }

  // Returns a link to contract metadata
  function contractURI() public pure returns (string memory) {
        return "https://bafkreidyd7vleonfzrotwjchzzqehj65hg7a2y3nh6odgq23k3oevy7h7a.ipfs.nftstorage.link/";
    }

  // Public mint
  function mint(address _to, uint256 tokenNum) external payable nonReentrant{
    uint256 supply = totalSupply();
    require(!paused);
    require(supply+tokenNum <= maxSupply, "All tokens are minted");
    require(price*tokenNum == msg.value, "Insufficient funds");
    
    _mintRandom(_to, tokenNum);
    _withdraw();
  }

  function upgradePlatinumBundle() public payable nonReentrant{
    uint256 supply = totalSupply();
    require(supply+11 <= maxSupply, "All tokens are minted");
    require(platinumUpgradeCounter < 20, "All slots are over");
    require(price*10 == msg.value, "Insufficient funds");

    _mintRandom(msg.sender, 10);
    sendUpgradedToken(msg.sender, reservedTokensPlatinum[platinumUpgradeCounter]);
    _withdraw();

    platinumUpgradeCounter++;
  }

  function upgradeDiamondBundle() public payable nonReentrant{
    uint256 supply = totalSupply();
    require(supply+31 <= maxSupply, "All tokens are minted");
    require(diamondUpgradeCounter < 10, "All slots are over");
    require(price*30 == msg.value, "Insufficient funds");

    _mintRandom(msg.sender, 30);
    sendUpgradedToken(msg.sender, reservedTokensDiamond[diamondUpgradeCounter]);
    _withdraw();

    diamondUpgradeCounter++;
  }

  function sendUpgradedToken(address _to, uint256 _tokenId) private {
    uint256 supply = totalSupply();
     _mint(_to, _tokenId);
     --remainingSupply;
     if(supply+1 == 1000 || supply+1 == 2000 || supply+1 == 3000 || supply+1 == 4000 || supply+1 == 5000 || supply+1 == 6000 || supply+1 == 7000 || supply+1 == 8000){
        uint256 _price = price*110/100;
        _setTokenPrice(_price);
      }
  }

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
    _setTokenPrice(_price);
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
  function _withdraw() private {
    (bool os, ) = payable(withdrawAddress).call{value: address(this).balance}("");
    require(os);
  }

  function withdraw() public onlyOwner {
    (bool os, ) = payable(withdrawAddress).call{value: address(this).balance}("");
    require(os);
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