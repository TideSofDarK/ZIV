"use strict";
var heroID = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );

var teamID = Game.GetLocalPlayerInfo().player_team_id;

var marksPath = "file://{resources}/layout/custom_game/minimap/marks/";
var bounds = null;

// Calculate relative image position
function getRelativePosition( pos )
{
	if (!pos)
		return [0, 0];

	var width = bounds["max"].x - bounds["min"].x;
	var height = bounds["max"].y - bounds["min"].y;

	var posX = pos[0] - bounds["min"].x;
	var posY = bounds["max"].y - pos[1];

	return [ posX / width, posY / height ];
}

// Calculate normal panel sizes
function getPanelSize( panel )
{
	if (!panel)
		return { width: 0, height: 0 };

	return {
		width: panel.actuallayoutwidth * 1920 / Game.GetScreenWidth(),
		height: panel.actuallayoutheight * 1080 / Game.GetScreenHeight()
	}
}

function updateImagePosition()
{
	var relPos = getRelativePosition( Entities.GetAbsOrigin(heroID) );

	var size = getPanelSize( $( "#MinimapImage" ) );
	var parentSize = getPanelSize( $( "#ImagePanel" ) );

	var offset = {
		x: -size.width * relPos[0] + parentSize.width / 2,
		y: -size.height * relPos[1] + parentSize.height / 2
	}

	if (!isNaN(offset.x) && !isNaN(offset.y))
	{
		$( "#MinimapImage" ).style.marginLeft = offset.x + "px;"
		$( "#MinimapImage" ).style.marginTop =  offset.y + "px;"
	}
}

function getEntityAngle( entityID )
{
	var forward = Entities.GetForward( entityID );
	var offset = (forward[0] < 0 ? 270 : 90) 

	return offset - Math.atan(forward[1] / forward[0]) * 180 / 3.14;
}

function updatePointerPosition()
{
	var size = getPanelSize( $( "#PointerImage" ) );
	var parentSize = getPanelSize( $( "#ImagePanel" ) );

	var offset = {
		x: parentSize.width / 2 - size.width / 2,
		y: parentSize.height / 2 - size.height / 2
	}

	if (!isNaN(offset.x) && !isNaN(offset.y))
	{
		$( "#PointerImage" ).style.marginLeft = offset.x + "px;"
		$( "#PointerImage" ).style.marginTop =  offset.y + "px;"

		$( "#PointerImage" ).style.transform = "rotateZ(" + getEntityAngle(heroID) + "deg);";		
	}
}

function removeUnusedMarks( units )
{
	var marksContainer = $( "#MarksMap" );
	var count = marksContainer.GetChildCount();

	for (var i = 0; i < count; i++) {
		var childID = marksContainer.GetChild(i).id;
		var matches = childID.match(/[\d]+$/);
		var entityID = matches && matches.length > 0 ? matches[0] : -1;

		if (units.indexOf(Number(entityID)) == -1)
			marksContainer.GetChild(i).DeleteAsync(0.1);
	}
}

function setMapPosByWorldPos( panel, pos )
{
	var size = getPanelSize( panel );
	var relPos = getRelativePosition( pos );
	var parentSize = getPanelSize( $( "#MinimapImage" ) );

	var offset = {
		x: parentSize.width * relPos[0]- size.width / 2,
		y: parentSize.height * relPos[1] - size.height / 2
	}

	if (!isNaN(offset.x) && !isNaN(offset.y))
	{
		panel.style.marginLeft = offset.x + "px;"
		panel.style.marginTop = offset.y + "px;"
	}	
}

// Get mark filename
function getMarkType( entity )
{
	var type = "default";
	if (Entities.IsHero( entity ))
		return "hero";

	if (Entities.GetUnitName(entity) == "npc_temple_obelisk")
		return "obelisk";

	return type;
} 

function createMarkPanel( entity )
{
	var panel = $.CreatePanel( "Panel", $( "#MarksMap" ), "Entity_" + entity );
	panel.BLoadLayout( marksPath + getMarkType( entity ) +".xml", false, false );

	panel.entity = entity; 

	if (typeof panel.UpdateClass == 'function')
		panel.UpdateClass();

	// Set mark rotation
	panel.style.transform = 'rotateZ( ' + -settings.rotation + 'deg );';
	return panel;
} 

// Filter units for minimap
function filterUnits()
{
	var visionRange = Entities.GetCurrentVisionRange( heroID );	
	return Entities.GetAllEntities().filter(function( entity ) {
		//$.Msg(Entities.GetUnitName(entity));
		return Entities.IsEntityInRange( heroID, entity, visionRange ) &&
			!Entities.IsInvisible( entity ) && 
			//Entities.IsValidEntity( entity ) &&
			(Entities.IsHero( entity ) || Entities.GetUnitName(entity) == "npc_temple_obelisk") &&
			heroID != entity; 
	})
}

function updateUnits()
{
	var rangeUnits = filterUnits( heroID );

	removeUnusedMarks( rangeUnits )

	for(var ent of rangeUnits)
	{
		var panel = $( "#MarksMap" ).FindChild("Entity_" + ent);
		if (!panel)
			panel = createMarkPanel( ent );

		setMapPosByWorldPos( panel, Entities.GetAbsOrigin(ent) );
	}
}

// Update event position by attached entity
function updateEvents()
{
	var marksContainer = $( "#EventsMap" );
	var count = marksContainer.GetChildCount();

	for (var i = 0; i < count; i++) {
		var eventPanel = marksContainer.GetChild(i);
		if (!eventPanel.entity || eventPanel.entity == -1)
			continue;

		setMapPosByWorldPos( eventPanel, Entities.GetAbsOrigin( eventPanel.entity ));
	}	
}

function clearFog()
{
	$("#FogMap").RunJavascript('FillFog();'); 

	var heroes = Game.GetPlayerIDsOnTeam(teamID).map(function(pID){
		return Players.GetPlayerHeroEntityIndex(pID);
	});

	for(var hero of heroes)
	{
		var pos = getRelativePosition( Entities.GetAbsOrigin(hero) );
		// Relative vision
		var visionRange =Entities.GetCurrentVisionRange( hero ) /  (bounds["max"].x - bounds["min"].x);	
		
		$("#FogMap").RunJavascript('ClearFog(' + pos[0] + ', ' + pos[1] + ', ' + visionRange +');'); 
	}
}

function updateMinimap()
{
	if ($.GetContextPanel().visible){
		updateImagePosition();
		updatePointerPosition();
		updateUnits();
		updateEvents();

		clearFog(); 		
	}

	$.Schedule(0.02, updateMinimap);

	$("#FogMap").RunJavascript('LoadImage("http://puu.sh/rXDr6/5613600704.png");');  
}

function minimapClick()
{
	var mousePos = GameUI.GetCursorPosition();
	var containerPos = $( "#ImagePanel" ).GetPositionWithinWindow();

	var image = $( "#MinimapImage" );
	var offset = {
		x: ((mousePos[0] - containerPos.x) - image.actualxoffset) / image.actuallayoutwidth,
		y: ((mousePos[1] - containerPos.y) - image.actualyoffset) / image.actuallayoutheight
	}

	/* Тут должно быть преобразование координат
	var angle = settings.rotation / 180 * Math.PI;

	offset.x = offset.x * Math.cos(angle) - offset.y * Math.sin(angle);
	offset.y = offset.x * Math.sin(angle) + offset.y * Math.cos(angle);
	*/

	var x = bounds["min"].x + (bounds["max"].x - bounds["min"].x) * offset.x;
	var y = bounds["max"].y - (bounds["max"].y - bounds["min"].y) * offset.y;

	// Minimap events
	if (GameUI.IsAltDown())
		GameEvents.SendCustomGameEventToServer( "set_minimap_event", { "type": "ping", "duration": 5, "pos": [ x, y ] } );
	// Moving
	else
	{
		var order = {
			OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position : [x, y, 0],
			Queue : false,
			ShowEffects : false
		};

		Game.PrepareUnitOrders( order );
	}
}

function setWorldBounds( args ) 
{
	var args = CustomNetTables.GetTableValue("scenario", "map");

	bounds = {};

	bounds["min"] = args.min;
	bounds["max"] = args.max;
	bounds["name"] = args.map; 

	updateMinimap();
}

// Events handler
function minimapEvent( args )
{
	var panel = $.CreatePanel( "Panel", $( "#EventsMap" ), args["Type"] );
	panel.BLoadLayout( marksPath + "events.xml", false, false );
	panel.FormEvent( args.type, args.player, args.entity ); 

	// Delay to calculate sizes
	$.Schedule(0.1, function() {
		setMapPosByWorldPos( panel, [ args.pos[0], args.pos[1] ]);
	});

	panel.DeleteAsync( args.duration ); 
}

function changeMinimapMode()
{
	//$("#FogMap").ToggleClass("WindowClosed"); 
	if (!$.GetContextPanel()) {
		return;
	}
	if ($.GetContextPanel().BHasClass("Hero"))
	{
	 	$.GetContextPanel().RemoveClass("Hero");
	 	$.GetContextPanel().AddClass("TopRight");

	 	$( "#MinimapImage" ).hittest = true;
	}
	else
	{
	 	$.GetContextPanel().RemoveClass("TopRight");
	 	$.GetContextPanel().AddClass("Hero"); 

	 	$( "#MinimapImage" ).hittest = false;
	}
}

(function()
{
	GameEvents.Subscribe("custom_minimap_event", minimapEvent);

	if (!GameUI.CustomUIConfig().changeMinimapMode)
	{
		GameUI.CustomUIConfig().changeMinimapMode = changeMinimapMode; 
	}

	setWorldBounds(); 

	$("#FogMap").SetURL('http://ec2-54-93-180-157.eu-central-1.compute.amazonaws.com/test_minimap/minimap.html');
	//CustomNetTables.SubscribeNetTableListener( "scenario", setWorldBounds );
})();