local addonName, ns = ...

local playerClass = select(2, UnitClass('player'))

local played = false
local f = CreateFrame('Frame')
f:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
f:RegisterEvent('PLAYER_ALIVE')

-- Event handling
f:SetScript('OnEvent', function(self, event, ...)
	if self[event] then
		return self[event] (self, event, ...)
	end
end)

local rank, maxRank = nil, nil

function checkForTalent()
	local hasExecute = false
	if playerClass == 'WARLOCK' and select(5, GetTalentInfo(1, 13) > 0 then
		hasExecute = true
	elseif playerClass == 'PRIEST' and GetPrimaryTalentTree() == 3 then
		hasExecute = true
	elseif playerClass == 'HUNTER' then -- All hunter specs use Kill Shot
		hasExecute = true
	elseif playerClass == 'PALADIN' and GetPrimaryTalentTree() == 3 then
		hasExecute = true
	elseif playerClass == 'WARRIOR' and GetPrimaryTalentTree() == (1 or 2) then
		hasExecute = true
	end
	
	if hasExecute then
		f:RegisterEvent('UNIT_HEALTH')
		f:RegisterEvent('PLAYER_TARGET_CHANGED')
		if playerClass == 'WARLOCK' then
			f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
		end
	else
		f:UnregisterEvent('UNIT_HEALTH')
		f:UnregisterEvent('PLAYER_TARGET_CHANGED')
		if playerClass == 'WARLOCK' then
			f:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
		end
	end
end

function f:ACTIVE_TALENT_GROUP_CHANGED()
	checkForTalent()
end

function f:PLAYER_ALIVE()
	checkForTalent()
end
	
function f:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local eventType = select(2, ...)
	local srcName = select(4, ...)
	
	if eventType == 'SPELL_PERIODIC_DAMAGE' and srcName == UnitName('player') then
		local spellName = select(10, ...)
		local drainSoulName = GetSpellInfo(1120) --Drain Soul

		if spellName == drainSoulName then
        	PlaySoundFile('Interface\\AddOns\\'..addonName..'\\Sounds\\tick.mp3')
		end
	end
end

local executeRange = 0.25 -- For warlocks and shadow priests
if playerClass == ('HUNTER' or 'PALADIN' or 'WARRIOR') then
	executeRange = 0.20
end

function f:UNIT_HEALTH(self, unit)
	if played or not UnitIsEnemy('player', 'target') or UnitIsDeadOrGhost('target') or CanExitVehicle() then
		return
	end
	
	local currentHealth = UnitHealth('target') / UnitHealthMax('target')
	
	if (UnitClassification('target') == ('worldboss' or 'elite' or 'rareelite')) or UnitIsPlayer('target') then
		if currentHealth < executeRange then
			PlaySoundFile('Interface\\AddOns\\'..addonName..'\\Sounds\\quaddamage.mp3')
			played = true
		end
	end
end

function f:PLAYER_TARGET_CHANGED()
	played = false
end