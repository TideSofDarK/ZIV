function OnDragDrop(panelId, draggedPanel) {
	var itemName = draggedPanel["itemname"];
	var itemIndex = draggedPanel["contextEntityIndex"];

	draggedPanel.m_DragCompleted = true;

	if (itemName.indexOf( "item_gem_" ) === -1) {
		var displayPanel = $.CreatePanel( "DOTAItemImage", $("#FortifyItem"), "FortifyItemImage" );
		displayPanel.itemname = itemName;

		$("#FortifyItem").currentItem = itemIndex;

		Game.EmitSound( "ui.inv_equip_bone" )
	} else {
		var itemKV = CustomNetTables.GetTableValue( "item_kvs", itemName );
		if (itemKV) {
			$("#FortifyTextBlockLabel").text = "+" + itemKV["FortifyModifiersCount"] + " " + $.Localize(itemName + "_fortify_string");
		}

		var displayPanel = $.CreatePanel( "DOTAItemImage", $("#FortifyTool"), "FortifyToolImage" );
		displayPanel.itemname = itemName;

		$("#FortifyTool").currentItem = itemIndex;

		Game.EmitSound( "Item.PickUpGemShop" )
	}
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
		}
	}
}

function CloseButton() {
	$.GetContextPanel().RemoveAndDeleteChildren();
	$.GetContextPanel().DeleteAsync( 0.0 );
}

(function() {
	$.GetContextPanel().SetDraggable( true );
	// $.RegisterEventHandler( 'DragEnter', $.GetContextPanel(), OnDragEnter );
	$.RegisterEventHandler( 'DragDrop', $.GetContextPanel(), OnDragDrop );
})();