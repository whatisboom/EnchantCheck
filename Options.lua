----------------------------------------------
-- Options Panel (AceConfig, provided by BoomForge)
----------------------------------------------

local Options = {}
EnchantCheck.Options = Options

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Builds one boolean toggle entry backed by EnchantCheck's existing
-- GetSetting/SetSetting, the same source of truth /ec set and /ec toggle use.
local function Toggle(key, order, name, desc)
	return {
		order = order,
		type = "toggle",
		width = "full",
		name = name,
		desc = desc,
		get = function() return EnchantCheck:GetSetting(key) end,
		set = function(_, val) EnchantCheck:SetSetting(key, val) end,
	}
end

-- Builds one severity dropdown entry (off/warning/error) backed by
-- GetSetting/SetSetting, validated the same way /ec set validates it
-- against EnchantCheckConstants.ENUM_SETTINGS.
local function Select(key, order, name, desc, values)
	return {
		order = order,
		type = "select",
		name = name,
		desc = desc,
		values = values,
		get = function() return EnchantCheck:GetSetting(key) end,
		set = function(_, val) EnchantCheck:SetSetting(key, val) end,
	}
end

function Options:Setup()
	local L = LibStub("AceLocale-3.0"):GetLocale("EnchantCheck")
	local DEBUG_LEVELS = EnchantCheckConstants.DEBUG_LEVELS

	local severityValues = {
		["off"] = L["OPT_SEVERITY_OFF"],
		["warning"] = L["OPT_SEVERITY_WARNING"],
		["error"] = L["OPT_SEVERITY_ERROR"],
	}

	local options = {
		type = "group",
		name = "EnchantCheck",
		args = {
			generalHeader = { order = 10, type = "header", name = L["OPT_SECTION_GENERAL"] },
			enable = Toggle("enable", 11, L["OPT_ENABLE"], L["OPT_ENABLE_DESC"]),

			smartHeader = { order = 20, type = "header", name = L["OPT_SECTION_SMART_FILTERING"] },
			smartNotifications = Toggle("smartNotifications", 21, L["OPT_SMART_NOTIFICATIONS"], L["OPT_SMART_NOTIFICATIONS_DESC"]),
			ignoreHeirlooms = Toggle("ignoreHeirlooms", 22, L["OPT_IGNORE_HEIRLOOMS"], L["OPT_IGNORE_HEIRLOOMS_DESC"]),

			warningsHeader = { order = 30, type = "header", name = L["OPT_SECTION_WARNINGS"] },
			warnMissingItems = Toggle("warnMissingItems", 31, L["OPT_WARN_MISSING_ITEMS"], L["OPT_WARN_MISSING_ITEMS_DESC"]),
			primaryEnchantSeverity = Select("primaryEnchantSeverity", 32, L["OPT_PRIMARY_ENCHANT_SEVERITY"], L["OPT_PRIMARY_ENCHANT_SEVERITY_DESC"], severityValues),
			primaryEnchantIconOnly = Toggle("primaryEnchantIconOnly", 33, L["OPT_PRIMARY_ENCHANT_ICON_ONLY"], L["OPT_PRIMARY_ENCHANT_ICON_ONLY_DESC"]),
			secondaryEnchantSeverity = Select("secondaryEnchantSeverity", 34, L["OPT_SECONDARY_ENCHANT_SEVERITY"], L["OPT_SECONDARY_ENCHANT_SEVERITY_DESC"], severityValues),
			secondaryEnchantIconOnly = Toggle("secondaryEnchantIconOnly", 35, L["OPT_SECONDARY_ENCHANT_ICON_ONLY"], L["OPT_SECONDARY_ENCHANT_ICON_ONLY_DESC"]),
			warnMissingGems = Toggle("warnMissingGems", 36, L["OPT_WARN_MISSING_GEMS"], L["OPT_WARN_MISSING_GEMS_DESC"]),
			warnLowItemLevel = Toggle("warnLowItemLevel", 37, L["OPT_WARN_LOW_ITEM_LEVEL"], L["OPT_WARN_LOW_ITEM_LEVEL_DESC"]),
			socketUpgradeSeverity = Select("socketUpgradeSeverity", 38, L["OPT_SOCKET_UPGRADE_SEVERITY"], L["OPT_SOCKET_UPGRADE_SEVERITY_DESC"], severityValues),
			socketUpgradeIconOnly = Toggle("socketUpgradeIconOnly", 39, L["OPT_SOCKET_UPGRADE_ICON_ONLY"], L["OPT_SOCKET_UPGRADE_ICON_ONLY_DESC"]),
			warnWrongArmorType = Toggle("warnWrongArmorType", 40, L["OPT_WARN_WRONG_ARMOR_TYPE"], L["OPT_WARN_WRONG_ARMOR_TYPE_DESC"]),
			warnWrongStats = Toggle("warnWrongStats", 41, L["OPT_WARN_WRONG_STATS"], L["OPT_WARN_WRONG_STATS_DESC"]),

			soundsHeader = { order = 50, type = "header", name = L["OPT_SECTION_SOUNDS"] },
			enableSounds = Toggle("enableSounds", 51, L["OPT_ENABLE_SOUNDS"], L["OPT_ENABLE_SOUNDS_DESC"]),

			advancedHeader = { order = 90, type = "header", name = L["OPT_SECTION_ADVANCED"] },
			debugLevel = {
				order = 91,
				type = "select",
				name = L["OPT_DEBUG_LEVEL"],
				desc = L["OPT_DEBUG_LEVEL_DESC"],
				values = {
					[DEBUG_LEVELS.OFF] = L["OPT_DEBUG_LEVEL_OFF"],
					[DEBUG_LEVELS.WARNING] = L["OPT_DEBUG_LEVEL_WARNING"],
					[DEBUG_LEVELS.INFO] = L["OPT_DEBUG_LEVEL_INFO"],
					[DEBUG_LEVELS.NOTICE] = L["OPT_DEBUG_LEVEL_NOTICE"],
				},
				get = function() return EnchantCheck:GetSetting("debugLevel") end,
				set = function(_, val) EnchantCheck:SetSetting("debugLevel", val) end,
			},
		},
	}

	AceConfig:RegisterOptionsTable("EnchantCheck", options)
	self.dialogFrame = AceConfigDialog:AddToBlizOptions("EnchantCheck", "EnchantCheck")
end

function Options:Open()
	if Settings and Settings.OpenToCategory and self.dialogFrame then
		Settings.OpenToCategory(self.dialogFrame.name)
	elseif AceConfigDialog then
		AceConfigDialog:Open("EnchantCheck")
	end
end
