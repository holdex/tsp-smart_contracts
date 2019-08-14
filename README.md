# Token distribution
Token distribtuion is a base contract for managing a token distribution process, allowing users to contriute ETH and receive back tokens equal to a specific value. 


## Functions
Below are listed the functionalities supported by Holdex distribution contract


##### `function getState()` 
Returns information about the current state of the smart contract. Ex.: paused, finalized, start and end-date, amount of tokens distributed etc.


##### `fitsTokensForSaleCap(uint256 _amount)`
Ensures the token purchase doesn't amount exceed the total amount of tokens vailable for sale. 
>Parameter:
`_amount` - token amount

##### `getTokensForSaleCap()`
Returns amount of available tokens for sale


##### `function getDistributedTokens()`
Return the amount of distributed tokens


##### `function setTokenContract(ERC20Token token)`
Connect your ERC-20 token contract to the token distribution contract. 
>Parameter:
`ERC20Token` - must be a valid ERC-20 token address


##### `function getInvestorClaimedTokens(address _investor)`
Returns the amount of tokens claim by a contributor.
>Parameter:
>`_investor` - contributor address


##### `function whitelistInvestors(address[] calldata _investors)`
Whitelist a single or multiple contributor addresses at a single time. Whitelist allows contributors to purchase tokens. 
>Parameter:
>`_investors` - contributor addresses

##### `function blockInvestors(address[] calldata _investors)`
Block a single or multiple contributors addresses from token purchase.
>Parameter:
>`_investors` - contributor addresses

##### `function setPurchasedTokensClaimLockDate(uint _date)`
Defines a date from which token claim will be allowed over purchased tokens. The date can be both in past and future. A date in past will enable the claim right away.
>Parameter:
>`_date` - date timestamp


##### `function setBonusTokensClaimLockDate(uint _date)`
Defines a date from which token claim will be allowed over bonus tokens. The date can be both in past and future. A date in past will enable the claim right away.
>Parameter:
>`_date` - date timestamp

##### `function setCrowdsaleStartDate(uint256 _date)`
Defines a date from which token purchase will be enabled for all whitelisted addresses.
>Parameter:
>`_date` - date timestamp

##### `function setEndDate(uint256 _date)`
Defines a static end-date. 
>Parameter:
>`_date` - date timestamp

##### `function setMinPurchaseInWei(uint256 _minPurchaseInWei)`
Defines the minimal amount of ETH that any whitelisted contributor can purchase tokens with.
>Parameter:
>`_minPurchaseInWei` - amount in WEI

##### `function setMaxInvestorContributionInWei(uint256 _maxInvestorContributionInWei)`
Defines the maximum amount of contribution that any whitelisted address can make. 
>Parameter:
>`_minPurchaseInWei` - amount in WEI

##### `function changeTokenRate(uint256 _tokenRate)`
Changes the amount of tokens distributed for 1 ETH.
>Parameter:
>`_tokenRate` - token amount


##### `function buyTokens(bytes32 _promoCode, address _referrer, uint _discountId, bool _holdex, bytes32[] calldata _partners)`
Token purchase
>Parameters:
>`_promoCode` - promo-code
>`_referrer` - referrer address
>`_discountId` - bonusId
>`_holdex` - true/false. (defines whether contribution is subject to commission)
>`_partners` - list of partners that will receive commision


##### `function sendTokens(address _investor, uint256 _amount)`
Airdrop tokens to any whitelisted address.
>Parameters:
>`_investor` - wallet address
>`_amount` - amount of tokens to be transferred


##### `function burnUnsoldTokens()`
Burns all remaining tokens from distirbution contract address.


##### `function claimTokens()`
Calling this function will transfer tokens from distribution contract address to the contributor calling it. The token amount will be taken from distribution contract ledger.

##### `function refundTokensPurchase(address payable _investor, uint _purchaseId)`
Refund ETH in exchange of a single token purchase to the contributor. If tokens were already claimed, the refund is not possible. 
>Parameters:
>`_investor` - contributor wallet address
>`_purchaseId` - ID of the transaction recorded in distribution contract ledger


##### `function refundAllInvestorTokensPurchases(address payable _investor)`
Refund ETH in exchange of all pruchased tokens to the contributor. If tokens were already claimed, the refund is not possible.
>Parameter:
>`_investor` - contributor wallet address



##### `function getInvestorTokensPurchasesLength(address _investor)`
Return the amount of pruchased tokens by a single contributor. 
>Parameter:
>`_investor` - contributor wallet address


##### `function getInvestorTokensPurchase(address _investor, uint _purchaseId)`
Internal function. Calculates the amount of tokens a contributor should receive after token purchase. 
>Parameters:
>`_investor` - contributor wallet address
>`_purchaseId` - ID of the transaction recorded in distribution contract ledger


##### `function setPaused(bool p)`
Pauses token distribution contract work. Any purchase or claim is prohibited during pause. Call this function again to resume contract work.
>Parameter:
>`p` - true/fale


##### `function finalize()`
Finalizes token distribution contract work. This action can't be reverted. 

## Events
Below are listed the events that are stored in the blockchain. You can parse these events to extract data about a specific action that happened inside the token distribution contract

##### `event InvestorWhitelisted`
##### `event InvestorBlocked`
##### `event TokensPurchased`
##### `event TokensPurchaseRefunded`
##### `event TokensSent`
##### `event TokensClaimed`

---
# Bonus campaign
Bonuses campaigns allow you to send free additional tokens over each token purchase. Campaigns are limited by time. Bonus campaigns alos poses a lock date which will lock both purchased and bonus tokens until a certain date.

## Functions

##### `function getBonus(address _investor, uint _purchaseId, uint256 _purchasedTokensAmount, uint256 _purchasedWeiAmount, uint _discountId)`
Internal function. Returns the amount of bonus a contributor received from his token purchase.
>Parameters:
>`_investor` - contributor wallet address
>`_purchaseId` - ID of the transaction recorded in distribution contract ledger
>`_purchasedTokensAmount` - amount of tokens purchased
>`_purchasedWeiAmount` - amount of ETH used for purchase
>`_discountId` - bonus ID applied


##### `function getBlockedBonus(address _investor, uint _purchaseId)`
Returns the amount of bonus tokens locked by a transaction.
>Parameters:
>`_investor` - contributor wallet address
>`_purchaseId` - ID of the transaction recorded in distribution contract ledger


##### `function getBlockedPurchased(address _investor, uint _purchaseId)`
Returns the amount of purchased tokens locked by a transaction.
>Parameters:
>`_investor` - contributor wallet address
>`_purchaseId` - ID of the transaction recorded in distribution contract ledger


##### `function cancelBonus(address _investor, uint _purchaseId)`
Internal function. Cencels bonus allocation.
>Parameters:
>`_investor` - contributor wallet address
>`_purchaseId` - ID of the transaction recorded in distribution contract ledger

##### `function cancelPurchase(address _investor, uint _purchaseId)`
Internal function. Cencels token purchase.
>Parameters:
>`_investor` - contributor wallet address
>`_purchaseId` - ID of the transaction recorded in distribution contract ledger


##### `function calculateBonusAmount(uint256 _purchasedAmount, uint _discountId)`
Internal function. Calculates the amount if bonus to be allocated in a token purchase.
>Parameters:
>`_purchasedAmount` - amount of tokens purchased
>`_discountId` - ID of the bonus applied

##### `function addDiscountPhase(string memory _name, uint8 _percent, uint _fromDate, uint _toDate, uint _lockDate)`
Internal function. Creates a new bonus campaign for token distribution.
>Parameters:
>`_name` - campaign name
>`_percent` - bonus prcent allocated per purchase
>`_fromDate` - campaign start date
>`_toDate` - campaign end date
>`_lockDate` - campaign lock date. (date until both purchase and bonus tokens will be locked)


##### `function discontinueDiscountPhase(uint _index)`
Internal function. Discontinues active bonus.
>Parameter:
>`_index` - bonus campaign ID


## Events

##### `event DiscountPhaseAdded`
##### `event DiscountPhaseBonusApplied`
##### `event DiscountPhaseBonusCanceled`
##### `event DiscountPhasePurchaseCanceled`
##### `event DiscountPhaseDiscontinued`

---

# Bonus structure campaign
Unlike bonus campaigns, bonus structure follow a certain purchase pattern before it is applied. Bonus structure require a token purchase to exceed a certain amount of ETH to be applied. 

## Functions

##### `function setCrowdsale(IStaffUtil _crowdsale)`
Internal function. Connects the bonus structure campaign contract with the token distribution contract.
>Parameter:
>`_crowdsale` - token distribution contract address

##### `function getBonus(address _investor, uint256 _purchasedAmount, uint256 _purchasedValue)`
Internal function. Returns the amount of bonus a contributor received from his token purchase.
>Parameters:
>`_investor` - contributor wallet address
>`_purchasedAmount` - amount of tokens purchased in transaction
>`_purchasedValue` - amount of ETH consumed for transaction


##### `function calculateBonus(uint256 _purchasedAmount, uint256 _purchasedValue)`
Internal function. Calculates the amount if bonus to be allocated in a token purchase.
>Parameters:
>`_purchasedAmount` - amount of tokens purchased in transaction
>`_purchasedValue` - amount of ETH consumed for transaction


##### `function addDiscountStruct(bytes32 _name, uint256 _tokens, uint[2] calldata _dates, uint256[] calldata _fromWei, uint256[] calldata _toWei, uint256[] calldata _percent)`
Internal function. Creates a new bonus structure campaign.
>Parameters:
>`_name` - campaign name
>`_tokens` - amount of tokens to be allocated for tha campaign
>`_dates` - start and end date
>`_fromWei` - minimal amount of ETH requied for bonus to be applied
>`_toWei` - maximal amount of ETH requied for bonus to be applied
>`_percent` - bonus percent allocated per purchase


##### `function removeDiscountStruct(uint _index)`
Internal function. Discontinues a bonus structure campaign. 
>Parameter:
>`_index` - bonus campaign ID


## Events


##### `event DiscountStructAdded`
##### `event DiscountStructRemoved`
##### `event DiscountStructUsed`

---

# Promo codes
Promo codes contract is responsible for creating promo-codes and allocating bonus tokens to contributors who purchased with a promo-code. 

## Functions

##### `function setCrowdsale(IStaffUtil _crowdsale)`
Internal function. Connects the bonus structure campaign contract with the token distribution contract.
>Parameter:
>`_crowdsale` - token distribution contract address


##### `function applyBonusAmount(address _investor, uint256 _purchasedAmount, bytes32 _promoCode)`
Internal function. Applies bonus to a token purchase. 
>Parameters:
>`_investor` - contributor wallet address
>`_purchasedAmount` - amount of tokens purchased in transaction
>`_promoCode` - promo-code applied for transaction


##### `function calculateBonusAmount(address _investor, uint256 _purchasedAmount, bytes32 _promoCode)`
Internal function. Calculates the amount of bonus to be applied to a token purchase.
>Parameters:
>`_investor` - contributor wallet address
>`_purchasedAmount` - amount of tokens purchased in transaction
>`_promoCode` - promo-code applied for transaction


##### `function addPromoCode(string memory _name, bytes32 _code, uint256 _maxUses, uint8 _percent)`
Internal function. Creates a new promo-code. 
>`_name` - promo-code name
>`_code` - promo-code code
>`_maxUses` - maximum amount of purchases made from different wallet addresses that can be made with this promo code
>`_percent` - bonus percent allocated per purchase


##### `function removePromoCode(bytes32 _code)`
Internal function. Removes an active promo-code. 
>Parameter:
>`_code` - promo-code code



## Events

##### `event PromoCodeAdded`
##### `event PromoCodeRemoved`
##### `event PromoCodeUsed`