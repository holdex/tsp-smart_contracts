pragma solidity ^0.4.24;


import "./Staff.sol";
import "./StaffUtil.sol";
import "./Token.sol";
import "./DiscountPhases.sol";
import "./DiscountStructs.sol";
import "./PromoCodes.sol";


contract Crowdsale is StaffUtil {
	using SafeMath for uint256;

	Token tokenContract;
	PromoCodes promoCodesContract;
	DiscountPhases discountPhasesContract;
	DiscountStructs discountStructsContract;

	address ethFundsWallet;
	uint256 referralBonusPercent;
	uint256 startDate;

	uint256 crowdsaleStartDate;
	uint256 endDate;
	uint256 tokenDecimals;
	uint256 tokenRate;
	uint256 tokensForSaleCap;
	uint256 minPurchaseInWei;
	uint256 maxInvestorContributionInWei;
	bool paused;
	bool finalized;
	uint256 weiRaised;
	uint256 soldTokens;
	uint256 bonusTokens;
	uint256 sentTokens;
	uint256 claimedSoldTokens;
	uint256 claimedBonusTokens;
	uint256 claimedSentTokens;
	uint256 purchasedTokensClaimDate;
	uint256 bonusTokensClaimDate;
	mapping(address => Investor) public investors;

	enum InvestorStatus {UNDEFINED, WHITELISTED, BLOCKED}

	struct Investor {
		InvestorStatus status;
		uint256 contributionInWei;
		uint256 purchasedTokens;
		uint256 bonusTokens;
		uint256 referralTokens;
		uint256 receivedTokens;
		TokensPurchase[] tokensPurchases;
	}

	struct TokensPurchase {
		uint256 value;
		uint256 amount;
		uint256 bonus;
		address referrer;
		uint256 referrerSentAmount;
	}

	event InvestorWhitelisted(address indexed investor, uint timestamp, address byStaff);
	event InvestorBlocked(address indexed investor, uint timestamp, address byStaff);
	event TokensPurchased(
		address indexed investor,
		uint indexed purchaseId,
		uint256 value,
		uint256 purchasedAmount,
		uint256 promoCodeAmount,
		uint256 discountPhaseAmount,
		uint256 discountStructAmount,
		address indexed referrer,
		uint256 referrerSentAmount,
		uint timestamp
	);
	event TokensPurchaseRefunded(
		address indexed investor,
		uint indexed purchaseId,
		uint256 value,
		uint256 amount,
		uint256 bonus,
		uint timestamp,
		address byStaff
	);
	event TokensSent(address indexed investor, uint256 amount, uint timestamp, address byStaff);
	event TokensClaimed(
		address indexed investor,
		uint256 purchased,
		uint256 bonus,
		uint256 referral,
		uint256 received,
		uint timestamp,
		address byStaff
	);

	constructor (
		uint256[11] uint256Args,
		address[5] addressArgs
	) StaffUtil(Staff(addressArgs[4])) public {

		// uint256 args
		startDate = uint256Args[0];
		crowdsaleStartDate = uint256Args[1];
		endDate = uint256Args[2];
		tokenDecimals = uint256Args[3];
		tokenRate = uint256Args[4];
		tokensForSaleCap = uint256Args[5];
		minPurchaseInWei = uint256Args[6];
		maxInvestorContributionInWei = uint256Args[7];
		purchasedTokensClaimDate = uint256Args[8];
		bonusTokensClaimDate = uint256Args[9];
		referralBonusPercent = uint256Args[10];

		// address args
		ethFundsWallet = addressArgs[0];
		promoCodesContract = PromoCodes(addressArgs[1]);
		discountPhasesContract = DiscountPhases(addressArgs[2]);
		discountStructsContract = DiscountStructs(addressArgs[3]);

		require(startDate < crowdsaleStartDate);
		require(crowdsaleStartDate < endDate);
		require(tokenDecimals > 0);
		require(tokenRate > 0);
		require(tokensForSaleCap > 0);
		require(minPurchaseInWei <= maxInvestorContributionInWei);
		require(ethFundsWallet != address(0));
	}

	function getState() external view returns (bool[2] boolArgs, uint256[18] uint256Args, address[6] addressArgs) {
		boolArgs[0] = paused;
		boolArgs[1] = finalized;
		uint256Args[0] = weiRaised;
		uint256Args[1] = soldTokens;
		uint256Args[2] = bonusTokens;
		uint256Args[3] = sentTokens;
		uint256Args[4] = claimedSoldTokens;
		uint256Args[5] = claimedBonusTokens;
		uint256Args[6] = claimedSentTokens;
		uint256Args[7] = purchasedTokensClaimDate;
		uint256Args[8] = bonusTokensClaimDate;
		uint256Args[9] = startDate;
		uint256Args[10] = crowdsaleStartDate;
		uint256Args[11] = endDate;
		uint256Args[12] = tokenRate;
		uint256Args[13] = tokenDecimals;
		uint256Args[14] = minPurchaseInWei;
		uint256Args[15] = maxInvestorContributionInWei;
		uint256Args[16] = referralBonusPercent;
		uint256Args[17] = getTokensForSaleCap();
		addressArgs[0] = staffContract;
		addressArgs[1] = ethFundsWallet;
		addressArgs[2] = promoCodesContract;
		addressArgs[3] = discountPhasesContract;
		addressArgs[4] = discountStructsContract;
		addressArgs[5] = tokenContract;
	}

	function fitsTokensForSaleCap(uint256 _amount) public view returns (bool) {
		return getDistributedTokens().add(_amount) <= getTokensForSaleCap();
	}

	function getTokensForSaleCap() public view returns (uint256) {
		if (tokenContract != address(0)) {
			return tokenContract.balanceOf(this);
		}
		return tokensForSaleCap;
	}

	function getDistributedTokens() public view returns (uint256) {
		return soldTokens.sub(claimedSoldTokens).add(bonusTokens.sub(claimedBonusTokens)).add(sentTokens.sub(claimedSentTokens));
	}

	function setTokenContract(Token token) external onlyOwner {
		require(token.decimals() == tokenDecimals);
		require(tokenContract == address(0));
		require(token != address(0));
		tokenContract = token;
	}

	function getInvestorClaimedTokens(address _investor) external view returns (uint256) {
		if (tokenContract != address(0)) {
			return tokenContract.balanceOf(_investor);
		}
		return 0;
	}

	function whitelistInvestors(address[] _investors) external onlyOwnerOrStaff {
		for (uint256 i = 0; i < _investors.length; i++) {
			if (_investors[i] != address(0) && investors[_investors[i]].status != InvestorStatus.WHITELISTED) {
				investors[_investors[i]].status = InvestorStatus.WHITELISTED;
				emit InvestorWhitelisted(_investors[i], now, msg.sender);
			}
		}
	}

	function blockInvestors(address[] _investors) external onlyOwnerOrStaff {
		for (uint256 i = 0; i < _investors.length; i++) {
			if (_investors[i] != address(0) && investors[_investors[i]].status != InvestorStatus.BLOCKED) {
				investors[_investors[i]].status = InvestorStatus.BLOCKED;
				emit InvestorBlocked(_investors[i], now, msg.sender);
			}
		}
	}

	function setPurchasedTokensClaimLockDate(uint _date) external onlyOwner {
		purchasedTokensClaimDate = _date;
	}

	function setBonusTokensClaimLockDate(uint _date) external onlyOwner {
		bonusTokensClaimDate = _date;
	}

	function setCrowdsaleStartDate(uint256 _date) external onlyOwner {
		crowdsaleStartDate = _date;
	}

	function setEndDate(uint256 _date) external onlyOwner {
		endDate = _date;
	}

	function setMinPurchaseInWei(uint256 _minPurchaseInWei) external onlyOwner {
		minPurchaseInWei = _minPurchaseInWei;
	}

	function setMaxInvestorContributionInWei(uint256 _maxInvestorContributionInWei) external onlyOwner {
		require(minPurchaseInWei <= _maxInvestorContributionInWei);
		maxInvestorContributionInWei = _maxInvestorContributionInWei;
	}

	function changeTokenRate(uint256 _tokenRate) external onlyOwner {
		require(_tokenRate > 0);
		tokenRate = _tokenRate;
	}

	function buyTokens(bytes32 _promoCode, address _referrer, uint _discountId) external payable {
		require(!finalized);
		require(!paused);
		require(startDate < now);
		require(investors[msg.sender].status == InvestorStatus.WHITELISTED);
		require(msg.value > 0);
		require(msg.value >= minPurchaseInWei);
		require(investors[msg.sender].contributionInWei.add(msg.value) <= maxInvestorContributionInWei);

		uint purchaseId = investors[msg.sender].tokensPurchases.push(TokensPurchase({
			value : 0,
			amount : 0,
			bonus : 0,
			referrer : 0x0,
			referrerSentAmount : 0
			})) - 1;

		// calculate purchased amount
		uint256 purchasedAmount;
		if (tokenDecimals > 18) {
			purchasedAmount = msg.value.mul(tokenRate).mul(10 ** (tokenDecimals - 18));
		} else if (tokenDecimals < 18) {
			purchasedAmount = msg.value.mul(tokenRate).div(10 ** (18 - tokenDecimals));
		} else {
			purchasedAmount = msg.value.mul(tokenRate);
		}

		// calculate total amount, this includes promo code amount or discount phase amount
		uint256 promoCodeBonusAmount = promoCodesContract.applyBonusAmount(msg.sender, purchasedAmount, _promoCode);
		uint256 discountPhaseBonusAmount = discountPhasesContract.getBonus(msg.sender, purchaseId, purchasedAmount, msg.value, _discountId);
		uint256 discountStructBonusAmount = discountStructsContract.getBonus(msg.sender, purchasedAmount, msg.value);
		uint256 bonusAmount = promoCodeBonusAmount.add(discountPhaseBonusAmount).add(discountStructBonusAmount);

		// update referrer's referral tokens
		uint256 referrerBonusAmount;
		address referrerAddr;
		if (
			_referrer != address(0)
			&& msg.sender != _referrer
			&& investors[_referrer].status == InvestorStatus.WHITELISTED
		) {
			referrerBonusAmount = purchasedAmount * referralBonusPercent / 100;
			referrerAddr = _referrer;
		}

		// check that calculated tokens will not exceed tokens for sale cap
		require(fitsTokensForSaleCap(purchasedAmount.add(bonusAmount).add(referrerBonusAmount)));

		// update crowdsale total amount of capital raised
		weiRaised = weiRaised.add(msg.value);
		soldTokens = soldTokens.add(purchasedAmount);
		bonusTokens = bonusTokens.add(bonusAmount).add(referrerBonusAmount);

		// update referrer's bonus tokens
		investors[referrerAddr].referralTokens = investors[referrerAddr].referralTokens.add(referrerBonusAmount);

		// update investor's purchased tokens
		investors[msg.sender].purchasedTokens = investors[msg.sender].purchasedTokens.add(purchasedAmount);

		// update investor's bonus tokens
		investors[msg.sender].bonusTokens = investors[msg.sender].bonusTokens.add(bonusAmount);

		// update investor's tokens eth value
		investors[msg.sender].contributionInWei = investors[msg.sender].contributionInWei.add(msg.value);

		// update investor's tokens purchases
		investors[msg.sender].tokensPurchases[purchaseId].value = msg.value;
		investors[msg.sender].tokensPurchases[purchaseId].amount = purchasedAmount;
		investors[msg.sender].tokensPurchases[purchaseId].bonus = bonusAmount;
		investors[msg.sender].tokensPurchases[purchaseId].referrer = referrerAddr;
		investors[msg.sender].tokensPurchases[purchaseId].referrerSentAmount = referrerBonusAmount;

		// log investor's tokens purchase
		emit TokensPurchased(
			msg.sender,
			purchaseId,
			msg.value,
			purchasedAmount,
			promoCodeBonusAmount,
			discountPhaseBonusAmount,
			discountStructBonusAmount,
			referrerAddr,
			referrerBonusAmount,
			now
		);

		// forward eth to funds wallet
		require(ethFundsWallet.call.gas(300000).value(msg.value)());
	}

	function sendTokens(address _investor, uint256 _amount) external onlyOwner {
		require(investors[_investor].status == InvestorStatus.WHITELISTED);
		require(_amount > 0);
		require(fitsTokensForSaleCap(_amount));

		// update crowdsale total amount of capital raised
		sentTokens = sentTokens.add(_amount);

		// update investor's received tokens balance
		investors[_investor].receivedTokens = investors[_investor].receivedTokens.add(_amount);

		// log tokens sent action
		emit TokensSent(
			_investor,
			_amount,
			now,
			msg.sender
		);
	}

	function burnUnsoldTokens() external onlyOwner {
		require(tokenContract != address(0));
		require(finalized);

		uint256 tokensToBurn = tokenContract.balanceOf(this).sub(getDistributedTokens());
		require(tokensToBurn > 0);

		tokenContract.burn(tokensToBurn);
	}

	function claimTokens() external {
		require(tokenContract != address(0));
		require(!paused);
		require(investors[msg.sender].status == InvestorStatus.WHITELISTED);

		uint256 clPurchasedTokens;
		uint256 clReceivedTokens;
		uint256 clBonusTokens_;
		uint256 clRefTokens;

		require(purchasedTokensClaimDate < now || bonusTokensClaimDate < now);

		{
			uint256 contributionInWei = investors[msg.sender].contributionInWei;
			uint256 purchasedTokens = investors[msg.sender].purchasedTokens;
			uint256 receivedTokens = investors[msg.sender].receivedTokens;

			for (i = 0; i < investors[msg.sender].tokensPurchases.length; i++) {
				uint256[2] memory blockedPurchased = discountPhasesContract.getBlockedPurchased(msg.sender, i);
				if (blockedPurchased[0] > 0) {
					purchasedTokens = purchasedTokens.sub(blockedPurchased[0]);
					contributionInWei = contributionInWei.sub(blockedPurchased[1]);
				} else {
					discountPhasesContract.cancelPurchase(msg.sender, i);
				}
			}

			if (purchasedTokensClaimDate < now && (purchasedTokens > 0 || receivedTokens > 0)) {
				investors[msg.sender].contributionInWei = investors[msg.sender].contributionInWei.sub(contributionInWei);
				investors[msg.sender].purchasedTokens = investors[msg.sender].purchasedTokens.sub(purchasedTokens);
				investors[msg.sender].receivedTokens = 0;

				claimedSoldTokens = claimedSoldTokens.add(purchasedTokens);
				claimedSentTokens = claimedSentTokens.add(receivedTokens);

				// free up storage used by transaction
				for (uint i = 0; i < investors[msg.sender].tokensPurchases.length; i++) {
					delete (investors[msg.sender].tokensPurchases[i]);
				}

				clPurchasedTokens = purchasedTokens;
				clReceivedTokens = receivedTokens;

				tokenContract.transfer(msg.sender, purchasedTokens.add(receivedTokens));
			}
		}

		{
			uint256 bonusTokens_ = investors[msg.sender].bonusTokens;
			uint256 refTokens = investors[msg.sender].referralTokens;

			for (i = 0; i < investors[msg.sender].tokensPurchases.length; i++) {
				uint256 blockedBonus = discountPhasesContract.getBlockedBonus(msg.sender, i);
				if (blockedBonus > 0) {
					bonusTokens_ = bonusTokens_.sub(blockedBonus);
				} else {
					discountPhasesContract.cancelBonus(msg.sender, i);
				}
			}

			if (bonusTokensClaimDate < now && (bonusTokens_ > 0 || refTokens > 0)) {
				investors[msg.sender].bonusTokens = investors[msg.sender].bonusTokens.sub(bonusTokens_);
				investors[msg.sender].referralTokens = 0;

				claimedBonusTokens = claimedBonusTokens.add(bonusTokens_).add(refTokens);

				clBonusTokens_ = bonusTokens_;
				clRefTokens = refTokens;

				tokenContract.transfer(msg.sender, bonusTokens_.add(refTokens));
			}
		}

		require(clPurchasedTokens > 0 || clBonusTokens_ > 0 || clRefTokens > 0 || clReceivedTokens > 0);
		emit TokensClaimed(msg.sender, clPurchasedTokens, clBonusTokens_, clRefTokens, clReceivedTokens, now, msg.sender);
	}

	function refundTokensPurchase(address _investor, uint _purchaseId) external payable onlyOwner {
		require(msg.value > 0);
		require(investors[_investor].tokensPurchases[_purchaseId].value == msg.value);

		_refundTokensPurchase(_investor, _purchaseId);

		// forward eth to investor's wallet address
		_investor.transfer(msg.value);
	}

	function refundAllInvestorTokensPurchases(address _investor) external payable onlyOwner {
		require(msg.value > 0);
		require(investors[_investor].contributionInWei == msg.value);

		for (uint i = 0; i < investors[_investor].tokensPurchases.length; i++) {
			if (investors[_investor].tokensPurchases[i].value == 0) {
				continue;
			}

			_refundTokensPurchase(_investor, i);
		}

		// forward eth to investor's wallet address
		_investor.transfer(msg.value);
	}

	function _refundTokensPurchase(address _investor, uint _purchaseId) private {
		// update referrer's referral tokens
		address referrer = investors[_investor].tokensPurchases[_purchaseId].referrer;
		if (referrer != address(0)) {
			uint256 sentAmount = investors[_investor].tokensPurchases[_purchaseId].referrerSentAmount;
			investors[referrer].referralTokens = investors[referrer].referralTokens.sub(sentAmount);
			bonusTokens = bonusTokens.sub(sentAmount);
		}

		// update investor's eth amount
		uint256 purchaseValue = investors[_investor].tokensPurchases[_purchaseId].value;
		investors[_investor].contributionInWei = investors[_investor].contributionInWei.sub(purchaseValue);

		// update investor's purchased tokens
		uint256 purchaseAmount = investors[_investor].tokensPurchases[_purchaseId].amount;
		investors[_investor].purchasedTokens = investors[_investor].purchasedTokens.sub(purchaseAmount);

		// update investor's bonus tokens
		uint256 bonusAmount = investors[_investor].tokensPurchases[_purchaseId].bonus;
		investors[_investor].bonusTokens = investors[_investor].bonusTokens.sub(bonusAmount);

		// update crowdsale total amount of capital raised
		weiRaised = weiRaised.sub(purchaseValue);
		soldTokens = soldTokens.sub(purchaseAmount);
		bonusTokens = bonusTokens.sub(bonusAmount);

		// free up storage used by transaction
		delete (investors[_investor].tokensPurchases[_purchaseId]);

		// cancel bonus discount phase bonus
		discountPhasesContract.cancelBonus(_investor, _purchaseId);

		// cancel bonus discount phase purchase
		discountPhasesContract.cancelPurchase(_investor, _purchaseId);

		// log investor's tokens purchase refund
		emit TokensPurchaseRefunded(_investor, _purchaseId, purchaseValue, purchaseAmount, bonusAmount, now, msg.sender);
	}

	function getInvestorTokensPurchasesLength(address _investor) public constant returns (uint) {
		return investors[_investor].tokensPurchases.length;
	}

	function getInvestorTokensPurchase(
		address _investor,
		uint _purchaseId
	) external constant returns (
		uint256 value,
		uint256 amount,
		uint256 bonus,
		address referrer,
		uint256 referrerSentAmount
	) {
		value = investors[_investor].tokensPurchases[_purchaseId].value;
		amount = investors[_investor].tokensPurchases[_purchaseId].amount;
		bonus = investors[_investor].tokensPurchases[_purchaseId].bonus;
		referrer = investors[_investor].tokensPurchases[_purchaseId].referrer;
		referrerSentAmount = investors[_investor].tokensPurchases[_purchaseId].referrerSentAmount;
	}

	function setPaused(bool p) external onlyOwner {
		paused = p;
	}

	function finalize() external onlyOwner {
		finalized = true;
	}
}
