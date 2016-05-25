"use strict";

var hpBar;
var hpLabel;
var nameLabel;

function OnScenarioChanged(args) {
	var args = CustomNetTables.GetTableValue( args, "boss" );

	if (!args) { return 0; }
	
	hpLabel.text = args["hp"] + "/" + args["maxHP"];
	nameLabel.text = $.Localize(args["boss"]);

	var hp = args["hp"];
	var maxHP = args["maxHP"];

	if (hp != NaN && maxHP != NaN) {
		var hpPercentage = hp / maxHP;
		var value = (hpPercentage * 1000);
		if (value != NaN) {
			hpBar.style.width = value + "px;";
		}
	}
}

(function () {
	hpBar = $("#BossHPBar");
	hpLabel = $("#BossHPLabel");
	nameLabel = $("#BossName");

	$("#HPBarForeground").AddClass("BossHPBackground"+(Math.floor(Math.random() * (3 - 1 + 1)) + 1));

	OnScenarioChanged("scenario");
	
	CustomNetTables.SubscribeNetTableListener( "scenario", OnScenarioChanged );
})();