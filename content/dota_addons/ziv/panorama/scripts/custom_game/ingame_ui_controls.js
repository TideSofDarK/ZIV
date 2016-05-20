"use strict";

var m_AbilityCasting = [];

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

function ZIVStopAbility(number) {
	var ability = Entities.GetAbility( Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ), number-1 ); 
	if (m_AbilityCasting[ability] == true) {
		m_AbilityCasting[ability] = false;
	}
}

function ZIVCastAbility(number, pressing) { 
	var ability = Entities.GetAbility( Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ), number-1 ); 

	if (ability !== -1) {
		if (pressing && m_AbilityCasting[ability] == false) {
			return;
		}
		var order = {
			AbilityIndex : ability,
			Queue : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_DEFAULT,
			ShowEffects : true,
			OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_NO_TARGET
		};
		var abilityBehavior = Abilities.GetBehavior( order.AbilityIndex );
		var target = GetMouseCastTarget();

		if ( abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT ) {
			if (abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET && target != -1) {
				order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TARGET;
				order.TargetIndex = target;
				order.Position = GetMouseCastPosition( order.AbilityIndex );
			}
			else {
				order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_CAST_POSITION;
				order.Position = GetMouseCastPosition( order.AbilityIndex );
			}
		}
		if ( abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET )
		{
			if (abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT && target == -1) {
				order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_CAST_POSITION;
				order.Position = GetMouseCastPosition( order.AbilityIndex );
			}
			else if (target !== -1) 
			{
				order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TARGET;
				order.TargetIndex = GetMouseCastTarget();
			}
		}

		if (Abilities.IsCooldownReady(ability) === true && Abilities.IsInAbilityPhase(ability) === false) {
			Game.PrepareUnitOrders( order );
		}

		m_AbilityCasting[ability] = true;
		
		$.Schedule(Abilities.GetCooldownTimeRemaining( ability ) + 0.08, (function() {ZIVCastAbility(number, true)}) )
	}
}

(function()
{
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
})();