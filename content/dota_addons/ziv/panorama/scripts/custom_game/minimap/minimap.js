"use strict";
var heroID = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );

var marksPath = "file://{resources}/layout/custom_game/minimap/marks/";
var bounds = null;

var squares = {};
var fogSquareSize = 0;
var maxFogSquares = 32;
var fogMapSize = {};

// Calculate relative image position
function GetRelativePosition( pos )
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
function GetPanelSize( panel )
{
	if (!panel)
		return { width: 0, height: 0 };

	return {
		width: panel.actuallayoutwidth * 1920 / Game.GetScreenWidth(),
		height: panel.actuallayoutheight * 1080 / Game.GetScreenHeight()
	}
}

function UpdateImagePosition()
{
	var relPos = GetRelativePosition( Entities.GetAbsOrigin(heroID) );

	var size = GetPanelSize( $( "#MinimapImage" ) );
	var parentSize = GetPanelSize( $( "#ImagePanel" ) );

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

function GetEntityAngle( entityID )
{
	var forward = Entities.GetForward( entityID );
	var offset = (forward[0] < 0 ? 270 : 90) 

	return offset - Math.atan(forward[1] / forward[0]) * 180 / 3.14;
}

function UpdatePointerPosition()
{
	var size = GetPanelSize( $( "#PointerImage" ) );
	var parentSize = GetPanelSize( $( "#ImagePanel" ) );

	var offset = {
		x: parentSize.width / 2 - size.width / 2,
		y: parentSize.height / 2 - size.height / 2
	}

	if (!isNaN(offset.x) && !isNaN(offset.y))
	{
		$( "#PointerImage" ).style.marginLeft = offset.x + "px;"
		$( "#PointerImage" ).style.marginTop =  offset.y + "px;"

		$( "#PointerImage" ).style.transform = "rotateZ(" + GetEntityAngle(heroID) + "deg);";		
	}
}

function RemoveUnusedMarks( units )
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

function SetMapPosByWorldPos( panel, pos )
{
	var size = GetPanelSize( panel );
	var relPos = GetRelativePosition( pos );
	var parentSize = GetPanelSize( $( "#MinimapImage" ) );

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
function GetMarkType( entity )
{
	var type = "default";

	return type;
}

function CreateMarkPanel( entity )
{
	var panel = $.CreatePanel( "Panel", $( "#MarksMap" ), "Entity_" + entity );
	panel.BLoadLayout( marksPath + GetMarkType( entity ) +".xml", false, false );

	panel.entity = entity;

	if (panel.UpdateClass)
		panel.UpdateClass();

	return panel;
} 

// Filter units for minimap
function FilterUnits()
{
	var visionRange = Entities.GetCurrentVisionRange( heroID );	
	return Entities.GetAllEntities().filter(function( entity ) {
		return Entities.IsEntityInRange( heroID, entity, visionRange ) &&
			!Entities.IsInvisible( entity ) && 
			Entities.IsValidEntity( entity ) &&
			Entities.IsHero( entity ) &&
			heroID != entity;
	})
}

function UpdateUnits()
{
	var rangeUnits = FilterUnits( heroID );

	RemoveUnusedMarks( rangeUnits )

	for(var ent of rangeUnits)
	{
		var panel = $( "#MarksMap" ).FindChild("Entity_" + ent);
		if (!panel)
			panel = CreateMarkPanel( ent );

		SetMapPosByWorldPos( panel, Entities.GetAbsOrigin(ent) );
	}
}

// Update event position by attached entity
function UpdateEvents()
{
	var marksContainer = $( "#EventsMap" );
	var count = marksContainer.GetChildCount();

	for (var i = 0; i < count; i++) {
		var eventPanel = marksContainer.GetChild(i);
		if (!eventPanel.entity || eventPanel.entity == -1)
			continue;

		SetMapPosByWorldPos( eventPanel, Entities.GetAbsOrigin( eventPanel.entity ));
	}	
}

function UpdateMinimap()
{
	UpdateImagePosition();
	UpdatePointerPosition();
	UpdateUnits();
	UpdateEvents();

	$.Schedule(0.05, UpdateMinimap);
}

function MinimapClick()
{
	var mousePos = GameUI.GetCursorPosition();
	var containerPos = $( "#ImagePanel" ).GetPositionWithinWindow();

	var image = $( "#MinimapImage" );
	var offset = {
		x: ((mousePos[0] - containerPos.x) - image.actualxoffset) / image.actuallayoutwidth,
		y: ((mousePos[1] - containerPos.y) - image.actualyoffset) / image.actuallayoutheight
	}

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

function SetWorldBounds( args ) 
{
	bounds = {};

	bounds["min"] = args.min;
	bounds["max"] = args.max;
	bounds["name"] = args.map;
}

// Events handler
function MinimapEvent( args )
{
	var panel = $.CreatePanel( "Panel", $( "#EventsMap" ), args["Type"] );
	panel.BLoadLayout( marksPath + "events.xml", false, false );
	panel.FormEvent( args.type, args.player, args.entity ); 

	// Delay to calculate sizes
	$.Schedule(0.1, function() {
		SetMapPosByWorldPos( panel, [ args.pos[0], args.pos[1] ]);
	});

	panel.DeleteAsync( args.duration );
}

function ChangeMinimapMode()
{
	$("#MinimapCanvas").ToggleClass("WindowClosed");
	// if ($.GetContextPanel().BHasClass("Hero"))
	// {
	// 	$.GetContextPanel().RemoveClass("Hero");
	// 	$.GetContextPanel().AddClass("TopRight");

	// 	$( "#MinimapImage" ).hittest = true;
	// }
	// else
	// {
	// 	$.GetContextPanel().RemoveClass("TopRight");
	// 	$.GetContextPanel().AddClass("Hero");

	// 	$( "#MinimapImage" ).hittest = false;
	// }
}

function InitFogMap()
{
	var fogMap = $( "#FogMap" );
	$( "#FogMap" ).RemoveAndDeleteChildren();
	var size = GetPanelSize( $( "#MinimapImage" ) );

	fogSquareSize = Math.max(size.width, size.height) / maxFogSquares;
	fogMapSize = { width: size.width / fogSquareSize, height: size.height / fogSquareSize }
	
	for (var x = 0; x < fogMapSize.width; x++) {
		squares[x] = {}
		for (var y = 0; y < fogMapSize.height; y++) {
			var square = $.CreatePanel( "Panel", fogMap, "FOGSquare_" + x + "x" + y );

			square.AddClass("FOGSquare");
			square.style.x = ( x * fogSquareSize) + "px;";
			square.style.y = ( y * fogSquareSize) + "px;";
			square.style.width = fogSquareSize + "px;";
			square.style.height = fogSquareSize + "px;";

			squares[x][y] = square; 
		}
	}

	FOW() ;
}

function FOW() {
	if ( $( "#FogMap" ).GetChildCount() == 0 )
		return;

	var pos = Entities.GetAbsOrigin(heroID);

	var width = bounds["max"].x - bounds["min"].x;
	var height = bounds["max"].y - bounds["min"].y;

	pos[0] -=  bounds["min"].x;
	pos[1] -=  bounds["min"].y;

	var x = Math.ceil(pos[0] / width * fogMapSize.width) - 1;
	var y = fogMapSize.height - Math.ceil(pos[1] / height * fogMapSize.height);

	if (squares[x][y] && squares[x][y].visible)
	{
		squares[x][y].DeleteAsync(0);
		squares[x][y] = null;
	}

	if (squares[x + 1][y] && squares[x + 1][y].visible)
	{
		squares[x + 1][y].DeleteAsync(0);
		squares[x + 1][y] = null;
	}

	if (squares[x - 1][y] && squares[x - 1][y].visible)
	{
		squares[x - 1][y].DeleteAsync(0);
		squares[x - 1][y] = null;
	}

	if (squares[x][y + 1] && squares[x][y + 1].visible)
	{
		squares[x][y + 1].DeleteAsync(0);
		squares[x][y + 1] = null;
	}

	if (squares[x][y - 1] && squares[x][y - 1].visible)
	{
		squares[x][y - 1].DeleteAsync(0);
		squares[x][y - 1] = null;
	}	

	$.Schedule(0.1, FOW);
}

function UpdateCanvas() {
	$.Schedule(0.03, UpdateCanvas);
}

(function()
{
	GameEvents.SendCustomGameEventToServer( "world_bounds_request", {} );

	GameEvents.Subscribe("world_bounds", SetWorldBounds);
	// GameEvents.Subscribe("custom_minimap_event", MinimapEvent);

	if (!GameUI.CustomUIConfig().ChangeMinimapMode)
	{
		GameUI.CustomUIConfig().ChangeMinimapMode = ChangeMinimapMode; 
	}

	var mapImage = "'https://puu.sh/rzAer/92feb69948.png'";
	$("#MinimapCanvas").SetURL("about:blank");
	// Load map image
	$("#MinimapCanvas").RunJavascript("var c = document.createElement('canvas');\nc.setAttribute('id', 'myCanvas');\ndocument.body.appendChild(c);\ndocument.body.style.backgroundColor=\"#FFFFFFBB\";\nc.style.backgroundColor=\"FFFFFF\";\ndocument.body.style.margin=\"0px\";\nc.width=document.documentElement.clientWidth;\nc.height=document.documentElement.clientHeight;\nvar ctx = c.getContext(\"2d\");\nvar img = new Image();\nimg.onload=function(){ctx.drawImage(img, 0, 0, c.width, c.height);}\nimg.src = " + mapImage + ";");
	// Display player
	UpdateCanvas()

	if ($("#MinimapCanvas").FindChildTraverse("MousePanningImage")) {
		$("#MinimapCanvas").FindChildTraverse("MousePanningImage").DeleteAsync(0.0);
	}
})();