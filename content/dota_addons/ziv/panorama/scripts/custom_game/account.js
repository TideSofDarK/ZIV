var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

var Account = {};

Account.TIER_WOOD 		= 1;
Account.TIER_BRONZE 	= 2;
Account.TIER_SILVER 	= 3;
Account.TIER_GOLD 		= 4;
Account.TIER_PLATINUM 	= 5;

Account._EXP = 0;

Account.GetEXP = (function () {
    return PlayerTables.GetTableValue("accounts", Players.GetLocalPlayer()).exp;
});

Account.GetNeededEXP = (function (exp) {
    var exp = exp;
    if (!exp) {
    	exp = Account.GetEXP();
    }

    var level = Account.GetLevelByEXP(exp);

    return Account.GetEXPPerLevel() * (level + 1)
});

Account.GetLevelByEXP = (function (exp) {
    if (!exp) return 1;

    return Math.max(Math.floor(exp / Account.GetEXPPerLevel()), 1)
});

Account.GetTierByLevel = (function (level) {
    if (!level) return 1;

    var level = Math.min(level, Account.GetMaxLevel())

    return Math.max(Math.floor(level / Account.GetLevelsPerTier()), Account.TIER_WOOD)
});

Account.GetEXPPerLevel = (function (level) {
    return PlayerTables.GetTableValue("kvs", "account").EXP_PER_LEVEL;
});

Account.GetLevelsPerTier = (function (level) {
    return PlayerTables.GetTableValue("kvs", "account").LEVELS_PER_TIER;
});

Account.GetMaxLevel = (function (level) {
    return PlayerTables.GetTableValue("kvs", "account").MAX_LEVEL;
});

(function () {
	GameUI.CustomUIConfig().Account = Account;
})();