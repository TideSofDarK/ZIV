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

    return Account.GetEXPPerLevel() - (exp - ((Account.GetLevelByEXP(exp) - 1) * Account.GetEXPPerLevel()))
});

Account.GetLevel = (function () {
    return Account.GetLevelByEXP();
});

Account.GetLevelByEXP = (function (exp) {
    var exp = exp;
    if (!exp) {
        exp = Account.GetEXP();
    }

    return Math.max(Math.floor(exp / Account.GetEXPPerLevel()), 0) + 1
});

Account.GetTierByLevel = (function (level) {
    var level = level;
    if (!level) {
        level = Account.GetLevel();
    }

    var level = Math.min(level, Account.GetMaxLevel())
    
    return Math.max(Math.floor(level / Account.GetLevelsPerTier()), 0) + Account.TIER_WOOD
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