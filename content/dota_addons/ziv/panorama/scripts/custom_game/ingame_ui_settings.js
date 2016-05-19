"use strict";

function CloseButton() {
	$.GetContextPanel().RemoveFromPanelsQueue();
	$.GetContextPanel().SetHasClass("Hide", true);
}

function Open() {
	$.GetContextPanel().AddToPanelsQueue();
	$.GetContextPanel().SetHasClass("Hide", false);
}

(function() {
	GameEvents.Subscribe( "ziv_open_settings", Open );

	$("#FortifyTextBlockLabel").html = true;

	$.GetContextPanel().SetDraggable( true );
})();