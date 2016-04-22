function ItemShowTooltip(panel, item, queryUnit)
{
	if ( item == -1 )
		return;

	var itemName = Abilities.GetAbilityName( item );
	$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", panel, itemName, queryUnit );

	SetTooltipData(panel, item);
}

function ItemHideTooltip(panel, item)
{
	$.DispatchEvent( "DOTAHideAbilityTooltip", panel );

	DestroyTooltipData(panel, item);
}

function SetTooltipData(panel, item)
{
	var parent = panel;
	while(parent.id != "Hud")
		parent = parent.GetParent();

	if (item && item != -1) {
		var tooltip = parent.FindChildTraverse("DOTAAbilityTooltip").FindChildTraverse("Contents");
		// if (tooltip.FindChildTraverse("GemsPanel")) {
		// 	tooltip.FindChildTraverse("GemsPanel").RemoveAndDeleteChildren();
		// }
		tooltip.m_Item = item;

		tooltip.style.visibility = "collapse;";
	}
}

function DestroyTooltipData(panel, item)
{
	var parent = panel;
	while(parent.id != "Hud")
		parent = parent.GetParent();

	if (item && item != -1) {
		var tooltip = parent.FindChildTraverse("DOTAAbilityTooltip").FindChildTraverse("Contents");
		tooltip.m_Item = -1;
	}
}

(function () {
	GameUI.CustomUIConfig().ItemShowTooltip = ItemShowTooltip;
	GameUI.CustomUIConfig().ItemHideTooltip = ItemHideTooltip;
})();