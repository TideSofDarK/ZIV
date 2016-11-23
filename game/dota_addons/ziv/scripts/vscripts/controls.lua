if Controls == nil then
    _G.Controls = class({})
end

function Controls:Init()
	CustomGameEventManager:RegisterListener( "ziv_cast_ability_no_target_remote", Dynamic_Wrap(Controls, 'CastAbilityNoTargetRemote'))
	CustomGameEventManager:RegisterListener( "ziv_cast_ability_point_target_remote", Dynamic_Wrap(Controls, 'CastAbilityPointTargetRemote'))
end

function Controls:AbilityPhaseCheck( caster )
	for i=0,16 do
		local ability = caster:GetAbilityByIndex(i)
		if ability then
			if ability:IsInAbilityPhase() then return true end
		end
	end
end

function Controls:BasicCastingCheck( caster, ability )
	if Controls:AbilityPhaseCheck( caster ) then
		return true
	end

	if not ability:IsCooldownReady() then
		return true
	end

	if caster:HasModifier("modifier_custom_attack") then
		return true
	end
end

function Controls:CastAbilityNoTargetRemote(args)
	local caster = PlayerResource:GetPlayer(args.PlayerID):GetAssignedHero()
	local ability = EntIndexToHScript(tonumber(args.ability))

	if Controls:BasicCastingCheck( caster, ability ) then
		return
	end

	caster:CastAbilityNoTarget(ability,args.PlayerID)
end

function Controls:CastAbilityPointTargetRemote(args)
	local caster = PlayerResource:GetPlayer(args.PlayerID):GetAssignedHero()
	local ability = EntIndexToHScript(tonumber(args.ability))
	local target_entity = EntIndexToHScript(tonumber(args.target_entity))

	if Controls:BasicCastingCheck( caster, ability ) then
		return
	end

	if IsValidEntity(target_entity) then
		caster:CastAbilityOnTarget(target_entity,ability,args.PlayerID)
		return
	end

	local target = Vector(tonumber(args.target["0"]),tonumber(args.target["1"]),tonumber(args.target["2"]))

	if args.force then
		local distance = Distance(caster, target)
		local max_distance = ability:GetCastRange(target, caster)
		
		local final_distance = math.min(distance, max_distance) * 0.9

		target = caster:GetAbsOrigin() + ((caster:GetAbsOrigin() - target):Normalized() * -final_distance)
	end

	caster:CastAbilityOnPosition(target,ability,args.PlayerID)
end