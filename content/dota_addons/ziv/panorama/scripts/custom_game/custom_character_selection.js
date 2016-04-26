var heroFrames = [];

var heroList;
var heroesKVs;

var currentCharacter = 2;
var lockedIn = false;

var marginX = 0;
var marginY = -145;

function GetVectorFromStylePosition(posString) {
	var splitted = posString.split(" ");
	var vector = []
	for (var i = 0; i < splitted.length; i++) {
		vector[i] = parseInt(splitted[i]);
	}
	return vector
}

function SimpleLerp(a, b, t) {
	return a + (b - a) * t;
}

function LeftButton() {
	if ( currentCharacter > 0 && lockedIn == false)
	{
		currentCharacter--;
	}
	UpdateFrames();
}

function RightButton() {
	if ( currentCharacter < heroFrames.length-1 && lockedIn == false)
	{
		currentCharacter++;
	}
	UpdateFrames();
}

function LockIn() {
	if (lockedIn == false) {
		lockedIn = true;

		heroFrames[currentCharacter].AddClass( "selected" );

		$("#ChooseButton").SetHasClass( "selected", true );
		$("#LockInLabel").text = $.Localize("lockedin");
		$("#DirButtonLeft").AddClass( "disabled" );
		$("#DirButtonRight").AddClass( "disabled" );
		$.Schedule(2.0, CreateHero);
	}
}

function CreateHero() {
	var abilities = heroFrames[currentCharacter].FindChildTraverse("AbilitiesPanel");
	var selected_abilities = [];
	if (abilities) {
		for (var i = 0; i < abilities.GetChildCount(); i++) {
			var ability = abilities.GetChild( i );
			if (ability) {
				if (ability.BHasClass("selected")) {
					selected_abilities.push(ability.id);
				}
			}
		}
	}
	GameEvents.SendCustomGameEventToServer( "ziv_choose_hero", { "pID" : Players.GetLocalPlayer(), "hero_name" : heroFrames[currentCharacter].heroName, "abilities" : selected_abilities } );
}

function CreateFrames() {
	if (heroList == undefined || heroesKVs == undefined) {
		
		$.Schedule(0.1, CreateFrames);
	}
	else {
		var _root = $("#HeroFrames");

		for (var hero in heroList) {
	    	var value = heroList[hero];

	    	if (value == "1") {
				var newHeroFrame = $.CreatePanel( "Panel", _root, "HeroFrame_" + hero  );

				newHeroFrame.abilityPanels = [];

				newHeroFrame.heroName = hero;
				newHeroFrame.heroesKVs = heroesKVs;

				newHeroFrame.BLoadLayout( "file://{resources}/layout/custom_game/custom_character_selection_frame.xml", false, false );
				
				heroFrames.push(newHeroFrame);
	    	}
		}

		UpdateFrames();
	}
}

function UpdateFrames() {
    for (var i = heroFrames.length-1; i >= 0; i--) {
        var lockedInOffset = 0;
        var scrollOffset = 1;

        if (lockedIn && currentCharacter != i) {
            lockedInOffset = i < currentCharacter ? -3000 : 3000;
            scrollOffset = 0.275;
        }

        var sign = i < currentCharacter
            ? -1
            : i > currentCharacter ? 1 : 0;
        heroFrames[i].style.x = (1000 * sign + lockedInOffset + (( (i - currentCharacter) * marginX ) ) + "px 0px;") + "px;";
        heroFrames[i].style.y = "-45px;";
        heroFrames[i].style.zIndex = i < currentCharacter
            ? (heroFrames.length - currentCharacter)
            : i > currentCharacter
                ? (heroFrames.length - i - currentCharacter)
                : 10;

        heroFrames[i].SetHasClass( "unselectedLeft", i < currentCharacter );
        heroFrames[i].SetHasClass( "unselectedRight", i > currentCharacter );
    }
 
    // $.Schedule(0.01, UpdateFrames)
}

function CreateCharacterButton() {
	$("#Menu").style.visibility = "collapse;";
	$("#SelectionRoot").style.visibility = "visible;";

	CreateFrames();
}

function LoadCharacterButton() {
	$("#Menu").AddClass("FlippedB");
	$.Schedule(0.4, RemoveFlipClass);
}

function RemoveFlipClass() {
	$("#CharacterList").RemoveClass("FlippedA");
	$("#CharacterList").style.visibility = "visible;";
}

function SetHeroList(eventArgs) {
	heroList = eventArgs;
}

function SetHeroesKVs(eventArgs) {
	heroesKVs = eventArgs;
}

(function () {
	GameEvents.Subscribe( "ziv_set_herolist", SetHeroList );
	GameEvents.Subscribe( "ziv_set_heroes_kvs", SetHeroesKVs );

	// CreateFrames();

	GameUI.SetMouseCallback( function( eventName, arg ) {
		var CONSUME_EVENT = true;
		var CONTINUE_PROCESSING_EVENT = false;

		if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
			return CONTINUE_PROCESSING_EVENT;

		if ( eventName == "pressed" )
		{
		}
		else if ( eventName === "wheeled" )
		{
			if ( arg > 0 && currentCharacter > 0 )
			{
				currentCharacter--;
			}
			else if ( arg < 0 && currentCharacter < heroFrames.length-1 )
			{
				currentCharacter++;
			}
		}
		return CONTINUE_PROCESSING_EVENT;
	} );
})();