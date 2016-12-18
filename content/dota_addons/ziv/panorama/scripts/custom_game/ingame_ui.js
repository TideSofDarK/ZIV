"use strict";

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;
var Account = GameUI.CustomUIConfig().Account;

// pQuery - panorama jQuery (=
$.$ = GameUI.CustomUIConfig().$;

GameUI.SetRenderBottomInsetOverride( 0 );
GameUI.SetRenderTopInsetOverride( 0 );

var m_AbilityPanels = [];

var SPOrb1 = $("#SPOrb1");
var SPOrb2 = $("#SPOrb2");
var SPOrb3 = $("#SPOrb3");

var HPOrb = $("#HPOrb");
var SPOrb = $("#SPOrb");

var XPBar = $("#XPBarContainer");

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

	var heroKV = PlayerTables.GetTableValue("kvs", "heroes")[Entities.GetUnitName( queryUnit )];

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
			var abilityPanel = $.CreatePanel( "Panel", abilityListPanel, "Ability" + i );
			abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/ingame_ui_ability.xml", false, false );
			m_AbilityPanels.push( abilityPanel );

			if (abilityLayout == 5) {
				// abilityPanel.AddClass("Layout5");
			}
		}

		// update the panel for the current unit / ability
		var abilityPanel = m_AbilityPanels[ nUsedPanels ];
		abilityPanel.SetAbility( ability, queryUnit, i, false );
		
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
	$.Schedule( 0.2, UpdateHPAndMP );

	var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	var heroKV = PlayerTables.GetTableValue("kvs", "heroes")[Entities.GetUnitName( queryUnit )];

	if (!queryUnit || queryUnit == -1 || !heroKV) {
		return;
	}

	var hp 		= 	Entities.GetHealth( queryUnit )
	var maxHP 	= 	Entities.GetMaxHealth( queryUnit ) * 1.0
	var mp 		= 	Entities.GetMana( queryUnit )
	var maxMP 	= 	Entities.GetMaxMana( queryUnit ) * 1.0

	// $("#hp").text = hp + "/" + maxHP;
	// $("#sp").text = mp + "/" + maxMP;

	if (hp != NaN) {
		var hpPercentage = (hp / maxHP) * 100;
		HPOrb.style.height = hpPercentage + "%;";
	}

	if (mp != NaN) {
		var mpPercentage = Math.round((mp / maxMP) * 160);
		SPOrb.style.height = mpPercentage + "px;";
	}
}

function ToggleEquipmentWindow() {
	GameEvents.SendEventClientSide( "ziv_open_equipment", {} );
}

function ToggleFortifyWindow() {
	GameEvents.SendEventClientSide( "ziv_open_fortify", {} );
}

function OpenCraftingWindow() {
	GameEvents.SendEventClientSide( "ziv_open_crafting", {} );
}

function ToggleStatusWindow() {
	GameEvents.SendEventClientSide( "ziv_open_status", {} );
}

function OpenCraftingWindow() {
	GameEvents.SendEventClientSide( "ziv_open_crafting", {} );
}

function ToggleSettingsWindow() {
	GameEvents.SendEventClientSide( "ziv_open_settings", {} );
}

function PregameReady() {
	$("#PregameTimer").AddClass("WindowClosed");
	GameEvents.SendCustomGameEventToServer( "ziv_pregame_ready", {} );
}

function EndPregame() {
	$("#PregameTimer").AddClass("WindowClosed");
	Game.EmitSound("ui.npe_objective_given");
}

function UpdateScenario(table_name, key, data) {
	if (key == "pregame") {
		var time = parseInt(data.time);
		$("#PregameLabel").text = $.Localize("pregame_time") + Util.SecondsToHHMMSS(time);
		if (time == 0) {
			EndPregame();
		} else {
			$("#PregameTimer").RemoveClass("WindowClosed");
		}
	}
}

function UpdateAccount(tableName, changes, deletions) {
	if (changes[Players.GetLocalPlayer()]) {
		var exp 	= 	Account.GetEXP();
		var maxEXP 	= 	Account.GetNeededEXP(exp);

		if (maxEXP != 0) {
			var expPercentage = exp / maxEXP;
			var value = expPercentage * 100;
			if (value != NaN && value != Infinity && XPBar) {
				XPBar.style.width = value + "%;";
			}
		}
	}
}

(function()
{
	GameEvents.Subscribe( "dota_ability_changed", UpdateAbilityList );
	GameEvents.Subscribe("ziv_pregame_done", EndPregame)

	CustomNetTables.SubscribeNetTableListener( "scenario", UpdateScenario );
	PlayerTables.SubscribeNetTableListener( "accounts", UpdateAccount );

	UpdateAbilityList();
	
	UpdateHPAndMP();

	// GameUI.CustomUIConfig().ingame_ui = $.GetContextPanel();

    GameEvents.Subscribe( "ziv_custom_ui_open", (function CustomUIOpen(args) {
        if (!$.GetContextPanel()) {
            $.Schedule(0.1, (function () {
                CustomUIOpen(args);
            }));
            return;
        }
        var map = args["map"];
        var panelName = args["name"];

        var panel = $.CreatePanel( "Panel", $.GetContextPanel(), "" );
        panel.BLoadLayout( "file://{resources}/layout/custom_game/unique/" + panelName  + ".xml", false, false );
        panel.BLoadLayout( "file://{resources}/layout/custom_game/unique/" + map + "/" + panelName  + ".xml", false, false );

        panel.args = args;

        GameUI.CustomUIConfig().customPanels.push( panel );
    }));

	GameUI.CustomUIConfig().ToggleStatusWindow = ToggleStatusWindow;
	GameUI.CustomUIConfig().ToggleEquipmentWindow = ToggleEquipmentWindow;

	$.$('#quickstats').each(function(p) {
		p.visible = false;
	});

	$.Schedule(1, function() {
		$.$('#Hud #DOTADroppedItemTooltip').each(function(p) {
			p.visible = false;
		});
	}); 
})();