pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import "hardhat/console.sol";

contract Vendor is Ownable {

  YourToken yourToken;

  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }


  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "Send ETH for tokens");

    uint256 Buyamt = msg.value * tokensPerEth;

    uint256 amountOfTokens = yourToken.balanceOf(address(this));
    require(amountOfTokens >= Buyamt, "Vendor doesn't have enough tokens to sell");

    (bool sent) = yourToken.transfer(msg.sender, Buyamt);
    require(sent, "Failed to transfer token to user");
    emit BuyTokens(msg.sender, msg.value, Buyamt);

    return Buyamt;
  }

  function withdraw() public onlyOwner {
  uint256 ownerBalance = address(this).balance;
  require (ownerBalance > 0, "Owner doesn't have enough to withdraw");

  (bool sent,) = msg.sender.call{value: address(this).balance}("");
  require(sent, "Failed to send user balance back to the owner");



  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH


  // ToDo: create a sellTokens() function:

  function sellTokens(uint256 tokenAmountToSell) public {
  require(tokenAmountToSell > 0, "Specify an amount of token greater than zero");

  uint256 userBalance = yourToken.balanceOf(msg.sender);
  require(userBalance >= tokenAmountToSell, "Your balance is lower than the amount of tokens you want to sell");

  uint256 transferAMT = tokenAmountToSell / tokensPerEth;
  uint256 ownerETHBalance = address(this).balance;
  require(ownerETHBalance >= transferAMT, "Vendor doesn't have funds to accept the sell request");

  (bool sent) = yourToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
  require(sent, "Failed to transfer tokens from user to vendor");

  (sent,) = msg.sender.call{value: transferAMT}("");
  require(sent, "Failed to send ETH to the user");
  }


  function vendorBuyback(uint256 amount) public {

    yourToken.transferFrom(msg.sender, address(this), amount);
    

  }

}
