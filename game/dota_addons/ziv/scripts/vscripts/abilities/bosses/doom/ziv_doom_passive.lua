function Start( keys )
  --local caster = keys.caster
  
	--AI:BossStart( keys, SFM(caster) )
end

function Divide( keys )
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker
	
	local hp = caster:GetHealth()

	if hp == 0 then
		caster:SetHealth(1)

		ability:ApplyDataDrivenModifier(caster,caster,"modifier_doom_dead",{})

		local copies = {}

		for i=1,2 do
			--local new_keys = DeepCopy(keys)
      local copy = CreateUnitByName(caster:GetUnitName(),caster:GetAbsOrigin(),true,nil,nil,caster:GetTeamNumber())
			copy:SetModelScale(caster:GetModelScale() * 0.75)
			copy:RemoveAbility("ziv_doom_passive")
			copy:SetMaxHealth(caster:GetMaxHealth()/2)
			table.insert(copies, copy)
			AI:BossStart( copy )
      
      copy.sfm.aggro:SetTable(caster.sfm.aggro.table)
		end

		Timers:CreateTimer(function (  )
			local hp = 0
			if IsValidEntity(copies[1]) then
				hp = copies[1]:GetHealth()
			end
			if IsValidEntity(copies[2]) then
				hp = hp + copies[2]:GetHealth()
			end
			caster:SetHealth(hp)
			if hp > 0 then
				return 0.03
			end
		end)
	end
end