var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

var selectedBoss = "";

function OnDropDownChanged() {
	selectedBoss = $("#BossesDropDown").GetSelected().id;
}

function SpawnBoss() {
	GameEvents.SendCustomGameEventToServer("ziv_debug_create_boss", {"boss_name" : selectedBoss});
}

function RemoveBoss() {
	GameEvents.SendCustomGameEventToServer("ziv_debug_remove_boss", {});
}

function HealBoss() {
	GameEvents.SendCustomGameEventToServer("ziv_debug_heal_boss", {});
}

(function() {
	var units = PlayerTables.GetTableValue("kvs", "units");

	Util.RemoveChildren($("#BossesDropDown"));

	for (var name in units) {
		if (name.match("npc_boss_")) {
			var bossEntry = $.CreatePanel("Label", $("#BossesDropDown"), name);
			bossEntry.text = $.Localize(name);
        	bossEntry.AddClass("DropDownChild");
        	$("#BossesDropDown").AddOption(bossEntry);
        	$("#BossesDropDown").SetSelected(name);
		}
	}
})();