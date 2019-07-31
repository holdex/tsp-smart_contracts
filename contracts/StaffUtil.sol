pragma solidity ^0.5.0;


import "./interfaces/IStaff.sol";


contract StaffUtil {
	IStaff public staffContract;

	constructor (IStaff _staffContract) public {
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
