"use strict";
var imagePath = "file://{images}/custom_game/minimap/event_icons/";

function GetPlayerColor( PlayerID )
{
	var color = Players.GetPlayerColor( PlayerID ).toString(16);
	color = color.substring(6, 8) + color.substring(4, 6) + color.substring(2, 4) + color.substring(0, 2);
	return "#" + color + ";";
}

function EmitEventSournd( type )
{
	var soundFile = "General.PingWarning";

	switch(type)
	{
		case "attack":
			soundFile = "General.PingAttack";
			break;

		case "defend":
			soundFile = "General.PingDefense";
			break;
	}

	Game.EmitSound(soundFile);
}

function FormEvent( type, player, entity )
{
	$( "#Icon" ).SetImage( imagePath + type + ".png" );
	$( "#Icon" ).style.washColor = GetPlayerColor( player );

	$.GetContextPanel().entity = entity;

	EmitEventSournd( type );
}

(function()
{ 
	$.GetContextPanel().entity = -1;
	$.GetContextPanel().FormEvent = FormEvent;
})();