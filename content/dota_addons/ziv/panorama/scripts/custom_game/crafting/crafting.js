"use strict";

var craftingItemPanel = null;

function Open() {
	$.GetContextPanel().SetHasClass("Hide", false);
}

function CloseButton() {
	$.GetContextPanel().SetHasClass("Hide", true);
}

function RecipeClick( id )
{
	$.Msg("Recipe " + id + " clicked!");

	$.Msg(craftingItemPanel.id)
	craftingItemPanel.Update( 0 );
}

function AddRecipe( id )
{
	var recipePanel = $.CreatePanel( "Panel", $( "#RecipesList" ), "Recipe_" + id );
	recipePanel.BLoadLayout( "file://{resources}/layout/custom_game/crafting/recipe_title.xml", false, false );

	recipePanel.SetName( "Name " + id )

	var click = (function() { 
				return function() {
					RecipeClick( id );	
				}
			}(recipePanel));

	recipePanel.SetPanelEvent("onmouseactivate", click);
}

function FillRecipesList()
{
	for (var i = 0; i < 50; i++)
		AddRecipe( i );   
}

/*
 *   Search
 */

function SearchHover()
{
	if ($( "#Search" ).text == "Type here..."/*$.Localize( "#exchange_bet_text" )*/ )
		$( "#Search" ).text = "";
}

function SearchStopHover()
{
	if ($( "#Search" ).text == "" && !$( "#Search" ).BHasKeyFocus())
		$( "#Search" ).text = "Type here...";//$.Localize( "#exchange_bet_text" );
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
function AddRecipeSlot( parent, num )
{
	var part = $.CreatePanel( "Panel", parent, "RecipePart_" + num );
	part.BLoadLayout( "file://{resources}/layout/custom_game/crafting/item_mini.xml", false, false );
	part.AddClass("recipepart-image");
	part.SetHasClass("recipepart-image", true);	
}

function AddPlus( parent )
{
	var plusPanel = $.CreatePanel( "Label", parent, "" );
	plusPanel.AddClass("recipe-plus");
	plusPanel.SetHasClass("recipe-plus", true);	
	plusPanel.text = "+";
}

function CreateRecipeParts( count )
{
	$( "#RecipeRow1" ).RemoveAndDeleteChildren();
	$( "#RecipeRow2" ).RemoveAndDeleteChildren();

	for (var i = 0; i < count; i++) {
		var panelName = i < 4 ? "#RecipeRow1" : "#RecipeRow2";
		AddRecipeSlot( $( panelName ), i );
	}
}

function InitSlots()
{
	craftingItemPanel = $.CreatePanel( "Panel", $( "#ItemImage" ), "CraftingItemPanel" );
	craftingItemPanel.BLoadLayout( "file://{resources}/layout/custom_game/crafting/item_mini.xml", false, false );
	
	CreateRecipeParts( 6 );
}

(function()
{
	InitSlots();

	FillRecipesList(); 

	GameEvents.Subscribe( "ziv_open_crafting", Open );
})();

