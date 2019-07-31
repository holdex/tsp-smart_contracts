pragma solidity ^0.5.0;

interface IStaff {
	function owner() external view returns (address);

	function isStaff(address s) external view returns (bool);
}
