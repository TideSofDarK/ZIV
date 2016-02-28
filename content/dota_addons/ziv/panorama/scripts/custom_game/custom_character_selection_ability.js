function AbilityShowTooltip()
{
	$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", $( "#AbilityButton" ), $( "#AbilityImage" ).abilityname, 0 );
}

function AbilityHideTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	$.DispatchEvent( "DOTAHideAbilityTooltip", abilityButton );
}

function AbilitySelect()
{
	var panel = $.GetContextPanel();
	panel.selectAbility();
}