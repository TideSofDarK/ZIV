var abilityXmargin = 100;
var abilityYmargin = 85;

function UpdateInfo() {
	var heroName = $.GetContextPanel().heroName;

	$("#HeroBioLabel").text = $.Localize("biography");
	$("#AbilitiesLabel").text = $.Localize("abilities");

	$("#HeroName").text = $.Localize(heroName);
	$("#HeroBio").text = $.Localize("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.");

	$("#hires").style.backgroundImage = "url(\"s2r://panorama/images/custom_game/heroes/" + heroName + "_ziv_jpg.vtex\");";
	
	var attribute = $.GetContextPanel().heroesKVs[heroName+"_ziv"]["AttributePrimary"].replace("DOTA_ATTRIBUTE_","").toLowerCase();
	var str = $.GetContextPanel().heroesKVs[heroName+"_ziv"]["AttributeBaseStrength"];
	var agi = $.GetContextPanel().heroesKVs[heroName+"_ziv"]["AttributeBaseAgility"];
	var int = $.GetContextPanel().heroesKVs[heroName+"_ziv"]["AttributeBaseIntelligence"];

	$("#str").text = str;
	$("#agi").text = agi;
	$("#int").text = int;

	$("#HeroName").style.backgroundImage = "url(\"s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_" + attribute + "_psd.vtex\");";
}

function GetSpellCount(layout)
{
	var strDigits = layout.split("");
	var number = 0;

	for (var i = 0; i < strDigits.length; i++) {
		number = number + parseInt(strDigits[i]);
	}

	return number;
}

function GetSpellPositionsBasedOnLayout(layout)
{
	var strDigits = layout.split("");
	var digits = [];
	var positions = [];
	
	var x = 0;
	var y = 0;

	for (var i = 0; i < strDigits.length; i++) {
		digits.push(parseInt(strDigits[i]));
		
		if (digits[i] == 1) {
			positions.push([x,y]);
		}
		else if (digits[i] > 1) {
			for (var z = 0; z < digits[i]; z++) {
				var newY = (abilityYmargin * -digits[i]) + (abilityYmargin * (z+1)) + (abilityYmargin * digits[i] / 4);
				positions.push([x,y+(newY)]);
			}
		}
		x = x + abilityXmargin;
	}

	return positions;
}

// This function converts layout string (e.g. "1122") to group like that [0],[1],[2,3],[2,3],[4,5],[4,5]

function GetAbilityGroups(layout) {
	var abilityGroups = [];

	var strDigits = layout.split("");

	var currentAbility = 0;

	for (var i = 0; i < strDigits.length; i++) {
		abilityGroups.push([]);
		
		for (var z = 0; z < parseInt(strDigits[i]); z++) {
			abilityGroups[abilityGroups.length-1].push(currentAbility + z);
		}
		for (var z = 0; z < parseInt(strDigits[i]) - 1; z++) {
			abilityGroups.push(abilityGroups[abilityGroups.length-1]);
			currentAbility++;
		}
		currentAbility++;
	}

	return abilityGroups;
}

function UpdateSkills() {
	var root = $("#AbilitiesPanel");
	
	var stringLayout = $.GetContextPanel().heroesKVs[$.GetContextPanel().heroName+"_ziv"]["ChooseLayout"].toString();
	var spellCount = GetSpellCount(stringLayout);
	var positions = GetSpellPositionsBasedOnLayout(stringLayout);
	var abilityGroups = GetAbilityGroups(stringLayout);

	var lastGroup = [];
	
	for (var i = 0; i < GetSpellCount(stringLayout); i++) {
		var newChildPanel = $.CreatePanel( "Panel", root, "AbilityPanel" );
		newChildPanel.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection_ability.xml", false, false );

		newChildPanel.FindChild("AbilityImage").abilityname = $.GetContextPanel().heroesKVs[$.GetContextPanel().heroName+"_ziv"]["Ability"+(i+1)];

		newChildPanel.style.marginLeft = "50px;"; 

		newChildPanel.style.x = positions[i][0] + "px;";
		newChildPanel.style.y = positions[i][1] + "px;";

		newChildPanel.abilityID = i;
		newChildPanel.abilityGroup = abilityGroups[i];

		if (newChildPanel.abilityGroup.length == 1 || lastGroup != newChildPanel.abilityGroup) {
			newChildPanel.SetHasClass("selected",true);
		}

		lastGroup = newChildPanel.abilityGroup;

		newChildPanel.selectAbility = (function() {
			if (this.abilityGroup.length > 1) {
				for (var i = 0; i < this.abilityGroup.length; i++) {
					$.GetContextPanel().abilityPanels[this.abilityGroup[i]].SetHasClass("selected",this.abilityID == this.abilityGroup[i]);
				}
			}
		});

		$.GetContextPanel().abilityPanels.push(newChildPanel);
	}
}	

(function () {
	UpdateInfo()
	UpdateSkills()
})();