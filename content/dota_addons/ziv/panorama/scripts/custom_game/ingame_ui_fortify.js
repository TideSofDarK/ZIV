var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

function OnDragDrop(panelId, draggedPanel) {
	var itemID = draggedPanel["contextEntityIndex"];
	var itemName = Abilities.GetAbilityName(itemID);
	draggedPanel.m_DragCompleted = true;

	if (!itemName) return;

	var itemKV = PlayerTables.GetTableValue("kvs", "items")[itemName];

	if (itemName.indexOf( "item_gem_" ) === -1 && itemName.indexOf( "item_rune_" ) === -1) {
		var displayPanel = $.CreatePanel( "DOTAItemImage", $("#FortifyItem"), "FortifyItemImage" );
		displayPanel.itemname = itemKV["AbilityTextureName"];
		displayPanel.contextEntityIndex = itemID;

		if ($("#FortifyItem").currentItem != itemID) {
			$("#FortifyTextBlockLabel").temp_text = "";
			$("#FortifyTextBlockLabel").temp_gem_text = "";
		}

		$("#FortifyItem").currentItem = itemID;

		GetModifiers({itemID : itemID});

		$("#FortifyItem").style.visibility = "visible;";

		GameUI.CustomUIConfig().AddItemTooltip( displayPanel, itemID );

		Game.EmitSound( "ui.inv_equip_bone" )
	} else {
		var itemKV = PlayerTables.GetTableValue("kvs", "items")[itemName];
		if (itemKV) {
			var plus = "+" + itemKV["FortifyModifiersCount"] + " " + $.Localize(itemName + "_fortify_string");
			if (itemName.indexOf( "item_rune_" ) !== -1) {
				for (var key in itemKV["FortifyModifiers"]) {
					var minValue = itemKV["FortifyModifiers"][key]["min"];
					var maxValue = itemKV["FortifyModifiers"][key]["max"];
					var percent = "";
					if (itemName.indexOf( "item_rune_" ) != -1) {
						var runeKV = PlayerTables.GetTableValue("kvs", "items")[itemName];
						if (!runeKV["Type"]) {
							percent = "%";
						} else if (runeKV["Type"] == "Float") {
							minValue /= 100;
							maxValue /= 100;
						}
					}
					plus = "+ (" + minValue + "-" + maxValue + ") " + percent + $.Localize(key);
					break;
				}
			}
			var newText = plus;
			$("#FortifyTextBlockLabel").text = newText;
			if ($("#FortifyTextBlockLabel").temp_text && $("#FortifyTextBlockLabel").temp_text != "") {
				$("#FortifyTextBlockLabel").text = $("#FortifyTextBlockLabel").text + "<br>" + $("#FortifyTextBlockLabel").temp_text;		
			}
			$("#FortifyTextBlockLabel").temp_gem_text = newText;
		}

		if ($("#FortifyToolImage")) { $("#FortifyToolImage").DeleteAsync( 0.0 ); }

		var displayPanel = $.CreatePanel( "DOTAItemImage", $("#FortifyTool"), "FortifyToolImage" );
		displayPanel.itemname = itemKV["AbilityTextureName"];
		displayPanel.contextEntityIndex = itemID;

		$("#FortifyTool").currentItem = itemID;

		$("#FortifyTool").style.visibility = "visible;";

		GameUI.CustomUIConfig().AddItemTooltip( displayPanel, itemID );

		Game.EmitSound( "Item.PickUpGemShop" );
	}
	
	CheckOKButton()
}

function GetModifiers(table) {
	var itemID = table.itemID;
	
	var modifiers = [];

	if (table["modifiers"]) {
		var modifiers = table["modifiers"];
	} else {
		var itemData = PlayerTables.GetTableValue("items", itemID);
		modifiers = itemData.fortify_modifiers;
	}

	if ($("#FortifyItem").currentItem == itemID) {
		$("#FortifyTextBlockLabel").text = $.Localize("dragfortify_gem");

		var newText = "";

		if (modifiers) {
			for (var gem in modifiers) {
				for (var modifier in modifiers[gem]) {
					var span = "<span class=\"" + modifiers[gem]["gem"] + "\">";
					var endSpan = "</span>";
					if (modifier != "gem") { 
						newText = newText + span + "+ " + Util.ConvertModifierValue(modifier, modifiers[gem][modifier]) + " " + $.Localize(modifier) + endSpan +"<br>";
					}
				}
			}
		}

		if (!$("#FortifyTool").currentItem && newText != "") {
			$("#FortifyTextBlockLabel").text = $("#FortifyTextBlockLabel").temp_text = newText;
		} else if ($("#FortifyTextBlockLabel").temp_gem_text != "" && newText != "") {
			$("#FortifyTextBlockLabel").text = $("#FortifyTextBlockLabel").temp_gem_text + "<br>" + newText;
		}
	}
}

function CheckOKButton() {
	$("#FortifyOKButton").enabled = ($("#FortifyTool").currentItem != undefined && $("#FortifyItem").currentItem != undefined);
}

function OKButton() {
	var item = $("#FortifyItem").currentItem;
	var tool = $("#FortifyTool").currentItem;

	if (item && tool) {
		if (true) { //check available slots for gems
			GameEvents.SendCustomGameEventToServer( "ziv_fortify_item", { "pID" : Players.GetLocalPlayer(), "item" : item, "tool" : tool } );

			$("#FortifyToolImage").DeleteAsync( 0.0 );
			$("#FortifyTool").currentItem = undefined;
			$("#FortifyTool").style.visibility = "collapse;";

			Game.EmitSound( "ui.crafting_gem_applied" );

			$("#FortifyOKButton").enabled = false;

			var characterPanel = $.CreatePanel( "Panel", $.GetContextPanel(), "Explosion" );
			characterPanel.BLoadLayoutSnippet("Sparks");
			characterPanel.DeleteAsync(4.0);
		}
	}
}

function CloseButton() {
	$.GetContextPanel().RemoveFromPanelsQueue();

	$.GetContextPanel().ToggleClass("Hide", true);

	$("#FortifyTool").currentItem = undefined;
	$("#FortifyItem").currentItem = undefined;
	if ($("#FortifyToolImage")) {
		$("#FortifyToolImage").DeleteAsync(0);
	}
	if ($("#FortifyItemImage")) {
		$("#FortifyItemImage").DeleteAsync(0);
	}
}

function Open() {
	$.GetContextPanel().AddToPanelsQueue();

	$.GetContextPanel().SetHasClass("Hide", false);
	if ($("#FortifyToolImage")) {
		$("#FortifyToolImage").DeleteAsync( 0.0 );
		$("#FortifyTool").currentItem = undefined;
	}
	if ($("#FortifyItemImage")) {
		$("#FortifyItemImage").DeleteAsync( 0.0 );
		$("#FortifyItem").currentItem = undefined;
	}
	if ($("#FortifyTextBlockLabel")) {
		$("#FortifyTextBlockLabel").text = $.Localize("dragfortify");
	}
}

(function() {
	GameEvents.Subscribe( "ziv_fortify_item_result", GetModifiers );
	GameEvents.Subscribe( "ziv_open_fortify", Open );

	$.GetContextPanel().SetDraggable( true );

	$.RegisterEventHandler( 'DragDrop', $.GetContextPanel(), OnDragDrop );
})();