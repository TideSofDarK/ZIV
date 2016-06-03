"use strict";

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

var ABILITY_COUNT = 5;
var MAXIMUM_ABILITY_ALTERNATIVES = 2;

var heroIcons = [];
var abilities = [];

var heroList;
var heroesKVs;

var currentCharacter = -1;
var lockedIn = false;

var heroRoot = $("#HeroRoot");
var abilityRoot = $("#Abilities");

var listRoot = $("#HeroList");

var heroPreview = $("#HeroPreview");

var damageType = $("#CharacterDamageTypeLabel");
var movespeed = $("#CharacterMovespeedLabel");
var attackType = $("#CharacterAttackTypeLabel");
var playstyle = $("#CharacterPlaystyleLabel");

function SimpleLerp(a, b, t) {
	return a + (b - a) * t;
}

function LockIn() {
	if (lockedIn == false) {
		lockedIn = true;
	}
}

function DeleteHeroPreview() {
    if (heroPreview) {
        heroPreview.visible = false;
        heroPreview.RemoveAndDeleteChildren();

        heroPreview = $.CreatePanel("Panel", heroRoot, "HeroPreview");
	    heroRoot.MoveChildAfter(heroPreview, $("#NameRunesLeague"));
    }
}

function CreateHeroButton() {
	var selected_abilities = [];
	for (var i = 0; i < abilities.length; i++) {
		selected_abilities.push(abilities[i].abilityname);
	}
	GameEvents.SendCustomGameEventToServer( "ziv_choose_hero", { "pID" : Players.GetLocalPlayer(), "hero_name" : heroIcons[currentCharacter].heroname, "abilities" : selected_abilities } );
}

function BackButton() {
	if (currentCharacter == -1) {
		$("#Menu").visible = true;
		$("#CreationRoot").visible = false;
	}
	else {
		DeleteHeroPreview(); 

		listRoot.visible = true;

		for (var i = 0; i < abilities.length; i++) {
			abilities[i].visible = false;
		}
		abilityRoot.ToggleClass("NoLabel");

		currentCharacter = -1;
		$("#CreateCharacterLabel").text = $.Localize("create_character");

		$("#NameRunesLeague").ToggleClass("OpacityPositionTransitionRight");
		$("#HeroInfo").ToggleClass("OpacityPositionTransitionLeft");

		$("#HighlightEasyCharacters").visible = true;
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

function SelectHero(hero) {
	var abilityLayout = hero.heroKV["AbilityLayout"];
	var chooseLayout = hero.heroKV["ChooseLayout"];

	var spellCount = hero.GetSpellCount();
	var abilityGroups = hero.GetAbilityGroups();

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
			z += abilityGroups[z].length - 1;
		}
		z++;

		abilities[i].visible = true;

		abilities[i].FindChildTraverse("Hotkey").visible = PlayerTables.GetTableValue("kvs", "abilities")[abilityname]["AbilityBehavior"].indexOf("DOTA_ABILITY_BEHAVIOR_PASSIVE") == -1;
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
	$("#RuneSet1").checked = true;
	$("#League2").checked = true;

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

function SetupCreation() {
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

			newHeroIcon.SelectHero = (function() {
				SelectHero(this)
			});

			i++;
		}

		var panelCount = ABILITY_COUNT;

		for (var i = 0; i < panelCount; i++) {
			var newAbility = $.CreatePanel( "Panel", abilityRoot, "CCSAbility_" + i  );
			newAbility.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection/character_creation_ability.xml", false, false );
			var hotkey = newAbility.FindChildTraverse("HotkeyText");
			if (GameUI.CustomUIConfig().KEYBINDS[i].length == 1) {
				hotkey.text = GameUI.CustomUIConfig().KEYBINDS[i];
			}
			else {
				hotkey.text = " ";

				hotkey.AddClass("MouseIcon");
				hotkey.AddClass(GameUI.CustomUIConfig().KEYBINDS[i]);
			}

			newAbility.SetCreationOptions = SetCreationOptions;

			newAbility.visible = false;

			abilities.push(newAbility);
		}
	}
}

function CreateCharacterButton() {
	$("#Menu").style.visibility = "collapse;";
	$("#CreationRoot").style.visibility = "visible;";

	SetupCreation();
}

function LoadCharacterButton() {
	$("#Menu").AddClass("FlippedB");
	$.Schedule(0.4, RemoveFlipClass);
}

function RemoveFlipClass() {
	$("#CharacterList").RemoveClass("FlippedA");
	$("#CharacterList").style.visibility = "visible;";
}

function LoadCharactersList( args )
{
	args = {
		minCount: 4,
		heroList: [
			// { name: "npc_dota_hero_drow_ranger", level: 5 },
			// { name: "npc_dota_hero_windrunner", level: 8 },
			// { name: "npc_dota_hero_invoker", level: 1 }
		]
	};

	for(var hero of args.heroList)
	{
		var panel = $.CreatePanel( "Panel", $( "#LoadCharacterList" ), "Card_" + hero.name );
		panel.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection/character_selection_card.xml", false, false );
		panel.UpdateCard(hero);
	}

	if (args.heroList.length < args.minCount)
	{
		for (var i = 0; i < args.minCount - args.heroList.length; i++) {
			var panel = $.CreatePanel( "Panel", $( "#LoadCharacterList" ), "Card_default" );
			panel.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection/character_selection_card.xml", false, false );
			panel.UpdateCard(null, true);

			panel.SetPanelEvent("onmouseactivate", CreateCharacterButton);
		}
	}
}

(function () {
	GameEvents.Subscribe( "ziv_load_characters_list", LoadCharactersList );

	damageType.html = true;
	movespeed.html = true;
	attackType.html = true;
	playstyle.html = true;

	LoadCharactersList( null );
})();