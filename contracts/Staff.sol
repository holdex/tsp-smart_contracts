pragma solidity ^0.4.24;


import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/ownership/rbac/RBAC.sol";


contract Staff is Ownable, RBAC {

	string public constant ROLE_STAFF = "staff";

	function addStaff(address _staff) public onlyOwner {
		addRole(_staff, ROLE_STAFF);
	}

	function removeStaff(address _staff) public onlyOwner {
		removeRole(_staff, ROLE_STAFF);
	}

	function isStaff(address _staff) view public returns (bool) {
		return hasRole(_staff, ROLE_STAFF);
	}
}
