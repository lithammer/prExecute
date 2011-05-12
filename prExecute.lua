local addonName, addon = ...

local ExecuteList = {
	['DRUID'] = {nil, nil, nil},
	['DEATHKNIGHT'] = {nil, nil, nil},
	['MAGE'] = {nil, nil, nil},
	['HUNTER'] = {20, 20, 20},
	['PALADIN'] = {nil, nil, 20},
	['PRIEST'] = {nil, nil, 25},
	['ROGUE'] = {nil, nil, nil},
	['SHAMAN'] = {nil, nil, nil},
	['WARLOCK'] = {25, nil, 20},
	['WARRIOR'] = {20, 20, nil},
}

local playerClass = select(2, UnitClass('player'))
local playerName = UnitName('player')

local warningSound = 'Interface\\AddOns\\'..addonName..'\\Sounds\\quaddamage.mp3'
local tickSound = 'Interface\\AddOns\\'..addonName..'\\Sounds\\tick.mp3'

local function OnEvent(self, event, ...)
	addon[event](self, event, ...)
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', OnEvent)

local executeRange = 0
local function checkForExecute()
	local hasExecute = ExecuteList[playerClass][GetPrimaryTalentTree()] or false

	if hasExecute then
		executeRange = hasExecute
		frame:RegisterEvent('UNIT_HEALTH')
		frame:RegisterEvent('PLAYER_TARGET_CHANGED')
	else
		frame:UnregisterEvent('UNIT_HEALTH')
		frame:UnregisterEvent('PLAYER_TARGET_CHANGED')
	end

	if playerClass == 'WARLOCK' then
		frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	end
end

function addon:ACTIVE_TALENT_GROUP_CHANGED()
	checkForExecute()
end

function addon:PLAYER_ENTERING_WORLD()
	frame:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	frame:UnregisterEvent('PLAYER_ENTERING_WORLD')
	checkForExecute()
end

local drainSoulName = GetSpellInfo(1120) --Drain Soul
function addon:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local _, eventType, _, _, srcName, _, _, _, _, _, spellName = ...

	if eventType == 'SPELL_PERIODIC_DAMAGE' and srcName == playerName and spellName == drainSoulName then
		PlaySoundFile(tickSound)
	end
end

local soundPlayed = false
function addon:UNIT_HEALTH(self, unit)
	if (unit ~= 'target') or soundPlayed or CanExitVehicle() or UnitIsDeadOrGhost('target') or UnitIsFriend('player', 'target') then
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

function addon:PLAYER_TARGET_CHANGED()
	soundPlayed = false
end
