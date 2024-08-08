// RE: inspired by https://github.com/Astronaut828/SpeedRunEthereum/blob/main/Challenge2/Vendor.sol

pragma solidity 0.8.4; // Do not change the solidity version as it negativly impacts submission grading

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import "hardhat/console.sol";

contract Vendor is Ownable {
	uint256 public constant tokensPerEth = 100;
	uint256 internal amountOfTokens;

	event BuyTokens(address indexed buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address indexed seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);

	YourToken public yourToken;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// TODO: create a payable buyTokens() function:
	function buyTokens() public payable {
		require(msg.value > 0);
		amountOfTokens = msg.value * tokensPerEth;
		yourToken.transfer(msg.sender, amountOfTokens);

		emit BuyTokens(msg.sender, msg.value, amountOfTokens);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() public onlyOwner {
		uint256 tempBalance = address(this).balance;
		require(tempBalance > 0, "No balance to withdraw");

		(bool sent, ) = msg.sender.call{ value: tempBalance }("");
		require(sent, "Failed to send Eth");
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 _amount) public {
		require(_amount > 0, "Amount must be greater than zero");

		uint256 etherToSend = _amount / tokensPerEth;

		require(
			address(this).balance >= etherToSend,
			"Not enough Ether in the contract"
		);

		require(yourToken.transferFrom(msg.sender, address(this), _amount));
		payable(msg.sender).transfer(etherToSend);

		emit SellTokens(msg.sender, _amount, etherToSend);
	}
}