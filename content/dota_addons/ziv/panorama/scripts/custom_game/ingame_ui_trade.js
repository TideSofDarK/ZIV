var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

function OnDragDrop() {
	var itemID = draggedPanel["contextEntityIndex"];
	var itemName = Abilities.GetAbilityName(itemID);
	draggedPanel.m_DragCompleted = true;
}

function AcceptTrade() {
	$("#TradeAcceptButtonLabel").text = $.Localize("trade_waiting_button");

	GameEvents.SendCustomGameEventToServer( "ziv_accept_trade", { "tradeID" : $("#TradeRoot").tradeID } );
}

function AcceptRequest() {
	var requestPanel = $("#TradeRequest");
	requestPanel.ToggleClass("WindowClosed");

	var initiator = $("#TradeRequest").initiator;

	GameEvents.SendCustomGameEventToServer( "ziv_accept_trade_request", { "initiator" : initiator } );
}

function TradeRequest(args) {
	var requestPanel = $("#TradeRequest");
	requestPanel.ToggleClass("WindowClosed");

	$("#TradeRequest").initiator = args.initiator;

	$("#RequestLabel").text = Game.GetPlayerInfo(args.initiator).player_name + $.Localize("trade_request");
}

function Toggle(args) {
	$("#TradeRoot").ToggleClass("WindowClosed");
	if ($("#TradeRoot").BHasClass("WindowClosed")) {
		// $("#TradeRoot").RemoveFromPanelsQueue();
	} else {
		// $("#TradeRoot").AddToPanelsQueue();
	}

	if (args.tradeID) {
		$("#TradeRoot").tradeID = args.tradeID;

		var itemsContainerID = args.items;
		var offerContainerID = args.offer;

		GameUI.CustomUIConfig().OpenContainer({"id" : itemsContainerID, "panel" : $("#PlayerTradeItems")});
		GameUI.CustomUIConfig().OpenContainer({"id" : offerContainerID, "panel" : $("#OfferedTradeItems")});
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
	GameEvents.Subscribe( "ziv_transmit_trade_request", TradeRequest );
	GameEvents.Subscribe( "ziv_open_trade", Toggle );
	GameEvents.Subscribe( "ziv_close_trade", Toggle );

	// CreateOfferSlots();
	// CreatePlayerSlots();

	// $("#TradeRoot").SetDraggable( true );

	$.RegisterEventHandler( 'DragDrop', $("#TradeRoot"), OnDragDrop );

	$.GetContextPanel().ToggleClass("WindowClosed");
})();