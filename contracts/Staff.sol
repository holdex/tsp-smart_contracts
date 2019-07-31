pragma solidity ^0.5.0;


import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/access/Roles.sol";


contract Staff is Ownable {
	using Roles for Roles.Role;

	event StaffAdded(address indexed staff);
	event StaffRemoved(address indexed staff);

	Roles.Role private _staff;

	function addStaff(address s) public onlyOwner {
		_staff.add(s);
		emit StaffAdded(s);
	}

	function removeStaff(address s) public onlyOwner {
		_staff.remove(s);
		emit StaffRemoved(s);
	}

	function isStaff(address s) public view returns (bool) {
		return _staff.has(s);
	}
}
