var heroFrames = [];

var heroList;
var heroesKVs;

var currentCharacter = 2;
var lockedIn = false;

var marginX = 550;
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
}

function RightButton() {
	if ( currentCharacter < heroFrames.length-1 && lockedIn == false)
	{
		currentCharacter++;
	}
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
	GameEvents.SendCustomGameEventToServer( "ziv_choose_hero", { "pID" : Players.GetLocalPlayer(), "hero_name" : heroFrames[currentCharacter].heroName } );
}

function CreateFrames() {
	if (heroList == undefined || heroesKVs == undefined) {
		
		$.Schedule(0.1, CreateFrames);
	}
	else {
		var root = $.GetContextPanel();

		for (var hero in heroList) {
	    	var value = heroList[hero];

	    	if (value == "1") {
				var newHeroFrame = $.CreatePanel( "Panel", root, "HeroFrame" );

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
		var positionVector = heroFrames[i].style.position;
		if (positionVector != undefined) {
			var lockedInOffset = 0;
			var scrollOffset = 1;

			if (lockedIn && currentCharacter != i) {
				lockedInOffset = i < currentCharacter ? -3000 : 3000;
				scrollOffset = 0.275;
			}

			heroFrames[i].style.x = lockedInOffset + (( (i - currentCharacter) * marginX ) ) + "px;";
			heroFrames[i].style.y = (marginY/2) + ((Math.abs(currentCharacter - i) * marginY)) + "px;";

			heroFrames[i].SetHasClass( "unselected", i != currentCharacter );
		}
		else
		{
			heroFrames[i].style.position = "0px 0px -1px;";
		}
	}

	$.Schedule(0.01, UpdateFrames)
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

	CreateFrames();

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
			if ( arg < 0 && currentCharacter > 0 )
			{
				currentCharacter--;
			}
			else if ( arg > 0 && currentCharacter < heroFrames.length-1 )
			{
				currentCharacter++;
			}
		}
		return CONTINUE_PROCESSING_EVENT;
	} );
})();