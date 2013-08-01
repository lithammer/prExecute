local _, addon = ...

-- This is the specs from left to right, and the percentage value that the
-- execute sound should play, 0 to disable.
addon.config.executeList = {
	['DEATHKNIGHT'] = { 0,  0,  0},
	['DRUID']       = { 0,  0,  0,  0},
	['HUNTER']      = {20, 20, 20},
	['MAGE']        = { 0,  0,  0},
	['MONK']        = { 0,  0,  0},
	['PALADIN']     = { 0,  0, 20},
	['PRIEST']      = { 0,  0, 20},
	['ROGUE']       = {35,  0,  0},
	['SHAMAN']      = { 0,  0,  0},
	['WARLOCK']     = {20,  0, 20},
	['WARRIOR']     = {20, 20,  0},
}

-- Sound to play when you enter execute phase
addon.config.warningSound = 'Interface\\AddOns\\prExecute\\Sounds\\quaddamage.mp3'

-- Tick sound for Drain Soul (Warlocks only)
addon.config.tickSound = 'Interface\\AddOns\\prExecute\\Sounds\\tick.mp3'

-- Unit types for which the sound will be played
-- http://wowprogramming.com/docs/api/UnitClassification
addon.config.validUnitTypes = {
	--trivial = true,
	--normal = true,
	elite = true,
	rare = true,
	rareelite = true,
	worldboss = true
}
