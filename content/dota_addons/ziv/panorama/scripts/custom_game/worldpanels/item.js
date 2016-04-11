$.Msg("item");

function ItemCheck()
{
  var wp = $.GetContextPanel().WorldPanel
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

(function()
{ 
  ItemCheck();
})();