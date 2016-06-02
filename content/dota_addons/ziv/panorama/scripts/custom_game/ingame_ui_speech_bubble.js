"use strict";

function AddText()
{
	GameEvents.SendEventClientSide( "ziv_add_bubble_text", { text: 
		"adfgadfgabhafbaergafdbadfgagabfafadfgadfgabhaf baergafdbadfgagabfafadf gadfgabhafbaergafdbadfgagab" + 
		"fafadfgadfgabhafbaergafdbadfgagab fafadfgadfgabhafbaergafdbadfgagabfafadfgadf gabhafbaergafdbadfgagabfafadfgadfgabhafb aergafdbadfgagabfaf", timer: 5 } );
}

function AddBubbleText( args )
{
	$("#Text").text = args.text;
	$("#Bubble").visible = true;

	if (args.timer)
		$.Schedule(args.timer, function(){
			$("#Bubble").visible = false;
		});
}

(function()
{
	GameEvents.Subscribe( "ziv_add_bubble_text", AddBubbleText );
})();