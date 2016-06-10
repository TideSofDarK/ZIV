function Spawn( keys )
	local caster = keys.caster
	local ability = keys.ability

	local count = GetSpecial(ability, "spawn_count")

	for i=0,count-1 do
		Timers:CreateTimer(0.5 * i, function (  )
			local position = RandomPointInsideCircle(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, GetSpecial(ability, "spawn_max_radius"), GetSpecial(ability, "spawn_min_radius"))
			position.z = GetGroundHeight(position,caster)

			local particle = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_requiemofsouls_head.vpcf",PATTACH_CUSTOMORIGIN,nil)
			ParticleManager:SetParticleControl(particle,0,position+Vector(0,0,48))
			
			Director:SpawnPack(
			{
				Type = "oath_firespawn",
				SpawnBasic = true,
				SpawnLord = false,
				BasicSpread = 0,
				Count = 1,
				Position = position,
				NoLoot = true,
				Duration = 8.0
			})

			EmitSoundOnLocationWithCaster(position,"Hero_Phoenix.FireSpirits.Launch",caster)
		end)
	end
end