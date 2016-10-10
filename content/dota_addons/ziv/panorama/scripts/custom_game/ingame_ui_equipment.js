"use strict";

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

var equipmentContainerID;
var inventoryContainerID;

function Init(args) {
	if (args) {
		equipmentContainerID = args.equipmentContainerID;
		inventoryContainerID = args.inventoryContainerID;
	}

	GameUI.CustomUIConfig().OpenContainer({"id" : equipmentContainerID, "panel" : $("#Equipment")});
	GameUI.CustomUIConfig().OpenContainer({"id" : inventoryContainerID, "panel" : $("#Inventory")});

	var heroKV = PlayerTables.GetTableValue("kvs", "heroes")[Entities.GetUnitName(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))];
	var slots = heroKV["EquipmentSlots"].split(';');

	for (var i = 1; i <= 6; i++) {
		var panel = $("#Equipment").Children()[0].FindChildTraverse("slot"+i);
		panel.FindChildTraverse("ItemImage").style.backgroundImage = "url('file://{images}/custom_game/ingame_ui/slots/" + slots[i-1] + ".png');";
		panel.FindChildTraverse("ItemImage").style.backgroundSize = "100% 100%;";
	}

	$.GetContextPanel().SetHasClass("WindowClosed", false);
}

function Toggle() {
	if (!equipmentContainerID && !inventoryContainerID) {
		GameEvents.SendCustomGameEventToServer("ziv_get_containers", {})
	} else {
		if ($.GetContextPanel().BHasClass("WindowClosed") == false) {
			GameUI.CustomUIConfig().DeleteContainer({"id" : equipmentContainerID})
			GameUI.CustomUIConfig().DeleteContainer({"id" : inventoryContainerID})

			$.GetContextPanel().SetHasClass("WindowClosed", true);
		} else {
			$.GetContextPanel().SetHasClass("WindowClosed", false);
			Init();
		}
	}
}

(function()
{
	GameEvents.Subscribe( "ziv_open_equipment", Toggle );
	GameEvents.Subscribe( "ziv_set_containers", Init );
})();

