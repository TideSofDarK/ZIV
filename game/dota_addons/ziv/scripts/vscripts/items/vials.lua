function PrepareVial( container )
	Physics:Unit(container)

	local vial = container:GetContainedItem():GetName()

	container:RemoveCollider()
    collider = container:AddColliderFromProfile("delete")
    collider.radius = 75
    collider.fullRadius = 0
    collider.force = 0
    collider.linear = false
    collider.test = function(self, collider, collided)
      return collided.IsHero and collided:IsHero() == true
    end
    collider.postaction = function ( colliderTable, colliderUnit, collidedUnit )
    	ActivateVial( vial, collidedUnit )
    end
end

function ActivateVial( vial, caster )
	if vial == "item_hp_vial" then
		local particle = ParticleManager:CreateParticle("particles/props/vials/hp_vial.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
		ParticleManager:SetParticleControl(particle,1,caster:GetAbsOrigin() + Vector(0,0,64))

		caster:Heal(caster:GetMaxHealth() * randomf(ZIV_HP_VIAL_HEAL_MIN,ZIV_HP_VIAL_HEAL_MAX),nil)
		caster:EmitSound("DOTA_Item.Mango.Activate")
	elseif vial == "item_mp_vial" then
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

			local vial_name = "item_hp_vial"

			if result == 2 then
				vial_name = "item_mp_vial"

				if ZIV.HeroesKVs[hero:GetUnitName().."_ziv"]["UsesEnergy"] then
					vial_name = "item_ep_vial"
				end
			end

			return CreateItemOnPositionSync(position,CreateItem(vial_name, hero, hero))
		end
	end

	return nil
end