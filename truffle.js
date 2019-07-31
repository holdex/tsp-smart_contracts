const HDWalletProvider = require("truffle-hdwallet-provider");
require('dotenv').config();

console.log("============================================================================");
console.log("ACCOUNT           =", process.env.ACCOUNT);
console.log("GAS_PRICE_IN_GWEI =", process.env.GAS_PRICE_IN_GWEI);
console.log("NODE_URL          =", process.env.NODE_URL);
console.log("NETWORK_ID        =", process.env.NETWORK_ID);
console.log("============================================================================");
console.log("START_DATE                       =", process.env.START_DATE);
console.log("CROWDSALE_START_DATE             =", process.env.CROWDSALE_START_DATE);
console.log("END_DATE                         =", process.env.END_DATE);
console.log("TOKEN_DECIMALS                   =", process.env.TOKEN_DECIMALS);
console.log("TOKEN_RATE                       =", process.env.TOKEN_RATE);
console.log("TOKENS_FOR_SALE_CAP              =", process.env.TOKENS_FOR_SALE_CAP);
console.log("MIN_PURCHASE_IN_ETH              =", process.env.MIN_PURCHASE_IN_ETH);
console.log("MAX_INVESTOR_CONTRIBUTION_IN_ETH =", process.env.MAX_INVESTOR_CONTRIBUTION_IN_ETH);
console.log("PURCHASED_TOKENS_CLAIM_DATE      =", process.env.PURCHASED_TOKENS_CLAIM_DATE);
console.log("BONUS_TOKENS_CLAIM_DATE          =", process.env.BONUS_TOKENS_CLAIM_DATE);
console.log("REFERRAL_BONUS_PERCENT           =", process.env.REFERRAL_BONUS_PERCENT);
console.log("ETH_FUNDS_WALLET                 =", process.env.ETH_FUNDS_WALLET);
console.log("STAFF_ADDR                       =", process.env.STAFF_ADDR);
console.log("OWNER_ADDR                       =", process.env.OWNER_ADDR);
console.log("============================================================================");

module.exports = {
    networks: {
        remote: {
            provider: function () {
                return new HDWalletProvider(process.env.MNENOMIC, process.env.NODE_URL, process.env.ACCOUNT)
            },
            network_id: process.env.NETWORK_ID,
            gasPrice: process.env.GAS_PRICE_IN_GWEI * (10 ** 9)
        },
    }
};
