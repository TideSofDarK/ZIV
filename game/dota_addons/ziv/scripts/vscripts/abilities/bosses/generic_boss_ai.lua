BOSS_STATE_IDLE = 0
BOSS_STATE_CHASING = 1
BOSS_STATE_CASTING = 2

function AI:BossStart( keys )
	local caster = keys.caster
end

function AI:BossCasting( unit )
	Timers:CreateTimer(function (  )
		
	end)
end