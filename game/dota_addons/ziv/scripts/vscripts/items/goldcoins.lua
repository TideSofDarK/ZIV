function Pickup( keys )
	local caster = keys.caster
	local item = keys.ability

	PopupGoldGain(caster, item.amount or 0)
end