"use strict";

var objective;

function SetUIState(args) {

}

function OnScenarioChanged(args) {
	var args = CustomNetTables.GetTableValue( args, "obelisks" );
	var count = args["count"] + "/" + args["max"];
	objective.text = $.Localize("#temple_obelisks") + count;
}

(function () {
	objective = $("#objective1");

	OnScenarioChanged("scenario");

	GameEvents.Subscribe( "ziv_temple_set_ui_state", SetUIState);
	
	CustomNetTables.SubscribeNetTableListener( "scenario", OnScenarioChanged );

	GameUI.CustomUIConfig().setMinimapSettings({ rotation: 45 }); 
})();