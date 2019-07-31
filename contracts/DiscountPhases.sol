pragma solidity ^0.4.24;


import "./Staff.sol";
import "./StaffUtil.sol";
import "./Crowdsale.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract DiscountPhases is StaffUtil {
	using SafeMath for uint256;

	address public crowdsale;
	modifier onlyCrowdsale() {
		require(msg.sender == crowdsale);
		_;
	}
	function setCrowdsale(Crowdsale _crowdsale) external onlyOwner {
		require(crowdsale == address(0));
		require(_crowdsale.staffContract() == staffContract);
		crowdsale = _crowdsale;
	}

	event DiscountPhaseAdded(uint index, string name, uint8 percent, uint fromDate, uint toDate, uint lockDate, uint timestamp, address byStaff);
	event DiscountPhaseBonusApplied(uint index, uint purchaseId, uint256 bonusAmount, uint256 purchasedTokensAmount, uint256 purchasedWeiAmount, uint timestamp);
	event DiscountPhaseBonusCanceled(uint index, uint purchaseId, uint256 bonusAmount, uint timestamp);
	event DiscountPhasePurchaseCanceled(uint index, uint purchaseId, uint256 purchasedTokenAmount, uint256 purchasedWeiAmount, uint timestamp);
	event DiscountPhaseDiscontinued(uint index, uint timestamp, address byStaff);

	struct DiscountPhase {
		uint8 percent;
		uint fromDate;
		uint toDate;
		uint lockDate;
		bool discontinued;
	}

	DiscountPhase[] public discountPhases;

	mapping(address => mapping(uint => InvestorPurchase)) public investorPurchase;

	struct InvestorPurchase {
		bool exists;
		uint discountId;
		uint256 purchasedTokensAmount;
		uint256 purchasedWeiAmount;
	}

	mapping(address => mapping(uint => InvestorBonus)) public investorBonus;

	struct InvestorBonus {
		bool exists;
		uint discountId;
		uint256 bonusAmount;
	}

	constructor(Staff _staffContract) StaffUtil(_staffContract) public {
	}

	function getBonus(address _investor, uint _purchaseId, uint256 _purchasedTokensAmount, uint256 _purchasedWeiAmount, uint _discountId) public onlyCrowdsale returns (uint256) {
		uint256 bonusAmount = calculateBonusAmount(_purchasedTokensAmount, _discountId);
		if (bonusAmount > 0) {
			investorBonus[_investor][_purchaseId].exists = true;
			investorBonus[_investor][_purchaseId].discountId = _discountId;
			investorBonus[_investor][_purchaseId].bonusAmount = bonusAmount;

			investorPurchase[_investor][_purchaseId].exists = true;
			investorPurchase[_investor][_purchaseId].discountId = _discountId;
			investorPurchase[_investor][_purchaseId].purchasedTokensAmount = _purchasedTokensAmount;
			investorPurchase[_investor][_purchaseId].purchasedWeiAmount = _purchasedWeiAmount;

			emit DiscountPhaseBonusApplied(_discountId, _purchaseId, bonusAmount, _purchasedTokensAmount, _purchasedWeiAmount, now);
		}
		return bonusAmount;
	}

	function getBlockedBonus(address _investor, uint _purchaseId) public constant returns (uint256) {
		InvestorBonus storage discountBonus = investorBonus[_investor][_purchaseId];
		if (discountBonus.exists && discountPhases[discountBonus.discountId].lockDate > now) {
			return investorBonus[_investor][_purchaseId].bonusAmount;
		}
	}

	function getBlockedPurchased(address _investor, uint _purchaseId) public constant returns (uint256[2] purchasedAmount) {
		InvestorPurchase storage discountPurchase = investorPurchase[_investor][_purchaseId];
		if (discountPurchase.exists && discountPhases[discountPurchase.discountId].lockDate > now) {
			purchasedAmount[0] = investorPurchase[_investor][_purchaseId].purchasedTokensAmount;
			purchasedAmount[1] = investorPurchase[_investor][_purchaseId].purchasedWeiAmount;
		}
	}

	function cancelBonus(address _investor, uint _purchaseId) public onlyCrowdsale {
		InvestorBonus storage purchaseBonus = investorBonus[_investor][_purchaseId];
		if (purchaseBonus.bonusAmount > 0) {
			emit DiscountPhaseBonusCanceled(purchaseBonus.discountId, _purchaseId, purchaseBonus.bonusAmount, now);
		}
		delete (investorBonus[_investor][_purchaseId]);
	}

	function cancelPurchase(address _investor, uint _purchaseId) public onlyCrowdsale {
		InvestorPurchase storage discountPurchase = investorPurchase[_investor][_purchaseId];
		if (discountPurchase.purchasedTokensAmount > 0) {
			emit DiscountPhasePurchaseCanceled(discountPurchase.discountId, _purchaseId, discountPurchase.purchasedTokensAmount, discountPurchase.purchasedWeiAmount, now);
		}
		delete (investorPurchase[_investor][_purchaseId]);
	}

	function calculateBonusAmount(uint256 _purchasedAmount, uint _discountId) public constant returns (uint256) {
		if (discountPhases.length <= _discountId) {
			return 0;
		}
		if (now >= discountPhases[_discountId].fromDate && now <= discountPhases[_discountId].toDate && !discountPhases[_discountId].discontinued) {
			return _purchasedAmount.mul(discountPhases[_discountId].percent).div(100);
		}
	}

	function addDiscountPhase(string _name, uint8 _percent, uint _fromDate, uint _toDate, uint _lockDate) public onlyOwnerOrStaff {
		require(bytes(_name).length > 0);
		require(_percent > 0 && _percent <= 100);
		require(_fromDate < _toDate);
		uint index = discountPhases.push(DiscountPhase(_percent, _fromDate, _toDate, _lockDate, false)) - 1;
		emit DiscountPhaseAdded(index, _name, _percent, _fromDate, _toDate, _lockDate, now, msg.sender);
	}

	function discontinueDiscountPhase(uint _index) public onlyOwnerOrStaff {
		require(now < discountPhases[_index].toDate);
		require(!discountPhases[_index].discontinued);
		discountPhases[_index].discontinued = true;
		emit DiscountPhaseDiscontinued(_index, now, msg.sender);
	}
}
