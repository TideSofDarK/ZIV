function SpawnTombs( keys )
	local caster = keys.caster
	local ability = keys.ability

	local count = GetSpecial(ability, "tombs_number")

	PrecacheUnitByNameAsync("npc_dota_unit_undying_tombstone", function (  )
		for i=1,count do
			
			local tomb = CreateUnitByName("npc_undying_tomb",caster:GetAbsOrigin() + RandomPointOnCircle(375),true,caster,caster,caster:GetTeamNumber())

			TimedEffect("particles/units/heroes/hero_undying/undying_loadout.vpcf", tomb, 2.0)

			tomb:AddNewModifier(caster,ability,"modifier_kill",{duration = 8})
			ability:ApplyDataDrivenModifier(tomb,tomb,"modifier_undying_tomb",{})
		end
	end)
end

function OnTombSpawned( keys )
	local caster = keys.caster
	local ability = keys.ability

	Timers:CreateTimer(1.0, function (  )
		Director:SpawnPack(
			{
			Level = 1,
			SpawnBasic = true,
			SpawnLord = false,
			BasicSpread = 300,
			Count = math.random(GetSpecial(ability, "creeps_min"), GetSpecial(ability, "creeps_max")),
			Position = caster:GetAbsOrigin(),
			})
		if caster:IsAlive() == true then
			return 4.0
		end
	end) 
end