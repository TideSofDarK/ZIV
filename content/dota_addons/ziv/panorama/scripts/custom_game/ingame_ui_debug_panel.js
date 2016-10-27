var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

var selectedBoss = "";
var states = {
	idle: 0,
	casting: 1,
	chasing: 2
}


function OnDropDownChanged() {
	selectedBoss = $("#BossesDropDown").GetSelected().id;
}

function OnStateDropDownChanged() {
	GameEvents.SendCustomGameEventToServer("ziv_debug_change_boss_state", { boss_name: selectedBoss, state: states[$("#BossesStateDropDown").GetSelected().id] });
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

function ChangeBossState() {
	GameEvents.SendCustomGameEventToServer("ziv_debug_change_boss_state", {});
}

function LockState() {

}

function Toggle() {
	$.GetContextPanel().ToggleClass("WindowClosed");
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

	for (var k of Object.keys(states)) {
		var stateEntry = $.CreatePanel("Label", $("#BossesStateDropDown"), k);
		stateEntry.text = k;
    	stateEntry.AddClass("DropDownChild");
    	$("#BossesStateDropDown").AddOption(stateEntry);
	}
	$("#BossesStateDropDown").SetSelected("idle");

	Game.AddCommand("+ZIVShowDebugPanel", Toggle, "", 0); 
	Game.AddCommand("-ZIVShowDebugPanel", undefined, "", 0); 
})();