
--[ CONFIG ]-------------------------------------------------------------------

-- This is the specs from left to right, and the percentage value that the
-- execute sound should play, 0 to disable.
local ExecuteList = {
	['DEATHKNIGHT'] = { 0,  0,  0},
	['DRUID'] =       { 0,  0,  0},
	['HUNTER'] =      {20, 20, 20},
	['MAGE'] =        { 0,  0,  0},
	['MONK'] =        { 0,  0,  0},
	['PALADIN'] =     { 0,  0, 20},
	['PRIEST'] =      { 0,  0, 25},
	['ROGUE'] =       { 0,  0,  0},
	['SHAMAN'] =      { 0,  0,  0},
	['WARLOCK'] =     {25,  0, 20},
	['WARRIOR'] =     {20, 20,  0},
}

-- Sound to play when you enter execute phase
local warningSound = 'Interface\\AddOns\\prExecute\\Sounds\\quaddamage.mp3'
-- Tick sound for Drain Soul (Warlocks only)
local tickSound = 'Interface\\AddOns\\prExecute\\Sounds\\tick.mp3'

---[ END CONFIG ]--------------------------------------------------------------

local _, addon = ...

local playerClass = select(2, UnitClass('player'))
local playerName = UnitName('player')

local drainSoulName = GetSpellInfo(1120) --Drain Soul

local executeRange = 0
local soundPlayed = false

-- Utility functions

local function CheckForExecute()
	executeRange = ExecuteList[playerClass][GetSpecialization()] or 0
end

local function IsInvalidUnit(unit)
	return (unit ~= 'target') or soundPlayed or CanExitVehicle() or UnitIsDeadOrGhost('target') or UnitIsFriend('player', 'target')
end

-- Event handling

local function OnEvent(self, event, ...)
	addon[event](self, event, ...)
end

function addon:ACTIVE_TALENT_GROUP_CHANGED()
	CheckForExecute()
end

function addon:PLAYER_ENTERING_WORLD()
	CheckForExecute()
end

function addon:PLAYER_TARGET_CHANGED()
	soundPlayed = false
end

function addon:UNIT_HEALTH(self, unit)
	if IsInvalidUnit(unit) then
		return
	end

	local currentHealth = (UnitHealth('target') / UnitHealthMax('target')) * 100

	if (UnitClassification('target') ~= 'normal') or UnitIsPlayer('target') then
		if currentHealth < executeRange then
			PlaySoundFile(warningSound)
			soundPlayed = true
		end
	end
end

function addon:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local _, eventType, _, _, srcName, _, _, _, _, _, _, _, spellName = ...

	if eventType == 'SPELL_PERIODIC_DAMAGE' and srcName == playerName and spellName == drainSoulName then
		PlaySoundFile(tickSound)
	end
end

-- Frame creation

local f = CreateFrame('Frame')
f:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterEvent('PLAYER_TARGET_CHANGED')
f:RegisterEvent('UNIT_HEALTH')
if playerClass == 'WARLOCK' then
	f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
end

f:SetScript('OnEvent', OnEvent)
