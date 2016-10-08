var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;


var maxXOffset = 200;
var maxYOffset = 200;

function ItemCheck()
{
  var wp = $.GetContextPanel().WorldPanel;
  var offScreen = $.GetContextPanel().OffScreen;
  if (!offScreen && wp && Entities.IsItemPhysical(wp.entity)){
    var ent = wp.entity;
    if (ent){
      // Smooth in small square
      var worldPos = Entities.GetAbsOrigin( ent );
      if (worldPos)
      {
        var scrX = Game.WorldToScreenX( worldPos[0], worldPos[1], worldPos[2] );
        var scrY = Game.WorldToScreenY( worldPos[0], worldPos[1], worldPos[2] );
        var transConstr = 
          Math.abs($.GetContextPanel().X - scrX) < $.GetContextPanel().Width + maxXOffset && 
          Math.abs($.GetContextPanel().Y - scrY) < $.GetContextPanel().Height + maxYOffset;

        $.GetContextPanel().SetHasClass("Transition", transConstr);
      }

      var itemData = PlayerTables.GetTableValue("items", parseInt(wp.data["item_entity"]));
      if (itemData) {
        $("#ItemNameLabel").AddClass("Rarity" + itemData.rarity);
        $("#ItemNameLabel").text = Util.SpanString($.Localize("DOTA_Tooltip_ability_" + wp.data["name"]), "Rarity" + itemData.rarity);
      }

      $.GetContextPanel().SetHasClass("Hide", GameUI.IsAltDown() == false)
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

function Hover()
{
  var wp = $.GetContextPanel().WorldPanel;  
  var offScreen = $.GetContextPanel().OffScreen;
  var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
  if (!offScreen && wp) {
    // GameUI.CustomUIConfig().ShowItemTooltip($.GetContextPanel(), parseInt(wp.data["item_entity"]));
  }
}

function Leave()
{
  // GameUI.CustomUIConfig().HideItemTooltip($.GetContextPanel());
}

(function()
{ 
  ItemCheck();
})();