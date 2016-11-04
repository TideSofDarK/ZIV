var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

function item( panel ) {
  panel.SetPanelEvent("onactivate", function() { 
      var order = {
        OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_PICKUP_ITEM,
        TargetIndex : panel.Entity,
        Queue : false,
        ShowEffects : false
      };
      Game.PrepareUnitOrders( order );
  });

  panel.ItemCheck = function() {
    var offScreen = panel.OffScreen;
    var entity = panel.Entity;
    
    if (entity && !offScreen && Entities.IsItemPhysical(entity)){
      var itemData = PlayerTables.GetTableValue("items", parseInt(panel.Data["item_entity"]));
      var itemBase = $.Localize("DOTA_Tooltip_ability_" + panel.Data["name"]);
      if (itemData) {
        panel.FindChildTraverse("ItemCaptionLabel").text = itemBase;
        if (panel.Data["name"].match("item_rune_")) {
          panel.AddClass("RarityBorderRune");
          panel.FindChildTraverse("ItemCaptionLabel").AddClass("Rarity1");
        } else if (panel.Data["name"].match("item_forging_")) {
          panel.AddClass("RarityBorderForging");
          panel.FindChildTraverse("ItemCaptionLabel").AddClass("RarityForging");
        } else {
          panel.FindChildTraverse("ItemButton").AddClass("RarityBorder" + itemData.rarity);
          panel.FindChildTraverse("ItemCaptionLabel").AddClass("Rarity" + itemData.rarity);
        }

        if (itemData.caption) {
          panel.FindChildTraverse("ItemCaptionLabel").text = itemData.caption;
        }
      }
    }
  }
  // Init item data
  $.Schedule(0.2, panel.ItemCheck);
}

handlers.item = item;