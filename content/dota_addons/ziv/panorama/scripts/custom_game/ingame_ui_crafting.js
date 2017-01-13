"use strict";

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

var craftingItemPanel = null;
var selectedRecipe = null;

var progressBarWidth = 700;
var progressBarDelay = 1.1;

function Open() {
	$.GetContextPanel().AddToPanelsQueue();
	$.GetContextPanel().SetHasClass("WindowClosed", false);
}

function CloseButton() {
	$.GetContextPanel().RemoveFromPanelsQueue();
	$.GetContextPanel().SetHasClass("WindowClosed", true);
}

function OpenRecycleTab() {
	$("#RecycleTab").SetHasClass("ActiveTab", true);
	$("#ItemNameTab").SetHasClass("ActiveTab", false);

	$("#RecycleTabContent").visible = true;
	$("#ItemNameTabContent").visible = false;
}

function OpenCraftTab() {
	$("#RecycleTab").SetHasClass("ActiveTab", false);
	$("#ItemNameTab").SetHasClass("ActiveTab", true);

	$("#RecycleTabContent").visible = false;
	$("#ItemNameTabContent").visible = true;
}

function RecycleButton() {
	
	GameEvents.SendCustomGameEventToServer( "ziv_recycle_request", {} );
}

function ConfirmProgress(args) {
	var actualDuration = args.duration * progressBarDelay;

	StartProgress(actualDuration)

	$.Schedule(actualDuration, function () {
		Game.EmitSound("ui.crafting_confirm_socket");
	})

	Game.EmitSound("ui.crafting_slotslide");
}

function StartProgress(duration) {
	$("#ProgressBarGreen").style.transitionDuration = 0 + "s;";
	$("#ProgressBarMarker").style.transitionDuration = 0 + "s;";

	Util.SetProgressBarPercentage($("#ProgressBarGreen"), $("#ProgressBarMarker"), 0.0, progressBarWidth);

	$("#ProgressBarGreen").style.transitionDuration = duration + "s;";
	$("#ProgressBarMarker").style.transitionDuration = duration + "s;";

	Util.SetProgressBarPercentage($("#ProgressBarGreen"), $("#ProgressBarMarker"), 1.0, progressBarWidth);
}

function RecipeClick( id, panel )
{
	var rarity = id.substring(id.length - 1, id.length);

	craftingItemPanel.Update( "item_" + id.substring(0, id.length - 2), parseInt(rarity) );
	craftingItemPanel.FindChildTraverse("ItemImage").style.border = "3px solid " + $.Localize("rarity" + rarity + "_color") + ";";

	var possibleResults = PlayerTables.GetTableValue("kvs", "recipes")[id].PossibleResults;
	var possibleResultsString = "";
	for (var result in possibleResults) { 
		possibleResultsString = possibleResultsString + "<br>" + "  <font color=\"#ffffff\">• " + $.Localize("DOTA_Tooltip_ability_" + result) + "</font>";
	}

	$("#ItemDescLabel").SetDialogVariable("rarity", $.Localize("rarity"+rarity));
    $("#ItemDescLabel").SetDialogVariable("slot", $.Localize(id.substring(0, id.length - 2)));
    $("#ItemDescLabel").SetDialogVariable("color", $.Localize("rarity" + rarity + "_color"));
    $("#ItemDescLabel").html = true;
    $("#ItemDescLabel").text = $.Localize("craft_description", $("#ItemDescLabel")) + "<br>" + possibleResultsString;

	CreateRecipeParts(id);

	if (selectedRecipe) {
		selectedRecipe.FindChildTraverse("RecipeTitle").RemoveClass("RecipeLabelSelected");
	}
	panel.FindChildTraverse("RecipeTitle").AddClass("RecipeLabelSelected");
	selectedRecipe = panel;

	OpenCraftTab();
}

function AddRecipe( id )
{
	var rarity = id.substring(id.length - 1, id.length);

	var recipePanel = $.CreatePanel( "Panel", $( "#RecipesList" ), "Recipe_" + id );
	recipePanel.BLoadLayoutSnippet("RecipeTitle");
	recipePanel.FindChildTraverse("RecipeTitle").text = $.Localize("rarity"+rarity) + ' ' + $.Localize(id.substring(0, id.length - 2));
	recipePanel.FindChildTraverse("RecipeTitle").SetHasClass("Rarity"+rarity, true);

	var click = (function() { 
				return function() {
					RecipeClick( id, recipePanel );	
				}
			}(recipePanel));

	recipePanel.SetPanelEvent("onmouseactivate", click);

	if (selectedRecipe == null) 
	{
		selectedRecipe = recipePanel;
		RecipeClick( id, selectedRecipe )
	}
}

function FillRecipesList()
{
	for (var key in PlayerTables.GetTableValue("kvs", "recipes")) 
	{
		AddRecipe( key ); 
	}
}

function CraftButton() 
{
	if (selectedRecipe) 
	{
		var craftRequest = {}
		craftRequest["item"] = selectedRecipe.id;

		GameEvents.SendCustomGameEventToServer( "ziv_craft_request", craftRequest );
	}
}

/*
 *   Search
 */

function SearchHover()
{
	if ($( "#Search" ).text == "search..."/*$.Localize( "#exchange_bet_text" )*/ )
		$( "#Search" ).text = "";
}

function SearchStopHover()
{
	if ($( "#Search" ).text == "" && !$( "#Search" ).BHasKeyFocus())
		$( "#Search" ).text = "search...";//$.Localize( "#exchange_bet_text" );
}

function SearchRecipes()
{
	var searchText = $( "#Search" ).text;
	if (searchText == "")
		searchText = ".*";

	var regex = new RegExp(searchText, "i")

	var childCount = $( "#RecipesList" ).GetChildCount();

	for (var i = 0; i < childCount; i++) {
		var recipe = $( "#RecipesList" ).GetChild(i);
		var match = recipe.FindChild( "RecipeTitle" ).text.match(regex);
		recipe.visible = match != null || match != undefined;
	} 
}

/*
 *   Update info
 */

function UpdateInfo()
{

}

/*
 *   Item images init
 */
function AddRecipeSlot( parent, num, key, count )
{
	var part = $.CreatePanel( "Panel", parent, "RecipePart_" + num );
	part.BLoadLayout( "file://{resources}/layout/custom_game/ingame_ui_item.xml", false, false );
	part.AddClass("recipepart-image");
	part.SetHasClass("recipepart-image", true);	

	part.Update(key, 1);
	part.SetCount(count);
}

function AddPlus( parent )
{
	var plusPanel = $.CreatePanel( "Label", parent, "" );
	plusPanel.AddClass("recipe-plus");
	plusPanel.SetHasClass("recipe-plus", true);	
	plusPanel.text = "+";
}

function CreateRecipeParts( id )
{
	$( "#RecipeRow1" ).RemoveAndDeleteChildren();
	$( "#RecipeRow2" ).RemoveAndDeleteChildren();

	var recipe = PlayerTables.GetTableValue("kvs", "recipes")[id]["Parts"]

	var count = recipe.length;

	$( "#RecipeRow2" ).visible = count > 4;

	var i = 0;
	for (var key in recipe) 
	{
		var panelName = i < 4 ? "#RecipeRow1" : "#RecipeRow2";
		if (i % 4 != 0) {
			AddPlus( $( panelName ) );		
		}

		AddRecipeSlot($( panelName ), i, key, recipe[key]);

		i++;
	}
}

function InitSlots()
{
	craftingItemPanel = $.CreatePanel( "Panel", $( "#ItemDescImage" ), "CraftingItemPanel" );
	craftingItemPanel.BLoadLayout( "file://{resources}/layout/custom_game/ingame_ui_item.xml", false, false );
	craftingItemPanel.SetHasClass("CraftingItemPanel", true);
	
	// CreateRecipeParts( 8 );
}

(function()
{
	PlayerTables.SubscribeNetTableListener('characters', function (name, changes, dels) {
		if (changes["containers"]) {
			Util.RemoveChildren($("#RecycleItems"));
			Util.RemoveChildren($("#CraftingItems"));
			GameUI.CustomUIConfig().OpenContainer({"id" : PlayerTables.GetTableValue("characters", "containers")[Game.GetLocalPlayerID()].recycleContainerID, "panel" : $("#RecycleItems")});
			GameUI.CustomUIConfig().OpenContainer({"id" : PlayerTables.GetTableValue("characters", "containers")[Game.GetLocalPlayerID()].craftingContainerID, "panel" : $("#CraftingItems")});
		}
	});

	InitSlots();
	FillRecipesList(); 

	Util.SetProgressBarPercentage($("#ProgressBarGreen"), $("#ProgressBarMarker"), 0.0, progressBarWidth);

	GameEvents.Subscribe( "ziv_open_crafting", Open );
	GameEvents.Subscribe( "ziv_recycle_confirm", ConfirmProgress)
	GameEvents.Subscribe( "ziv_craft_confirm", ConfirmProgress)
})();

