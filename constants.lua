----------------------------------------------
-- EnchantCheck Constants
----------------------------------------------

-- Create global constants table immediately
local EnchantCheckConstants = {}
_G.EnchantCheckConstants = EnchantCheckConstants

----------------------------------------------
-- Version and Info
----------------------------------------------
EnchantCheckConstants.VERSION = "@project-version@"
EnchantCheckConstants.AUTHORS = "whatisboom"

----------------------------------------------
-- Level Constants
----------------------------------------------
EnchantCheckConstants.MAX_LEVEL = 80 -- Current max level for automated self-checks

----------------------------------------------
-- Slot ID Constants
-- Numeric slot indices matching WoW's INVSLOT_* globals
-- Used throughout the addon for consistent slot referencing
----------------------------------------------
EnchantCheckConstants.SLOT_IDS = {
	HEAD = 1,
	NECK = 2,
	SHOULDER = 3,
	BODY = 4,        -- Shirt
	CHEST = 5,
	WAIST = 6,
	LEGS = 7,
	FEET = 8,
	WRIST = 9,
	HAND = 10,
	FINGER1 = 11,
	FINGER2 = 12,
	TRINKET1 = 13,
	TRINKET2 = 14,
	BACK = 15,
	MAINHAND = 16,
	OFFHAND = 17,
	RANGED = 18,     -- Unused in modern WoW
	TABARD = 19,
}

----------------------------------------------
-- Class Colors
----------------------------------------------
EnchantCheckConstants.CLASS_COLORS = {
	["MAGE"] =		  "69CCF0",
	["WARLOCK"] =	  "9482C9",
	["PRIEST"] =	  "FFFFFF",
	["DRUID"] =		  "FF7D0A",
	["SHAMAN"] =	  "0070DE",
	["PALADIN"] =	  "F58CBA",
	["ROGUE"] =		  "FFF569",
	["HUNTER"] =	  "ABD473",
	["WARRIOR"] =	  "C79C6E",
	["DEATHKNIGHT"] = "C41F3B",
	["MONK"] = 		  "00FF96",
	["DEMONHUNTER"] = "A330C9",
	["EVOKER"] = 	  "33937F",
}

----------------------------------------------
-- Slot Configuration - What slots need enchants?
-- Using numeric indices to avoid dependency on WoW globals at load time
----------------------------------------------
EnchantCheckConstants.ENCHANT_SLOTS = {
	[1] = false,  -- HEAD (handled dynamically in main.lua initialization)
	[2] = false,   -- NECK
	[3] = false,   -- SHOULDER
	[4] = false,   -- BODY (shirt)
	[5] = true,    -- CHEST
	[6] = false,   -- WAIST
	[7] = true,    -- LEGS
	[8] = true,    -- FEET
	[9] = true,    -- WRIST
	[10] = false,  -- HAND
	[11] = true,   -- FINGER1
	[12] = true,   -- FINGER2
	[13] = false,  -- TRINKET1
	[14] = false,  -- TRINKET2
	[15] = true,   -- BACK
	[16] = true,   -- MAINHAND
	[17] = true,   -- OFFHAND
	[18] = false,  -- RANGED (unused)
	[19] = false,  -- TABARD
}

----------------------------------------------
-- Slot Configuration - What slots must have an item?
-- Using numeric indices to avoid dependency on WoW globals at load time
----------------------------------------------
EnchantCheckConstants.REQUIRED_SLOTS = {
	[1] = true,    -- HEAD
	[2] = true,    -- NECK
	[3] = true,    -- SHOULDER
	[4] = false,   -- BODY (shirt)
	[5] = true,    -- CHEST
	[6] = true,    -- WAIST
	[7] = true,    -- LEGS
	[8] = true,    -- FEET
	[9] = true,    -- WRIST
	[10] = true,   -- HAND
	[11] = true,   -- FINGER1
	[12] = true,   -- FINGER2
	[13] = true,   -- TRINKET1
	[14] = true,   -- TRINKET2
	[15] = true,   -- BACK
	[16] = true,   -- MAINHAND
	[17] = true,   -- OFFHAND
	[18] = false,  -- RANGED (unused)
	[19] = false,  -- TABARD
}

----------------------------------------------
-- Weapon Configuration - Which main-hand weapons require an off-hand item?
----------------------------------------------
EnchantCheckConstants.OFFHAND_REQUIRED = function(LI)
	return {
		[LI["Bows"]] = false,
		[LI["Crossbows"]] = false,
		[LI["Daggers"]] = true,
		[LI["Guns"]] = false,
		[LI["Fishing Poles"]] = false,
		[LI["Fist Weapons"]] = true,
		[LI["Miscellaneous"]] = true,
		[LI["One-Handed Axes"]] = true,
		[LI["One-Handed Maces"]] = true,
		[LI["One-Handed Swords"]] = true,
		[LI["Polearms"]] = false,
		[LI["Staves"]] = false,
		[LI["Thrown"]] = false,
		[LI["Two-Handed Axes"]] = false,
		[LI["Two-Handed Maces"]] = false,
		[LI["Two-Handed Swords"]] = false,
		[LI["Wands"]] = true,
	}
end

----------------------------------------------
-- Debug Levels
----------------------------------------------
EnchantCheckConstants.DEBUG_LEVELS = {
	OFF = 0,
	WARNING = 1,
	INFO = 2,
	NOTICE = 3,
}

----------------------------------------------
-- Default Configuration
----------------------------------------------
EnchantCheckConstants.DEFAULTS = {
	profile = {
		enable = true,
		rescanTimer = 1,
		rescanCount = 2,
		debugLevel = EnchantCheckConstants.DEBUG_LEVELS.WARNING,
		
		-- Smart Notification Settings
		smartNotifications = true,
		minItemLevelForWarnings = 400,
		ignoreHeirlooms = true,
		
		-- Warning Settings
		warnMissingItems = true,
		warnMissingEnchants = true,
		warnMissingGems = true,
		warnLowItemLevel = true,
		
		-- Sound Settings
		enableSounds = false,

		-- Visual Settings
		showTooltips = true,

		-- Content-Specific Settings
		suppressLevelingWarnings = true,
		enhancedDungeonChecks = true,

		-- Performance Settings
		enableCaching = true,
		cacheSize = 500, -- Maximum number of cached items
		cacheTTL = 300, -- Cache time-to-live in seconds (5 minutes)
	},
}

----------------------------------------------
-- Primary Stats Configuration
----------------------------------------------
EnchantCheckConstants.STAT_STRINGS = {
	["STRENGTH"] = "STRENGTH",
	["AGILITY"] = "AGILITY",
	["INTELLECT"] = "INTELLECT",
}

EnchantCheckConstants.PRIMARY_STATS = {
	[1] = EnchantCheckConstants.STAT_STRINGS.STRENGTH,
	[2] = EnchantCheckConstants.STAT_STRINGS.AGILITY,
	[4] = EnchantCheckConstants.STAT_STRINGS.INTELLECT,
}

----------------------------------------------
-- Item Level Thresholds
----------------------------------------------
EnchantCheckConstants.ITEM_LEVEL = {
	LOW_THRESHOLD_MULTIPLIER = 0.8, -- Items below 80% of average are flagged as low
	HEIRLOOM_RARITY = 7, -- Heirloom items (exempt from low level warnings)
}

----------------------------------------------
-- Quest IDs for Feature Unlocks
----------------------------------------------
EnchantCheckConstants.QUEST_IDS = {
	HEAD_ENCHANT_UNLOCK = 78429, -- Quest that unlocks head enchants
}

----------------------------------------------
-- Expansion Constants
----------------------------------------------
EnchantCheckConstants.EXPANSIONS = {
	DRAGONFLIGHT = 9,
	THE_WAR_WITHIN = 10,
}

----------------------------------------------
-- UI Constants
----------------------------------------------
EnchantCheckConstants.UI = {
	DISPLAY_DURATION = 86400, -- Message frame display duration (24 hours)
	ELVUI_BUTTON_OFFSET = {
		CHARACTER_FRAME = { x = -10, y = 15 },
		INSPECT_FRAME = { x = 10, y = -50 },
	},
	DEFAULT_BUTTON_OFFSET = {
		INSPECT_FRAME = { x = 10, y = 20 },
	},
	
	-- Color Codes
	COLORS = {
		GOOD = "|cff00FF00",      -- Green
		WARNING = "|cffFFFF00",   -- Yellow  
		ERROR = "|cffFF0000",     -- Red
		INFO = "|cff00FFFF",      -- Cyan
		SUGGESTION = "|cff00FF00", -- Light Green
		RESET = "|cffFFFFFF",     -- White
	},
	
	-- Severity Levels
	SEVERITY = {
		GOOD = 0,
		INFO = 1, 
		WARNING = 2,
		ERROR = 3,
	},
}

----------------------------------------------
-- Equipment Slot Count (excluding shirt/tabard)
----------------------------------------------
EnchantCheckConstants.EQUIPMENT_SLOTS = {
	TOTAL = 18,
	TWO_HANDED_COUNT = 15, -- Total slots minus offhand when using 2H weapon
	ONE_HANDED_COUNT = 16, -- Total slots when using 1H+offhand
	EXCLUDED_FROM_ILVL = { 4, 19 }, -- BODY and TABARD slots excluded from item level calculations
}

----------------------------------------------
-- Smart Notification System
----------------------------------------------

-- Role definitions based on spec
EnchantCheckConstants.SPEC_ROLES = {
	-- Death Knight
	[250] = "TANK",    -- Blood
	[251] = "MELEE",   -- Frost
	[252] = "MELEE",   -- Unholy
	
	-- Demon Hunter  
	[577] = "MELEE",   -- Havoc
	[581] = "TANK",    -- Vengeance
	
	-- Druid
	[102] = "RANGED",  -- Balance
	[103] = "MELEE",   -- Feral
	[104] = "TANK",    -- Guardian
	[105] = "HEALER",  -- Restoration
	
	-- Evoker
	[1467] = "RANGED", -- Devastation
	[1468] = "HEALER", -- Preservation
	[1473] = "RANGED", -- Augmentation
	
	-- Hunter
	[253] = "RANGED",  -- Beast Mastery
	[254] = "RANGED",  -- Marksmanship
	[255] = "MELEE",   -- Survival
	
	-- Mage
	[62] = "RANGED",   -- Arcane
	[63] = "RANGED",   -- Fire
	[64] = "RANGED",   -- Frost
	
	-- Monk
	[268] = "TANK",    -- Brewmaster
	[270] = "HEALER",  -- Mistweaver
	[269] = "MELEE",   -- Windwalker
	
	-- Paladin
	[65] = "HEALER",   -- Holy
	[66] = "TANK",     -- Protection
	[70] = "MELEE",    -- Retribution
	
	-- Priest
	[256] = "HEALER",  -- Discipline
	[257] = "HEALER",  -- Holy
	[258] = "RANGED",  -- Shadow
	
	-- Rogue
	[259] = "MELEE",   -- Assassination
	[260] = "MELEE",   -- Outlaw
	[261] = "MELEE",   -- Subtlety
	
	-- Shaman
	[262] = "RANGED",  -- Elemental
	[263] = "MELEE",   -- Enhancement
	[264] = "HEALER",  -- Restoration
	
	-- Warlock
	[265] = "RANGED",  -- Affliction
	[266] = "RANGED",  -- Demonology
	[267] = "RANGED",  -- Destruction
	
	-- Warrior
	[71] = "MELEE",    -- Arms
	[72] = "MELEE",    -- Fury
	[73] = "TANK",     -- Protection
}

-- Content type detection
EnchantCheckConstants.CONTENT_TYPES = {
	LEVELING = "LEVELING",
	DUNGEON = "DUNGEON", 
	MYTHIC_PLUS = "MYTHIC_PLUS",
	RAID = "RAID",
	PVP = "PVP",
	ENDGAME = "ENDGAME"
}


-- Content-based item level requirements  
EnchantCheckConstants.CONTENT_ILVL_REQUIREMENTS = {
	[EnchantCheckConstants.CONTENT_TYPES.LEVELING] = 0,
	[EnchantCheckConstants.CONTENT_TYPES.DUNGEON] = 450,
	[EnchantCheckConstants.CONTENT_TYPES.MYTHIC_PLUS] = 480, 
	[EnchantCheckConstants.CONTENT_TYPES.RAID] = 500,
	[EnchantCheckConstants.CONTENT_TYPES.PVP] = 460,
	[EnchantCheckConstants.CONTENT_TYPES.ENDGAME] = 480
}

-- Constants are already globally available from line 7