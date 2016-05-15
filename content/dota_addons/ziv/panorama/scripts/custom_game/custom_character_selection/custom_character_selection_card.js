"use strict";

function SelectCharacter()
{
	$.Msg("Selected!");
}

function DeleteCharacter()
{
	$.Msg("Deleted!");
}

function UpdateCard( characterInfo )
{
	if (!characterInfo)
	{
		$( "#CloseButton" ).visible = false;
		return;
	}

	$( "#HeroImage" ).SetImage( "file://{images}/custom_game/heroes/" + characterInfo.name + "_ziv.jpg" );
	$( "#HeroNameLabel" ).text = $.Localize(characterInfo.name);
	$( "#HeroLevel" ).text = $.Localize("level") + " " + characterInfo.level;

	$.GetContextPanel().SetPanelEvent("onmouseactivate", SelectCharacter);
}

function ShowDeleteTooltip()
{
	$.DispatchEvent( "DOTAShowTextTooltip", $.Localize("remove_hero"));
}

function HideDeleteTooltip()
{
	$.DispatchEvent( "DOTAHideTextTooltip");
}

(function () {
	$.GetContextPanel().UpdateCard = UpdateCard;
})();