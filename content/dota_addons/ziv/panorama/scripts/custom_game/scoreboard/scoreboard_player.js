"use strict";



function Update()
{
  var playerID = $.GetContextPanel().playerID;
  if (playerID == -1)
    return;

  var playerInfo = Game.GetPlayerInfo( playerID );

  if (!playerInfo)
    return;

  if ( playerInfo.player_selected_hero !== "" )
  {
    $( "#HeroImage" ).SetImage( "file://{images}/heroes/" + playerInfo.player_selected_hero + ".png" );
    $( "#HeroNameLevel" ).text = $.Localize(playerInfo.player_selected_hero) + " | " + $.Localize("level") + " " + playerInfo.player_level;
  }
  else
    $( "#HeroImage" ).SetImage( "file://{images}/custom_game/unassigned.png" );

  $( "#PlayerName").text = playerInfo.player_name;

  if (playerInfo.player_is_local)
    $( "#PlayerButtons" ).visible = false;
}

function OfferTrade()
{
  GameEvents.SendCustomGameEventToServer( "ziv_trade_request", { "target" : $.GetContextPanel().playerID } );
}

function InviteGroup()
{
  $.Msg("Group!");
}

(function()
{
  $.GetContextPanel().playerID = -1;
	$.GetContextPanel().Update = Update;
})();