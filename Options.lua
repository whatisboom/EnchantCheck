----------------------------------------------
-- Options Panel (AceConfig, provided by BoomForge)
----------------------------------------------

local Options = {}
EnchantCheck.Options = Options

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Fractions of a row -- used to lay several entries out per row (AceGUI wraps
-- once accumulated relative width in a row exceeds 1.0). Named widths like
-- "half" are a fixed pixel size calibrated for small addon dialogs, not a
-- fraction of this panel's actual (much wider) Blizzard Settings container,
-- so every multi-column row here uses "relative" instead.
local HALF_WIDTH = { width = "relative", relWidth = 0.5 }
local THIRD_WIDTH = { width = "relative", relWidth = 0.33 }

-- Builds one boolean toggle entry backed by EnchantCheck's existing
-- GetSetting/SetSetting, the same source of truth /ec set and /ec toggle use.
-- `widthSpec` defaults to a full-width row; pass THIRD_WIDTH (or similar) to
-- lay several toggles out per row instead.
local function Toggle(key, order, name, desc, widthSpec)
	widthSpec = widthSpec or { width = "full" }
	return {
		order = order,
		type = "toggle",
		width = widthSpec.width,
		relWidth = widthSpec.relWidth,
		name = name,
		desc = desc,
		get = function() return EnchantCheck:GetSetting(key) end,
		set = function(_, val) EnchantCheck:SetSetting(key, val) end,
	}
end

-- Display order for severity dropdowns, most to least severe -- AceGUI's
-- select widget otherwise iterates `values` in undefined hash order.
local SEVERITY_SORT_ORDER = { "error", "warning", "off" }

-- Builds one severity dropdown entry (off/warning/error) backed by
-- GetSetting/SetSetting, validated the same way /ec set validates it
-- against EnchantCheckConstants.ENUM_SETTINGS.
local function Select(key, order, name, desc, values, widthSpec)
	widthSpec = widthSpec or {}
	return {
		order = order,
		type = "select",
		width = widthSpec.width,
		relWidth = widthSpec.relWidth,
		name = name,
		desc = desc,
		values = values,
		sorting = SEVERITY_SORT_ORDER,
		get = function() return EnchantCheck:GetSetting(key) end,
		set = function(_, val) EnchantCheck:SetSetting(key, val) end,
	}
end

-- True if LibSharedMedia has zero sounds registered -- used to decide
-- whether the sound dropdown's description needs to point users at
-- LibSharedMedia to get any choices at all.
local function HasNoSounds()
	local LSM = LibStub("LibSharedMedia-3.0")
	return #LSM:List(LSM.MediaType.SOUND) == 0
end

function Options:Setup()
	local L = LibStub("AceLocale-3.0"):GetLocale("EnchantCheck")
	local LSM = LibStub("LibSharedMedia-3.0")
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
			smartNotifications = Toggle("smartNotifications", 21, L["OPT_SMART_NOTIFICATIONS"], L["OPT_SMART_NOTIFICATIONS_DESC"], THIRD_WIDTH),
			ignoreHeirlooms = Toggle("ignoreHeirlooms", 22, L["OPT_IGNORE_HEIRLOOMS"], L["OPT_IGNORE_HEIRLOOMS_DESC"], THIRD_WIDTH),

			warningsHeader = { order = 30, type = "header", name = L["OPT_SECTION_WARNINGS"] },

			-- Simple warning toggles, condensed 3 per row.
			warnMissingItems = Toggle("warnMissingItems", 31, L["OPT_WARN_MISSING_ITEMS"], L["OPT_WARN_MISSING_ITEMS_DESC"], THIRD_WIDTH),
			warnMissingGems = Toggle("warnMissingGems", 32, L["OPT_WARN_MISSING_GEMS"], L["OPT_WARN_MISSING_GEMS_DESC"], THIRD_WIDTH),
			warnLowItemLevel = Toggle("warnLowItemLevel", 33, L["OPT_WARN_LOW_ITEM_LEVEL"], L["OPT_WARN_LOW_ITEM_LEVEL_DESC"], THIRD_WIDTH),
			warnWrongArmorType = Toggle("warnWrongArmorType", 34, L["OPT_WARN_WRONG_ARMOR_TYPE"], L["OPT_WARN_WRONG_ARMOR_TYPE_DESC"], THIRD_WIDTH),
			warnWrongStats = Toggle("warnWrongStats", 35, L["OPT_WARN_WRONG_STATS"], L["OPT_WARN_WRONG_STATS_DESC"], THIRD_WIDTH),

			-- Own section so the row of 3 severity dropdowns always starts a
			-- fresh line, rather than sharing a row with whatever the
			-- Warnings section's toggles happened to leave partially filled.
			-- 3 columns x 2 rows: severity dropdowns on row 1, icon-only
			-- checkboxes directly below each on row 2.
			severityHeader = { order = 40, type = "header", name = L["OPT_SECTION_SEVERITY"] },
			primaryEnchantSeverity = Select("primaryEnchantSeverity", 41, L["OPT_PRIMARY_ENCHANT_SEVERITY"], L["OPT_PRIMARY_ENCHANT_SEVERITY_DESC"], severityValues, THIRD_WIDTH),
			secondaryEnchantSeverity = Select("secondaryEnchantSeverity", 42, L["OPT_SECONDARY_ENCHANT_SEVERITY"], L["OPT_SECONDARY_ENCHANT_SEVERITY_DESC"], severityValues, THIRD_WIDTH),
			socketUpgradeSeverity = Select("socketUpgradeSeverity", 43, L["OPT_SOCKET_UPGRADE_SEVERITY"], L["OPT_SOCKET_UPGRADE_SEVERITY_DESC"], severityValues, THIRD_WIDTH),
			primaryEnchantIconOnly = Toggle("primaryEnchantIconOnly", 44, L["OPT_PRIMARY_ENCHANT_ICON_ONLY"], L["OPT_PRIMARY_ENCHANT_ICON_ONLY_DESC"], THIRD_WIDTH),
			secondaryEnchantIconOnly = Toggle("secondaryEnchantIconOnly", 45, L["OPT_SECONDARY_ENCHANT_ICON_ONLY"], L["OPT_SECONDARY_ENCHANT_ICON_ONLY_DESC"], THIRD_WIDTH),
			socketUpgradeIconOnly = Toggle("socketUpgradeIconOnly", 46, L["OPT_SOCKET_UPGRADE_ICON_ONLY"], L["OPT_SOCKET_UPGRADE_ICON_ONLY_DESC"], THIRD_WIDTH),

			soundsHeader = { order = 50, type = "header", name = L["OPT_SECTION_SOUNDS"] },
			enableSounds = Toggle("enableSounds", 51, L["OPT_ENABLE_SOUNDS"], L["OPT_ENABLE_SOUNDS_DESC"]),
			soundId = {
				order = 52,
				type = "select",
				width = THIRD_WIDTH.width,
				relWidth = THIRD_WIDTH.relWidth,
				name = L["OPT_SOUND"],
				desc = function()
					if HasNoSounds() then
						return L["OPT_SOUND_DESC"] .. " " .. L["OPT_SOUND_DESC_EXPANDABLE"]
					end
					return L["OPT_SOUND_DESC"]
				end,
				disabled = function() return not EnchantCheck:GetSetting("enableSounds") end,
				values = function()
					local v = {}
					for _, key in ipairs(LSM:List(LSM.MediaType.SOUND)) do v[key] = key end
					return v
				end,
				get = function() return EnchantCheck:GetSetting("soundId") end,
				set = function(_, val) EnchantCheck:SetSetting("soundId", val) end,
			},
			soundPreview = {
				order = 53,
				type = "execute",
				name = L["OPT_SOUND_PREVIEW"],
				desc = L["OPT_SOUND_PREVIEW_DESC"],
				disabled = function() return not EnchantCheck:GetSetting("enableSounds") end,
				func = function() EnchantCheck:PlayNotificationSound() end,
			},

			advancedHeader = { order = 90, type = "header", name = L["OPT_SECTION_ADVANCED"] },
			debugLevel = {
				order = 91,
				type = "select",
				width = THIRD_WIDTH.width,
				relWidth = THIRD_WIDTH.relWidth,
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
