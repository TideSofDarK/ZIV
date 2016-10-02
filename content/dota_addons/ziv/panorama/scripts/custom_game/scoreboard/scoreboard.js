"use strict";

function Open() {
  $.GetContextPanel().ToggleClass("Show");
}

//-----------------------------------------------------------------------------
//	Update players
//-----------------------------------------------------------------------------
var playerPanels = [];

function CreatePlayers()
{
	$( "#Players" ).RemoveAndDeleteChildren();

	var playerIDs = Game.GetAllPlayerIDs();

	for(var id of playerIDs)
	{
		var panel = $.CreatePanel( "Panel", $( "#Players" ), "Player_" + id );
		panel.BLoadLayout( "file://{resources}/layout/custom_game/scoreboard/scoreboard_player.xml", false, false );
		panel.playerID = id;
 		
 		playerPanels.push(panel);
	}
}

function UpdatePlayers()
{
	for(var panel of playerPanels)
 		panel.Update();

 	$.Schedule(0.1, UpdatePlayers);
}

(function()
{
	CreatePlayers();

	UpdatePlayers(); 
})();