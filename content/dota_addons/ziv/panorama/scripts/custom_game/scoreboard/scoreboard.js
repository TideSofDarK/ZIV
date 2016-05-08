"use strict";

//-----------------------------------------------------------------------------
//	Slide tracking
//-----------------------------------------------------------------------------
var firstClick = true;
var isHoverButton = true;

var startMousePos = null;
var minMargin = -695
var startMargin = 0;

function TrackMouse()
{
  if (GameUI.IsMouseDown(0))
  {
    if (firstClick)
    {
      startMousePos = GameUI.GetCursorPosition();
      startMargin = $.GetContextPanel().GetPositionWithinWindow()["x"];
      firstClick = false;
    }
    else
    {          
      var curPos = GameUI.GetCursorPosition();
      var count = (curPos[0] - startMousePos[0] + startMargin) * 1920 / Game.GetScreenWidth();

      if (count > 0)
      	count = 0;
      if (count < minMargin)
      	count = minMargin; 

      if (!isNaN(count))
      	$.GetContextPanel().style.transform = "translatex(" + count + "px );";
      
    }
  }
  else
    firstClick = true;

  if (!isHoverButton)
  {
  	firstClick = true;
  	return;
  }

  $.Schedule(0.01, TrackMouse)
}

function OnLeaveButton()
{
  isHoverButton = false;
}

function OnHoverButton()
{
  if (!isHoverButton) 
  {
    isHoverButton = true;
    TrackMouse();
  }
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