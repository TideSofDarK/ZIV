"use strict";

var g_nMovingCameraOffset = 600;
var g_nStillCameraOffset = 0;
var g_flTimeSpentMoving = 0.0;
var HUD_THINK = 0.005;
var g_nBossCameraEntIndex = -1;
var g_flCameraDesiredOffset = -128.0;
var g_flAdditionalCameraOffset = 0.0;
var g_flMaxLookDistance = 1200.0;
var g_nCachedCameraEntIndex = -1;

var abilityCasting = [];
var abilityTimings = [];
var abilityDelay = 0.2;

GameUI.SetCameraTerrainAdjustmentEnabled( false );

function UpdateCamera()
{
	var localCamFollowIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	//handle spectators
	if ( Players.IsLocalPlayerInPerspectiveCamera() )
	{
		localCamFollowIndex = Players.GetPerspectivePlayerEntityIndex();
	}

	if ( localCamFollowIndex !== -1 )
	{
		if ( Entities.IsAlive( localCamFollowIndex ) === false )
			return;

		var vDesiredLookAtPosition = Entities.GetAbsOrigin( localCamFollowIndex );
		var vLookAtPos = GameUI.GetCameraLookAtPosition();
		var flCurOffset = GameUI.GetCameraLookAtPositionHeightOffset();
		var flCameraRawHeight = vLookAtPos[2] - flCurOffset;
		var flEntityHeight = vDesiredLookAtPosition[2];
		vDesiredLookAtPosition[1] = vDesiredLookAtPosition[1];
		
		var bMouseWheelDown = GameUI.IsMouseDown( 2 );
		if ( bMouseWheelDown )
		{
			var vScreenWorldPos = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() );
			if ( vScreenWorldPos !== null )
			{
				var vToCursor = [];
				vToCursor[0] = vScreenWorldPos[0] - vDesiredLookAtPosition[0];
				vToCursor[1] = vScreenWorldPos[1] - vDesiredLookAtPosition[1];
				vToCursor[2] = vScreenWorldPos[2] - vDesiredLookAtPosition[2];

				vToCursor = Game.Normalized( vToCursor );
				var flDistance = Math.min( Game.Length2D( vScreenWorldPos, vDesiredLookAtPosition ), g_flMaxLookDistance );
				vDesiredLookAtPosition[0] = vDesiredLookAtPosition[0] + vToCursor[0] * flDistance;
				vDesiredLookAtPosition[1] = vDesiredLookAtPosition[1] + vToCursor[1] * flDistance;
				vDesiredLookAtPosition[2] = vDesiredLookAtPosition[2] + vToCursor[2] * flDistance;
			}
		}

		var flHeightDiff = flCameraRawHeight - flEntityHeight;
		var flNewOffset = g_flCameraDesiredOffset - flHeightDiff + 50;
		var key = 0;
		// var bossData = CustomNetTables.GetTableValue("boss", key.toString());
		var flAdditionalOffset = 0.0;
		// if ( typeof( bossData ) != "undefined" )
		// {
		// 	var bShowBossHP = bossData["boss_hp"] == 0 ? false : true;
		// 	if ( bShowBossHP )
		// 	{
		// 	    flAdditionalOffset = 100.0;
		// 	}
		// }

		var t = Game.GetGameFrameTime() / 1.5;
		if ( t > 1.0 ) { t = 1.0; }

		g_flAdditionalCameraOffset = g_flAdditionalCameraOffset * t + flAdditionalOffset * ( 1.0 - t ); 
		flNewOffset = flNewOffset + g_flAdditionalCameraOffset;

		var flLerp = 0.0001;
		if ( bMouseWheelDown )
		{
			flLerp = 0.1;
		}
		if ( g_nCachedCameraEntIndex !== localCamFollowIndex )
		{
			flLerp = 1.5;
		}
		
		GameUI.SetCameraTargetPosition(vDesiredLookAtPosition, flLerp);
		GameUI.SetCameraLookAtPositionHeightOffset( flNewOffset );

		g_nCachedCameraEntIndex = localCamFollowIndex;
	}
	else
	{
		GameUI.SetCameraLookAtPositionHeightOffset( 0.0 );
	}
}

(function CameraThink() {
	if ( Game.GetState() < DOTA_GameState.DOTA_GAMERULES_STATE_POST_GAME )
	{
    	UpdateCamera();
    }
    $.Schedule(0, CameraThink);
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

function BeginMoveState(target)
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
			var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
			var ability = Entities.GetAbility( queryUnit, 3 ); 

			if (Abilities.IsInAbilityPhase(ability)) {
				return;
			}

			target = GetMouseCastTarget();

			var move = true;
			if (GameUI.IsShiftDown() || target != -1) {
				if ((Abilities.GetBehavior(ability) & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET) == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET) {
					GameEvents.SendCustomGameEventToServer("ziv_cast_ability_no_target_remote", {"ability" : ability});
				} else if ((Abilities.GetBehavior(ability) & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT) == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT) {
					GameEvents.SendCustomGameEventToServer("ziv_cast_ability_point_target_remote", {"ability" : ability, "target" : GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() ), "target_entity" : target, "force" : true});
				}

				var dcm = DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT;
				move = (Abilities.GetBehavior(ability) & dcm) == dcm;
			}
			if (move && !Entities.IsCommandRestricted(queryUnit)) {
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

	if ( targetIndex != -1 && Entities.IsEnemy( targetIndex )) {
		BeginMoveState( targetIndex );
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
	// GameUI.SetCameraPitchMax( 55 );
	GameUI.SetCameraYaw( 45 )
})();