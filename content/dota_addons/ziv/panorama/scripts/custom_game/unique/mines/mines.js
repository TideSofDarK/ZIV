"use strict";

var objective;

var pathGreen = $("#WagonPathGreen");
var pathRed = $("#WagonPathRed");

var marker = $("#WagonMarker");

function SetUIState(args) {

}

function OnScenarioChanged(args) {
	var args = CustomNetTables.GetTableValue( args, "obelisks" );
	var count = args["count"] + "/" + args["max"];
	objective.text = $.Localize("#temple_obelisks") + count;
}

// MInimap filter
// function minimapFilter( entity ){
// 	var heroID = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
// 	var visionRange = Entities.GetCurrentVisionRange( heroID );		
// 	return Entities.IsEntityInRange( heroID, entity, visionRange ) &&
// 		!Entities.IsInvisible( entity ) && 
// 		Entities.IsValidEntity( entity ) &&
// 		(Entities.IsHero( entity ) || Entities.GetUnitName(entity) == "npc_temple_obelisk") &&
// 		heroID != entity;
// }

// Get mark filename
// function getMarkType( entity )
// {
// 	var type = "default";
// 	if (Entities.IsHero( entity ))
// 		return "hero";

// 	if (Entities.GetUnitName(entity) == "npc_temple_obelisk")
// 		return "obelisk";

// 	return type; 
// } 

function SetPathPercentage(value) {
	pathGreen.style.width = value + "%;";
	
	var width = $("#WagonPath").contentwidth;
	width = ((value / 100) * width);

	pathGreen.style.width = width + "px;";
	marker.style.position = width + "px 0px 0px;";
}

(function () {
	SetPathPercentage(0);

	// objective = $("#objective1");

	// OnScenarioChanged("scenario");

	// GameEvents.Subscribe( "ziv_temple_set_ui_state", SetUIState);
	
	// CustomNetTables.SubscribeNetTableListener( "scenario", OnScenarioChanged );

	// GameUI.CustomUIConfig().setMinimapSettings({ rotation: 45, filter: minimapFilter, marks: getMarkType });  
})();