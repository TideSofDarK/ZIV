var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

function Toggle() {
	$.GetContextPanel().ToggleClass("WindowClosed");

	Update();
}

function Update() {
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	var name = Entities.GetUnitName(queryUnit);

	var panel = $.GetContextPanel();

	var status = CustomNetTables.GetTableValue( "hero_status", Players.GetLocalPlayer());
	var damage = PlayerTables.GetTableValue( "damage", queryUnit);

	$("#HiRes").style.backgroundImage = "url('file://{images}/custom_game/heroes/" + name + "_ziv.jpg');";
	$("#HeroNameLabel").text = "";
	$("#HeroNameLabel").text = $.Localize(name) + "<br>" + "<span class=\"LevelAndLeague\">" + "    " + $.Localize("level") + " " + Entities.GetLevel(queryUnit) + " | " + "Softcore" + "</span>";

	$("#Str").text = status["str"];
	$("#Agi").text = status["agi"];
	$("#Int").text = status["int"];

	$("#HP").text = $.Localize("status_hp") + Entities.GetHealth( queryUnit ) + "/" + Entities.GetMaxHealth( queryUnit );
	$("#HPRegen").text = $.Localize("status_hp_regen") + Util.RoundToTwo(parseFloat(Entities.GetHealthThinkRegen( queryUnit )));
	$("#EP").text = $.Localize("status_ep") + Entities.GetMana( queryUnit ) + "/" + Entities.GetMaxMana( queryUnit );
	$("#EPRegen").text = $.Localize("status_ep_regen") + Util.RoundToTwo(parseFloat(Entities.GetManaThinkRegen( queryUnit )));
	
	$("#ARMOR").text = $.Localize("status_armor") + Math.floor(Entities.GetArmorForDamageType( queryUnit, 1 ));
	$("#EVASION").text = $.Localize("status_evasion") + "0%";

	$("#FireResistance").text = $.Localize("status_fire_resistance") + "0%";
	$("#ColdResistance").text = $.Localize("status_cold_resistance") + "0%";
	$("#LightningResistance").text = $.Localize("status_lightning_resistance") + "0%";
	$("#DarkResistance").text = $.Localize("status_dark_resistance") + "0%";

	$("#AD").text = $.Localize("status_ad") + status["damage"];

	$("#FireIncrease").text = $.Localize("status_fire_increase") + "0%";
	$("#ColdIncrease").text = $.Localize("status_cold_increase") + "0%";
	$("#LightningIncrease").text = $.Localize("status_lightning_increase") + "0%";
	$("#DarkIncrease").text = $.Localize("status_dark_increase") + "0%";

	$("#CTC").text = $.Localize("status_ctc") + "0%";
}

(function()
{
	GameEvents.Subscribe( "ziv_open_status", Toggle );
})();