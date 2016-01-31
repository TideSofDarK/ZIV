"use strict";

var m_BuffPanels = []; // created up to a high-water mark, but reused

function OnEquipmentButtonClicked()
{
	 $( "#buffs_list" ).visible = $( "#buffs_list" ).visible == false;
}

function UpdateBuff( buffPanel, queryUnit, buffSerial )
{
	var noBuff = ( buffSerial == -1 );
	buffPanel.SetHasClass( "no_buff", noBuff );
	buffPanel.m_QueryUnit = queryUnit;
	buffPanel.m_BuffSerial = buffSerial;
	if ( noBuff )
	{
		return;
	}
	
	var nNumStacks = Buffs.GetStackCount( queryUnit, buffSerial );
	buffPanel.SetHasClass( "is_debuff", Buffs.IsDebuff( queryUnit, buffSerial ) );
	buffPanel.SetHasClass( "has_stacks", ( nNumStacks > 0 ) );

	var stackCount = buffPanel.FindChildInLayoutFile( "StackCount" );
	var itemImage = buffPanel.FindChildInLayoutFile( "ItemImage" );
	var abilityImage = buffPanel.FindChildInLayoutFile( "AbilityImage" );
	if ( stackCount )
	{
		stackCount.text = nNumStacks;
	}
	
	var buffTexture = Buffs.GetTexture( queryUnit, buffSerial );

	if (buffTexture) {
		buffPanel.buffTexture = buffTexture;
	}
	else if (buffPanel.buffTexture)
	{
		buffTexture = buffPanel.buffTexture;
	}

	var itemIdx = buffTexture.indexOf( "item_" );
	if ( itemIdx === -1 )
	{
		if ( itemImage ) itemImage.itemname = "";
		if ( abilityImage ) abilityImage.abilityname = buffTexture;
		buffPanel.SetHasClass( "item_buff", false );
		buffPanel.SetHasClass( "ability_buff", true );
	}
	else
	{
		if ( itemImage ) itemImage.itemname = buffTexture;
		if ( abilityImage ) abilityImage.abilityname = "";
		buffPanel.SetHasClass( "item_buff", true );
		buffPanel.SetHasClass( "ability_buff", false );
	}
}

function UpdateBuffs()
{
	var buffsListPanel = $( "#buffs_list" );
	if ( !buffsListPanel )
		return;

	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	
	var nBuffs = Entities.GetNumBuffs( queryUnit );

	for (var x = 0; x < m_BuffPanels.length; x++) {
		if (Buffs.GetName(m_BuffPanels[x].m_QueryUnit, m_BuffPanels[x].m_BuffSerial) == "") {
			m_BuffPanels[x].RemoveAndDeleteChildren();
			m_BuffPanels.splice(x, 1);
			x--;
		}
	}
	
	// update all the panels
	for ( var i = 0; i < nBuffs; ++i )
	{

		var buffSerial = Entities.GetBuff( queryUnit, i );

		var buffName = Buffs.GetName(queryUnit, buffSerial);

		if ( buffName.contains("_equipped_") == false )
			continue;

		if ( buffSerial == -1 )
			continue;

		var present = false;
		for (var x = 0; x < m_BuffPanels.length; x++) {
			if (m_BuffPanels[x].m_BuffSerial == buffSerial) {
				present = true;

				UpdateBuff( m_BuffPanels[x], queryUnit, buffSerial );
				break;
			}
		}
		
		if ( present == false )
		{
			// create a new panel
			var buffPanel = $.CreatePanel( "Panel", buffsListPanel, "" );
			buffPanel.BLoadLayout( "file://{resources}/layout/custom_game/buff_list_buff.xml", false, false );
			m_BuffPanels.push( buffPanel );

			UpdateBuff( buffPanel, queryUnit, buffSerial );
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

