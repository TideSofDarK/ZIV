"use strict";

var m_AbilityPanels = []; // created up to a high-water mark, but reused when selection changes

var m_InventoryPanels = []

var DOTA_ITEM_STASH_MIN = 0;
var DOTA_ITEM_STASH_MAX = 12;

var m_StatusPanel;
var m_FortifyPanel;
var m_CraftingPanel;

// var modelParticle;

function OnAbilityLearnModeToggled( bEnabled )
{
	UpdateAbilityList();
}

function UpdateAbilityList()
{
	var abilityListPanel = $( "#AbilityList" );
	if ( !abilityListPanel )
		return;

	var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );

	// see if we can level up
	var nRemainingPoints = Entities.GetAbilityPoints( queryUnit );
	var bPointsToSpend = ( nRemainingPoints > 0 );
	var bControlsUnit = Entities.IsControllableByPlayer( queryUnit, Game.GetLocalPlayerID() );
	$.GetContextPanel().SetHasClass( "could_level_up", ( bControlsUnit && bPointsToSpend ) );

	var heroKV = CustomNetTables.GetTableValue( "hero_kvs", Entities.GetUnitName( queryUnit )+"_ziv" );

	var abilityLayout = 0
	if (heroKV) {
		var abilityLayout = parseInt(heroKV["AbilityLayout"])
	}

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

			if (abilityLayout == 5) {
				abilityPanel.AddClass("Layout5");
			}
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

function UpdateHPAndMP() 
{
	var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	var heroKV = CustomNetTables.GetTableValue( "hero_kvs", Entities.GetUnitName( queryUnit )+"_ziv" );

	if (!queryUnit || queryUnit == -1 || !heroKV) $.Schedule( 0.1, UpdateHPAndMP );

	var hp = 	Entities.GetHealth( queryUnit )
	var maxHP = 	Entities.GetMaxHealth( queryUnit ) * 1.0
	var mp = 	Entities.GetMana( queryUnit )
	var maxMP = 	Entities.GetMaxMana( queryUnit ) * 1.0

	var xp = 	Entities.GetCurrentXP( queryUnit );
	var maxXP = 	Entities.GetNeededXPToLevel( queryUnit );

	if (heroKV["UsesEnergy"]) 
	{
		if (heroKV["DarkEnergy"]) {
			$("#SPOrb1").SwitchClass("Mana", "DarkEnergy");
			$("#SPOrb2").SwitchClass("Mana", "DarkEnergy");
			$("#SPOrb3").SwitchClass("Mana", "DarkEnergy");
		}
		else {
			$("#SPOrb1").SwitchClass("Mana", "Energy");
			$("#SPOrb2").SwitchClass("Mana", "Energy");
			$("#SPOrb3").SwitchClass("Mana", "Energy");
		}
	}

	// $("#hp").text = hp + "/" + maxHP;
	// $("#sp").text = mp + "/" + maxMP;

	if (hp != NaN) {
		var hpPercentage = (hp / maxHP * 100);
		$("#HPOrb").style.height = hpPercentage + "%;";
	}

	if (mp != NaN) {
		var mpPercentage = mp / maxMP * 100.0;
		$("#SPOrb").style.height = mpPercentage + "%;";
	}

	// if (maxMP == 0) {
	// 	$("#sp").text = "";
	// }

	if (xp != NaN && maxXP != NaN) {
		var xpPercentage = xp / maxXP;
		var value = (xpPercentage * 700);
		if (value != NaN && value != Infinity) {
			$("#XPBarRoot").style.width = value + "px;";
		}
	}

	$.Schedule( 0.1, UpdateHPAndMP );
}

function GrayoutButton() {
	$("#fortify_button").AddClass("Grayout");
	$("#craft_button").AddClass("Grayout");

	$("#fortify_button").enabled = false;
	$("#craft_button").enabled = false;
}

function SetCraftingButton() {
	$("#fortify_button").style.visibility = "collapse;";
	$("#craft_button").style.visibility = "visible;";

	$("#craft_button").RemoveClass("Grayout");
	$("#craft_button").enabled = true;
}

function SetFortifyButton() {
	$("#fortify_button").style.visibility = "visible;";
	$("#craft_button").style.visibility = "collapse;";

	$("#fortify_button").RemoveClass("Grayout");
	$("#fortify_button").enabled = true;
}

function OpenEquipment() {
	GameEvents.SendEventClientSide( "ziv_open_equipment", {} );
}

function OpenFortifyWindow() {
	GameEvents.SendEventClientSide( "ziv_open_fortify", {} );
}

function OpenCraftingWindow() {
	GameEvents.SendEventClientSide( "ziv_open_crafting", {} );
}

function OpenStatusWindow() {
	GameEvents.SendEventClientSide( "ziv_open_status", {} );
}

function OpenInventoryWindow() {
	GameEvents.SendCustomGameEventToServer( "OpenInventory", {} );
}

function OpenCraftingWindow() {
	GameEvents.SendEventClientSide( "ziv_open_crafting", {} );
}

function OpenSettingsWindow() {
	GameEvents.SendEventClientSide( "ziv_open_settings", {} );
}

(function()
{
	GameEvents.Subscribe( "dota_portrait_ability_layout_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_ability_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_hero_ability_points_changed", UpdateAbilityList );

	GameEvents.Subscribe( "ziv_set_fortify_button", SetFortifyButton );
	GameEvents.Subscribe( "ziv_set_crafting_button", SetCraftingButton );
	GameEvents.Subscribe( "ziv_set_grayout_button", GrayoutButton );
	
	UpdateAbilityList(); // initial update
	
	UpdateHPAndMP();

	GameUI.CustomUIConfig().ingame_ui = $.GetContextPanel();

	// GameUI.CustomUIConfig().hudRoot.FindChildTraverse("RadarButton").DeleteAsync(0.0);
})();