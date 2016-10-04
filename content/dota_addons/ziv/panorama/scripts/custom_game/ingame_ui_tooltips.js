"use strict";

function ShowItemTooltip(panel, itemID) {
	$.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', panel, panel.id, "file://{resources}/layout/custom_game/ingame_ui_custom_tooltip.xml", "itemID="+itemID);
}

function HideItemTooltip(panel) {
	$.DispatchEvent("UIHideCustomLayoutTooltip", panel, panel.id); 
}

function AddTooltip( panel, text, ability )
{
	panel.SetPanelEvent("onmouseover", function(){
		$.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', panel, panel.id, "file://{resources}/layout/custom_game/ingame_ui_custom_tooltip.xml", "text="+$.Localize( text )+"&ability="+ability);
	});

	panel.SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("UIHideCustomLayoutTooltip", panel, panel.id); 
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
	GameUI.CustomUIConfig().ShowItemTooltip = ShowItemTooltip;
	GameUI.CustomUIConfig().HideItemTooltip = HideItemTooltip;
})();