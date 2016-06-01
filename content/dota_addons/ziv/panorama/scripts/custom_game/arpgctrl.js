"use strict";

/* Action-RPG style input handling based on @Arhowk's code

Left click moves or trigger ability 4.
Right click triggers ability 5.
*/

var heightOffset = 300;
var clampOffset = 200;

function GetMouseCastTarget()
{
	var mouseEntities = GameUI.FindScreenEntities( GameUI.GetCursorPosition() );
	var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	mouseEntities = mouseEntities.filter( function(e) { return e.entityIndex !== localHeroIndex; } );
	for ( var e of mouseEntities )
	{
		if ( !e.accurateCollision )
			continue;
		return e.entityIndex;
	}

	for ( var e of mouseEntities )
	{
		return e.entityIndex;
	}

	return -1;
}

function GetMouseCastPosition( abilityIndex )
{
	var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	var localHeroPosition = Entities.GetAbsOrigin( localHeroIndex );
	var position = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() );
	var targetDelta = [ position[0] - localHeroPosition[0], position[1] - localHeroPosition[1] ];
	var targetDist = Math.sqrt( targetDelta[0] * targetDelta[0] + targetDelta[1] * targetDelta[1] );
	var abilityRange = Abilities.GetCastRange( abilityIndex );
	if ( targetDist > abilityRange && abilityRange > 0 )
	{
		position[0] = localHeroPosition[0] + targetDelta[0] * abilityRange / targetDist;
		position[1] = localHeroPosition[1] + targetDelta[1] * abilityRange / targetDist;
	}
	return position;
}

function BeginPickUpState( targetEntIndex )
{
	var order = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_PICKUP_ITEM,
		TargetIndex : targetEntIndex,
		QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
		ShowEffects : false
	};
	(function tic()
	{
		if ( GameUI.IsMouseDown( 0 ) )
		{
			$.Schedule( 1.0/30.0, tic );
			if ( Entities.IsValidEntity( order.TargetIndex) )
			{
				Game.PrepareUnitOrders( order );
			}
		}	
	})();
}

var offset = 0;

(function SmoothCameraZ()
{
	$.Schedule( 1.0/60.0, SmoothCameraZ );
	var minStep = 0.5;
	var target = Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))[2] - heightOffset;
	target = Math.max(0, Math.min(clampOffset, target));
	var delta = ( target - offset );
	if ( Math.abs( delta ) < minStep )
	{
		delta = target;
	}
	else
	{
		var step = delta * 0.3;
		if ( Math.abs( step ) < minStep )
		{
			if ( delta > 0 )
				step = minStep;
			else
				step = -minStep;
		}
		offset += step;
	}

	GameUI.SetCameraLookAtPositionHeightOffset(offset); 
	return;
})();

function BeginMoveState()
{
	var order = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position : [0, 0, 0],
		QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
		ShowEffects : false
	};
	(function tic()
	{
		if ( GameUI.IsMouseDown( 0 ) )
		{
			$.Schedule( 1.0/30.0, tic );
			if (GetMouseCastTarget() != -1) {
				GameUI.CustomUIConfig().ZIVCastAbility(4, false, true);
			}
			else {
				var mouseWorldPos = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() );
				if ( mouseWorldPos !== null )
				{
					if (GameUI.IsMouseDown( 2 ) )
					{
						return;
					}			
					order.Position = mouseWorldPos;
					Game.PrepareUnitOrders( order );
				}
			}
		}
	})();
}

function OnLeftButtonPressed()
{
	var targetIndex = GetMouseCastTarget();
	if ( targetIndex === -1 )
	{
		if ( GameUI.IsShiftDown() )
		{
			GameUI.CustomUIConfig().ZIVCastAbility(4, false, true);
		}
		else
		{
			BeginMoveState();
		}
	}
	else if ( Entities.IsItemPhysical( targetIndex ) )
	{
		BeginPickUpState( targetIndex );
	}
	else
	{
		BeginMoveState();
	}
}

// Main mouse event callback
GameUI.SetMouseCallback( function( eventName, arg ) {
	var nMouseButton = arg
	var CONSUME_EVENT = true;
	var CONTINUE_PROCESSING_EVENT = false;
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
		return CONTINUE_PROCESSING_EVENT;

	if ( eventName === "pressed" )
	{
		if ( arg === 0 )
		{
			OnLeftButtonPressed();
			
			return CONSUME_EVENT;
		}

		if ( arg === 1 )
		{
			GameUI.CustomUIConfig().ZIVCastAbility(5, false, true);
			return CONSUME_EVENT;
		}

		if ( arg === 2 )
		{
			return CONSUME_EVENT;
		}
	}

	if ( eventName === "released" )
	{
		if ( arg === 0 )
		{
			GameUI.CustomUIConfig().ZIVStopAbility4();
			return CONSUME_EVENT;
		}
	}

	if ( eventName === "doublepressed" )
	{
		return CONSUME_EVENT;
	}
	return CONTINUE_PROCESSING_EVENT;
} );

GameUI.SetCameraPitchMax( 55 );
GameUI.SetCameraYaw( 45 );
// GameUI.SetCameraDistance( 900 );
GameUI.SetCameraLookAtPositionHeightOffset(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))[2]); 