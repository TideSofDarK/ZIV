//$.Msg("item");

function ItemCheck()
{
  var wp = $.GetContextPanel().WorldPanel;
  var offScreen = $.GetContextPanel().OffScreen;
  if (!offScreen && wp){
    var ent = wp.entity;
    if (ent){
      $.GetContextPanel().SetHasClass("Hide", GameUI.IsAltDown() == false)
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
    GameEvents.SendEventClientSide( "ziv_open_side_item_desc", { "entity": wp.entity } );
}

function Leave()
{
  GameEvents.SendEventClientSide( "ziv_close_side_item_desc", null);
}

(function()
{ 
  ItemCheck();
})();