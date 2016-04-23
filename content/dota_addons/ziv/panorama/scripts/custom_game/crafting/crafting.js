"use strict";

var craftingItemPanel = null;
var selectedRecipe = null;

function Open() {
	$.GetContextPanel().AddToPanelsQueue();
	$.GetContextPanel().SetHasClass("Hide", false);
}

function CloseButton() {
	$.GetContextPanel().RemoveFromPanelsQueue();
	$.GetContextPanel().SetHasClass("Hide", true);
}

function RecipeClick( id, panel )
{
	craftingItemPanel.Update( id );
	$("#ItemDescLabel").text = $.Localize("DOTA_Tooltip_ability_"+id+"_Description");
	$("#ItemName").text = $.Localize("DOTA_Tooltip_ability_"+id);
	CreateRecipeParts(id);

	if (selectedRecipe) {
		selectedRecipe.FindChildTraverse("RecipeTitle").RemoveClass("RecipeLabelSelected");
	}
	panel.FindChildTraverse("RecipeTitle").AddClass("RecipeLabelSelected");
	selectedRecipe = panel;
}

function AddRecipe( id )
{
	var recipePanel = $.CreatePanel( "Panel", $( "#RecipesList" ), "Recipe_" + id );
	recipePanel.BLoadLayout( "file://{resources}/layout/custom_game/crafting/recipe_title.xml", false, false );

	recipePanel.SetName( $.Localize("DOTA_Tooltip_ability_"+id) )

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
	for (var key in GameUI.CustomUIConfig().recipes) 
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
		craftRequest["pID"] = Players.GetLocalPlayer();

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
	part.BLoadLayout( "file://{resources}/layout/custom_game/crafting/item_mini.xml", false, false );
	part.AddClass("recipepart-image");
	part.SetHasClass("recipepart-image", true);	

	part.Update(key);
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

	var count = Object.keys( GameUI.CustomUIConfig().recipes[id]["Recipe"] ).length;

	var i = 0;
	for (var key in GameUI.CustomUIConfig().recipes[id]["Recipe"]) 
	{
		var panelName = i < 4 ? "#RecipeRow1" : "#RecipeRow2";
		if (i % 4 != 0)
			AddPlus( $( panelName ) );		
		AddRecipeSlot( $( panelName ), i, key, GameUI.CustomUIConfig().recipes[id]["Recipe"][key] );

		i++;
	}
}

function InitSlots()
{
	craftingItemPanel = $.CreatePanel( "Panel", $( "#ItemImage" ), "CraftingItemPanel" );
	craftingItemPanel.BLoadLayout( "file://{resources}/layout/custom_game/crafting/item_mini.xml", false, false );
	
	// CreateRecipeParts( 8 );
}

(function()
{
	InitSlots();
	FillRecipesList(); 

	GameEvents.Subscribe( "ziv_open_crafting", Open );
})();

