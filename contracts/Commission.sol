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
			customers[_customer].wallet = _wallet;
			customers[_customer].commissionPercent = _commissionPercent;
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
		require(_commissionPercent > 0 && _commissionPercent < 100, "invalid commission percent");

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

	// Transfer Funds ==============================================================================

	function transfer(bool holdex, bytes32[] calldata _partners) external payable {
		// Inputs validation
		require(customers[msg.sender].wallet != address(0), "customer does not exist");
		require(msg.value > 0, "transaction value is 0");

		// Check if customer pays any commission
		if (customers[msg.sender].commissionPercent == 0) {
			// No commission. Transfer all funds
			customers[msg.sender].wallet.transfer(msg.value);
			return;
		}

		// Check if customer should pay some commission on this transaction
		if (holdex || _partners.length > 0) {
			// Commission applies. Calculate each's revenues

			// Customer revenue
			uint256 customerRevenue = msg.value.div(100).mul(100 - customers[msg.sender].commissionPercent);
			// Transfer revenue to customer
			customers[msg.sender].wallet.transfer(customerRevenue);

			// Calculate Holdex revenue
			uint256 holdexRevenue = msg.value.sub(customerRevenue);
			uint256 alreadySentPercent = 0;
			// Calculate partners revenues
			for (uint256 i = 0; i < _partners.length; i++) {
				Partner memory p = customers[msg.sender].partners[_partners[i]];
				require(p.commissionPercent > 0, "invalid partner");

				// Calculate partner revenue
				uint256 partnerRevenue = holdexRevenue.div(100 - alreadySentPercent).mul(p.commissionPercent);
				p.wallet.transfer(partnerRevenue);

				// Subtract partner revenue from Holdex revenue
				alreadySentPercent = alreadySentPercent.add(p.commissionPercent);
				holdexRevenue = holdexRevenue.sub(partnerRevenue);
			}

			require(holdexRevenue > 0, "holdex revenue is 0");
			// Transfer Holdex remained revenue
			wallet.transfer(holdexRevenue);
		}
	}
}
