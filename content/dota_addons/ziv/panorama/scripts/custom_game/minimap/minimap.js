"use strict";

var marksPath = "file://{resources}/layout/custom_game/minimap/marks/";
var units = [];
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
	var heroID = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
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
	if (!forward) {
		return 0;
	}
	
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

		var heroID = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
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

function createMarkPanel( entity )
{
	var panel = $.CreatePanel( "Panel", $( "#MarksMap" ), "Entity_" + entity );
	panel.BLoadLayout( marksPath + settings.marks( entity ) +".xml", false, false );

	panel.entity = entity; 

	if (typeof panel.UpdateClass == 'function')
		panel.UpdateClass();

	// Set mark rotation
	panel.style.transform = 'rotateZ( ' + -settings.rotation + 'deg );';
	return panel;
} 

function updateUnits()
{
	removeUnusedMarks( units )

	for(var ent of units)
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

	var teamID = Game.GetLocalPlayerInfo().player_team_id;
	var heroes = Game.GetPlayerIDsOnTeam(teamID).map(function(pID){
		return Players.GetPlayerHeroEntityIndex(pID);
	});

	for(var hero of heroes)
	{
		var pos = getRelativePosition( Entities.GetAbsOrigin(hero) );
		// Relative vision
		var visionRange = Entities.GetCurrentVisionRange( hero ) /  (bounds["max"].x - bounds["min"].x);	
		
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

	// $("#FogMap").RunJavascript('LoadImage("http://puu.sh/rXDr6/5613600704.png");');  
	$("#FogMap").RunJavascript('LoadImage("https://puu.sh/sE9Ef/fee0bda05d.png");');  
}

function calculateClickPosition( offset, angle ) {
	//return offset
	//offset = { x: 0, y: 0}
 	
 	offset = { x: offset.x - offset.x / 2, y: offset.y - offset.x / 2 };

	//var angle = -settings.rotation / 180 * Math.PI;

	var xMult = 1;
	var yMult = 1;

	offset.x = xMult * offset.x * Math.cos(angle) - yMult * offset.y * Math.sin(angle);
	offset.y = xMult * offset.x * Math.sin(angle) + yMult * offset.y * Math.cos(angle);

	//$.Msg({ x: offset.x + 0.5, y: offset.y + 0.5 });
	return offset//{ x: offset.x + 0.5, y: offset.y + 0.5 };
}

function minimapClick()
{
	return;
	//var angle = settings.rotation / 180 * Math.PI;
	//GameUI.CustomUIConfig().setMinimapSettings({ rotation: 0 });

	var mousePos = GameUI.GetCursorPosition();
	var containerPos = $( "#ImagePanel" ).GetPositionWithinWindow();

	var image = $( "#MinimapImage" );
	var offset = {
		x: ((mousePos[0] - containerPos.x) - image.actualxoffset) / image.actuallayoutwidth,
		y: ((mousePos[1] - containerPos.y) - image.actualyoffset) / image.actuallayoutheight
	}

	var x = bounds["min"].x + (bounds["max"].x - bounds["min"].x) * offset.x;
	var y = bounds["max"].y - (bounds["max"].y - bounds["min"].y) * offset.y;

	//var x1 = bounds["min"].x + (bounds["max"].x - bounds["min"].x) * offset1.x;
	//var y1 = bounds["max"].y - (bounds["max"].y - bounds["min"].y) * offset1.y;

	//var offset1 = calculateClickPosition( { x: x, y: y}, angle );

	// Minimap events
	if (GameUI.IsAltDown()){
		GameEvents.SendCustomGameEventToServer( "set_minimap_event", { "type": "ping", "duration": 5, "pos": [ x, y ] } );
		//GameEvents.SendCustomGameEventToServer( "set_minimap_event", { "type": "defend", "duration": 5, "pos": [ x1, y1 ] } );
	}
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

	//GameUI.CustomUIConfig().setMinimapSettings({ rotation: 45 });
}

// Filter units function
function getUnits() {
	units = Entities.GetAllEntities().filter(settings.filter);

	$.Schedule(0.1, getUnits);
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
	panel.style.transform = 'rotateZ( ' + -settings.rotation + 'deg );';

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
		GameUI.CustomUIConfig().changeMinimapMode = changeMinimapMode;

	setWorldBounds(); 

	$("#FogMap").SetURL('http://ec2-54-93-180-157.eu-central-1.compute.amazonaws.com/test_minimap/minimap.html');
	GameUI.CustomUIConfig().setMinimapSettings({ rotation: 45 });
	getUnits();

	//CustomNetTables.SubscribeNetTableListener( "scenario", setWorldBounds );

	// Override controls
    Game.AddCommand("+ZIVShowMinimap", changeMinimapMode, "", 0);
	Game.AddCommand("-ZIVShowMinimap", changeMinimapMode, "", 0);
})();