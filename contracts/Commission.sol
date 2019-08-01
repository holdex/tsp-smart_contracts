pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract Commission is Ownable {
	using SafeMath for uint256;

	address payable wallet;

	constructor(address payable _wallet) public {
		wallet = _wallet;
	}

	// Customers ===================================================================================

	event CustomerAdded(address indexed customer, address indexed wallet, uint256 commission);
	event CustomerUpdated(address indexed customer, address indexed wallet, uint256 commission);
	event CustomerRemoved(address indexed customer);

	mapping(address => Customer) public customers;

	struct Customer {
		address payable wallet;
		uint256 commissionPercent;
		mapping(bytes32 => Partner) partners;
	}

	function addCustomer(address _customer, address payable _wallet, uint256 _commissionPercent) external onlyOwner {
		// Inputs validation
		require(_customer != address(0), "missing customer address");
		require(_wallet != address(0), "missing wallet address");
		require(_commissionPercent < 100, "invalid commission percent");

		// Check if customer already exists
		if (customers[_customer].wallet == address(0)) {
			// Customer does not exist, add it
			customers[_customer] = Customer(_wallet, _commissionPercent);
			emit CustomerAdded(_customer, _wallet, _commissionPercent);
		} else {
			// Customer already exists, update it
			customers[_customer].wallet = _wallet;
			customers[_customer].commissionPercent = _commissionPercent;
			emit CustomerUpdated(_customer, _wallet, _commissionPercent);
		}
	}

	function removeCustomer(address _customer) external onlyOwner {
		delete customers[_customer];
		emit CustomerRemoved(_customer);
	}

	// Partners ====================================================================================

	event PartnerAdded(address indexed customer, bytes32 indexed partner, address indexed wallet, uint256 commission);
	event PartnerUpdated(address indexed customer, bytes32 indexed partner, address indexed wallet, uint256 commission);
	event PartnerRemoved(address indexed customer, bytes32 indexed partner);

	struct Partner {
		address payable wallet;
		uint256 commissionPercent;
	}

	function addPartner(address _customer, bytes32 _partner, address payable _wallet, uint256 _commissionPercent) external onlyOwner {
		// Inputs validation
		require(_customer != address(0), "missing customer address");
		require(_partner != "", "missing partner id");
		require(_wallet != address(0), "missing wallet address");
		require(_commissionPercent < 100, "invalid commission percent");

		// Check if partner already exists
		if (customers[_customer].partners[_partner].wallet == address(0)) {
			// Partner does not exist, add it
			customers[_customer].partners[_partner] = Partner(_wallet, _commissionPercent);
			emit PartnerAdded(_customer, _partner, _wallet, _commissionPercent);
		} else {
			// Partner already exists, update it
			customers[_customer].partners[_partner].wallet = _wallet;
			customers[_customer].partners[_partner].commissionPercent = _commissionPercent;
			emit PartnerUpdated(_customer, _partner, _wallet, _commissionPercent);
		}
	}

	function removePartner(address _customer, bytes32 _partner) external {
		delete customers[_customer].partners[_partner];
		emit PartnerRemoved(_customer, _partner);
	}

	// Funds/Commissions Transfers =================================================================

	//	event
	//
	//	function transfer(string partner) external payable {
	//		require(msg.sender == crowdsale);
	//
	//		uint256 fundsToTransfer = msg.value;
	//
	//		if (txFeeCapInWei > 0 && txFeeSentInWei < txFeeCapInWei) {
	//			for (uint i = 0; i < txFeeAddresses.length; i++) {
	//				uint256 txFeeToSendInWei = msg.value.mul(txFeeNumerator[i]).div(txFeeDenominator);
	//				if (txFeeToSendInWei > 0) {
	//					txFeeSentInWei = txFeeSentInWei.add(txFeeToSendInWei);
	//					fundsToTransfer = fundsToTransfer.sub(txFeeToSendInWei);
	//					txFeeAddresses[i].transfer(txFeeToSendInWei);
	//				}
	//			}
	//		}
	//
	//		ethFundsWallet.transfer(fundsToTransfer);
	//	}
}
