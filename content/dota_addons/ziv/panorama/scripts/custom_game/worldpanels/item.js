var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

var hidden = true;

var maxXOffset = 200;
var maxYOffset = 200;

function ItemCheck()
{
  var wp = $.GetContextPanel().WorldPanel;
  var offScreen = $.GetContextPanel().OffScreen;
  if (!offScreen && wp && Entities.IsItemPhysical(wp.entity)){
    var ent = wp.entity;
    if (ent){
      var itemData = PlayerTables.GetTableValue("items", parseInt(wp.data["item_entity"]));
      var itemBase = $.Localize("DOTA_Tooltip_ability_" + wp.data["name"]);
      if (itemData) {
        $("#ItemCaptionLabel").text = itemBase;
        if (wp.data["name"].match("item_rune_")) {
          $.GetContextPanel().AddClass("RarityBorderRune");
        } else if (wp.data["name"].match("item_forging_")) {
          $.GetContextPanel().AddClass("RarityBorderForging");
        } else {
          $("#ItemButton").AddClass("RarityBorder" + itemData.rarity);
          $("#ItemCaptionLabel").AddClass("Rarity" + itemData.rarity);
        }

        if (itemData.caption) {
          $("#ItemCaptionLabel").text = itemData.caption;
        }
      }
      if (hidden && GameUI.IsAltDown()) {
        hidden = false;
      } else if (!hidden && GameUI.IsAltDown()) {
        $.GetContextPanel().SetHasClass("Hide", false)
      } else {
        $.GetContextPanel().SetHasClass("Hide", true)
      }
    }
  }

  $.Schedule(1/30, ItemCheck);
}

function Click() {
  var wp = $.GetContextPanel().WorldPanel
  var order = {
    OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_PICKUP_ITEM,
    TargetIndex : wp.entity,
    Queue : false,
    ShowEffects : false
  };
  Game.PrepareUnitOrders( order );
}

(function()
{ 
  ItemCheck();
})();