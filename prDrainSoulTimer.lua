if select(2, UnitClass('player')) == 'WARLOCK' then


-- CONFIG -----------------------------------------------------------------------------------------------

local minHealth = 240000		-- minimum health of target for pDrainSoulTimer to do anything
local notification = false		-- if you want a notification in the chatframe when the addon enables
local alwaysPlayTick = false	-- plays the drain soul tick sound for all specs

-- END CONFIG -------------------------------------------------------------------------------------------



local played = false
local f = CreateFrame('Frame')
f:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
if alwaysPlayTick then f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED') end

f:SetScript('OnEvent', function(self, event, ...)
	if self[event] then
		return self[event] (self, event, ...)
	end
end)

function checkForTalent()
	local rank, maxRank = select(5, GetTalentInfo(1, 24, false, false, nil))
	
	if rank == maxRank then
		if not alwaysPlayTick then f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED') end
		f:RegisterEvent('UNIT_HEALTH')
		f:RegisterEvent('PLAYER_TARGET_CHANGED')
		
		if notification then print ('|cff4e96f7|Hspell:47200|h[Death\'s Embrace]|h|r detected, activating |cffFF33FFp|rDrainSoulTimer') end
	else
		if not alwaysPlayTick then f:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED') end
		f:UnregisterEvent('UNIT_HEALTH')
		f:UnregisterEvent('PLAYER_TARGET_CHANGED')
	end
end

function f:ACTIVE_TALENT_GROUP_CHANGED()
	checkForTalent()
end

function f:PLAYER_ENTERING_WORLD()
	checkForTalent()
end
	
function f:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local eventType = select(2, ...)
	local srcName = select(4, ...)
	
	if eventType == 'SPELL_PERIODIC_DAMAGE' and srcName == UnitName('player') then
		local spellName = select(10, ...)
		local drainSoulName = GetSpellInfo(1120) --Drain Soul Rank 1

		if(spellName == drainSoulName) then
        	PlaySoundFile('Interface\\AddOns\\pDrainSoulTimer\\Sounds\\tick.wav')
		end
	end
end

function f:UNIT_HEALTH()
	if played or not UnitIsEnemy('player', 'target') or UnitIsDead('target') then
		return
	end
	
	local currentHealth = UnitHealth('target') / UnitHealthMax('target')
	
	if UnitHealthMax('target') > minHealth then
		if currentHealth < 0.25 then
			PlaySoundFile('Interface\\AddOns\\pDrainSoulTimer\\Sounds\\quaddamage.wav')

			played = true
		end
	end
end

function f:PLAYER_TARGET_CHANGED()
	played = false
end

end -- end warlock check