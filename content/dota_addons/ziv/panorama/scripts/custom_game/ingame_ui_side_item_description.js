function Open( args ) {
	$.GetContextPanel().SetHasClass("Hide", false);
	var entity = args["entity"];

	//$( "#ItemImage" ).itemname
}

function Close() {
	$.GetContextPanel().SetHasClass("Hide", true);
}

(function()
{
	GameEvents.Subscribe( "ziv_open_side_item_desc", Open );
	GameEvents.Subscribe( "ziv_close_side_item_desc", Close );  
})();