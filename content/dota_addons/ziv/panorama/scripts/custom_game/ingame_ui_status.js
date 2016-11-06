var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

function Toggle() {
	$.GetContextPanel().ToggleClass("WindowClosed");

	Update();
}

function Update() {
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	var name = Entities.GetUnitName(queryUnit);

	$("#HiRes").style.backgroundImage = "url('file://{images}/custom_game/heroes/" + name + "_ziv.jpg');";
	$("#HeroNameLabel").text = "";
	$("#HeroNameLabel").text = $.Localize(name) + "<br>" + "<span class=\"LevelAndLeague\">" + "    " + $.Localize("level") + " " + Entities.GetLevel(queryUnit) + " | " + "Softcore" + "</span>";

	ResetValues();
}

function ResetValues() {
	var queryUnit = Players.GetLocalPlayerPortraitUnit();

	if (!PlayerTables.GetTableValue( "characters", "status") || !PlayerTables.GetTableValue( "damage", queryUnit)) return;
	
	var status = PlayerTables.GetTableValue( "characters", "status")[Players.GetLocalPlayer()];
	var damage = PlayerTables.GetTableValue( "damage", queryUnit);

	if (!status) return;

	$("#Str").text = status["str"];
	$("#Agi").text = status["agi"];
	$("#Int").text = status["int"];

	$("#HP").text = $.Localize("status_hp") + Entities.GetHealth( queryUnit ) + "/" + Entities.GetMaxHealth( queryUnit );
	$("#HPRegen").text = $.Localize("status_hp_regen") + Util.RoundToTwo(parseFloat(Entities.GetHealthThinkRegen( queryUnit )));
	$("#EP").text = $.Localize("status_ep") + Entities.GetMana( queryUnit ) + "/" + Entities.GetMaxMana( queryUnit );
	$("#EPRegen").text = $.Localize("status_ep_regen") + Util.RoundToTwo(parseFloat(Entities.GetManaThinkRegen( queryUnit )));
	
	$("#ARMOR").text = $.Localize("status_armor") + damage[12];
	$("#EVASION").text = $.Localize("status_evasion") + Util.RoundToThree((0.05 * (1 + (damage[11] / 300)))) + "%";

	var localResistances = damage[0];

	$("#FireResistance").text = $.Localize("status_fire_resistance") + (localResistances + damage[1]) + "%";
	$("#ColdResistance").text = $.Localize("status_cold_resistance") + (localResistances + damage[2]) + "%";
	$("#LightningResistance").text = $.Localize("status_lightning_resistance") + (localResistances + damage[3]) + "%";
	$("#DarkResistance").text = $.Localize("status_dark_resistance") + (localResistances + damage[4]) + "%";

	$("#AD").text = $.Localize("status_ad") + status["damage"];

	$("#FireIncrease").text = $.Localize("status_fire_increase") + damage[5] + "%";
	$("#ColdIncrease").text = $.Localize("status_cold_increase") + damage[6] + "%";
	$("#LightningIncrease").text = $.Localize("status_lightning_increase") + damage[7] + "%";
	$("#DarkIncrease").text = $.Localize("status_dark_increase") + damage[8] + "%";

	$("#HPL").text = $.Localize("status_hp_leech") + damage[13] + "%";
	$("#EPL").text = $.Localize("status_ep_leech") + damage[14] + "%";

	$("#CTC").text = $.Localize("status_ctc") + damage[9] + "%";
	$("#CD").text = $.Localize("status_cd") + damage[10] + "%";
}

function OnDamageChanged(name, changes, dels) {
	ResetValues();
}

function OnCharactersChanged(name, changes, dels) {
	ResetValues();
}

(function()
{
	GameEvents.Subscribe( "ziv_open_status", Toggle );

	PlayerTables.SubscribeNetTableListener("damage", OnDamageChanged);
	PlayerTables.SubscribeNetTableListener("characters", OnCharactersChanged);
})();