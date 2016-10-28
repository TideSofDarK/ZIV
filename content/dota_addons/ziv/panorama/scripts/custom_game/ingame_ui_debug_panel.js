var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

var selectedBoss = "";
var states = {
	idle: 0,
	casting: 1,
	chasing: 2
}

function hookSliderChange(panel, callback, onComplete) {
    var shouldListen = false;
    var checkRate = 0.1;
    var currentValue = panel.value;

    var inputChangedLoop = function() {
        // Check for a change
        if(currentValue != panel.value) {
            // Update current string
            currentValue = panel.value;

            // Run the callback
            callback(panel, currentValue);
        }

        if(shouldListen) {
            $.Schedule(checkRate, inputChangedLoop);
        }
    }

    panel.SetPanelEvent('onmouseover', function() {
        // Enable listening, and monitor the field
        shouldListen = true;
        inputChangedLoop();
    });

    panel.SetPanelEvent('onmouseout', function() {
        // No longer listen
        shouldListen = false;

        // Check the value once more
        inputChangedLoop();

        // When we complete
        onComplete(panel, currentValue);
    });
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
	GameEvents.SendCustomGameEventToServer("ziv_debug_change_boss_lock_state", { lock:  $("#LockState").checked });
}

function Toggle() {
	$.GetContextPanel().ToggleClass("WindowClosed");
}

function onHealthChange(panel, value) {
	GameEvents.SendCustomGameEventToServer("ziv_debug_change_boss_health", { "health" : value });
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

	hookSliderChange($("#BossHealth"), onHealthChange, function(){})

	Game.AddCommand("+ZIVShowDebugPanel", Toggle, "", 0); 
	Game.AddCommand("-ZIVShowDebugPanel", undefined, "", 0); 
})();