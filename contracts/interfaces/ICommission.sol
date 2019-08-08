pragma solidity ^0.5.0;

interface ICommission {
	function transfer(bool holdex, bytes32[] calldata _partners) external payable;
}
