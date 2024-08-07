// RE: inspired by https://github.com/Astronaut828/SpeedRunEthereum/blob/main/Challenge1/Staker.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; // Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	uint256 public constant threshold = 1 ether;
	uint256 public deadline = block.timestamp + 72 hours;

	event Stake(address indexed staker, uint256 stake);

	mapping(address => uint256) public balances;

	ExampleExternalContract public exampleExternalContract;

	// @notice Modifier to check if deadline has been met
	modifier deadlineMet() {
		require(block.timestamp > deadline, "Deadline not Met");
		_;
	}

    // @notice Modifier to check if deadline has been met
    modifier deadlineNotMet() {
        require(block.timestamp <= deadline, "Deadline has been met");
        _;
    }

	// @notice Modifier to check if threshold has been met
	modifier thresholdNotMet() {
		require(getTotalBanalce() < threshold, "Threshold has been Met");
		_;
	}

	// @notice Modifier to check if external contract 'ExampleExternalContract' has been completed or not
	modifier notCompleted() {
		require(
			exampleExternalContract.completed() == false,
			"ExampleExternalContract is completed"
		);
		_;
	}

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	// @notice Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
	// (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
	function stake() public payable deadlineNotMet {
		balances[msg.sender] += msg.value;

		emit Stake(msg.sender, msg.value);
	}

	// @notice After some `deadline` allow anyone to call an `execute()` function
	// @notice If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    // TODO: #1
	function execute() public deadlineMet notCompleted {
        if (getTotalBanalce() >= threshold) {
            exampleExternalContract.complete{ value: address(this).balance }();
        }
	}

	// @notice `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
	function withdraw() public thresholdNotMet {
		uint256 tempBalance = balances[msg.sender];
		require(tempBalance > 0, "No balance to withdraw");

		balances[msg.sender] = 0;

		(bool sent, ) = msg.sender.call{ value: tempBalance }("");
		require(sent, "Failed to send Eth");
	}

	// @notice `timeLeft()` view function that returns the time left before the deadline for the frontend
	function timeLeft() public view returns (uint256 timer) {
		if (block.timestamp <= deadline) {
			timer = deadline - block.timestamp;
			return timer;
		} else if (block.timestamp >= deadline) {
			return 0;
		}
	}

    // @notice `getTotalBanalce()` view function that returns the total balance of the contract
    function getTotalBanalce() public view returns (uint256) {
        return address(this).balance;
    }

	// @notice The `receive()` special function that receives eth and calls stake()
	receive() external payable {
		stake();
	}
}