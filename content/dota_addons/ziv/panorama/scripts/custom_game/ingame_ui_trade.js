var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

function OnDragDrop() {
	var itemID = draggedPanel["contextEntityIndex"];
	var itemName = Abilities.GetAbilityName(itemID);
	draggedPanel.m_DragCompleted = true;
}

function AcceptButton() {

}

function Toggle() {
	$.GetContextPanel().ToggleClass("WindowClosed");
	if ($.GetContextPanel().BHasClass("WindowClosed")) {
		$.GetContextPanel().RemoveFromPanelsQueue();
	} else {
		$.GetContextPanel().AddToPanelsQueue();
	}
}

function CreateItemSlot( parent, num ) {
    var itemPanel = $.CreatePanel( "Panel", parent, "Slot_" + num );
    itemPanel.BLoadLayout( "file://{resources}/layout/custom_game/containers/dota_inventory_item.xml", false, false );
}

function GenerateSlots( parent ) {
	parent.RemoveAndDeleteChildren();

	var rowsCount = 2;
	var itemsInRow = 6;
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

	$.GetContextPanel().SetDraggable( true );

	$.RegisterEventHandler( 'DragDrop', $.GetContextPanel(), OnDragDrop );
})();