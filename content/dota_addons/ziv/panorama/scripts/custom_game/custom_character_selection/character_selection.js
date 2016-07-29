"use strict";

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

var ABILITY_COUNT = 5;
var MAXIMUM_ABILITY_ALTERNATIVES = 2;

var heroIcons = [];
var abilities = [];

var characterData = [
			{ character_name: "Nagibe322", hero_name: "npc_dota_hero_drow_ranger" },
			{ character_name: "Dauni4", hero_name: "npc_dota_hero_invoker" } ];

var heroList;
var heroesKVs;

var currentCharacter = -1;
var lockedIn = false;

var noCharacters = true;

var heroRoot = $("#HeroRoot");
var abilityRoot = $("#Abilities");

var listRoot = $("#HeroList");

var heroPreview = $("#HeroPreview");

var damageType = $("#CharacterDamageTypeLabel");
var movespeed = $("#CharacterMovespeedLabel");
var attackType = $("#CharacterAttackTypeLabel");
var playstyle = $("#CharacterPlaystyleLabel");

var presets = [
	$("#Preset1"),
	$("#Preset2"),
	$("#Preset3")
]

function CharacterCreationDeletePreview() {
    if (heroPreview) {
        heroPreview.visible = false;
        heroPreview.RemoveAndDeleteChildren();
        heroPreview.DeleteAsync(0.0);

        heroPreview = $.CreatePanel("Panel", heroRoot, "HeroPreview");
        heroPreview.hittest=false;
        heroPreview.hittestchildren=false;
	    heroRoot.MoveChildAfter(heroPreview, $("#NameRunesLeague"));
    }
}

function CharacterCreationGetSelectedPreset() {
	for (var preset in presets) {
		if (presets[preset].IsSelected()) {
			return presets[preset].preset;
		}
	}
}

function CharacterCreationCreate() {
	// Check for name
	var nameLabel = $("#CharacterNameEntry");
	var name = nameLabel.text;
	if (name.length < 6 || name.length > 16) {
		$.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', nameLabel, "CharacterCreationError", "file://{resources}/layout/custom_game/ingame_ui_custom_tooltip.xml", "text="+$.Localize("creation_error_length"));
		return;
	}

	if (name.match(/^[A-Za-z0-9_-]{6,16}$/gm)) {
		// Gather abilities
		var selectedAbilities = [];
		for (var i = 0; i < abilities.length; i++) {
			selectedAbilities.push(abilities[i].abilityname);
		}

		var characterTable = { "character_name" : name, "hero_name" : heroIcons[currentCharacter].heroname, "abilities" : selectedAbilities, "preset" : CharacterCreationGetSelectedPreset() };

		GameEvents.SendCustomGameEventToServer( "ziv_gamesetup_create_character", characterTable);

		CharacterCreationCancel();
		CharacterCreationClose();
	} else {
		$.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', nameLabel, "CharacterCreationError", "file://{resources}/layout/custom_game/ingame_ui_custom_tooltip.xml", "text="+$.Localize("creation_error_symbols"));
		return;
	}
}

function CharacterCreationClose() {
	$("#CreationRoot").AddClass("WindowClosed")
	UpdateGameSetupPlayerState("connected");
	GameEvents.SendEventClientSide( "ziv_remove_ui_blur", { } );
}

function CharacterCreationCancel() {
	CharacterCreationDeletePreview(); 

	listRoot.visible = true;

	for (var i = 0; i < abilities.length; i++) {
		abilities[i].GetParent().visible = false;
	}
	abilityRoot.ToggleClass("NoLabel");

	currentCharacter = -1;
	$("#CreateCharacterLabel").text = $.Localize("create_character_headline");

	$("#NameRunesLeague").ToggleClass("OpacityPositionTransitionRight");
	$("#HeroInfo").ToggleClass("OpacityPositionTransitionLeft");

	$("#HighlightEasyCharacters").visible = true;
}

function CharacterCreationBack() {
	if (currentCharacter == -1) {
		CharacterCreationClose();
	}
	else {
		CharacterCreationCancel()
	}
}

function SetCreationOptions(table) {
	if (table["Playstyle"]) {
		playstyle.text = $.Localize("character_playstyle") + ": <span class=\"" + table["Playstyle"] + "\">" + $.Localize(table["Playstyle"]) + "</span>";
	}
	if (table["AttackCapabilities"]) {
		attackType.text = $.Localize("character_attack_type") + ": <span class=\"" + table["AttackCapabilities"] + "\">" + $.Localize(table["AttackCapabilities"]) + "</span>";
	}
	if (table["PrimaryDamageType"]) {
		damageType.text = $.Localize("character_damage_type") + ": <span class=\"" + table["PrimaryDamageType"] + "\">" + $.Localize(table["PrimaryDamageType"]) + "</span>";
	}
	if (table["MovementSpeed"]) {
		movespeed.text = $.Localize("character_movespeed") + ": <span class=\"" + "Movespeed" + "\">" + table["MovementSpeed"] + "</span>";
	}	
}

function CharacterCreationSelectHero(hero) {
	var abilityLayout = hero.heroKV["AbilityLayout"];
	var chooseLayout = hero.heroKV["ChooseLayout"];

	var spellCount = hero.GetSpellCount();
	var abilityGroups = hero.GetAbilityGroups();

	var heroPresets = PlayerTables.GetTableValue("kvs", "presets")[hero.heroname];

	SetCreationOptions(hero.heroKV);

	var z = 0;
	for (var i = 0; i < abilityLayout; i++) {
		var group = [];
		for (var x = 0; x < abilityGroups[z].length; x++) {
			group.push(hero.heroKV["Ability"+(abilityGroups[z][x]+1)] );
		}

		var abilityname = hero.heroKV["Ability"+(z+1)];

		abilities[i].SetAbility(abilityname, group.length > 1 ? group : []);
		
		if (abilityGroups[z].length > 1) {
			abilities[i].FindChildTraverse("CCSAbilityBorderInner").AddClass("CCSSelectableAbilityBorderInner");
			z += abilityGroups[z].length - 1;
		} else {
			abilities[i].FindChildTraverse("CCSAbilityBorderInner").RemoveClass("CCSSelectableAbilityBorderInner");
		}
		z++;

		abilities[i].GetParent().visible = true;

		abilities[i].GetParent().FindChildTraverse("Hotkey").visible = PlayerTables.GetTableValue("kvs", "abilities")[abilityname]["AbilityBehavior"].indexOf("DOTA_ABILITY_BEHAVIOR_PASSIVE") == -1;
	}
	abilityRoot.visible = true;
	abilityRoot.ToggleClass("NoLabel");

	var previewStyle = "width: 600px; height: 550px; align: center center;";
	heroPreview.LoadLayoutFromStringAsync("<root><Panel><DOTAScenePanel style='" + previewStyle + "' unit='" + hero.heroname + "'/></Panel></root>", false, false);

	listRoot.visible = false;
	heroRoot.visible = true;

	$("#CreateCharacterLabel").text = $.Localize(hero.heroname);

	$("#NameRunesLeague").ToggleClass("OpacityPositionTransitionRight");
	$("#HeroInfo").ToggleClass("OpacityPositionTransitionLeft");
	$("#BioLabel").text = $.Localize(hero.heroname+"_bio");

	// Default checked radio buttons
	$("#HeroOptionTab1").checked = true;
	$("#Preset1").checked = true;
	$("#League2").checked = true;

	for (var preset in presets) {
		presets[preset].visible = false;
	}
	if (heroPresets) {
		var i = 0;
		for (var key in heroPresets) {
			var panel = presets[i];
			for (var c = 0; c < panel.Children().length; c++) {
				if (panel.Children()[c].text) {
					panel.Children()[c].text = $.Localize(key);
					GameUI.CustomUIConfig().AddTooltip(panel.Children()[c], key+"_Tooltip");
				}
			}
			panel.preset = key;
			panel.visible=true;
			i++;
		}
	}

	$("#DOTA_ATTRIBUTE_STRENGTH").RemoveClass("MainAttribute");
	$("#DOTA_ATTRIBUTE_AGILITY").RemoveClass("MainAttribute");
	$("#DOTA_ATTRIBUTE_INTELLECT").RemoveClass("MainAttribute");
	$("#DOTA_ATTRIBUTE_STRENGTH").text = hero.heroKV["AttributeBaseStrength"];
	$("#DOTA_ATTRIBUTE_AGILITY").text = hero.heroKV["AttributeBaseAgility"];
	$("#DOTA_ATTRIBUTE_INTELLECT").text = hero.heroKV["AttributeBaseIntelligence"];
	$("#"+hero.heroKV["AttributePrimary"]).AddClass("MainAttribute");

	$("#HighlightEasyCharacters").visible = false;

	Game.EmitSound( hero.heroKV["CreationSound"]);

	currentCharacter = hero.heroID;
}

function CharacterCreationSetup() {
	if (abilities.length == 0) {
		var heroList = PlayerTables.GetTableValue("kvs", "heroes");

		var count1 = 3;
		var count2 = 2;
		var count3 = 3;

		var i = 1;

		GameUI.CustomUIConfig().ClearPanel($("#HeroList1"));
		GameUI.CustomUIConfig().ClearPanel($("#HeroList2"));
		GameUI.CustomUIConfig().ClearPanel($("#HeroList3"));
		GameUI.CustomUIConfig().ClearPanel(abilityRoot);

		for (var hero in heroList) {
	    	var kv = heroList[hero];

			var heroListPanel;
			if (i < count1) {
				heroListPanel = $("#HeroList1");
			}
			else if (i > count1 && i <= (count1 + count2)) {
				heroListPanel = $("#HeroList2");
			}
			else if (i >= (count2 + count3)) {
				heroListPanel = $("#HeroList3");
			}

			var newHeroIcon = $.CreatePanel( "Panel", heroListPanel, "HeroIcon_" + hero  );
			newHeroIcon.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection/character_creation_icon.xml", false, false );

			newHeroIcon.SetHero(hero, kv, i-1)
			
			heroIcons.push(newHeroIcon);

			newHeroIcon.Select = (function() {
				CharacterCreationSelectHero(this)
			});

			i++;
		}

		var panelCount = ABILITY_COUNT;

		for (var i = 0; i < panelCount; i++) {
			var selectionRoot = $.CreatePanel( "Panel", abilityRoot, "CCSAbilitySelection_" + i  );
			selectionRoot.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection/character_creation_ability_selection.xml", false, false );
			var hotkey = selectionRoot.FindChildTraverse("HotkeyText");
			if (GameUI.CustomUIConfig().KEYBINDS[i].length == 1) {
				hotkey.text = GameUI.CustomUIConfig().KEYBINDS[i];
			}
			else {
				hotkey.text = " ";

				hotkey.AddClass("MouseIcon");
				hotkey.AddClass(GameUI.CustomUIConfig().KEYBINDS[i]);
			}

			var newAbility = $.CreatePanel( "Panel", selectionRoot, "CCSAbility_" + i  );
			newAbility.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection/character_creation_ability.xml", false, false );

			newAbility.SetCreationOptions = SetCreationOptions;

			newAbility.GetParent().visible = false;

			abilities.push(newAbility);
		}
	}
}

function CharacterCreationOpen() {
	CharacterCreationSetup();
	$("#CreationRoot").RemoveClass("WindowClosed")

	UpdateGameSetupPlayerState("choosing_character");

	GameEvents.SendEventClientSide( "ziv_apply_ui_blur", { "ui" : "gamesetup"} );
	GameEvents.SendEventClientSide( "ziv_apply_ui_blur", { "ui" : "loading_screen"} );
}

function CharacterSelectionSetup() {
	var characterList = $("#CharacterList");

	$.Each(characterList.Children(), function (panel) {
		panel.RemoveAndDeleteChildren();
	});

	$.Each(characterData, function (heroTable) {
		var characterPanel = $.CreatePanel( "Panel", characterList, "CreateNewCharater" );
		characterPanel.BLoadLayoutSnippet("Character");
		characterPanel.FindChildTraverse("QuestionMark").visible = false;

		characterPanel.FindChildTraverse("CharacterModel").RemoveAndDeleteChildren();
		characterPanel.FindChildTraverse("CharacterModel").DeleteAsync(0.0);

		characterPanel.FindChildTraverse("CharacterModelSelected").RemoveAndDeleteChildren();
		characterPanel.FindChildTraverse("CharacterModelSelected").DeleteAsync(0.0);
		
		var modelPanelSelected = $.CreatePanel( "Panel", characterPanel, "CharacterModelSelected" );
		var previewStyle = "width: 100%; height: 100%; align: center center;";
		modelPanelSelected.LoadLayoutFromStringAsync("<root><Panel><DOTAScenePanel style='" + previewStyle + "' unit='" + heroTable.hero_name + "'/></Panel></root>", false, false);
		modelPanelSelected.AddClass("CharacterModelSelected");

		var modelPanel = $.CreatePanel( "Panel", characterPanel, "CharacterModel" );
		previewStyle = "width: 575px; height: 555px; align: center center;";
		modelPanel.LoadLayoutFromStringAsync("<root><Panel hittest='false'><DOTAScenePanel hittest='false' style='" + previewStyle + "' unit='" + heroTable.hero_name + "'/></Panel></root>", false, false);

		characterPanel.FindChildTraverse("CharacterNameLabel").text = heroTable.character_name;
	})

	var createNewCharacterPanel = $.CreatePanel( "Panel", characterList, "CreateNewCharater" );
	createNewCharacterPanel.BLoadLayoutSnippet("Character");
	createNewCharacterPanel.FindChildTraverse("CharacterModel").AddClass("SilhouetteModel");
	createNewCharacterPanel.SetPanelEvent("onmouseactivate", function () {
		CharacterCreationOpen();
	});
}

function CharacterSelectionLockIn() {
	if (lockedIn == false) {
		lockedIn = true;
	}
}

function UpdateGameSetupPlayerState(status) {
	var table = CustomNetTables.GetTableValue( "gamesetup", "status" );
	table[Players.GetLocalPlayer()] = status;

	GameEvents.SendCustomGameEventToServer( "ziv_write_to_nettable", { 
		"name" : "gamesetup", 
		"key" : "status",
		"value" : table } );
}

function OnCharactersTableChanged(table, key, data) {
	if (key == Players.GetLocalPlayer()) {
		
	}
}

(function () {
	// GameEvents.Subscribe( "ziv_load_characters_list", LoadCharactersList );

	CustomNetTables.SubscribeNetTableListener( 'characters', OnCharactersTableChanged );

	CharacterSelectionSetup();

	// SetupCreation()
	// CreateCharacterButton()

	// LoadCharactersList( null );
})();