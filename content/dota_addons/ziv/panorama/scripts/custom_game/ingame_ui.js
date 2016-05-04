"use strict";

var m_AbilityPanels = []; // created up to a high-water mark, but reused when selection changes
var m_AbilityCasting = [];

var m_InventoryPanels = []

var DOTA_ITEM_STASH_MIN = 0;
var DOTA_ITEM_STASH_MAX = 12;

var m_StatusPanel;
var m_FortifyPanel;
var m_CraftingPanel;

// var modelParticle;

function GetMouseCastTarget()
{
	$.Msg("asd");
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
				$.Msg("asd");
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

function SetPortrait() 
{
	var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	$("#PortaitImage").heroname = Entities.GetUnitName(queryUnit);
}

function UpdateHPAndMP() 
{
	var queryUnit = Game.GetLocalPlayerInfo()["player_selected_hero_entity_index"];
	if (!queryUnit || queryUnit == -1) $.Schedule( 0.1, UpdateHPAndMP );
	var hp = 	Entities.GetHealth( queryUnit )
	var maxHP = 	Entities.GetMaxHealth( queryUnit )
	var mp = 	Entities.GetMana( queryUnit )
	var maxMP = 	Entities.GetMaxMana( queryUnit )

	var heroKV = CustomNetTables.GetTableValue( "hero_kvs", Entities.GetUnitName( queryUnit )+"_ziv" );
	if (heroKV["UsesEnergy"]) 
	{
		$("#sp_bar").AddClass("EnergyBar")
	}

	$("#hp").text = hp + "/" + maxHP;
	$("#sp").text = mp + "/" + maxMP;

	if (hp) {
		var hpPercentage = Math.ceil(hp / maxHP * 100);
		$("#hp_bar").style.width = hpPercentage + "%;";
	}

	if (mp) {
		var mpPercentage = Math.ceil(mp / maxMP * 100);
		$("#sp_bar").style.width = mpPercentage + "%;";
	}

	if (maxMP == 0) {
		$("#sp").text = "";
	}

	$.Schedule( 0.1, UpdateHPAndMP );
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
			Queue : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
			ShowEffects : false,
			OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_NO_TARGET
		};
		var abilityBehavior = Abilities.GetBehavior( order.AbilityIndex );
		if ( abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT )
		{
			order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_CAST_POSITION;
			order.Position = GetMouseCastPosition( order.AbilityIndex );
		}
		if ( abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET )
		{
			var target = GetMouseCastTarget();
			if (target !== -1) 
			{
				order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TARGET;
				order.TargetIndex = GetMouseCastTarget();
			}
		}

		if (Abilities.GetCooldownTimeRemaining( ability ) == 0) {
			Game.PrepareUnitOrders( order );
		}

		m_AbilityCasting[ability] = true;
		
		$.Schedule(Abilities.GetCooldownTimeRemaining( ability ), (function() {ZIVCastAbility(number, true)}) )
	}
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
	GameEvents.SendEventClientSide( "ziv_open_equipment", {} )
}

function OpenFortifyWindow() {
	GameEvents.SendEventClientSide( "ziv_open_fortify", {} )
}

function OpenCraftingWindow() {
	GameEvents.SendEventClientSide( "ziv_open_crafting", {} )
}

function OpenStatusWindow() {
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

	SetPortrait();

	GameUI.CustomUIConfig().ZIVCastAbility = ZIVCastAbility;
	GameUI.CustomUIConfig().ZIVStopAbility = ZIVStopAbility; 

	// GameUI.CustomUIConfig().hudRoot.FindChildTraverse("RadarButton").DeleteAsync(0.0);
})();