"use strict";

var heroIcons = [];

var heroList;
var heroesKVs;

var currentCharacter = 2;
var lockedIn = false;

var marginX = 0;
var marginY = -145;

function GetVectorFromStylePosition(posString) {
	var splitted = posString.split(" ");
	var vector = []
	for (var i = 0; i < splitted.length; i++) {
		vector[i] = parseInt(splitted[i]);
	}
	return vector
}

function SimpleLerp(a, b, t) {
	return a + (b - a) * t;
}

function LockIn() {
	if (lockedIn == false) {
		lockedIn = true;

		heroIcons[currentCharacter].AddClass( "selected" );

		$("#ChooseButton").SetHasClass( "selected", true );
		$("#LockInLabel").text = $.Localize("lockedin");
		$("#DirButtonLeft").AddClass( "disabled" );
		$("#DirButtonRight").AddClass( "disabled" );
		$.Schedule(2.0, CreateHero);
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

function SetupCreation() {
	if (heroList == undefined || heroesKVs == undefined) {
		
		$.Schedule(0.1, SetupCreation);
	}
	else {
		var count1 = 3;
		var count2 = 2;
		var count3 = 3;

		var i = 1;

		for (var hero in heroList) {
	    	var value = heroList[hero];

	    	if (value == "1") {
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

				newHeroIcon.heroName = hero;
				newHeroIcon.heroKV = value;

				newHeroIcon.SetHero(hero)
				
				heroIcons.push(newHeroIcon);

				i++;
	    	}
		}
	}
}

function CreateCharacterButton() {
	$("#Menu").style.visibility = "collapse;";
	$("#CreationRoot").style.visibility = "visible;";
}

function LoadCharacterButton() {
	$("#Menu").AddClass("FlippedB");
	$.Schedule(0.4, RemoveFlipClass);
}

function RemoveFlipClass() {
	$("#CharacterList").RemoveClass("FlippedA");
	$("#CharacterList").style.visibility = "visible;";
}

function SetHeroList(eventArgs) {
	heroList = eventArgs;
}

function SetHeroesKVs(eventArgs) {
	heroesKVs = eventArgs;
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
	GameEvents.Subscribe( "ziv_set_herolist", SetHeroList );
	GameEvents.Subscribe( "ziv_set_heroes_kvs", SetHeroesKVs );

	GameEvents.Subscribe( "ziv_load_characters_list", LoadCharactersList );

	LoadCharactersList( null );

	SetupCreation();

	GameUI.SetMouseCallback( function( eventName, arg ) {
		var CONSUME_EVENT = true;
		var CONTINUE_PROCESSING_EVENT = false;

		if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
			return CONTINUE_PROCESSING_EVENT;

		if ( eventName == "pressed" )
		{
		}
		else if ( eventName === "wheeled" )
		{
			if ( arg > 0 && currentCharacter > 0 )
			{
				currentCharacter--;
			}
			else if ( arg < 0 && currentCharacter < heroIcons.length-1 )
			{
				currentCharacter++;
			}
		}
		return CONTINUE_PROCESSING_EVENT;
	} );
})();