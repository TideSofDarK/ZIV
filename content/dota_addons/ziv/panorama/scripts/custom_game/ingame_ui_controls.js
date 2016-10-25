"use strict";

GameUI.SetRenderBottomInsetOverride( 0 );
GameUI.SetRenderTopInsetOverride( 0 );

var heightOffset = 300;
var clampOffset = 200;
var offset = 0;

var abilityCasting = [];
var abilityTimings = [];
var abilityDelay = 0.2;

(function UpdateCamera()
{
	GameUI.SetCameraTarget(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ));
	
	$.Schedule( 1.0/30.0, UpdateCamera );
	var minStep = 0.5;
	var heroY = Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))[2];
	var target = heroY - heightOffset;
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

	GameUI.SetCameraLookAtPositionHeightOffset(offset - 150 + (heroY * 0.01)); 
	return;
})();

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
		if ( GameUI.IsMouseDown( 0 ))
		{
			$.Schedule( 1.0/30.0, tic );

			var move = true;
			if (GameUI.IsShiftDown() || GetMouseCastTarget() != -1) {
				var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
				var ability = Entities.GetAbility( queryUnit, 3 ); 
				
				if ((Abilities.GetBehavior(ability) & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET) == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET) {
					GameEvents.SendCustomGameEventToServer("ziv_cast_ability_no_target_remote", {"ability" : ability});
				} else {
					GameUI.CustomUIConfig().ZIVCastAbility(4, false, true);
				}

				var dcm = DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT;
				move = (Abilities.GetBehavior(ability) & dcm) == dcm;
			}
			if (move) {
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
	
	if (GameUI.IsShiftDown()) {
		BeginMoveState();
	} else if ( targetIndex != -1 && Entities.IsEnemy( targetIndex )) {
		BeginMoveState();
	} else if ( Entities.IsItemPhysical( targetIndex ) ) {
		BeginPickUpState( targetIndex );
	} else {
		BeginMoveState();
	}
}

function GetMouseCastTarget()
{
	var mouseEntities = GameUI.FindScreenEntities( GameUI.GetCursorPosition() );
	var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	mouseEntities = mouseEntities.filter( function(e) { return (e.entityIndex !== localHeroIndex) && Entities.IsEnemy(e.entityIndex); } );
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

function ZIVStopAbility(number) {
	var ability = Entities.GetAbility( Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ), number-1 ); 
	if (abilityCasting[ability] == true) {
		abilityCasting[ability] = false;
	}
}

function ZIVCastAbility(number, pressing, single) { 
	var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	var ability = Entities.GetAbility( queryUnit, number-1 ); 
	if (Entities.IsAlive(queryUnit) == false || 
		Entities.IsCommandRestricted(queryUnit) == true ||
		Entities.IsSilenced(queryUnit) == true) {
		return false;
	}

	if (ability !== -1) {
		if (!abilityTimings[ability]) {
			abilityTimings[ability] = 0;
		}

		if (pressing && abilityCasting[ability] == false) {
			return;
		}

		if ((Game.Time() - abilityTimings[ability]) > abilityDelay && Abilities.IsCooldownReady(ability) === true && Abilities.IsInAbilityPhase(ability) === false && Abilities.GetCooldownTimeRemaining(ability) === 0.0) {
			abilityTimings[ability] = Game.Time();
			Abilities.ExecuteAbility( ability, queryUnit, true );
		}

		var tic = Abilities.GetCooldownTimeRemaining( ability );

		if (!single) {
			abilityCasting[ability] = true;
				
			$.Schedule(tic, (function() {ZIVCastAbility(number, true)}) );
		}
		return tic;
	}
}

(function()
{
	// Hotkeys
	GameUI.CustomUIConfig().ZIVCastAbility = ZIVCastAbility;
	GameUI.CustomUIConfig().ZIVStopAbility = ZIVStopAbility; 

    GameUI.CustomUIConfig().ZIVCastAbility1 = function() { GameUI.CustomUIConfig().ZIVCastAbility(1) }
    GameUI.CustomUIConfig().ZIVCastAbility2 = function() { GameUI.CustomUIConfig().ZIVCastAbility(2) }
    GameUI.CustomUIConfig().ZIVCastAbility3 = function() { GameUI.CustomUIConfig().ZIVCastAbility(3) }
    GameUI.CustomUIConfig().ZIVCastAbility4 = function() { GameUI.CustomUIConfig().ZIVCastAbility(4) }
    GameUI.CustomUIConfig().ZIVCastAbility5 = function() { GameUI.CustomUIConfig().ZIVCastAbility(5) }

    GameUI.CustomUIConfig().ZIVStopAbility1 = function() { GameUI.CustomUIConfig().ZIVStopAbility(1) }
    GameUI.CustomUIConfig().ZIVStopAbility2 = function() { GameUI.CustomUIConfig().ZIVStopAbility(2) }
    GameUI.CustomUIConfig().ZIVStopAbility3 = function() { GameUI.CustomUIConfig().ZIVStopAbility(3) }
    GameUI.CustomUIConfig().ZIVStopAbility4 = function() { GameUI.CustomUIConfig().ZIVStopAbility(4) }
    GameUI.CustomUIConfig().ZIVStopAbility5 = function() { GameUI.CustomUIConfig().ZIVStopAbility(5) }

    Game.AddCommand("+ZIVCastAbility1", GameUI.CustomUIConfig().ZIVCastAbility1, "", 0);
    Game.AddCommand("+ZIVCastAbility2", GameUI.CustomUIConfig().ZIVCastAbility2, "", 0);
    Game.AddCommand("+ZIVCastAbility3", GameUI.CustomUIConfig().ZIVCastAbility3, "", 0);
    Game.AddCommand("+ZIVCastAbility4", GameUI.CustomUIConfig().ZIVCastAbility4, "", 0);
    Game.AddCommand("+ZIVCastAbility5", GameUI.CustomUIConfig().ZIVCastAbility5, "", 0);

    Game.AddCommand("-ZIVCastAbility1", GameUI.CustomUIConfig().ZIVStopAbility1, "", 0);
    Game.AddCommand("-ZIVCastAbility2", GameUI.CustomUIConfig().ZIVStopAbility2, "", 0);
    Game.AddCommand("-ZIVCastAbility3", GameUI.CustomUIConfig().ZIVStopAbility3, "", 0);
    Game.AddCommand("-ZIVCastAbility4", GameUI.CustomUIConfig().ZIVStopAbility4, "", 0);
    Game.AddCommand("-ZIVCastAbility5", GameUI.CustomUIConfig().ZIVStopAbility5, "", 0);

    Game.AddCommand("+ZIVShowMinimap", GameUI.CustomUIConfig().ChangeMinimapMode, "", 0); 
	Game.AddCommand("-ZIVShowMinimap", GameUI.CustomUIConfig().ChangeMinimapMode, "", 0); 

    Game.AddCommand("+ZIVShowStatus", GameUI.CustomUIConfig().ToggleStatusWindow, "", 0); 
	Game.AddCommand("+ZIVShowEquipment", GameUI.CustomUIConfig().ToggleEquipmentWindow, "", 0); 

    //Mouse
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

    // Camera
	GameUI.SetCameraPitchMax( 55 );
	GameUI.SetCameraLookAtPositionHeightOffset(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))[2]/2); 
})();