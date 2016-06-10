function Start( keys )
	local caster = keys.caster
	local ability = keys.ability

	local intro_duration = GetSpecial(ability, "intro_duration")

	AddAnimationTranslate(caster, "desolation")

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_oath_invu",{duration = intro_duration})

	StartAnimation(caster, {duration=intro_duration, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.0})

	Timers:CreateTimer(intro_duration, function (  )
		AI:BossStart( keys )
		caster:RemoveModifierByName("modifier_boss_hpbar_panel_spawner")
	end)
end