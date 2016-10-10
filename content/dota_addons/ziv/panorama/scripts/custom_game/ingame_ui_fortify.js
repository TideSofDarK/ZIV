var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

const MAXIMUM_SOCKETS = 3;

function OnDragDrop(panelId, draggedPanel) {
	var itemID = draggedPanel["contextEntityIndex"];
	var itemName = Abilities.GetAbilityName(itemID);
	draggedPanel.m_DragCompleted = true;

	if (!itemName) return;

	var itemKV = PlayerTables.GetTableValue("kvs", "items")[itemName];

	if (itemName.indexOf( "item_gem_" ) === -1 && 
		itemName.indexOf( "item_rune_" ) === -1 && 
		itemName.indexOf( "item_forging_" ) === -1) {
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

		Game.EmitSound( "ui.inv_equip_bone" )
	} else {
		var itemKV = PlayerTables.GetTableValue("kvs", "items")[itemName];
		if (itemKV) {
			var plus;
			if (itemName.indexOf("item_forging_") != -1) {
				plus = $.Localize(itemName + "_Fortify");
			} else {
				plus = "+ " + itemKV["FortifyModifiersCount"] + " " + $.Localize(itemName + "_Fortify");
				if (itemName.indexOf( "item_rune_" ) !== -1) {
					for (var key in itemKV["FortifyModifiers"]) {
						var minValue = itemKV["FortifyModifiers"][key]["min"];
						var maxValue = itemKV["FortifyModifiers"][key]["max"];
						if (itemName.indexOf( "item_rune_" ) != -1) {
							var runeKV = PlayerTables.GetTableValue("kvs", "items")[itemName];
							if (runeKV["Type"] == "Float") {
								minValue /= 100;
								maxValue /= 100;
							}
						}
						plus = "+ (" + minValue + "-" + maxValue + ")" + " " + $.Localize(key);
						break;
					}
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

		Game.EmitSound( "Item.PickUpGemShop" );
	}

	GameUI.CustomUIConfig().AddItemTooltip( displayPanel, itemID );
	
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
					var span = ""; //"<span class=\"" + modifiers[gem]["gem"] + "\">";
					var endSpan = "";//"</span>";
					if (modifier != "gem") { 
						newText = newText + span + "+ " + Math.abs(Util.ConvertValue(modifier, 0, modifiers[gem][modifier], true)) + " " + $.Localize(modifier) + endSpan +"<br>";
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

function Toggle() {
	$.GetContextPanel().ToggleClass("WindowClosed");
	if ($.GetContextPanel().BHasClass("WindowClosed")) {
		$.GetContextPanel().RemoveFromPanelsQueue();
	} else {
		$.GetContextPanel().AddToPanelsQueue();
	}

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
		$("#FortifyTextBlockLabel").temp_text = "";
		$("#FortifyTextBlockLabel").temp_gem_text = "";
	}
}

(function() {
	GameEvents.Subscribe( "ziv_fortify_item_result", GetModifiers );
	GameEvents.Subscribe( "ziv_open_fortify", Toggle );

	$.GetContextPanel().SetDraggable( true );

	$.RegisterEventHandler( 'DragDrop', $.GetContextPanel(), OnDragDrop );
})();