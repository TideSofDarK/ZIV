var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

function OnDragDrop(panelId, draggedPanel) {
	var itemIndex = draggedPanel["contextEntityIndex"];
	var itemName = Abilities.GetAbilityName(itemIndex);
	draggedPanel.m_DragCompleted = true;

	var itemKV = PlayerTables.GetTableValue("kvs", "items")[itemName];

	if (itemName.indexOf( "item_gem_" ) === -1 &&
		(itemName.indexOf( "item_rune_" ) === -1 && $("#FortifyItem").currentItem == undefined) ||
		(itemName.indexOf( "item_rune_" ) !== -1 && $("#FortifyItem").currentItem == undefined)) {
		var displayPanel = $.CreatePanel( "DOTAItemImage", $("#FortifyItem"), "FortifyItemImage" );
		displayPanel.itemname = itemKV["AbilityTextureName"];
		displayPanel.contextEntityIndex = itemIndex;

		$("#FortifyItem").currentItem = itemIndex;

		GameEvents.SendCustomGameEventToServer( "ziv_fortify_item_get_modifiers", { "pID" : Players.GetLocalPlayer(), "item" : itemIndex } );

		$("#FortifyItem").style.visibility = "visible;";

		Game.EmitSound( "ui.inv_equip_bone" )
	} else {
		var itemKV = PlayerTables.GetTableValue("kvs", "items")[itemName];
		if (itemKV) {
			var plus = "+" + itemKV["FortifyModifiersCount"] + " " + $.Localize(itemName + "_fortify_string");
			if (itemName.indexOf( "item_rune_" ) !== -1) {
				for (var key in itemKV["FortifyModifiers"]) {
					plus = "+" + itemKV["FortifyModifiers"][key]["min"] + "-" + itemKV["FortifyModifiers"][key]["max"] + " " + $.Localize(key);
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
		displayPanel.contextEntityIndex = itemIndex;

		$("#FortifyTool").currentItem = itemIndex;

		$("#FortifyTool").style.visibility = "visible;";

		Game.EmitSound( "Item.PickUpGemShop" );
	}
	
	CheckOKButton()
}

function FortifyResult(table) {
	var item = table["item"];
	var modifiers = table["modifiers"];

	$("#FortifyTool").style.visibility = "collapse;";

	GameEvents.SendCustomGameEventToServer( "ziv_fortify_item_get_modifiers", { "pID" : Players.GetLocalPlayer(), "item" : item } );
}

function GetModifiers(table) {
	var item = table["item"];
	var modifiers = table["modifiers"];
	
	if ($("#FortifyItem").currentItem == item) {
		$("#FortifyTextBlockLabel").text = $.Localize("dragfortify_gem");

		var newText = "";

		for (var i = 1; i < Object.keys( modifiers ).length + 1; i++) {
			for (var key in modifiers[i.toString()]) {
				var span = "<span class=\"" + modifiers[i.toString()]["gem"] + "\">";
				var endSpan = "</span>";
				if (key != "gem") { 
					newText = newText + span + "+" + modifiers[i.toString()][key] + " " + $.Localize(key) + endSpan +"<br>";
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

function AcceptButton() {
	var item = $("#FortifyItem").currentItem;
	var tool = $("#FortifyTool").currentItem;

	if (item && tool) {
		if (true) { //check available slots for gems
			GameEvents.SendCustomGameEventToServer( "ziv_fortify_item", { "pID" : Players.GetLocalPlayer(), "item" : item, "tool" : tool } );

			$("#FortifyToolImage").DeleteAsync( 0.0 );

			$("#FortifyTool").currentItem = undefined;

			Game.EmitSound( "ui.crafting_gem_applied" );

			$("#FortifyOKButton").enabled = false;
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

function CreateItemSlot( parent, num ) {
    var itemPanel = $.CreatePanel( "Panel", parent, "Slot_" + num );
    itemPanel.BLoadLayout( "file://{resources}/layout/custom_game/containers/dota_inventory_item.xml", false, false );
}

function GenerateSlots( parent ) {
	parent.RemoveAndDeleteChildren();

	var rowsCount = 3;
	var itemsInRow = 7;
	var num = 0;

	for (var i = 0; i < rowsCount; i++) {
		var row = $.CreatePanel( "Panel", parent, "Row_" + i );
		row.AddClass("ItemsRow");

		for (var j = 0; j < itemsInRow; j++)
			CreateItemSlot(row, num++);
	}
}

function CreateOfferSlots() {
	GenerateSlots( $( "#OfferedTradeItems" ) );
}

function CreatePlayerSlots() {
	GenerateSlots( $( "#PlayerTradeItems" ) );
}

(function() {
	CreateOfferSlots();
	CreatePlayerSlots();
	
	//$("#FortifyOKButton").enabled = false;
/*
	GameEvents.Subscribe( "ziv_fortify_item_result", FortifyResult );
	GameEvents.Subscribe( "ziv_fortify_get_modifiers", GetModifiers );
	GameEvents.Subscribe( "ziv_open_fortify", Open );
*/
	//$("#FortifyTextBlockLabel").html = true;

	$.GetContextPanel().SetDraggable( true );
	$.RegisterEventHandler( 'DragDrop', $.GetContextPanel(), OnDragDrop );
})();