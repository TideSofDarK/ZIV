"use strict";

/* Action-RPG style input handling by @Arhowk

Left click moves or trigger ability 1.
Right click triggers ability 2.
*/

function DoesPlayerUnitHaveBuff(buffName){
	var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	for(var i = 0; i < Entities.GetNumBuffs(localHeroIndex); i++){
		if(Buffs.GetName(localHeroIndex, Entities.GetBuff(localHeroIndex,i)) == buffName){
			return true;
		}
	}
	return false;
}

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

//Tracks when the left mouse button is following a target
function BeginAttackState(targetEntity){
	var order = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position : [0, 0, 0],
		QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
		ShowEffects : true
	};
	
	if(targetEntity && targetEntity !== -1){
		order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_ATTACK_TARGET;
		order.TargetIndex = targetEntity
		Game.PrepareUnitOrders(order)

		if (GameUI.CustomUIConfig().LMBPressed == true) {
			$.Schedule(0.4, OnLeftButtonPressed);

		}
		return
	}
	/*
	(function tic()
	{
		if ( GameUI.IsMouseDown( 0 ) )
		{
			$.Schedule( 1.0/30.0, tic );
			var mouseWorldPos = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() );
			if ( mouseWorldPos !== null )
			{
				if ( GameUI.IsMouseDown( 1 ) || GameUI.IsMouseDown( 2 ) )
				{
					return;
				}			
				order.Position = mouseWorldPos;
				Game.PrepareUnitOrders( order );
			}
		}
	})();*/
}

// Tracks the right-button is following a target or QWERT
function BeginSpellState( nMouseButton, abilityIndex, targetEntityIndex )
{
	var order = {
		AbilityIndex : abilityIndex,
		QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
		ShowEffects : false
	};

	var abilityBehavior = Abilities.GetBehavior( abilityIndex );
	if ( abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT )
	{
		order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_CAST_POSITION;
		order.Position = GetMouseCastPosition( abilityIndex );
	}


	if ( ( abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET ) && ( targetEntityIndex !== -1 ) )
	{
		// If shift is held down and we've a valid point target order and our unit target is out of range,
		// just use the point target.
		if ( ! ( GameUI.IsShiftDown() 
				&& order.OrderType !== undefined 
				&& !Entities.IsEntityInRange( Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ), targetEntityIndex, abilityRange ) ) )
		{
			order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TARGET;
			order.TargetIndex = targetEntityIndex;
		}
	}

	if ( abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET )
	{
		order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_CAST_NO_TARGET
	}

	if ( order.OrderType === undefined )
		return;

	(function tic()
	{
		if ( GameUI.IsMouseDown( nMouseButton ) )
		{
			if ( order.TargetIndex !== undefined )
			{
				if ( Entities.GetTeamNumber( order.TargetIndex ) === DOTATeam_t.DOTA_TEAM_GOODGUYS )
				{
					return;
				}
				if ( !Entities.IsAlive( order.TargetIndex) )
				{
					return;
				}
			}
	
			if ( order.TargetIndex === undefined && GameUI.IsShiftDown() )
			{
				order.Position = GetMouseCastPosition( abilityIndex );
			}

			if ( Abilities.IsCooldownReady( order.AbilityIndex ) && !Abilities.IsInAbilityPhase( order.AbilityIndex ) )
			{
				Game.PrepareUnitOrders( order );
			}
			$.Schedule( 1.0/30.0, tic );
		}	
	})();
}

// Tracks the left-button helf when picking up an item.
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

// Tracks the left-button held state when moving.
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
		if ( GameUI.IsMouseDown( 0 ) || GameUI.IsMouseDown(1) )
		{
			$.Schedule( 1.0/30.0, tic );
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
		}else{
			if(DoesPlayerUnitHaveBuff("modifier_berserker_whirlwind")){
				GameEvents.SendCustomGameEventToServer("whirlwind_cancel", {});
			}
		}
	})();
}

// Handle Left Button events
function OnLeftButtonPressed()
{
	// if(Entities.GetAbilityCount(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())) >= 7){
		// var castAbilityIndex = Entities.GetAbility( Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ), 5 );
		// var targetIndex = GetMouseCastTarget();
		// if ( targetIndex === -1 )
		// {
		// 	if ( GameUI.IsShiftDown() )
		// 	{
		// 		if(Abilities.IsPassive(castAbilityIndex)){
		// 			BeginAttackState()
		// 		}else{
		// 			BeginSpellState( 0, castAbilityIndex, -1 );
		// 		}
		// 	}
		// 	else
		// 	{
		// 		BeginMoveState();
		// 	}
		// }
		// else if ( Entities.IsItemPhysical( targetIndex ) )
		// {
		// 	BeginPickUpState( targetIndex );
		// }
		// else
		// {
		// 	if(!Abilities.IsPassive(castAbilityIndex) && Abilities.IsCooldownReady(castAbilityIndex) && Abilities.GetLevel(castAbilityIndex) > 0 && Abilities.GetManaCost(castAbilityIndex) < Entities.GetMana(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))){
		// 		BeginSpellState( 0, castAbilityIndex, targetIndex );
		// 		$.Msg("ATTACK " + ("" + !Abilities.IsPassive(castAbilityIndex)) + ("" + Abilities.IsCooldownReady(castAbilityIndex)) + ("" + Abilities.GetLevel(castAbilityIndex) > 0) + ( "" + Abilities.GetManaCost(castAbilityIndex) < Entities.GetMana(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))));
		// 	}else{
		// 		if ( GameUI.IsShiftDown() )
		// 		{

		// 			GameUI.SelectUnit( targetIndex, false )
		// 		}
		// 		else
		// 		{
		// 			BeginAttackState(targetIndex);
		// 		}
		// 	}
		// }
	// }else
	{
		var targetIndex = GetMouseCastTarget();
		if ( targetIndex === -1 )
		{
			if ( GameUI.IsShiftDown() )
			{
				GameUI.SelectUnit( targetIndex, false )
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
			BeginAttackState(targetIndex);
		}
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
		// Left-click is move to position or attack
		if ( arg === 0 )
		{
			GameUI.CustomUIConfig().LMBPressed = true;
			OnLeftButtonPressed();
			
			return CONSUME_EVENT;
		}

		// Right-click is use ability #2
		if ( arg === 1 )
		{
			OnRightButtonPressed();
			return CONSUME_EVENT;
		}

		// Middle-click is reset yaw.
		if ( arg === 2 )
		{
			g_targetYaw = 0;
			g_yaw = g_targetYaw;
			return CONSUME_EVENT;
		}
	}

	if ( eventName === "released" )
	{
		// Left-click is move to position or attack
		if ( arg === 0 )
		{
			GameUI.CustomUIConfig().LMBPressed = false;
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
GameUI.SetCameraDistance( 900 );
GameUI.SetCameraLookAtPositionHeightOffset( 200 )