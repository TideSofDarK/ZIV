//$.Msg("item");
var maxXOffset = 200;
var maxYOffset = 200;

function ItemCheck()
{
  var wp = $.GetContextPanel().WorldPanel;
  var offScreen = $.GetContextPanel().OffScreen;
  if (!offScreen && wp){
    var ent = wp.entity;
    if (ent){
      $.GetContextPanel().SetHasClass("Hide", GameUI.IsAltDown() == false)

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

      $("#ItemNameLabel").text = $.Localize("DOTA_Tooltip_ability_" + wp.data["name"]);
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
  if (!offScreen && wp)
    GameEvents.SendEventClientSide( "ziv_open_side_item_desc", { "entity": wp.entity, "name": wp.data["name"] } );
}

function Leave()
{
  GameEvents.SendEventClientSide( "ziv_close_side_item_desc", null);
}

(function()
{ 
  ItemCheck();
})();