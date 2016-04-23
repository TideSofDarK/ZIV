"use strict";
var hudRoot = null;
var tooltip = null;

var MAX_GEMS = 4;

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
			color = "#3d50c5";
			break;
		case 2:
			color = "#ffea00";
			break;
		case 3:
			color = "#FFA500";
			break;
		case 4:
			color = "#FF00FF";
			break;
	}

	label.style.washColor = color + ";";
	image.style.boxShadow = "inset " + color + " 1px 1px 6px 2px;";
}

function CreateGemsPanel( fortify_modifiers )
{
	var gems = tooltip.FindChildTraverse("GemsPanel");
	if (!gems)
	{
		gems = $.CreatePanel( "Panel", tooltip, "GemsPanel" );
		gems.style.width = "100%;";
		gems.style.flowChildren = "down";
	}

	var gemsCount = Object.keys( fortify_modifiers ).length;

	for (var i = 0; i < MAX_GEMS; i++) {
		var gem = gems.FindChildTraverse("GemSlot_" + i);
		if (gem)
		{

		}
		else
		{
			gem = $.CreatePanel( "Panel", gems, "GemSlot_" + i );
			gem.BLoadLayout( "file://{resources}/layout/custom_game/crafting/gem_slot.xml", false, false );
		}

		if (i >= gemsCount) 
		{
			// gems.style.visibility = "collapse;";
		}
		else
		{	
			if (fortify_modifiers[i+1]) 
			{
				var itemname = fortify_modifiers[i+1]["gem"]
				gem.SetImage(itemname) 
				gem.SetText(fortify_modifiers[i+1]) 
			}
			$.Msg("dick");
			gems.style.visibility = "visible;";

			gem.Update(0);
		}
	}	
}

function CreateModifiersPanel( built_in_modifiers )
{
	var modifiers = tooltip.FindChildTraverse("AbilityAttributes").GetParent();

	var new_modifiers = modifiers.FindChildTraverse("AdditionalModifiers");
	if (!new_modifiers) {
		new_modifiers = $.CreatePanel( "Label", modifiers, "AdditionalModifiers" );
		new_modifiers.html = true;
	}
	new_modifiers.text = "";

	tooltip.FindChildTraverse("ItemCost").style.visibility = tooltip.FindChildTraverse("BuyCostLabel").text == "0" ? "collapse;" : "visible;";

	if (Object.keys( built_in_modifiers ).length >= 1)
	{
		new_modifiers.style.visibility = "visible;";

		var newText = "";
		var i = 0;
		for (var key in built_in_modifiers)
		{
			var value = built_in_modifiers[key];

			newText = newText + "+ " + value + " " + $.Localize(key);

			if (i+1 < Object.keys( built_in_modifiers ).length) {
				newText = newText + "<br>";
			}

			i = i + 1;
		}

		new_modifiers.text = "<br>"+newText;

		modifiers.MoveChildAfter(new_modifiers, tooltip.FindChildTraverse("AbilityAttributes"));
	}
	else
	{
		new_modifiers.style.visibility = "collapse;";
	}
}

function HideCustomPanels() 
{
	var tooltip = hudRoot.FindChildTraverse("DOTAAbilityTooltip").FindChildTraverse("Contents");
	var modifiers = tooltip.FindChildTraverse("AbilityAttributes").GetParent();

	var new_modifiers = modifiers.FindChildTraverse("AdditionalModifiers");
	var gems = tooltip.FindChildTraverse("GemsPanel");

	if (new_modifiers) {
		new_modifiers.style.visibility = "collapse;";
	}
	if (gems) {
		gems.style.visibility = "collapse;";
	}
}

function Tooltip( )
{
	if (hudRoot && hudRoot.FindChildTraverse("DOTAAbilityTooltip")) {
		
		var label = tooltip.FindChildTraverse("AbilityName");
		var image = tooltip.FindChildTraverse("ItemImage");

		if (tooltip.m_Item == -1) {
			tooltip.style.visibility = "visible;";
			SetRarity( 0, label, image );

			$.Schedule(0.03, Tooltip);
			return;
		}

		GameEvents.SendCustomGameEventToServer( "ziv_item_tooltip_get_modifiers", { "pID" : Players.GetLocalPlayer(), "item" : tooltip.m_Item } );
	}
}

function ShowActualTooltip(keys) {
	tooltip.style.visibility = "visible;";

	var label = tooltip.FindChildTraverse("AbilityName");
	var image = tooltip.FindChildTraverse("ItemImage");

	SetRarity( keys.rarity, label, image );

	CreateModifiersPanel( keys.built_in_modifiers );
	CreateGemsPanel( keys.fortify_modifiers );

	$.Msg(keys);
}

function SetTooltipNode() {
	if (tooltip) return;
	else {
		$.Schedule(0.03, SetTooltipNode);
		tooltip = hudRoot.FindChildTraverse("DOTAAbilityTooltip").FindChildTraverse("Contents");
	}
}

(function()
{
	hudRoot = GetHudRoot();

	SetTooltipNode();

	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltipForEntityIndex", Tooltip);
	$.RegisterForUnhandledEvent( "DOTAHideAbilityTooltip", HideCustomPanels);
	GameEvents.Subscribe( "ziv_item_tooltip_send_modifiers", ShowActualTooltip );
})();

