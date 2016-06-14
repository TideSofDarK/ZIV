"use strict";

var abilityCasting = [];
var abilityTimings = [];
var abilityDelay = 0.2;

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
		return;
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