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
EnchantCheckConstants.MAX_LEVEL = 90 -- Current max level for automated self-checks

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
	[1] = true,   -- HEAD
	[2] = false,   -- NECK
	[3] = true,    -- SHOULDER
	[4] = false,   -- BODY (shirt)
	[5] = true,    -- CHEST
	[6] = false,   -- WAIST
	[7] = true,    -- LEGS
	[8] = true,    -- FEET
	[9] = false,   -- WRIST
	[10] = false,  -- HAND
	[11] = true,   -- FINGER1
	[12] = true,   -- FINGER2
	[13] = false,  -- TRINKET1
	[14] = false,  -- TRINKET2
	[15] = false,  -- BACK
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
		rescanCount = 10,
		debugLevel = EnchantCheckConstants.DEBUG_LEVELS.WARNING,
		
		-- Smart Notification Settings
		smartNotifications = true,
		minItemLevelForWarnings = 200,
		ignoreHeirlooms = true,
		
		-- Warning Settings
		warnMissingItems = true,
		warnMissingEnchants = true,
		warnMissingGems = true,
		warnLowItemLevel = true,
		warnPurchaseableUpgrades = true,
		
		-- Sound Settings
		enableSounds = false,

		-- Content-Specific Settings
		suppressLevelingWarnings = true,
		enhancedDungeonChecks = true,
	},
}

----------------------------------------------
-- Item Level Thresholds
----------------------------------------------
-- Item rarity values:
-- 0 = Poor (gray)
-- 1 = Common (white)
-- 2 = Uncommon (green)
-- 3 = Rare (blue)
-- 4 = Epic (purple)
-- 5 = Legendary (orange)
-- 6 = Artifact (gold)
-- 7 = Heirloom (yellow-gold)
EnchantCheckConstants.ITEM_LEVEL = {
	LOW_THRESHOLD_MULTIPLIER = 0.8, -- Items below 80% of average are flagged as low
	HEIRLOOM_RARITY = 7, -- Heirloom items (exempt from low level warnings)
}

----------------------------------------------
-- Socket Upgrade Configuration
----------------------------------------------
EnchantCheckConstants.SOCKET_UPGRADES = {
	MAX_SOCKETS = 1, -- Head, wrist, and waist can have 1 socket added via Jewelbinder
	UPGRADEABLE_SLOTS = {1, 9, 6}, -- HEAD, WRIST, WAIST
}

----------------------------------------------
-- UI Constants
----------------------------------------------
EnchantCheckConstants.UI = {
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
-- Slot Overlay Configuration
----------------------------------------------

-- Maps slot ID to the paperdoll frame name suffix
-- Usage: _G[prefix .. SLOT_FRAME_NAMES[slotId] .. "Slot"]
-- where prefix is "Character" or "Inspect"
EnchantCheckConstants.SLOT_FRAME_NAMES = {
	[1] = "Head",
	[2] = "Neck",
	[3] = "Shoulder",
	[4] = "Body",       -- Shirt
	[5] = "Chest",
	[6] = "Waist",
	[7] = "Legs",
	[8] = "Feet",
	[9] = "Wrist",
	[10] = "Hands",
	[11] = "Finger0",
	[12] = "Finger1",
	[13] = "Trinket0",
	[14] = "Trinket1",
	[15] = "Back",
	[16] = "MainHand",
	[17] = "SecondaryHand",
}

EnchantCheckConstants.OVERLAY = {
	ICON_SIZE = 14,
	ICON_PADDING = 1,
	BORDER_SIZE = 2,
	BORDER_COLORS = {
		ERROR = { r = 1, g = 0, b = 0, a = 0.9 },     -- Red
		WARNING = { r = 1, g = 1, b = 0, a = 0.9 },   -- Yellow
	},
	ICONS = {
		MISSING_ENCHANT = "Interface\\Icons\\INV_Enchant_FormulaSuperior_01",
		MISSING_GEM = "Interface\\Icons\\INV_Misc_Gem_01",
		LOW_ILVL = "Interface\\Icons\\Spell_ChargeDown",
		PURCHASEABLE_UPGRADE = "Interface\\Icons\\INV_Misc_Coin_01",
	},
	TOOLTIPS = {
		MISSING_ENCHANT = "Missing enchant",
		MISSING_GEM = "Missing gem",
		LOW_ILVL = "Low item level",
		PURCHASEABLE_UPGRADE = "Can add sockets",
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

-- Content type detection
EnchantCheckConstants.CONTENT_TYPES = {
	LEVELING = "LEVELING",
	DUNGEON = "DUNGEON", 
	MYTHIC_PLUS = "MYTHIC_PLUS",
	RAID = "RAID",
	PVP = "PVP",
	ENDGAME = "ENDGAME"
}


-- Content-based item level requirements (Midnight Season 1, post-squish)
-- These thresholds determine when enchant/gem warnings are shown based on content type
-- LEVELING: 0 (relaxed - no ilvl requirement, suppress most warnings)
-- DUNGEON: 220 (Adventurer baseline)
-- MYTHIC_PLUS: 250 (Champion track / M+ entry)
-- RAID: 246 (Normal raid entry level)
-- PVP: 233 (Veteran baseline)
EnchantCheckConstants.CONTENT_ILVL_REQUIREMENTS = {
	[EnchantCheckConstants.CONTENT_TYPES.LEVELING] = 0,
	[EnchantCheckConstants.CONTENT_TYPES.DUNGEON] = 220,
	[EnchantCheckConstants.CONTENT_TYPES.MYTHIC_PLUS] = 250,
	[EnchantCheckConstants.CONTENT_TYPES.RAID] = 246,
	[EnchantCheckConstants.CONTENT_TYPES.PVP] = 233,
	[EnchantCheckConstants.CONTENT_TYPES.ENDGAME] = 250
}

-- Constants are already globally available from line 7