"use strict";

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

var ABILITY_COUNT = 5;
var MAXIMUM_ABILITY_ALTERNATIVES = 2;

var heroIcons = [];
var abilities = [];

var characterData = [];

var heroList;
var heroesKVs;

var currentHero = -1;
var lockedIn = false;

var firstLaunch = true;

var selectionIsLocked = false;

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

function CheckForHostPrivileges()
{
	var playerInfo = Game.GetLocalPlayerInfo();
	if ( !playerInfo )
		return;
 
	if (playerInfo.player_has_host_privileges) {
		Game.SetRemainingSetupTime( 3000 ); 
		Game.SetAutoLaunchEnabled( false );
	}
}

function SetStatusIcon(panel, status) {
	panel.SetHasClass("StatusDisconnected", status == "StatusDisconnected");
	panel.SetHasClass("StatusReady", status == "StatusReady");
	panel.SetHasClass("StatusConnected", status == "StatusConnected");
}

function OnGameSetupTableChanged(tableName, changesObject, deletionsObject) {
	if (changesObject["time"]) {
		var time = changesObject["time"]["time"]
		$("#TimeLabel").text = Util.SecondsToHHMMSS(time);
	}
	if (changesObject["status"]) {
		var status = changesObject["status"];

		for (var playerID = 0; playerID < GameUI.CustomUIConfig().mapMaxPlayers; playerID++) {
			var playerInfo = Game.GetPlayerInfo( playerID );

			if (playerInfo != undefined) {
				var playerPanelName = "Player_" + playerID;
				var playerPanel = $("#"+playerPanelName);
				if (playerPanel) {
					playerPanel.FindChildTraverse("Avatar").steamid = playerInfo.player_steamid;
					playerPanel.FindChildTraverse("NameLabel").text = playerInfo.player_name;

					var statusIconPanel = playerPanel.FindChildTraverse("PlayerStatus");
					var statusTextPanel = playerPanel.FindChildTraverse("StatusLabel");
	 
					if (playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED) {
						var playerStatus = status;
						if (playerStatus && playerStatus[playerID]) {
							statusTextPanel.text = $.Localize("gamesetup_" + playerStatus[playerID]);

							if (playerStatus[playerID] == "ready") {
								SetStatusIcon(statusIconPanel, "StatusReady");
							} else { 
								SetStatusIcon(statusIconPanel, "StatusConnected");
							}
						} else {
							statusTextPanel.text = $.Localize("gamesetup_connected");

							SetStatusIcon(statusIconPanel, "StatusConnected");
						}
					} else {
						statusTextPanel.text = $.Localize("gamesetup_disconected");

						SetStatusIcon(statusIconPanel, "StatusDisconnected");
					}
				}
			}
		}
	}
}

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
		$.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', nameLabel, "CharacterCreationError", "file://{resources}/layout/custom_game/ingame_ui_custom_tooltip.xml", "text="+$.Localize("gamesetup_creation_error_length"));
		return;
	}

	for (var key in characterData) {
		if (characterData[key].character_name == name) {
			$.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', nameLabel, "CharacterCreationError", "file://{resources}/layout/custom_game/ingame_ui_custom_tooltip.xml", "text="+$.Localize("gamesetup_creation_error_same"));
			return;
		}
	}

	if (name.match(/^[A-Za-z0-9_-]{6,16}$/gm)) {
		// Gather abilities
		var selectedAbilities = [];
		for (var i = 0; i < abilities.length; i++) {
			selectedAbilities.push(abilities[i].abilityname);
		}

		var characterTable = { "character_name" : name, "hero_name" : heroIcons[currentHero].heroname, "abilities" : selectedAbilities, "preset" : CharacterCreationGetSelectedPreset() };

		GameEvents.SendCustomGameEventToServer( "ziv_gamesetup_create_character", characterTable);

		nameLabel.text = "";

		CharacterCreationCancel();
		CharacterCreationClose();

		CharacterSelectionToggleLoader();
	} else {
		$.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', nameLabel, "CharacterCreationError", "file://{resources}/layout/custom_game/ingame_ui_custom_tooltip.xml", "text="+$.Localize("gamesetup_creation_error_symbols"));
		return;
	}
}

function CharacterCreationClose() {
	$("#CreationRoot").AddClass("WindowClosed")
	UpdateGameSetupPlayerState("connected");
	RemoveBlur();
}

function CharacterCreationCancel() {
	CharacterCreationDeletePreview(); 

	listRoot.visible = true;

	for (var i = 0; i < abilities.length; i++) {
		abilities[i].GetParent().visible = false;
	}
	abilityRoot.ToggleClass("NoLabel");

	currentHero = -1;
	$("#CreateCharacterLabel").text = $.Localize("gamesetup_create_character_headline");

	$("#NameRunesLeague").ToggleClass("OpacityPositionTransitionRight");
	$("#HeroInfo").ToggleClass("OpacityPositionTransitionLeft");

	$("#HighlightEasyCharacters").visible = true;
}

function CharacterCreationBack() {
	if (currentHero == -1) {
		CharacterCreationClose();
	}
	else {
		CharacterCreationCancel()
	}
}

function SetCreationOptions(table) {
	if (table["Playstyle"]) {
		playstyle.text = $.Localize("gamesetup_character_playstyle") + ": <span class=\"" + table["Playstyle"] + "\">" + $.Localize(table["Playstyle"]) + "</span>";
		GameUI.CustomUIConfig().AddTooltip(playstyle, "gamesetup_character_playstyle_" + table["Playstyle"] + "_Tooltip");
	}
	if (table["AttackCapabilities"]) {
		attackType.text = $.Localize("gamesetup_character_attack_type") + ": <span class=\"" + table["AttackCapabilities"] + "\">" + $.Localize(table["AttackCapabilities"]) + "</span>";
	}
	if (table["PrimaryDamageType"]) {
		damageType.text = $.Localize("gamesetup_character_damage_type") + ": <span class=\"" + table["PrimaryDamageType"] + "\">" + $.Localize(table["PrimaryDamageType"]) + "</span>";
	}
	if (table["MovementSpeed"]) {
		movespeed.text = $.Localize("gamesetup_character_movespeed") + ": <span class=\"" + "Movespeed" + "\">" + table["MovementSpeed"] + "</span>";
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

	currentHero = hero.heroID;
}

function CharacterCreationSetup() {
	if (abilities.length == 0) {
		var heroList = PlayerTables.GetTableValue("kvs", "heroes");

		if (!heroList) {
			$.Schedule(0.1, CharacterCreationSetup);
			return;
		}

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
			newHeroIcon.BLoadLayout( "file://{resources}/layout/custom_game/gamesetup_hero_icon.xml", false, false );

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
			selectionRoot.BLoadLayout( "file://{resources}/layout/custom_game/gamesetup_ability_selection.xml", false, false );
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
			newAbility.BLoadLayout( "file://{resources}/layout/custom_game/gamesetup_ability.xml", false, false );

			newAbility.SetCreationOptions = SetCreationOptions;

			newAbility.GetParent().visible = false;

			abilities.push(newAbility);
		}
	}
}

function CharacterCreationOpen() {
	CharacterCreationSetup();
	$("#CreationRoot").RemoveClass("WindowClosed")

	UpdateGameSetupPlayerState("preparing");

	Blur($("#CreationRoot"));
}

function CharacterSelectionToggleLoader() {
	$("#CharacterListLoader").visible = true;
	$("#NoCharactersWarning").style.visibility = "collapse;";
}

function CharacterSelectionSetup() {
	CharacterSelectionToggleLoader()
	GameUI.CustomUIConfig().LoadCharacters((function (obj) {
		var loadedCharacters = JSON.parse(obj);
		var characterData = [];

		$("#CharacterListLoader").visible = false;

        for (var i = 0; i < loadedCharacters.length; i++) {
        	var character = {};
        	character["id"] = loadedCharacters[i]["ID"];
        	character["hero_name"] = loadedCharacters[i]["HeroName"];
        	character["character_name"] = loadedCharacters[i]["CharacterName"];
        	character["abilities"] = JSON.parse(loadedCharacters[i]["Abilities"]);
        	character["equipment"] = JSON.parse(loadedCharacters[i]["Equipment"]);

        	characterData.push(character);
        }

		var characterList = $("#CharacterList");

		$.Each(characterList.Children(), function (panel) {
			panel.DeleteAsync(0.0);
			panel.RemoveAndDeleteChildren();
		});

		if (characterData.length == 0) {
        	if (firstLaunch == true) {
        		CharacterCreationOpen(); 
        		firstLaunch = false;
        	}
        	$("#NoCharactersWarning").style.visibility = "visible;";
        	return
        }

		$.Each(characterData, function (characterTable) {
			(function() {
				var characterPanel = $.CreatePanel( "Panel", characterList, characterTable.id );
				characterPanel.BLoadLayoutSnippet("Character");

				characterPanel.characterTable = characterTable;

				characterPanel.FindChildTraverse("CharacterModel").RemoveAndDeleteChildren();
				characterPanel.FindChildTraverse("CharacterModel").DeleteAsync(0.0);

				characterPanel.FindChildTraverse("CharacterModelSelected").RemoveAndDeleteChildren();
				characterPanel.FindChildTraverse("CharacterModelSelected").DeleteAsync(0.0);
				
				var modelPanelSelected = $.CreatePanel( "RadioButton", characterPanel, "CharacterModelSelected" );
				var previewStyle = "width: 100%; height: 100%; align: center top; overflow: clip clip;";
				modelPanelSelected.LoadLayoutFromStringAsync("<root><Panel><DOTAScenePanel style='" + previewStyle + "' unit='" + characterTable.hero_name + "'/></Panel></root>", false, false);
				modelPanelSelected.AddClass("CharacterModel");
				modelPanelSelected.AddClass("CharacterModelSelected");
				modelPanelSelected.group = "Characters";

				var modelPanel = $.CreatePanel( "Panel", characterPanel, "CharacterModel" );
				previewStyle = "width: 100%; height: 100%; align: center top; overflow: clip clip;";
				modelPanel.LoadLayoutFromStringAsync("<root><Panel hittest='false'><DOTAScenePanel hittest='false' style='" + previewStyle + "' unit='" + characterTable.hero_name + "'/></Panel></root>", false, false);
				modelPanel.AddClass("CharacterModel");

				characterPanel.FindChildTraverse("CharacterNameLabel").text = characterTable.character_name;
			})();
		})
	}));
}

function CharacterSelectionGetSelectedCharacter() {
	var characterList = $("#CharacterList");
	for (var panel of characterList.Children()) { 
		if (panel.FindChildTraverse("CharacterModelSelected") && panel.FindChildTraverse("CharacterModelSelected").IsSelected()) {
			return panel.characterTable;
		}
	}
	return -1
}

function CharacterSelectionDeleteCharacter() {
	var selectedCharacter = CharacterSelectionGetSelectedCharacter();
	if (selectedCharacter != -1) {
		GameUI.CustomUIConfig().DeleteCharacter( selectedCharacter.id, CharacterSelectionSetup )
	}
}

function CharacterSelectionLock() {
	var selectedCharacter = CharacterSelectionGetSelectedCharacter();

	selectionIsLocked = true;
	var characterList = $("#CharacterList");
	var i = 1;
	for (var panel of characterList.Children()) { 
		var characterPanel = panel.FindChildTraverse("CharacterModelSelected");
		if (characterPanel) {
			if (!characterPanel.IsSelected()) {
				panel.AddClass("Hidden");
			} else {
				// Magic as fuck!
				var offset = (255 * (Math.ceil(characterList.Children().length / 2) - i)) + (characterList.Children().length % 2 == 0 ? 127 : 0);
				panel.style.transform = "translate3d(" + offset +  "px, -50px, 0px);";
				
				// $("#PreviewClassLabel").text = panel.FindChildTraverse("CharacterNameLabel").text;
				panel.FindChildTraverse("CharacterNameLabel").text = "";
			}
		}
		i++;
	}
	characterList.AddClass("Expanded");

	var previewAbilities = $("#CharacterPreviewAbilities").Children();
	for (var i = 0; i < previewAbilities.length; i++) {
		(function () {
			var abilityPanel = previewAbilities[i];
			abilityPanel.abilityname = selectedCharacter.abilities[i];
			GameUI.CustomUIConfig().AddAbilityTooltip(abilityPanel, abilityPanel.abilityname);
		})();
	}

	var previewEquipment = $("#CharacterPreviewEquipment").Children();
	var attributesKVs = PlayerTables.GetTableValue("kvs", "attributes");
	var heroKV = PlayerTables.GetTableValue("kvs", "heroes")[selectedCharacter.hero_name];
	var itemKVs = PlayerTables.GetTableValue("kvs", "items");
	var slots = heroKV["EquipmentSlots"].split(';');
	for (var i = 0; i < previewEquipment.length; i++) {
		previewEquipment[i].SetImage("file://{images}/custom_game/ingame_ui/slots/" + slots[i] + ".png");
	}
	for (var x = selectedCharacter.equipment.length - 1; x >= 0; x--) {
		var itemName = selectedCharacter.equipment[x]["item"];
		for (var i = 0; i < previewEquipment.length; i++) {
			if (previewEquipment[i].itemname.match("item") == null && slots[i].match(itemKVs[itemName]["Slot"]) != null) {
				previewEquipment[i].itemname = itemName;
				break;
			}
		}
	}
	
	$("#PreviewClassLabel").text = $.Localize(selectedCharacter.hero_name);

	$("#PreviewHealthPointsLabel").text = $.Localize("gamesetup_character_preview_hp") + (parseInt((heroKV["AttributeBaseStrength"] * attributesKVs["HP_PER_STR"])) + parseInt(heroKV["StatusHealth"]));
	$("#PreviewEnergyPointsLabel").text = $.Localize("gamesetup_character_preview_ep") + (parseInt((heroKV["AttributeBaseIntelligence"] * attributesKVs["MANA_PER_INT"])) + parseInt(heroKV["StatusMana"]));
	$("#PreviewStrengthLabel").text = $.Localize("gamesetup_character_preview_strength") + heroKV["AttributeBaseStrength"];
	$("#PreviewDexterityLabel").text = $.Localize("gamesetup_character_preview_dexterity") + heroKV["AttributeBaseAgility"];
	$("#PreviewIntelligenceLabel").text = $.Localize("gamesetup_character_preview_intelligence") + heroKV["AttributeBaseIntelligence"];

	$("#PreviewPVPKillsLabel").text = $.Localize("gamesetup_character_preview_pvp_kills") + "0";
	$("#PreviewGamesPlayedLabel").text = $.Localize("gamesetup_character_preview_games_played") + "0";

	$("#CharacterListBackground").AddClass("Expanded");

	$("#CharacterPreview").SetHasClass("Hidden", false);

	$("#CharacterButtons").AddClass("Hidden");
}

function CharacterSelectionLockIn() {
	var selectedCharacter = CharacterSelectionGetSelectedCharacter();

	if (lockedIn == false && selectedCharacter != -1) {
		lockedIn = true;

		UpdateGameSetupPlayerState("ready");
	}
}

function UpdateGameSetupPlayerState(status) {
	var selectedCharacter = CharacterSelectionGetSelectedCharacter();
	GameEvents.SendCustomGameEventToServer( "ziv_gamesetup_update_status", { "status" : status, "character" : selectedCharacter });
}

function Blur(target) {
	$.Each($.GetContextPanel().Children(), (function (panel) {
		if (panel.id != target.id) {
			panel.AddClass("Blur");
		}
	}))
}

function RemoveBlur() {
	$.Each($.GetContextPanel().Children(), (function (panel) {
		panel.RemoveClass("Blur");
	}))
}

(function (){
	GameEvents.Subscribe( "ziv_setup_character_selection", CharacterSelectionSetup );
	GameEvents.Subscribe( "ziv_gamesetup_lock", CharacterSelectionLock );

	PlayerTables.SubscribeNetTableListener( 'gamesetup', OnGameSetupTableChanged );

	Game.PlayerJoinTeam(2);

	CheckForHostPrivileges();

	var mapInfo = Game.GetMapInfo();

	// Get max players for a map
	var mapName = CustomNetTables.GetTableValue("scenario", "map").map;
	GameUI.CustomUIConfig().mapMaxPlayers = parseInt(mapName.replace( /^\D+/g, ''));

	$("#StoryLabel").text = $.Localize(mapName + "_story");
	$("#ObjectivesLabel").text = $.Localize(mapName + "_objectives");

	for (var playerID = 0; playerID < GameUI.CustomUIConfig().mapMaxPlayers; playerID++) {
		var playerPanelName = "Player_" + playerID;
		var playerPanel = $.CreatePanel("Panel", playerID < (GameUI.CustomUIConfig().mapMaxPlayers / 2) ? $("#PlayerListLeft") : $("#PlayerListRight"), playerPanelName);
		playerPanel.BLoadLayoutSnippet("Player" + (playerID >= (GameUI.CustomUIConfig().mapMaxPlayers / 2) ? "Right" : "Left"));
		
		playerPanel.SetHasClass("FramePadding", (playerID + 1) % 2 == 0);
	}

	UpdateGameSetupPlayerState("connected");
})();