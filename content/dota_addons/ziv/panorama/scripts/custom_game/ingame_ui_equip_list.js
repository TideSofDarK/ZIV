"use strict";

var m_BuffPanels = []; // created up to a high-water mark, but reused

function UpdateBuff( buffPanel )
{
	$.Schedule(0.1, function () {
		buffPanel.Update()
	})

	var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );

	for ( var i = 0; i < Entities.GetNumBuffs( queryUnit ); ++i )
	{
		var buffSerial = Entities.GetBuff( queryUnit, i );

		var buffName = Buffs.GetName(queryUnit, buffSerial);

		var itemName;
		var slot;

		if (buffName.contains("_equipped_")) {
			itemName = buffName.replace("modifier_", "");
			slot = itemName.substring(itemName.indexOf("_equipped_"), itemName.length).replace("_equipped_","");
			itemName = itemName.substring(0, itemName.indexOf("_equipped"));
		}

		if (itemName && slot && buffPanel.id == slot)
		{
			buffPanel.m_BuffName = buffName;
			buffPanel.m_BuffSerial = buffSerial;

			if (itemName == "") 
			{
				buffPanel.m_ItemImage.style.visibility = "collapse;"
			}
			else
			{
				buffPanel.m_ItemImage.itemname = "item_" + itemName;
				buffPanel.m_ItemImage.style.visibility = "visible;"
			}
			return;
		}
	}

	buffPanel.m_ItemImage.style.visibility = "collapse;"
}

function UpdateBuffs()
{
	var buffsListPanel = $( "#equip_list" );
	if ( !buffsListPanel )
		return;

	var children = buffsListPanel.Children();

	for (var i = 0; i < children.length; i++) {
		children[i].DeleteAsync(0.0);
	}

	var queryUnit = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );

	var heroKV = CustomNetTables.GetTableValue( "hero_kvs", Entities.GetUnitName( queryUnit )+"_ziv" );
	var slots = heroKV["EquipmentSlots"].split(';');
	
	var nBuffs = Entities.GetNumBuffs( queryUnit );

	for ( var i = 0; i < slots.length; ++i )
	{
		var buffPanel = $.CreatePanel( "Panel", buffsListPanel, slots[i]);
		buffPanel.BLoadLayout( "file://{resources}/layout/custom_game/equip_list_buff.xml", false, false );
		m_BuffPanels.push( buffPanel );

		buffPanel.AddClass(slots[i]);

		buffPanel.style.backgroundImage = "url(\'file://{images}/custom_game/ingame_ui/slots/" + slots[i] + ".png\');";

		buffPanel.Update = function() {
			UpdateBuff(this);	
		};

		buffPanel.Update();
	}
}

function GetVectorFromStylePosition(posString) {
	if (!posString) return [0,0,0]
	var splitted = posString.split(" ");
	var vector = []
	for (var i = 0; i < splitted.length; i++) {
		vector[i] = parseInt(splitted[i]);
	}
	return vector
}

function Open()
{
	if (m_BuffPanels.length == 0) UpdateBuffs();
	// $.GetContextPanel().style.visibility = $.GetContextPanel().style.visibility == "collapse" ? "visible;" : "collapse;";

	for (var i = 0; i < m_BuffPanels.length; i++) {
		var id = m_BuffPanels[i].id;
		m_BuffPanels[i].SetHasClass(id, m_BuffPanels[i].BHasClass(id) == false)
		// m_BuffPanels[i].RemoveClass("HiddenBuff")
	}
}

(function()
{
	String.prototype.contains = function(it) { return this.indexOf(it) != -1; };

	// GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateBuffs );
	// GameEvents.Subscribe( "dota_player_update_query_unit", UpdateBuffs );

	GameEvents.Subscribe( "ziv_open_equipment", Open );
	
	// AutoUpdateBuffs(); // initial update of dynamic state
})();

