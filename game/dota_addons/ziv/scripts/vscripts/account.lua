if not Account then
	_G.Account = class({})
end

Account.SETTINGS = LoadKeyValues('scripts/kv/Account.kv')
Account.REWARDS = LoadKeyValues('scripts/kv/AccountRewards.kv')

Account.EXP_PER_LEVEL = Account.SETTINGS.EXP_PER_LEVEL
Account.LEVELS_PER_TIER = Account.SETTINGS.LEVELS_PER_TIER
Account.MAX_LEVEL = Account.SETTINGS.MAX_LEVEL

Account.TIER_WOOD 		= 1
Account.TIER_BRONZE 	= 2
Account.TIER_SILVER 	= 3
Account.TIER_GOLD 		= 4
Account.TIER_PLATINUM 	= 5

function Account:Init()
	PlayerTables:CreateTable("accounts", GeneratePlayerArray({exp = 1}), true)

	ListenToGameEvent('game_rules_state_change', 
		function(keys)
			local state = GameRules:State_Get()

			if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
				Account:FetchPlayerData(  )
			end
		end, 
	nil)
end

function Account:FetchPlayerData(  )
	DoToAllPlayers(function ( player )
		SU:LoadPlayerData( { PlayerID = player:GetPlayerID() } )
	end)
end

function Account:GetEXP( pID )
	return PlayerTables:GetTableValue("accounts", pID).exp
end

function Account:GetLevel( pID )
	return Account:GetLevelByEXP( Account:GetEXP( pID ) )
end

function Account:GetLevelByEXP( exp )
	if not exp or type(exp) ~= 'number' then return 1 end

	return math.max(math.floor(exp / Account.EXP_PER_LEVEL), 0) + 1
end

function Account:GetTierByLevel( level )
	if not level or type(level) ~= 'number' then return 1 end

	level = math.min(level, Account.MAX_LEVEL)

	return math.max(math.floor(level / Account.LEVELS_PER_TIER), Account.TIER_WOOD)
end

function Account:AddEXP( pID, amount )
	local exp = PlayerTables:GetTableValue("accounts", pID).exp
	
	local level = Account:GetLevelByEXP( exp )

	exp = exp + amount

	PlayerTables:SetSubTableValue("accounts", pID, "exp", exp)
	print(Account:GetLevelByEXP( exp ))
	if Account:GetLevelByEXP( exp ) > level then
		Account:LevelUp( pID )
	end
end

function Account:AddCreepEXP( pID )
	Account:AddEXP( pID, Account:GetCreepBounty() )
end

function Account:AddBossEXP( pID )
	Account:AddEXP( pID, Account:GetBossBounty() )
end

function Account:AddHeroEXP( pID )
	Account:AddEXP( pID, Account:GetHeroBounty() )
end

function Account:GetCreepBounty()
	return RandomInt(Account.SETTINGS.CreepEXPMin,Account.SETTINGS.CreepEXPMax)
end

function Account:GetBossBounty()
	return RandomInt(Account.SETTINGS.BossEXPMin,Account.SETTINGS.BossEXPMax)
end

function Account:GetHeroBounty()
	return RandomInt(Account.SETTINGS.HeroEXPMin,Account.SETTINGS.HeroEXPMax)
end

function Account:LevelUp( pID )
	local hero = Characters.current_session_characters[pID]

	if hero then
		-- TODO
		-- Particles

		local level = Account:GetLevel( pID )
		for k,v in pairs(Account.REWARDS[tostring(level)]) do
			if self[v] then
				self[v](self, pID)
			end
		end
	end

	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pID), "ziv_account_levelup", {})
end

function Account:SmallTreasure( pID )
	Account:TreasureReward( pID, "SmallTreasure" )
end

function Account:BigTreasure( pID )
	Account:TreasureReward( pID, "BigTreasure" )
end

function Account:TreasureReward( pID, size )
	local hero = Characters.current_session_characters[pID]

	local container = Containers:CreateContainer({
		layout 			= {3,3},
		skins 			= {size},
		headerText 		= "",
		pids 			= {pID},
		entity 			= hero,
		closeOnOrder 	= false,
		position 		= "25% 25%",
		OnDragWorld 	= true,
	-- 	OnDragTo = (function (playerID, container, unit, item, fromSlot, toContainer, toSlot) 
	-- 		local item2 = toContainer:GetItemInSlot(toSlot)
	-- 		local addItem = nil
	-- 		if item2 and IsValidEntity(item2) and (item2:GetAbilityName() ~= item:GetAbilityName() or not item2:IsStackable() or not item:IsStackable()) then
	-- 			if Containers.itemKV[item2:GetAbilityName()].ItemCanChangeContainer == 0 then
	-- 				return false
	-- 			end
	-- 			toContainer:RemoveItem(item2)
	-- 			addItem = item2

	-- 			if unit.equipment.id == container.id then
	-- 				local toSlotName = KeyValues:Split(ZIV.HeroesKVs[unit:GetUnitName()]["EquipmentSlots"], ';')[fromSlot]

	-- 				if ZIV.ItemKVs[addItem:GetName()]["Slot"] and string.match(toSlotName, ZIV.ItemKVs[addItem:GetName()]["Slot"]) then
	-- 					Equipment:Equip( unit, addItem )
	-- 				end
	-- 			end
	-- 		end

	-- 		if toContainer:AddItem(item, toSlot) then
	-- 			container:ClearSlot(fromSlot)
	-- 			if addItem then
	-- 				if container:AddItem(addItem, fromSlot) then
	-- 					return true
	-- 				else
	-- 					toContainer:RemoveItem(item)
	-- 					toContainer:AddItem(item2, toSlot, nil, true)
	-- 					container:AddItem(item, fromSlot, nil, true)
	-- 					return false
	-- 				end
	-- 			end
	-- 			return true
	-- 		elseif addItem then
	-- 			toContainer:AddItem(item2, toSlot, nil, true)
	-- 		end

	-- 		return false 
	-- 	end)
	})

	for k,v in pairs(Account.SETTINGS[size]) do
		for _,item_table in pairs(v) do
			container:AddItem(Loot:CreateItem( hero, Loot[item_table.ItemType], Loot[item_table.Rarity], nil ))
		end
	end

	container:Open(pID)
end