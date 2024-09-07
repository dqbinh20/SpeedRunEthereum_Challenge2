pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);
	uint256 public constant tokensPerEth = 100;

	YourToken public yourToken;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() public payable {
		require(msg.value > 0, "Send ETH to buy tokens");

		uint amountOfTokens = msg.value * tokensPerEth;

		uint vendorBalance = yourToken.balanceOf(address(this));
		require(
			vendorBalance >= amountOfTokens,
			"Vendor has insufficient tokens"
		);

		bool sent = yourToken.transfer(msg.sender, amountOfTokens);
		require(sent, "Failed to send tokens to buyer");
		emit BuyTokens(msg.sender, msg.value, amountOfTokens);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	// function withdraw() public onlyOwner {
	// 	uint ownerBalance = address(this).balance;
	// 	require(ownerBalance > 0, "No ETH left to withdraw");
	// 	(bool sent, ) = msg.sender.call{ value: address(this).balance }("");
	// 	require(sent, "Failed to send ETH");
	// }

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 amount) public {
		require(amount > 0, "Amount must be greater than zero");
		uint256 ethToReturn = amount / tokensPerEth;
		require(
			address(this).balance >= ethToReturn,
			"Vendor has insufficient ETH"
		);

		require(
			yourToken.transferFrom(msg.sender, address(this), amount),
			"Failed to transfer tokens from seller"
		);

		(bool sent, ) = msg.sender.call{ value: ethToReturn }("");
		require(sent, "Failed to send ETH to seller");

		emit SellTokens(msg.sender, amount, ethToReturn);
	}
}
