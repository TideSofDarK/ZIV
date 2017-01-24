"use strict";

var objective;

var pathGreen = $("#WagonPathGreen");
var pathRed = $("#WagonPathRed");

var marker = $("#WagonMarker");

function SetUIState(args) {

}

function OnScenarioChanged() {
	var args = CustomNetTables.GetTableValue( "scenario", "wagon" );
	if (!args) return;
	SetPathPercentage(args.percentage || 0);
}

function MinimapFilter( entity ) {
	var heroID = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	var visionRange = Entities.GetCurrentVisionRange( heroID );		
	return Entities.IsEntityInRange( heroID, entity, visionRange ) &&
		!Entities.IsInvisible( entity ) && 
		Entities.IsValidEntity( entity ) &&
		(Entities.IsHero( entity ) || Entities.GetUnitName(entity) == "npc_mines_wagon") &&
		heroID != entity;
}

function GetMarkType( entity )
{
	var type = "default";
	if (Entities.IsRealHero( entity ))
		return "hero";

	if (Entities.GetUnitName(entity) == "npc_mines_wagon")
		return "wagon";

	return type; 
} 

function SetPathPercentage(value) {
	pathGreen.style.width = value + "%;";
	
	var width = $("#WagonPath").contentwidth;
	width = (value * width);

	pathGreen.style.width = width + "px;";
	marker.style.position = width + "px 0px 0px;";
}

(function () {
	SetPathPercentage(0);

	// objective = $("#objective1");

	OnScenarioChanged();

	// GameEvents.Subscribe( "ziv_temple_set_ui_state", SetUIState);
	
	CustomNetTables.SubscribeNetTableListener( "scenario", OnScenarioChanged );

	GameUI.CustomUIConfig().SetMinimapSettings({ rotation: 45, filter: MinimapFilter, marks: GetMarkType, image: "https://puu.sh/txVKl/2b023ec639.png" });  

	
})();