"use strict";

var pID;

function CustomSettingDamage() {
	var table = CustomNetTables.GetTableValue( "settings", pID );
	table["CustomSettingDamage"] = $("#CustomSettingDamage").checked == true ? 1 : 0;
	GameEvents.SendCustomGameEventToServer( "ziv_write_to_nettable", { 
		"name" : "settings", 
		"key" : pID,
		"value" : table } );
}

function CustomSettingAutoEquip() {
	var table = CustomNetTables.GetTableValue( "settings", pID );
	table["CustomSettingAutoEquip"] = $("#CustomSettingAutoEquip").checked == true ? 1 : 0;
	GameEvents.SendCustomGameEventToServer( "ziv_write_to_nettable", { 
		"name" : "settings", 
		"key" : pID,
		"value" : table } );
}

function CustomSettingShowTooltip() {
	var table = CustomNetTables.GetTableValue( "settings", pID );
	table["CustomSettingShowTooltip"] = $("#CustomSettingShowTooltip").checked == true ? 1 : 0;
	GameEvents.SendCustomGameEventToServer( "ziv_write_to_nettable", { 
		"name" : "settings", 
		"key" : pID,
		"value" : table } );
}

function CustomSettingControls() {
	var table = CustomNetTables.GetTableValue( "settings", pID );
	table["CustomSettingControls"] = $("#CustomSettingControls").checked == true ? 1 : 0;
	GameEvents.SendCustomGameEventToServer( "ziv_write_to_nettable", { 
		"name" : "settings", 
		"key" : pID,
		"value" : table } );
}

function Toggle() {
	$.GetContextPanel().ToggleClass("WindowClosed");
	if ($.GetContextPanel().BHasClass("WindowClosed")) {
		$.GetContextPanel().RemoveFromPanelsQueue();
	} else {
		$.GetContextPanel().AddToPanelsQueue();
	}
}

(function() {
	GameEvents.Subscribe( "ziv_open_settings", Toggle );

	pID = Players.GetLocalPlayer().toString();

	var children = $("#Checkboxes").Children();
	var settings = CustomNetTables.GetTableValue( "settings", pID );
	$.Msg(settings);
	for (var i = 0; i < children.length; i++) {
		children[i].checked = settings[children[i].id] == 1;
	}

	$.GetContextPanel().SetDraggable( true );
})();