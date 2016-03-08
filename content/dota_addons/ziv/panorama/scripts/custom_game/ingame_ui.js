"use strict";

var m_AbilityPanels = []; // created up to a high-water mark, but reused when selection changes

function OnLevelUpClicked()
{
	if ( Game.IsInAbilityLearnMode() )
	{
		Game.EndAbilityLearnMode();
	}
	else
	{
		Game.EnterAbilityLearnMode();
	}
}

function OnAbilityLearnModeToggled( bEnabled )
{
	UpdateAbilityList();
}

function UpdateAbilityList()
{
	var abilityListPanel = $( "#ability_list" );
	if ( !abilityListPanel )
		return;

	var queryUnit = Players.GetLocalPlayerPortraitUnit();

	// see if we can level up
	var nRemainingPoints = Entities.GetAbilityPoints( queryUnit );
	var bPointsToSpend = ( nRemainingPoints > 0 );
	var bControlsUnit = Entities.IsControllableByPlayer( queryUnit, Game.GetLocalPlayerID() );
	$.GetContextPanel().SetHasClass( "could_level_up", ( bControlsUnit && bPointsToSpend ) );

	var abilityLayout = parseInt(CustomNetTables.GetTableValue( "hero_kvs", Entities.GetUnitName( queryUnit )+"_ziv" )["AbilityLayout"])

	// update all the panels
	var nUsedPanels = 0;
	for ( var i = 0; i < abilityLayout; ++i )
	{
		var ability = Entities.GetAbility( queryUnit, i );
		if ( ability == -1 )
			continue;

		if ( !Abilities.IsDisplayedAbility(ability) )
			continue;
		
		if ( nUsedPanels >= m_AbilityPanels.length )
		{
			// create a new panel
			var abilityPanel = $.CreatePanel( "Panel", abilityListPanel, "" );
			abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/ingame_ui_ability.xml", false, false );
			m_AbilityPanels.push( abilityPanel );
		}

		// update the panel for the current unit / ability
		var abilityPanel = m_AbilityPanels[ nUsedPanels ];
		abilityPanel.SetAbility( ability, queryUnit, Game.IsInAbilityLearnMode() );
		
		nUsedPanels++;
	}

	// clear any remaining panels
	for ( var i = nUsedPanels; i < m_AbilityPanels.length; ++i )
	{
		var abilityPanel = m_AbilityPanels[ i ];
		abilityPanel.SetAbility( -1, -1, false );
	}
}

function UpdateHPAndMP() {
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	var hp = 	Entities.GetHealth( queryUnit )
	var maxHP = 	Entities.GetMaxHealth( queryUnit )
	var mp = 	Entities.GetMana( queryUnit )
	var maxMP = 	Entities.GetMaxMana( queryUnit )

	$("#hp").text = hp + "/" + maxHP;
	$("#mp").text = mp + "/" + maxMP;

	if (hp) {
		var hpPercentage = Math.ceil(hp / maxHP * 100);
		$("#hp_bar").style.width = hpPercentage + "%;";
	}

	if (mp) {
		var mpPercentage = Math.ceil(mp / maxMP * 100);
		$("#mp_bar").style.width = mpPercentage + "%;";
	}

	if (maxMP == 0) {
		$("#mp").text = "";
	}

	$.Schedule( 0.1, UpdateHPAndMP );
}

(function()
{
	GameEvents.Subscribe( "dota_portrait_ability_layout_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_ability_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_hero_ability_points_changed", UpdateAbilityList );
	
	UpdateAbilityList(); // initial update
	UpdateHPAndMP();
})();