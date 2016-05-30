"use strict";

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

var KEYBINDS = {
	0: "q",
	1: "w",
	2: "e",
	3: "LMB",
	4: "RMB"
};

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
	    heroRoot.MoveChildAfter(heroPreview, $("#NameColorLeague"));
    }
}

function CreateHero() {
	var abilities = heroIcons[currentCharacter].FindChildTraverse("AbilitiesPanel");
	var selected_abilities = [];
	if (abilities) {
		for (var i = 0; i < abilities.GetChildCount(); i++) {
			var ability = abilities.GetChild( i );
			if (ability) {
				if (ability.BHasClass("selected")) {
					selected_abilities.push(ability.id);
				}
			}
		}
	}
	GameEvents.SendCustomGameEventToServer( "ziv_choose_hero", { "pID" : Players.GetLocalPlayer(), "hero_name" : heroIcons[currentCharacter].heroName, "abilities" : selected_abilities } );
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

		$("#NameColorLeague").ToggleClass("OpacityPositionTransitionRight");
		$("#Bio").ToggleClass("OpacityPositionTransitionLeft");

		$("#HighlightEasyCharacters").visible = true;
	}
}

function SelectHero(hero) {
	var abilityLayout = hero.heroKV["AbilityLayout"];
	var chooseLayout = hero.heroKV["ChooseLayout"];

	var spellCount = hero.GetSpellCount();
	var abilityGroups = hero.GetAbilityGroups();

	var z = 0;
	for (var i = 0; i < abilityLayout; i++) {
		abilities[i].SetAbility(hero.heroKV["Ability"+(z+1)]);
		
		if (abilityGroups[z].length > 1) {
			z += abilityGroups[z].length - 1;
		}
		z++;

		abilities[i].visible = true;
	}
	abilityRoot.visible = true;
	abilityRoot.ToggleClass("NoLabel");

	var previewStyle = "width: 600px; height: 550px; align: center center;";
	heroPreview.LoadLayoutFromStringAsync("<root><Panel><DOTAScenePanel style='" + previewStyle + "' unit='" + hero.heroname + "'/></Panel></root>", false, false);

	listRoot.visible = false;
	heroRoot.visible = true;

	$("#CreateCharacterLabel").text = $.Localize(hero.heroname);

	$("#NameColorLeague").ToggleClass("OpacityPositionTransitionRight");
	$("#Bio").ToggleClass("OpacityPositionTransitionLeft");
	$("#BioLabel").text = $.Localize(hero.heroname+"_bio");

	$("#HighlightEasyCharacters").visible = false;

	Game.EmitSound( hero.heroKV["CreationSound"]);

	currentCharacter = hero.unitID;
}

function SetupCreation() {
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

		newHeroIcon.abilityPanels = [];

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
		newAbility.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection/custom_character_selection_ability.xml", false, false );
		var hotkey = newAbility.FindChildTraverse("HotkeyText");
		if (KEYBINDS[i].length == 1) {
			hotkey.text = KEYBINDS[i];
		}
		else {
			hotkey.text = " ";

			hotkey.AddClass("MouseIcon");
			hotkey.AddClass(KEYBINDS[i]);
		}

		newAbility.visible = false;

		abilities.push(newAbility);
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
		panel.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection/custom_character_selection_card.xml", false, false );
		panel.UpdateCard(hero);
	}

	if (args.heroList.length < args.minCount)
	{
		for (var i = 0; i < args.minCount - args.heroList.length; i++) {
			var panel = $.CreatePanel( "Panel", $( "#LoadCharacterList" ), "Card_default" );
			panel.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection/custom_character_selection_card.xml", false, false );
			panel.UpdateCard(null, true);

			panel.SetPanelEvent("onmouseactivate", CreateCharacterButton);
		}
	}
}

(function () {
	GameEvents.Subscribe( "ziv_load_characters_list", LoadCharactersList );

	LoadCharactersList( null );
})();