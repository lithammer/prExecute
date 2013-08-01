local _, addon = ...
local config = addon.config

local _, playerClass = UnitClass('player')
local playerName = UnitName('player')

local executeRange = 0
local soundPlayed = false

local drainSoulName = GetSpellInfo(1120)

local UpdateExecuteRange = function()
	executeRange = config.executeList[playerClass][GetSpecialization()] or 0
end

local Events = {
	PLAYER_SPECIALIZATION_CHANGED = UpdateExecuteRange,

	ACTIVE_TALENT_GROUP_CHANGED = UpdateExecuteRange,

	PLAYER_ENTERING_WORLD = UpdateExecuteRange,

	PLAYER_TARGET_CHANGED = function()
		soundPlayed = false
	end,

	UNIT_HEALTH_FREQUENT = function(self, unit)
		if soundPlayed or CanExitVehicle() or UnitIsDeadOrGhost('target') or UnitIsFriend('player', 'target') then
			return
		end

		local currentHealth = UnitHealth('target') / UnitHealthMax('target') * 100

		if config.validUnitTypes[UnitClassification('target')] or UnitIsPlayer('target') then
			if currentHealth < executeRange then
				PlaySoundFile(config.warningSound)
				soundPlayed = true
			end
		end
	end,

	COMBAT_LOG_EVENT_UNFILTERED = function(event, ...)
		local _, eventType, _, _, srcName, _, _, _, _, _, _, _, spellName = ...

		if eventType == 'SPELL_PERIODIC_DAMAGE' and srcName == playerName and spellName == drainSoulName then
			PlaySoundFile(config.tickSound)
		end
	end
}

-- Frame creation

local f = CreateFrame('Frame')
f:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
f:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterEvent('PLAYER_TARGET_CHANGED')
f:RegisterUnitEvent('UNIT_HEALTH_FREQUENT', 'target')

if playerClass == 'WARLOCK' then
	f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
end

f:SetScript('OnEvent', function(self, event, ...)
	Events[event](self, event, ...)
end)
