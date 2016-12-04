var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

var Account = {};

Account.XP_PER_LEVEL = PlayerTables.GetTableValue("kvs", "account").XP_PER_LEVEL;
Account.LEVELS_PER_TIER = PlayerTables.GetTableValue("kvs", "account").LEVELS_PER_TIER;
Account.MAX_LEVEL = PlayerTables.GetTableValue("kvs", "account").MAX_LEVEL;

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
    var exp = exp || Account.GetEXP();

    var level = Util.GetLevelByEXP(exp);

    return GameUI.CustomUIConfig().EXP_PER_LEVEL * (level + 1)
});

Account.GetLevelByEXP = (function (exp) {
    if (!exp) return 1;

    return Math.max(Math.floor(exp / Account.EXP_PER_LEVEL), 1)
});

Account.GetTierByLevel = (function (level) {
    if (!level) return 1;

    var level = Math.min(level, Account.MAX_LEVEL)

    return Math.max(Math.floor(level / Account.LEVELS_PER_TIER), Account.TIER_WOOD)
});

(function () {
	GameUI.CustomUIConfig().Account = Account;

	PlayerTables.SubscribeNetTableListener( "account", UpdateAccount );
})();