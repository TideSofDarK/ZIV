function Open() {
	GameUI.CustomUIConfig().ZIVAddToPanelsQueue($.GetContextPanel());
	Update();
	$.GetContextPanel().SetHasClass("Hide", false);
}

function CloseButton() {
	GameUI.CustomUIConfig().ZIVRemoveFromPanelsQueue($.GetContextPanel());
	$.GetContextPanel().SetHasClass("Hide", true);
}

function roundToTwo(num) {    
    return +(Math.round(num + "e+2")  + "e-2");
}

function Update() {
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	var name = Entities.GetUnitName(queryUnit);

	var panel = $.GetContextPanel();

	var status = CustomNetTables.GetTableValue( "hero_status", Players.GetLocalPlayer());

	// $("#hires").SetImage("file://{images}/custom_game/heroes/" + name + "_ziv.jpg");
	$("#hires").style.backgroundImage = "url(\"s2r://panorama/images/custom_game/heroes/" + name + "_ziv_jpg.vtex\");";
	$("#HeroNameLabel").html = true;
	$("#HeroNameLabel").text = $.Localize(name) + "<br>" + "<span class=\"LevelAndLeague\">" + "    Level " + Entities.GetLevel(queryUnit) + " | " + "Softcore" + "</span>";

	$("#Str").text = status["str"];
	$("#Agi").text = status["agi"];
	$("#Int").text = status["int"];

	$("#HP").text = $.Localize("status_hp") + Entities.GetHealth( queryUnit ) + "/" + Entities.GetMaxHealth( queryUnit ) + " + " + roundToTwo(parseFloat(Entities.GetHealthThinkRegen( queryUnit )));
	$("#MP").text = $.Localize("status_mp") + Entities.GetMana( queryUnit ) + "/" + Entities.GetMaxMana( queryUnit ) + " + " + roundToTwo(parseFloat(Entities.GetManaThinkRegen( queryUnit )));
	$("#AD").text = $.Localize("status_ad") + status["damage"];
	$("#ARMOR").text = $.Localize("status_armor") + Math.floor(Entities.GetArmorForDamageType( queryUnit, 1 ));
	$("#EVASION").text = $.Localize("status_evasion") + "0%";
	$("#MDA").text = $.Localize("status_mda") + "0%";
	$("#CTC").text = $.Localize("status_ctc") + "0%";
}

(function()
{
	GameEvents.Subscribe( "ziv_open_status", Open );
})();