function OnLethalDamage( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local casterHP = caster:GetHealth()
	local player = PlayerResource:GetPlayer(caster:GetPlayerOwnerID())

	if casterHP == 1 then
		caster:SetMana(0.0)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_hero_dead", {})
		caster:SetWaitingForRespawn( true )

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_DIE, rate=0.8})
		Timers:CreateTimer(3.0, function (  )
			FreezeAnimation(caster)
		end)

		if player then
			CustomGameEventManager:Send_ServerToPlayer(player,"ziv_death_panel",{})
			-- caster:EmitSound()
			-- EmitSoundOnClient("UI.Death",player)
		end

		caster.revive_panel = WorldPanels:CreateWorldPanelForAll({
			layout = "revive",
			entity = caster:GetEntityIndex(),
			data = {},
			entityHeight = 150,
	    })
	end	
end