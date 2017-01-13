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
	for k,v in pairs(GeneratePlayerArray({exp = 1})) do
		print(type(k))
	end
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
		hero:EmitSound("ui.trophy_levelup")
		TimedEffect("particles/ziv_levelup.vpcf", hero, 5.0)

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
		buttons 		= {"Grab All"},
		headerText 		= "",
		pids 			= {pID},
		entity 			= hero,
		closeOnOrder 	= false,
		position 		= "25% 25%",
		OnDragWorld 	= true,
		OnButtonPressed = function(playerID, container, unit, button, buttonName)
			if button == 1 then
				local items = container:GetAllItems()
				for _,item in ipairs(items) do
					container:RemoveItem(item)
					Containers:AddItemToUnit(unit,item)
				end

				container:Close(playerID)
			end
		end,
		OnDragTo = (function (playerID, container, unit, item, fromSlot, toContainer, toSlot) 
			return false 
		end)
	})

	for k,v in pairs(Account.SETTINGS[size]) do
		for _,item_table in pairs(v) do
			container:AddItem(Loot:CreateItem( hero, Loot[item_table.ItemType], Loot[item_table.Rarity], nil ))
		end
	end

	container:Open(pID)
end