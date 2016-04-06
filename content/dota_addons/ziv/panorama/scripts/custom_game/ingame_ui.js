"use strict";

var m_AbilityPanels = []; // created up to a high-water mark, but reused when selection changes

var m_InventoryPanels = []

var DOTA_ITEM_STASH_MIN = 0;
var DOTA_ITEM_STASH_MAX = 12;

var m_StatusPanel;
var m_FortifyPanel;
var m_CraftingPanel;

var modelParticle;

function UpdateInventory()
{
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	for ( var i = 0; i < DOTA_ITEM_STASH_MAX; ++i )
	{
		var inventoryPanel = m_InventoryPanels[i]
		var item = Entities.GetItemInSlot( queryUnit, i );

		inventoryPanel.SetItem( queryUnit, item );
	}
}

function CreateInventoryPanels()
{
	var stashPanel = undefined; //$( "#stash_row" );
	var firstRowPanel = $( "#inventory_row_1" );
	var secondRowPanel = $( "#inventory_row_2" );
	var thirdRowPanel = $( "#inventory_row_3" );
	var fourthRowPanel = $( "#inventory_row_4" );

	if ( !firstRowPanel || !secondRowPanel || !secondRowPanel || !secondRowPanel )
		return;

	// stashPanel.RemoveAndDeleteChildren();
	firstRowPanel.RemoveAndDeleteChildren();
	secondRowPanel.RemoveAndDeleteChildren();
	thirdRowPanel.RemoveAndDeleteChildren();
	fourthRowPanel.RemoveAndDeleteChildren();
	
	m_InventoryPanels = []

	for ( var i = 0; i < 4; ++i )
	{
		for (var y = 0; y < 3; y++) {
			var parentPanel = firstRowPanel;

			if ( i == 0 )
			{
				parentPanel = firstRowPanel;
			}
			else if ( i == 1 )
			{
				parentPanel = secondRowPanel;
			}
			else if ( i == 2 )
			{
				parentPanel = thirdRowPanel;
			}
			else if ( i == 3 )
			{
				parentPanel = fourthRowPanel;
			}

			var inventoryPanel = $.CreatePanel( "Panel", parentPanel, "" );
			inventoryPanel.BLoadLayout( "file://{resources}/layout/custom_game/ingame_ui_inventory_item.xml", false, false );
			inventoryPanel.SetItemSlot( i );

			m_InventoryPanels.push( inventoryPanel );	
		}
	}
}

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

	var queryUnit = Game.GetLocalPlayerInfo()["player_selected_hero_entity_index"];
	// GameUI.SetCameraTarget(queryUnit);

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
	var queryUnit = Game.GetLocalPlayerInfo()["player_selected_hero_entity_index"];
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

// function CreateHPAndMPParticles() {
// 	var queryUnit = Game.GetLocalPlayerInfo()["player_selected_hero_entity_index"];

// 	if (modelParticle) {
// 		Particles.DestroyParticleEffect(modelParticle, true);
// 	}

//     modelParticle = Particles.CreateParticle("particles/ziv_hp_bar.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, queryUnit);


//     UpdateParticles();
// }

// function UpdateParticles() {
//     Particles.SetParticleControl(modelParticle, 3, [0,0,0])
//     Particles.SetParticleControl(modelParticle, 0, GameUI.GetScreenWorldPosition())
//     $.Schedule(0.1, UpdateParticles);
// }

function CreateSideButtons() {
	// $.CreatePanel( "Panel", $("#SideButtons"), "" ).BLoadLayout( "file://{resources}/layout/custom_game/equip_list.xml", false, false );
}

function OpenFortifyWindow() {
	// $.CreatePanel( "Panel", $.GetContextPanel(), "" ).BLoadLayout( "file://{resources}/layout/custom_game/ingame_ui_fortify.xml", false, false );
	GameEvents.SendEventClientSide( "ziv_open_fortify", {} )
}

function OpenStatusWindow() {
	// $.CreatePanel( "Panel", $.GetContextPanel(), "" ).BLoadLayout( "file://{resources}/layout/custom_game/ingame_ui_status.xml", false, false );
	GameEvents.SendEventClientSide( "ziv_open_status", {} )
}

function OpenInventoryWindow() {
	GameEvents.SendCustomGameEventToServer( "OpenInventory", {} );
}

function OpenCraftingWindow() {
	GameEvents.SendEventClientSide( "ziv_open_crafting", null )
}

(function()
{
	// CreateInventoryPanels();
	// UpdateInventory();

	// GameEvents.Subscribe( "dota_inventory_changed", UpdateInventory );
	// GameEvents.Subscribe( "dota_inventory_item_changed", UpdateInventory );
	// GameEvents.Subscribe( "m_event_dota_inventory_changed_query_unit", UpdateInventory );
	// GameEvents.Subscribe( "m_event_keybind_changed", UpdateInventory );
	// GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateInventory );
	// GameEvents.Subscribe( "dota_player_update_query_unit", UpdateInventory );

	GameEvents.Subscribe( "dota_portrait_ability_layout_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_ability_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_hero_ability_points_changed", UpdateAbilityList );
	
	UpdateAbilityList(); // initial update
	UpdateHPAndMP();

	CreateSideButtons();

	// CreateHPAndMPParticles();
})();