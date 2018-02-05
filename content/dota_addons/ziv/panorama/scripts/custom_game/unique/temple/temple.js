"use strict";

var objective;

function SetUIState(args) {

}

function OnScenarioChanged(args) {
	var args = CustomNetTables.GetTableValue( args, "obelisks" );
	var count = args["count"] + "/" + args["max"];
	objective.text = $.Localize("#temple_obelisks") + count;
}

// MInimap filter
function MinimapFilter( entity ){
	var heroID = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	var visionRange = Entities.GetCurrentVisionRange( heroID );		
	return Entities.IsEntityInRange( heroID, entity, visionRange ) &&
		!Entities.IsInvisible( entity ) && 
		Entities.IsValidEntity( entity ) &&
		(Entities.IsHero( entity ) || Entities.GetUnitName(entity) == "npc_temple_obelisk") &&
		heroID != entity;
}

// Get mark filename
function GetMarkType( entity )
{
	var type = "default";
	if (Entities.IsHero( entity ))
		return "hero";

	if (Entities.GetUnitName(entity) == "npc_temple_obelisk")
		return "obelisk";

	return type; 
} 

(function () {
	objective = $("#objective1");

	OnScenarioChanged("scenario");

	GameEvents.Subscribe( "ziv_temple_set_ui_state", SetUIState);
	
	CustomNetTables.SubscribeNetTableListener( "scenario", OnScenarioChanged );

	// GameUI.CustomUIConfig().SetMinimapSettings({ rotation: 45, filter: MinimapFilter, marks: GetMarkType, image: "http://puu.sh/rXDr6/5613600704.png" });  
})();