"use strict";

var m_BuffPanels = []; // created up to a high-water mark, but reused

function OnEquipmentButtonClicked()
{
	 $( "#equip_list" ).visible = $( "#equip_list" ).visible == false;
}

function UpdateBuff( buffPanel, itemName )
{
	var itemImage = buffPanel.FindChildInLayoutFile( "ItemImage" );
	// itemImage.itemname = "item_" + buffPanel.id;

	if (itemName == "") 
	{
		buffPanel.style.backgroundImage = "url(\'file://{images}/custom_game/ingame_ui/slots/" + buffPanel.id + ".png\');";
		itemImage.style.visibility = "collapse;"
	}
	else
	{
		itemImage.itemname = "item_" + itemName;
		itemImage.style.visibility = "visible;"
	}

	// $.Msg("url(\'file://{images}/items/" + buffPanel.id + ".png\');");

	// $.Msg("item_" + buffPanel.id);

	return;
}

function UpdateBuffs()
{
	var buffsListPanel = $( "#equip_list" );
	if ( !buffsListPanel )
		return;

	var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );

	var heroKV = CustomNetTables.GetTableValue( "hero_kvs", Entities.GetUnitName( queryUnit )+"_ziv" );
	var slots = heroKV["EquipmentSlots"].split(';');
	
	var nBuffs = Entities.GetNumBuffs( queryUnit );

	// for (var x = 0; x < slots.length; x++) {
	// 	if (Buffs.GetName(m_BuffPanels[x].m_QueryUnit, m_BuffPanels[x].m_BuffSerial) == "") {
	// 		m_BuffPanels[x].RemoveAndDeleteChildren();
	// 		m_BuffPanels.splice(x, 1);
	// 		x--;
	// 	}
	// }

	// update all the panels
	for ( var i = 0; i < Math.max(slots.length, nBuffs); ++i )
	{
		var present = false;
		if (m_BuffPanels.length == slots.length)
		{
			var buffSerial = Entities.GetBuff( queryUnit, i );

			var buffName = Buffs.GetName(queryUnit, buffSerial);

			var itemName = "";
			var slot = "";

			if (buffName.contains("_equipped_")) {
				itemName = buffName.replace("modifier_", "");
				slot = itemName.substring(itemName.indexOf("_equipped_"), itemName.length).replace("_equipped_","");
				itemName = itemName.substring(0, itemName.indexOf("_equipped"));
			}

			for (var x = 0; x < m_BuffPanels.length; x++) {
				if (m_BuffPanels[x].id == slot) {
					present = true;

					UpdateBuff( m_BuffPanels[x], itemName );
					break;
				}
			}
		}
		else if ( present == false )
		{
			// create a new panel
			var buffPanel = $.CreatePanel( "Panel", buffsListPanel, slots[i]);
			buffPanel.BLoadLayout( "file://{resources}/layout/custom_game/equip_list_buff.xml", false, false );
			m_BuffPanels.push( buffPanel );

			UpdateBuff( buffPanel, "" );
		}
	}

	
}

function AutoUpdateBuffs()
{
	UpdateBuffs();
	$.Schedule( 0.03, AutoUpdateBuffs );
}

(function()
{
	String.prototype.contains = function(it) { return this.indexOf(it) != -1; };

	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateBuffs );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateBuffs );
	
	AutoUpdateBuffs(); // initial update of dynamic state
})();

