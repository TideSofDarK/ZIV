function PrepareVial( container )
	Physics:Unit(container)

	container:RemoveCollider()
    collider = container:AddColliderFromProfile("gravity")
    collider.radius = 75
    collider.fullRadius = 0
    collider.force = 0
    collider.linear = false
    collider.test = function(self, collider, collided)
      return collided.IsHero and collided:IsHero() == true
    end
    collider.postaction = function ( colliderTable, colliderUnit, collidedUnit )
    	PickupVial( container, collidedUnit )
    end
end

function ActivateHPVial( keys )
	local caster = keys.caster
	local ability = keys.ability

	ParticeManager:CreateParticle("particles/heroes/dark_goddess/dark_goddess_concentration_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)

	caster:Heal(caster:GetMaxHealth() * randomf(0.1,0.15),ability)
end

function ActivateMPVial( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:GiveMana(caster:GetMaxMana() * randomf(0.1,0.15))
end

function ActivateEPVial( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:GiveMana(caster:GetMaxMana() * randomf(0.1,0.15))
end

function PickupVial( container, hero )
	hero:PickupDroppedItem(container:GetContainedItem())
	UTIL_Remove(container)
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