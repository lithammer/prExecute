
--[ CONFIG ]-------------------------------------------------------------------

-- This is the specs from left to right, and the percentage value that the
-- execute sound should play, 0 to disable.
local executeList = {
	['DEATHKNIGHT'] = { 0,  0,  0},
	['DRUID'] =       { 0,  0,  0},
	['HUNTER'] =      {20, 20, 20},
	['MAGE'] =        { 0,  0,  0},
	['MONK'] =        { 0,  0,  0},
	['PALADIN'] =     { 0,  0, 20},
	['PRIEST'] =      { 0,  0, 20},
	['ROGUE'] =       { 0,  0,  0},
	['SHAMAN'] =      { 0,  0,  0},
	['WARLOCK'] =     {20,  0, 20},
	['WARRIOR'] =     {20, 20,  0},
}

-- Sound to play when you enter execute phase
local warningSound = 'Interface\\AddOns\\prExecute\\Sounds\\quaddamage.mp3'
-- Tick sound for Drain Soul (Warlocks only)
local tickSound = 'Interface\\AddOns\\prExecute\\Sounds\\tick.mp3'

---[ END CONFIG ]--------------------------------------------------------------

local _, addon = ...

local playerClass = select(2, UnitClass('player'))

local executeRange = 0
local soundPlayed = false

-- http://wowprogramming.com/docs/api/UnitClassification
local validUnitTypes = {
	--trivial = true,
	--normal = true,
	elite = true,
	rare = true,
	rareelite = true,
	worldboss = true,
}

local function UpdateExecuteRange()
	executeRange = executeList[playerClass][GetSpecialization()] or 0
end

function addon:PLAYER_SPECIALIZATION_CHANGED()
	UpdateExecuteRange()
end

function addon:ACTIVE_TALENT_GROUP_CHANGED()
	UpdateExecuteRange()
end

function addon:PLAYER_ENTERING_WORLD()
	UpdateExecuteRange()
end

function addon:PLAYER_TARGET_CHANGED()
	soundPlayed = false
end

function addon:UNIT_HEALTH_FREQUENT(self, unit)
	if soundPlayed or CanExitVehicle() or UnitIsDeadOrGhost('target') or UnitIsFriend('player', 'target') then
		return
	end

	local currentHealth = UnitHealth('target') / UnitHealthMax('target') * 100

	if validUnitTypes[UnitClassification('target')] or UnitIsPlayer('target') then
		if currentHealth < executeRange then
			PlaySoundFile(warningSound)
			soundPlayed = true
		end
	end
end

local playerName = UnitName('player')
local drainSoulName = GetSpellInfo(1120) --Drain Soul

function addon:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local _, eventType, _, _, srcName, _, _, _, _, _, _, _, spellName = ...

	if eventType == 'SPELL_PERIODIC_DAMAGE' and srcName == playerName and spellName == drainSoulName then
		PlaySoundFile(tickSound)
	end
end

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
	addon[event](self, event, ...)
end)
