"use strict";

$.GetContextPanel().entity = -1;

function Click()
{
	if (GameUI.IsAltDown())
	{
		var entity = $.GetContextPanel().entity;
		var eventType = "defend";

		var pos = Entities.GetAbsOrigin( entity );
		GameEvents.SendCustomGameEventToServer( "set_minimap_event", { "type": eventType, "duration": 5, "pos": [ pos[0], pos[1] ], "entity": entity } );
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
	$.DispatchEvent( "DOTAShowTextTooltip", $.Localize( "#defend" ) );
}

function HideEntityTooltip()
{
	$.DispatchEvent( "DOTAHideTextTooltip");
}

(function()
{ 

})();