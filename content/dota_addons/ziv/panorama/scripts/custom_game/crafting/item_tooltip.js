"use strict";
var hudRoot = null;

function GetHudRoot()
{
	var parent = $.GetContextPanel().GetParent();
	while(parent.id != "Hud")
		parent = parent.GetParent();

	return parent;
}

function SetRarity( rarity, label, image )
{
	var color = "#ffffff";

	switch( rarity )
	{
		case 1:
			color = "#00ff00";
			break;
		case 2:
			color = "#0000ff";
			break;
		case 3:
			color = "#ff00ff";
			break;
		case 4:
			color = "#ffb400";
			break;
		case 5:
			color = "#ff0000";
			break;
	}

	label.style.washColor = color + ";";
	image.style.boxShadow = "inset " + color + " 1px 1px 6px 2px;";
}

function CreateGemsPanel( tooltip )
{
	var gems = tooltip.FindChildTraverse("GemsPanel");
	if (!gems)
	{
		gems = $.CreatePanel( "Panel", tooltip, "GemsPanel" );
		gems.style.width = "100%;";
		gems.style.flowChildren = "down";
	}

	gems.RemoveAndDeleteChildren();

	var gemsCount = 3;
	for (var i = 0; i < gemsCount; i++) {
		var gem = $.CreatePanel( "Panel", gems, "GemSlot_" + i );
		gem.BLoadLayout( "file://{resources}/layout/custom_game/crafting/gem_slot.xml", false, false );

		gem.Update(0);
	}	
}

function Tooltip( panelName )
{
	var tooltip = hudRoot.FindChildTraverse("DOTAAbilityTooltip").FindChildTraverse("Contents");
	CreateGemsPanel( tooltip );

	var rarity = 4;

	var label = tooltip.FindChildTraverse("AbilityName");
	var image = tooltip.FindChildTraverse("ItemImage");

	SetRarity( rarity, label, image );
}

(function()
{
	hudRoot = GetHudRoot();
	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltipForEntityIndex", Tooltip);	
})();

