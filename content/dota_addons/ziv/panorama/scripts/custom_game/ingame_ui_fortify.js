function OnDragDrop(panelId, draggedPanel) {
	var itemName = draggedPanel["itemname"];
	var itemIndex = draggedPanel["contextEntityIndex"];

	draggedPanel.m_DragCompleted = true;

	if (itemName.indexOf( "item_gem_" ) === -1) {
		var displayPanel = $.CreatePanel( "DOTAItemImage", $("#FortifyItem"), "FortifyItemImage" );
		displayPanel.itemname = itemName;

		$("#FortifyItem").currentItem = itemIndex;

		GameEvents.SendCustomGameEventToServer( "ziv_fortify_item_get_modifiers", { "pID" : Players.GetLocalPlayer(), "item" : itemIndex } );

		Game.EmitSound( "ui.inv_equip_bone" )
	} else {
		var itemKV = CustomNetTables.GetTableValue( "item_kvs", itemName );
		if (itemKV) {
			var newText = "+" + itemKV["FortifyModifiersCount"] + " " + $.Localize(itemName + "_fortify_string")
			$("#FortifyTextBlockLabel").text = newText;
			if ($("#FortifyTextBlockLabel").temp_text && $("#FortifyTextBlockLabel").temp_text != "") {
				$("#FortifyTextBlockLabel").text = $("#FortifyTextBlockLabel").text + "<br>" + $("#FortifyTextBlockLabel").temp_text;		
			}
			$("#FortifyTextBlockLabel").temp_gem_text = newText;
		}

		if ($("#FortifyToolImage")) { $("#FortifyToolImage").DeleteAsync( 0.0 ); }

		var displayPanel = $.CreatePanel( "DOTAItemImage", $("#FortifyTool"), "FortifyToolImage" );
		displayPanel.itemname = itemName;

		$("#FortifyTool").currentItem = itemIndex;

		Game.EmitSound( "Item.PickUpGemShop" )
	}

	CheckOKButton()
}

function FortifyResult(table) {
	var item = table["item"];
	var modifiers = table["modifiers"];
	GameEvents.SendCustomGameEventToServer( "ziv_fortify_item_get_modifiers", { "pID" : Players.GetLocalPlayer(), "item" : item } );
}

function GetModifiers(table) {
	var item = table["item"];
	var modifiers = table["modifiers"];
	
	if ($("#FortifyItem").currentItem == item) {
		$("#FortifyTextBlockLabel").text = $.Localize("dragfortify_gem");

		var newText = "";

		for (var i = 1; i < Object.keys( modifiers ).length + 1; i++) {
			$.Msg(modifiers[i.toString()]["gem"]+"asd");
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

function OKButton() {
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
	$.GetContextPanel().RemoveAndDeleteChildren();
	$.GetContextPanel().DeleteAsync( 0.0 );
}

(function() {
	$("#FortifyOKButton").enabled = false;

	GameEvents.Subscribe( "ziv_fortify_item_result", FortifyResult );
	GameEvents.Subscribe( "ziv_fortify_get_modifiers", GetModifiers );

	$("#FortifyTextBlockLabel").html = true;

	$.GetContextPanel().SetDraggable( true );
	$.RegisterEventHandler( 'DragDrop', $.GetContextPanel(), OnDragDrop );
})();