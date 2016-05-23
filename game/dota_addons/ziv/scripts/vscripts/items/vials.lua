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

		caster:Heal(caster:GetMaxHealth() * randomf(0.1,0.15),nil)
		caster:EmitSound("DOTA_Item.Mango.Activate")
	elseif vial == "item_mp_vial" then
		caster:GiveMana(caster:GetMaxMana() * randomf(0.1,0.15))
	else
		caster:GiveMana(caster:GetMaxMana() * randomf(0.1,0.15))
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