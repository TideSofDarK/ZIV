if not Trade then
    Trade = class({})
end

Trade.TRADE_CONTAINERS = {}

function Trade:Init()
	CustomGameEventManager:RegisterListener("ziv_trade_request", Dynamic_Wrap(Trade, 'TradeRequest'))
	CustomGameEventManager:RegisterListener("ziv_accept_trade_request", Dynamic_Wrap(Trade, 'AcceptRequest'))

	Convars:RegisterCommand( "tt",  Dynamic_Wrap(Trade, 'TestTrade'), "", FCVAR_CHEAT )
end

function Trade:TestTrade()
	Trade:TradeRequest({PlayerID = 0, target = 1})
end

function Trade:TradeRequest(args)
	local initiator = args.PlayerID
	local target = args.target

	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(target), "ziv_transmit_trade_request", {initiator = initiator})
end

function Trade:AcceptRequest(args)
	local initiator = args.initiator
	local accepter = args.PlayerID

	Trade.TRADE_CONTAINERS[initiator] = Containers:CreateContainer({
		layout 			= {6,6},
		skins 			= {"Trade"},
		position 		= "0px 0px",
		pids 			= {initiator},
		entity 			= PlayerResource:GetPlayer(initiator):GetAssignedHero(),
		closeOnOrder 	= false,
		OnDragWorld 	= false
    })

	Trade.TRADE_CONTAINERS[accepter] = Containers:CreateContainer({
		layout 			= {6,6},
		skins 			= {"Trade"},
		position 		= "0px 0px",
		pids 			= {accepter},
		entity 			= PlayerResource:GetPlayer(accepter):GetAssignedHero(),
		closeOnOrder 	= false,
		OnDragWorld 	= false
    })

	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(initiator)), "ziv_open_trade", {items = Trade.TRADE_CONTAINERS[initiator].id, offer = Trade.TRADE_CONTAINERS[accepter].id})

	if initiator ~= accepter then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(accepter)), "ziv_open_trade", {items = Trade.TRADE_CONTAINERS[accepter].id, offer = Trade.TRADE_CONTAINERS[initiator].id})
	end
end

function Trade:CancelTrade(args)

end