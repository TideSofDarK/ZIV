function PrepareVial( container )
	Physics:Unit(container)

	local vial = container:GetUnitName()

	container:RemoveCollider()
    local collider = container:AddColliderFromProfile("delete")
    collider.radius = 75
    collider.fullRadius = 0
    collider.force = 0
    collider.linear = false
    collider.test = function(self, collider, collided)
    	if collided.IsHero and collided:IsHero() == true then
    		if vial == "npc_hp_vial" then
    			return true
			elseif vial == "npc_mp_vial" then
				return not ZIV.HeroesKVs[collided:GetUnitName().."_ziv"]["UsesEnergy"]
			elseif vial == "npc_ep_vial" then
				return false
			end
    	end
    	return false
    end
    collider.postaction = function ( colliderTable, colliderUnit, collidedUnit )
    	ActivateVial( vial, collidedUnit )
    end
end

function ActivateVial( vial, caster )
	if vial == "npc_hp_vial" then
		local particle = ParticleManager:CreateParticle("particles/props/vials/hp_vial.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
		ParticleManager:SetParticleControl(particle,1,caster:GetAbsOrigin() + Vector(0,0,64))

		caster:Heal(caster:GetMaxHealth() * randomf(ZIV_HP_VIAL_HEAL_MIN,ZIV_HP_VIAL_HEAL_MAX),nil)
		caster:EmitSound("DOTA_Item.Mango.Activate")
	elseif vial == "npc_mp_vial" then
		local particle = ParticleManager:CreateParticle("particles/items3_fx/mango_active.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)

		caster:GiveMana(caster:GetMaxMana() * randomf(ZIV_MP_VIAL_MANA_MIN,ZIV_MP_VIAL_MANA_MAX))
		caster:EmitSound("Bottle.Drink")
	else
		local particle = ParticleManager:CreateParticle("particles/props/vials/ep_vial.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
		ParticleManager:SetParticleControl(particle, 1, Vector(200,0,0))

		caster:GiveMana(caster:GetMaxMana() * randomf(ZIV_EP_VIAL_ENERGY_MIN,ZIV_EP_VIAL_ENERGY_MAX))
		caster:EmitSound("Greevil.Purification")
	end
end

function CreateVial( hero, position )
	if hero.vial_choice_rng and hero.vial_rng then
		if hero.vial_rng:Next() then
			local result = hero.vial_choice_rng:Choose()

			local vial_name = "npc_hp_vial"

			if result == 2 then
				vial_name = "npc_mp_vial"

				if ZIV.HeroesKVs[hero:GetUnitName().."_ziv"]["UsesEnergy"] then
					-- vial_name = "npc_ep_vial"
					return nil
				end
			end

			local vial = CreateUnitByName(vial_name,position,true,hero,hero,hero:GetTeamNumber())
			InitAbilities(vial)

			return vial
		end
	end

	return nil
end

function VialSpawned( keys )
	local caster = keys.caster
	local ability = keys.ability

	StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE, rate=1.0, translate="empty"})

	local particle = ParticleManager:CreateParticle("particles/props/vials/"..string.gsub(caster:GetUnitName(), "npc_", "").."_dropped.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
end