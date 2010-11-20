if select(2, UnitClass('player')) ~= 'WARLOCK' then return end

-- CONFIG -----------------------------------------------------------------------------------------------

local alwaysPlayTick = true		-- plays the drain soul tick sound for all specs

-- END CONFIG -------------------------------------------------------------------------------------------



local played = false
local f = CreateFrame('Frame')
f:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
f:RegisterEvent('PLAYER_ALIVE')
f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

f:SetScript('OnEvent', function(self, event, ...) if self[event] then return self[event] (self, event, ...) end end)

function checkForTalent()
	local rank, maxRank = select(5, GetTalentInfo(1, 13, false, false, nil))
	
	if rank and (maxRank > 0) and rank == maxRank then
		f:RegisterEvent('UNIT_HEALTH')
		f:RegisterEvent('PLAYER_TARGET_CHANGED')
	else
		f:UnregisterEvent('UNIT_HEALTH')
		f:UnregisterEvent('PLAYER_TARGET_CHANGED')
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
        	PlaySoundFile('Interface\\AddOns\\prDrainSoulTimer\\Sounds\\tick.mp3')
		end
	end
end

function f:UNIT_HEALTH()
	if played or not UnitIsEnemy('player', 'target') or UnitIsDeadOrGhost('target') or CanExitVehicle() then
		return
	end
	
	local currentHealth = UnitHealth('target') / UnitHealthMax('target')
	
	if (UnitClassification('target') == ('worldboss' or 'elite' or 'rareelite')) or UnitIsPlayer('target') then
		if currentHealth < 0.25 then
			PlaySoundFile('Interface\\AddOns\\prDrainSoulTimer\\Sounds\\quaddamage.mp3')
			played = true
		end
	end
end

function f:PLAYER_TARGET_CHANGED()
	played = false
end