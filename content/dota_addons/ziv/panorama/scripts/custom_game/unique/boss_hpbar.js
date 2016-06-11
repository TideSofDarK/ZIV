"use strict";

var hpBar;
var hpLabel;
var nameLabel;

function UpdateBar() {
	$.Schedule(0.1, UpdateBar);

	var args = $.GetContextPanel().args;
	if (!args) { return 0; }

	var hp = Entities.GetHealth(args.boss)
	var maxHP = Entities.GetMaxHealth(args.boss)
	
	hpLabel.text = hp + "/" + maxHP;
	nameLabel.text = $.Localize(Entities.GetUnitName(args.boss));

	if (hp != NaN && maxHP != NaN) {
		var hpPercentage = hp / maxHP;
		var value = (hpPercentage * 875);
		if (value != NaN) {
			hpBar.style.width = value + "px;";
		}
	}
}

(function () {
	hpBar = $("#BossHPBar");
	hpLabel = $("#BossHPLabel");
	nameLabel = $("#BossName");

	// $("#HPBarForeground").AddClass("BossHPBackground"+(Math.floor(Math.random() * (3 - 1 + 1)) + 1));

	$.Schedule(0.1, function () {
		Game.EmitSound("ui.npe_objective_given");
	});

	UpdateBar();
})();