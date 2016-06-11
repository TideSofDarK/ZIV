"use strict";

var hpBar;
var hpLabel;
var nameLabel;

function UpdateBar() {
	var args = $.GetContextPanel().args;
	if (!args) { $.Schedule(0.1, UpdateBar); return 0; }

	var hp = Entities.GetHealth(args.boss)
	var maxHP = Entities.GetMaxHealth(args.boss)

	if (hp != NaN && maxHP != NaN) {
		hpLabel.text = hp + "/" + maxHP;
		nameLabel.text = $.Localize(Entities.GetUnitName(args.boss));

		var hpPercentage = hp / maxHP;
		var value = (hpPercentage * 876);
		if (value != NaN) {
			hpBar.style.width = value + "px;";
		}

		$.Schedule(0.1, UpdateBar);
	} else {
		hpBar.style.width = 0 + "px;";
		hpLabel.text = 0 + "/" + 0;

		$("#HPBarGlass").AddClass("HPBarGlassBroken");

		Game.EmitSound("ui.npe_objective_complete");

		$.Schedule(2.5, RemoveBar);
	}
}

function RemoveBar() {
	var panel = $.GetContextPanel();
	panel.AddClass("BossHPRootOutro");
	// $.Schedule(3.0, function () {
	panel.DeleteAsync(3.0);
	// });
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