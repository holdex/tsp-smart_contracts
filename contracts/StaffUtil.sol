pragma solidity ^0.4.0;


import "./Staff.sol";


contract StaffUtil {
	Staff public staffContract;

	constructor (Staff _staffContract) public {
		require(msg.sender == _staffContract.owner());
		staffContract = _staffContract;
	}

	modifier onlyOwner() {
		require(msg.sender == staffContract.owner());
		_;
	}

	modifier onlyOwnerOrStaff() {
		require(msg.sender == staffContract.owner() || staffContract.isStaff(msg.sender));
		_;
	}
}
