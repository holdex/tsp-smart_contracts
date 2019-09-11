pragma solidity ^0.5.0;


import "./interfaces/IStaff.sol";
import "./StaffUtil.sol";
import "./interfaces/IStaffUtil.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract DiscountPhases is StaffUtil {
	using SafeMath for uint256;

	address public crowdsale;
	modifier onlyCrowdsale() {
		require(address(msg.sender) == crowdsale);
		_;
	}
	
	/**
	function setCrowdsale
	
	Connect bonus contract with distribution contract.
	Parameter: 
	_crowdsale - distribution contract address
	*/
	
	function setCrowdsale(IStaffUtil _crowdsale) external onlyOwner {
		require(crowdsale == address(0));
		require(_crowdsale.staffContract() == address(staffContract));
		crowdsale = address(_crowdsale);
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

	constructor(IStaff _staffContract) StaffUtil(_staffContract) public {
	}
	
	/**
	function getBonus
	
	Internal function. Returns the amount of bonus a contributor should receive from a token purchase.
	Parameters: 
	_investor - contributor wallet address
	_purchaseId - ID of the transaction recorded in distribution contract ledger
	_purchasedTokensAmount - amount of tokens purchased
	_purchasedWeiAmount - amount of ETH used for purchase
	_discountId - bonus ID applied
	*/

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
	
	/**
	function getBlockedBonus
	
	Returns the amount of bonus tokens locked by a transaction.
	Parameters: 
	_investor - contributor wallet address
	_purchaseId - ID of the transaction recorded in distribution contract ledger
	*/
	
	function getBlockedBonus(address _investor, uint _purchaseId) public view returns (uint256) {
		InvestorBonus storage discountBonus = investorBonus[_investor][_purchaseId];
		if (discountBonus.exists && discountPhases[discountBonus.discountId].lockDate > now) {
			return investorBonus[_investor][_purchaseId].bonusAmount;
		}
		return 0;
	}
	
	/**
	function getBlockedPurchased
	
	Returns the amount of purchased tokens locked by a transaction.
	Parameters: 
	_investor - contributor wallet address
	_purchaseId - ID of the transaction recorded in distribution contract ledger
	*/

	function getBlockedPurchased(address _investor, uint _purchaseId) public view returns (uint256[2] memory purchasedAmount) {
		InvestorPurchase storage discountPurchase = investorPurchase[_investor][_purchaseId];
		if (discountPurchase.exists && discountPhases[discountPurchase.discountId].lockDate > now) {
			purchasedAmount[0] = investorPurchase[_investor][_purchaseId].purchasedTokensAmount;
			purchasedAmount[1] = investorPurchase[_investor][_purchaseId].purchasedWeiAmount;
		}
	}
	
	/**
	function cancelBonus
	
	Internal function. Cencels bonus allocation.
	Parameters: 
	_investor - contributor wallet address
	_purchaseId - ID of the transaction recorded in distribution contract ledger
	*/
	
	function cancelBonus(address _investor, uint _purchaseId) public onlyCrowdsale {
		InvestorBonus storage purchaseBonus = investorBonus[_investor][_purchaseId];
		if (purchaseBonus.bonusAmount > 0) {
			emit DiscountPhaseBonusCanceled(purchaseBonus.discountId, _purchaseId, purchaseBonus.bonusAmount, now);
		}
		delete (investorBonus[_investor][_purchaseId]);
	}
	
	/**
	function cancelPurchase
	
	Internal function. Cencels token purchase related to bonus allocation.
	Parameters: 
	_investor - contributor wallet address
	_purchaseId - ID of the transaction recorded in distribution contract ledger
	*/
	
	function cancelPurchase(address _investor, uint _purchaseId) public onlyCrowdsale {
		InvestorPurchase storage discountPurchase = investorPurchase[_investor][_purchaseId];
		if (discountPurchase.purchasedTokensAmount > 0) {
			emit DiscountPhasePurchaseCanceled(discountPurchase.discountId, _purchaseId, discountPurchase.purchasedTokensAmount, discountPurchase.purchasedWeiAmount, now);
		}
		delete (investorPurchase[_investor][_purchaseId]);
	}
	
	/**
	function calculateBonusAmount
	
	Internal function. Calculates the amount if bonus to be allocated in a token purchase.
	Parameters: 
	_purchasedAmount - amount of tokens purchased
	_discountId - ID of the bonus applied
	*/
	
	function calculateBonusAmount(uint256 _purchasedAmount, uint _discountId) public view returns (uint256) {
		if (discountPhases.length <= _discountId) {
			return 0;
		}
		if (now >= discountPhases[_discountId].fromDate && now <= discountPhases[_discountId].toDate && !discountPhases[_discountId].discontinued) {
			return _purchasedAmount.mul(discountPhases[_discountId].percent).div(100);
		}
		return 0;
	}
	
	/**
	function addDiscountPhase
	
	Internal function. Creates a new bonus campaign for token distribution.
	Parameters: 
	_name - campaign name
	_percent - bonus prcent allocated per purchase
	_fromDate - campaign start date
	_toDate - campaign end date
	_lockDate - campaign lock date. (date until both purchase and bonus tokens will be locked)
	*/
	
	function addDiscountPhase(string memory _name, uint8 _percent, uint _fromDate, uint _toDate, uint _lockDate) public onlyOwnerOrStaff {
		require(bytes(_name).length > 0);
		require(_percent > 0 && _percent <= 100);
		require(_fromDate < _toDate);
		uint index = discountPhases.push(DiscountPhase(_percent, _fromDate, _toDate, _lockDate, false)) - 1;
		emit DiscountPhaseAdded(index, _name, _percent, _fromDate, _toDate, _lockDate, now, msg.sender);
	}
	
	/**
	function discontinueDiscountPhase
	
	Internal function. Discontinues active bonus.
	Parameter:
	_index - bonus campaign ID
	*/
	
	function discontinueDiscountPhase(uint _index) public onlyOwnerOrStaff {
		require(now < discountPhases[_index].toDate);
		require(!discountPhases[_index].discontinued);
		discountPhases[_index].discontinued = true;
		emit DiscountPhaseDiscontinued(_index, now, msg.sender);
	}
}
