"use strict";
var hudRoot = null;

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

function CreateGemsPanel( tooltip, fortify_modifiers )
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
			gem.DeleteAsync(0.0);
		}
		else
		{	
			if (fortify_modifiers[i+1]) 
			{
				var itemname = fortify_modifiers[i+1]["gem"]
				gem.SetImage(itemname) 
				gem.SetText(fortify_modifiers[i+1]) 
			}
			
			gem.Update(0);
		}
	}	
}

function CreateModifiersPanel( tooltip, built_in_modifiers )
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
	$.Msg("s")
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

	var label = tooltip.FindChildTraverse("AbilityName");
	var image = tooltip.FindChildTraverse("ItemImage");

	SetRarity( 0, label, image );
}

function Tooltip( )
{
	if (hudRoot && hudRoot.FindChildTraverse("DOTAAbilityTooltip")) {
		var tooltip = hudRoot.FindChildTraverse("DOTAAbilityTooltip").FindChildTraverse("Contents");
		tooltip.style.visibility = "visible;";

		var gemsPanel = tooltip.FindChildTraverse("GemsPanel");
		var modifiersPanel = tooltip.FindChildTraverse("ModifiersPanel");
		if (gemsPanel) {
			// gemsPanel.RemoveAndDeleteChildren();
		}
		if (modifiersPanel) {
			// modifiersPanel.RemoveAndDeleteChildren();
		}

		if (tooltip.m_Item == -1) {
			$.Schedule(0.03, Tooltip);
			return;
		}

		GameEvents.SendCustomGameEventToServer( "ziv_item_tooltip_get_modifiers", { "pID" : Players.GetLocalPlayer(), "item" : tooltip.m_Item } );
	}
}

function ShowActualTooltip(keys) {
	var tooltip = hudRoot.FindChildTraverse("DOTAAbilityTooltip").FindChildTraverse("Contents");
	tooltip.style.visibility = "visible;";

	// tooltip.FindChildTraverse("GemsPanel").RemoveAndDeleteChildren();
	// tooltip.FindChildTraverse("ModifiersPanel").RemoveAndDeleteChildren();	

	var label = tooltip.FindChildTraverse("AbilityName");
	var image = tooltip.FindChildTraverse("ItemImage");

	SetRarity( keys.rarity, label, image );

	CreateModifiersPanel( tooltip, keys.built_in_modifiers );
	CreateGemsPanel( tooltip, keys.fortify_modifiers );

	$.Msg(keys);
}

(function()
{
	hudRoot = GetHudRoot();
	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltipForEntityIndex", Tooltip);
	$.RegisterForUnhandledEvent( "DOTAHideAbilityTooltip", HideCustomPanels);
	GameEvents.Subscribe( "ziv_item_tooltip_send_modifiers", ShowActualTooltip );
})();

