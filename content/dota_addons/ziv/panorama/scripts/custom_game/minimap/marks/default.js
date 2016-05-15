"use strict";

$.GetContextPanel().entity = -1;

function UpdateClass()
{
	var entity = $.GetContextPanel().entity;
	var panel = $.GetContextPanel();	

	if (Entities.IsHero(entity))
	{
		panel.AddClass("hero");
		$("#Icon").SetImage( "file://{images}/heroes/icons/" + Entities.GetUnitName(entity) + ".png" );
		$("#Icon").style.washColor = Entities.IsEnemy(entity) ? "#ff0000bb;" : "#00ff00bb;";
		return;
	}

	panel.AddClass("square");

	if (Entities.IsItemPhysical(entity))
		panel.AddClass("yellow");

	if (Entities.IsEnemy(entity))
		panel.AddClass("red");
	else if (Entities.IsNeutralUnitType(entity))
		panel.AddClass("white");
	else
		panel.AddClass("green");

	$.Schedule(0.1, UpdateClass);	
}

function Click()
{
	if (GameUI.IsAltDown())
	{
		var entity = $.GetContextPanel().entity;

		var eventType = "";
		if ( Entities.IsEnemy(entity) )
			eventType = "attack";
		else
			if ( Entities.GetTeamNumber(entity) == Players.GetTeam( Players.GetLocalPlayer() ) )
				eventType = "defend";

		if (eventType)
		{
			var pos = Entities.GetAbsOrigin( entity );
			GameEvents.SendCustomGameEventToServer( "set_minimap_event", { "type": eventType, "duration": 5, "pos": [ pos[0], pos[1] ], "entity": entity } );
		}
	}
	else
	{
		var order = {
			OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position : Entities.GetAbsOrigin($.GetContextPanel().entity),
			Queue : false,
			ShowEffects : false
		};
		Game.PrepareUnitOrders( order );
	}
}

function ShowEntityTooltip()
{
	$.DispatchEvent( "DOTAShowTextTooltip", "Entity " + $.GetContextPanel().entity);
}

function HideEntityTooltip()
{
	$.DispatchEvent( "DOTAHideTextTooltip");
}

(function()
{ 
	$.GetContextPanel().UpdateClass = UpdateClass;
	UpdateClass();
})();