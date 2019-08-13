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
>`_investor` - ID of the transaction recorded in distribution contract ledger


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