function Start( keys )
	local caster = keys.caster
	local ability = keys.ability

	Timers:CreateTimer(math.random(2.0, 16.0), function (  )
		if caster:IsNull() == false and caster:IsAlive() then
			FallingRocks(keys)
			return math.random(5.0, 14.0)
		end
	end)
end

function FallingRocks(keys)
	local caster = keys.caster

	local unit = CreateUnitByName("npc_dummy_unit",RandomPointOnMap(),true,nil,nil,caster:GetTeamNumber())
	unit:SetMoveCapability(1)

	local particle = ParticleManager:CreateParticle("particles/unique/temple/temple_falling_rocks.vpcf",PATTACH_ABSORIGIN,unit)

	Timers:CreateTimer(3.0, function ()
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for k,v in pairs(units) do
			if v ~= caster then
				DealDamage( caster, v, v:GetMaxHealth()/10, DAMAGE_TYPE_PHYSICAL ) 
			end
		end

		-- DealDamage()
	end)
end