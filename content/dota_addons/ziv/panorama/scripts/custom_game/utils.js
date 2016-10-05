var Util = {};

Util.SecondsToHHMMSS = (function (d) {
	d = Number(d);
	var h = Math.floor(d / 3600);
	var m = Math.floor(d % 3600 / 60);
	var s = Math.floor(d % 3600 % 60);
	return ((h > 0 ? h + ":" + (m < 10 ? "0" : "") : "") + m + ":" + (s < 10 ? "0" : "") + s); 
});

Util.GetSteamID32 = (function () {
    var playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID());

    var steamID64 = playerInfo.player_steamid,
        steamIDPart = Number(steamID64.substring(3)),
        steamID32 = String(steamIDPart - 61197960265728);

    return steamID32;
});

Util.GetDate = (function () {
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();

    return yyyy * 10000 + mm * 100 + dd;
});

Util.RoundToTwo = (function (num) {    
    return +(Math.round(num + "e+2")  + "e-2");
});

Util.AutoUppercase = (function (str) {
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
});

Util.SpanString = (function (str, className) {
    return "<span class=\"" + className + "\">" + str + "</span>";
});

Util.ColorString = (function (str, color) {
    return "<font color=\"" + color + "\">" + str + "</font>";
});

Util.ConvertModifierValue = (function (modifier, value) {
    var hero = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
    var heroName = PlayerTables.GetTableValue("kvs", "heroes")[Entities.GetUnitName(hero)]["SecondName"];

    var newValue = value;

    if (modifier.indexOf( heroName ) != -1) {
        var runeKV = PlayerTables.GetTableValue("kvs", "items")[modifier.replace("ziv_" + heroName, "item_rune")];
        if (!runeKV["Type"]) {
            newValue += "%";
        } else if (runeKV["Type"] == "Float") {
            newValue /= 100;
        }
    }

    return newValue;
});

(function(){
	GameUI.CustomUIConfig().Util = Util;
})()