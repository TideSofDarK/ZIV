"use strict";

function AddTooltip( panel, text )
{
	panel.SetPanelEvent("onmouseover", function(){
		$.DispatchEvent("DOTAShowTextTooltip", panel, $.Localize( text ) );
	});

	panel.SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("DOTAHideTextTooltip"); 
	});
}

function InitTooltip( panel )
{
	var text = panel.GetAttributeString("tooltip", "")
	if (text != "")
		AddTooltip( panel, text );

	var childCount = panel.GetChildCount();
	if (childCount == 0)
		return;

	for(var i = 0; i < childCount; i++)
		InitTooltip( panel.GetChild(i) );
}

(function () {
	InitTooltip( $.GetContextPanel() );
	GameUI.CustomUIConfig().AddTooltip = AddTooltip;
})();