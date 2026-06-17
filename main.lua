----------------------------------------------
-- Module
----------------------------------------------
EnchantCheck = LibStub("AceAddon-3.0"):NewAddon("Enchant Check", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0");

----------------------------------------------
-- Localization
----------------------------------------------
local L = LibStub("AceLocale-3.0"):GetLocale("EnchantCheck")

----------------------------------------------
-- Other libs
----------------------------------------------

----------------------------------------------
-- Constants-dependent locals (initialized in OnInitialize)
----------------------------------------------
local ClassColor
local CheckSlotEnchant = EnchantCheckConstants.ENCHANT_SLOTS
local CheckSlotMissing = EnchantCheckConstants.REQUIRED_SLOTS

----------------------------------------------
-- Config options and debug levels (initialized in OnInitialize)
----------------------------------------------
-- These will be set in OnInitialize to ensure proper loading order
local d_warn, d_info, d_notice, debugLevel

----------------------------------------------
-- Print debug message
----------------------------------------------
function EnchantCheck:Debug(level, msg, ...)
	if debugLevel and level and (level <= debugLevel) then
		self:Printf(msg, ...)
	end
end

----------------------------------------------
-- Configuration Management
----------------------------------------------
function EnchantCheck:GetSetting(key)
	return self.db.profile[key]
end

function EnchantCheck:SetSetting(key, value)
	self.db.profile[key] = value
	self:OnConfigUpdate()
end

function EnchantCheck:ToggleSetting(key)
	local currentValue = self:GetSetting(key)
	if type(currentValue) == "boolean" then
		self:SetSetting(key, not currentValue)
		return not currentValue
	else
		self:Printf("Setting '%s' is not a boolean value", key)
		return nil
	end
end

----------------------------------------------
-- Console Commands
----------------------------------------------
function EnchantCheck:ChatCommand(msg)
	local args = {}
	for word in msg:gmatch("%S+") do
		table.insert(args, word)
	end
	
	if #args == 0 or args[1] == "help" then
		self:ShowHelp()
	elseif args[1] == "config" or args[1] == "settings" then
		self:ShowConfig()
	elseif args[1] == "set" and args[2] and args[3] then
		self:SetConfigValue(args[2], args[3])
	elseif args[1] == "toggle" and args[2] then
		self:ToggleConfigValue(args[2])
	elseif args[1] == "reset" then
		self:ResetConfig()
	elseif args[1] == "check" then
		self:CheckGear("player", true)
	else
		self:Printf("|cffFFFF00Unknown command:|r '%s'. Type |cff00FF00/enchantcheck help|r for available commands.", args[1] or "")
	end
end

function EnchantCheck:ShowHelp()
	self:Printf("|cff00FF00EnchantCheck Commands:|cffFFFFFF")
	self:Printf("  |cffFFFF00/enchantcheck help|cffFFFFFF - Show this help")
	self:Printf("  |cffFFFF00/enchantcheck check|cffFFFFFF - Check your gear")
	self:Printf("  |cffFFFF00/enchantcheck config|cffFFFFFF - Show current settings")
	self:Printf("  |cffFFFF00/enchantcheck set <setting> <value>|cffFFFFFF - Change a setting (use camelCase)")
	self:Printf("  |cffFFFF00/enchantcheck toggle <setting>|cffFFFFFF - Toggle a boolean setting (use camelCase)")
	self:Printf("  |cffFFFF00/enchantcheck reset|cffFFFFFF - Reset all settings to defaults")
	self:Printf("  |cff888888Examples: smartNotifications, ignoreHeirlooms|cffFFFFFF")
end

----------------------------------------------
-- Debug Function
----------------------------------------------

function EnchantCheck:ShowConfig()
	self:Printf("|cff00FF00Current EnchantCheck Settings:|cffFFFFFF")
	
	-- Check if db is available
	if not self.db or not self.db.profile then
		self:Printf("|cffFF0000ERROR: Settings database not initialized!|cffFFFFFF")
		return
	end
	
	-- Show all settings with nil handling
	self:Printf("  Smart Notifications: |cffFFFF00%s|cffFFFFFF", tostring(self:GetSetting("smartNotifications") or "nil"))
	self:Printf("  Ignore Heirlooms: |cffFFFF00%s|cffFFFFFF", tostring(self:GetSetting("ignoreHeirlooms") or "nil"))
	self:Printf("  Enable Sounds: |cffFFFF00%s|cffFFFFFF", tostring(self:GetSetting("enableSounds") or "nil"))
end

function EnchantCheck:SetConfigValue(setting, value)
	local currentValue = self:GetSetting(setting)
	if currentValue == nil then
		self:Printf("Unknown setting: %s", setting)
		return
	end
	
	local newValue
	if type(currentValue) == "boolean" then
		newValue = (value:lower() == "true" or value == "1")
	elseif type(currentValue) == "number" then
		newValue = tonumber(value)
		if not newValue then
			self:Printf("Invalid number value: %s", value)
			return
		end
	else
		newValue = value
	end
	
	self:SetSetting(setting, newValue)
	self:Printf("Set %s to %s", setting, tostring(newValue))
end

function EnchantCheck:ToggleConfigValue(setting)
	local newValue = self:ToggleSetting(setting)
	if newValue ~= nil then
		self:Printf("Toggled %s to %s", setting, tostring(newValue))
	end
end

function EnchantCheck:ResetConfig()
	local defaults = EnchantCheckConstants.DEFAULTS or EnchantCheck.defaults
	if not defaults or not defaults.profile then
		self:Printf("|cffFF0000ERROR: Cannot reset - defaults not available!|cffFFFFFF")
		return
	end
	
	for key, value in pairs(defaults.profile) do
		self.db.profile[key] = value
	end
	self:Printf("Configuration reset to defaults")
	self:OnConfigUpdate()
end

----------------------------------------------
--- Init
----------------------------------------------
function EnchantCheck:OnInitialize()
	ClassColor = EnchantCheckConstants.CLASS_COLORS
	
	-- Set version info
	EnchantCheck.version = EnchantCheckConstants.VERSION
	EnchantCheck.authors = EnchantCheckConstants.AUTHORS
	
	-- Set defaults
	EnchantCheck.defaults = EnchantCheckConstants.DEFAULTS
	
	-- Initialize debug levels
	d_warn = EnchantCheckConstants.DEBUG_LEVELS.WARNING
	d_info = EnchantCheckConstants.DEBUG_LEVELS.INFO
	d_notice = EnchantCheckConstants.DEBUG_LEVELS.NOTICE
	debugLevel = d_warn
	
	-- Initialize database
	self.db = LibStub("AceDB-3.0"):New("EnchantCheckDB", EnchantCheck.defaults, "profile")

	-- Register console commands
	self:RegisterChatCommand("enchantcheck", "ChatCommand")
	self:RegisterChatCommand("ec", "ChatCommand")

	if self.db.profile.enable then
		self:Enable();
	end

	self:Debug(d_notice, L["LOADED"]);
end

----------------------------------------------
-- Event Handlers
----------------------------------------------
function EnchantCheck:OnEnable()
	self:RegisterEvent("INSPECT_READY");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("SOCKET_INFO_SUCCESS");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");

	self:Debug(d_notice, L["ENABLED"]);
end

----------------------------------------------
-- OnDisable()
----------------------------------------------
function EnchantCheck:OnDisable()
	self:UnregisterEvent("INSPECT_READY");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("SOCKET_INFO_SUCCESS");
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	self:UnregisterEvent("PLAYER_LOGIN");

	self:CancelAllTimers()

	-- Hide all overlays
	self:ClearAllOverlays("Character")
	self:ClearAllOverlays("Inspect")

	self:Debug(d_notice, L["DISABLED"]);
end

----------------------------------------------
-- OnConfigUpdate()
----------------------------------------------
function EnchantCheck:OnConfigUpdate()
	-- Enable
	if (self.db.profile.enable) then
		if not EnchantCheck:IsEnabled() then
			EnchantCheck:Enable()
		end
	else
		if EnchantCheck:IsEnabled() then
			EnchantCheck:Disable()
		end
	end
end

----------------------------------------------
-- Item link functions
----------------------------------------------
-- For the player's own equipped gear, C_Item.GetCurrentItemLevel(ItemLocation)
-- returns the same value as the character pane / tooltip — it reflects any
-- scaling cap applied to the equipped instance. GetDetailedItemLevelInfo on the
-- link can be wildly off for items with scaling bonus_ids (e.g. Legion Remix
-- gear reporting 655 when the worn item is actually 102), so we only fall back
-- to it for the inspect case where no ItemLocation is available.
function EnchantCheck:GetActualItemLevel(unit, slot, link)
	if not link or link == "" then
		return 0
	end

	if unit and slot and UnitIsUnit(unit, "player") then
		local loc = ItemLocation:CreateFromEquipmentSlot(slot)
		if loc and C_Item.DoesItemExist(loc) then
			local lvl = C_Item.GetCurrentItemLevel(loc)
			if lvl and lvl > 0 then
				return lvl
			end
		end
	end

	local effective = GetDetailedItemLevelInfo(link)
	if effective and effective > 0 then
		return effective
	end

	local _, _, _, basicLevel = C_Item.GetItemInfo(link)
	return basicLevel or 0
end

-- Extract (enchantID, gemCount) from the item string embedded in a link.
-- Item string format: ItemID:EnchantID:Gem1:Gem2:Gem3:Gem4:...
-- Returns 0, 0 if the link doesn't parse.
function EnchantCheck:ParseEnchantAndGems(link)
	local enchant, g1, g2, g3, g4 = link:match("|Hitem:%d+:(%d*):(%d*):(%d*):(%d*):(%d*)")
	if not enchant then return 0, 0 end
	local gemCount = 0
	if tonumber(g1) and tonumber(g1) > 0 then gemCount = gemCount + 1 end
	if tonumber(g2) and tonumber(g2) > 0 then gemCount = gemCount + 1 end
	if tonumber(g3) and tonumber(g3) > 0 then gemCount = gemCount + 1 end
	if tonumber(g4) and tonumber(g4) > 0 then gemCount = gemCount + 1 end
	return tonumber(enchant) or 0, gemCount
end


----------------------------------------------
-- Smart Notification System
----------------------------------------------


function EnchantCheck:ShouldWarnAboutSlot(slot, item)
	if not CheckSlotEnchant[slot] then return false end
	if not self:GetSetting("smartNotifications") then return true end
	-- Epic+ only; heirlooms (7) cannot be enchanted.
	local rarity = item.rarity or 0
	return rarity >= 4 and rarity ~= 7
end


----------------------------------------------
-- Visual Enhancement Functions
----------------------------------------------

function EnchantCheck:GetColorForSeverity(severity)
	local UI = EnchantCheckConstants.UI
	if severity == UI.SEVERITY.GOOD then return UI.COLORS.GOOD end
	if severity == UI.SEVERITY.INFO then return UI.COLORS.INFO end
	if severity == UI.SEVERITY.WARNING then return UI.COLORS.WARNING end
	if severity == UI.SEVERITY.ERROR then return UI.COLORS.ERROR end
	return UI.COLORS.RESET
end

function EnchantCheck:FormatMessage(message, severity)
	return self:GetColorForSeverity(severity) .. message .. EnchantCheckConstants.UI.COLORS.RESET
end


function EnchantCheck:PlayNotificationSound()
	if not self:GetSetting("enableSounds") then
		return
	end
	
	PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, self:GetSetting("soundChannel"))
end

----------------------------------------------
-- Helper Functions for CheckGear
----------------------------------------------

function EnchantCheck:ProcessItemData(unit, item, slot)
	local _, _, rarity = C_Item.GetItemInfo(item.link)
	local enchant, gemCount = self:ParseEnchantAndGems(item.link)
	item.rarity = rarity or 0
	item.enchant = enchant
	item.gems = gemCount
	item.level = self:GetActualItemLevel(unit, slot, item.link) or 0

	if item.level == 0 then
		self:Debug(d_warn, "Item level is 0 for slot %d (%s)", slot, item.link)
	end

	item.stats = C_Item.GetItemStats(item.link) or {}

	local _, _, _, _, _, classID, subclassID = C_Item.GetItemInfoInstant(item.link)
	item.classID = classID
	item.subclassID = subclassID

	item.sockets = 0
	for label in pairs(item.stats) do
		if label:find("EMPTY_SOCKET_", 1, true) then
			item.sockets = item.sockets + 1
		end
	end
end

function EnchantCheck:CheckMissingItems(items, twoHanded)
	local missingItems = {}
	local hasMissingItems = false
	
	for slot = 1, EnchantCheckConstants.EQUIPMENT_SLOTS.TOTAL do
		if not items[slot].link and not items[slot].id then
			if CheckSlotMissing[slot] and ((slot ~= EnchantCheckConstants.SLOT_IDS.OFFHAND) or not twoHanded) then
				table.insert(missingItems, slot)
				hasMissingItems = true
			end
		end
	end
	
	return missingItems, hasMissingItems
end

function EnchantCheck:CheckMissingEnchants(items)
	local missingEnchants = {}
	local hasMissingEnchants = false

	for slot = 1, EnchantCheckConstants.EQUIPMENT_SLOTS.TOTAL do
		local item = items[slot]
		if item.link and (item.enchant == 0) then
			if self:ShouldWarnAboutSlot(slot, item) then
				local itemType = select(6, C_Item.GetItemInfo(item.link))

				if not (item.rarity == EnchantCheckConstants.ITEM_LEVEL.ARTIFACT_RARITY or (slot == EnchantCheckConstants.SLOT_IDS.OFFHAND and itemType ~= WEAPON)) then
					table.insert(missingEnchants, slot)
					hasMissingEnchants = true
				end
			end
		end
	end
	
	return missingEnchants, hasMissingEnchants
end

function EnchantCheck:CheckMissingGems(items)
	local missingGems = {}
	local hasMissingGems = false

	for slot = 1, EnchantCheckConstants.EQUIPMENT_SLOTS.TOTAL do
		local item = items[slot]
		if item.link and item.gems < item.sockets then
			table.insert(missingGems, slot)
			hasMissingGems = true
		end
	end

	return missingGems, hasMissingGems
end

function EnchantCheck:CheckPurchaseableUpgrades(items)
	local upgradeableItems = {}
	local hasUpgradeableItems = false

	-- Only check if setting is enabled
	if not self:GetSetting("warnPurchaseableUpgrades") then
		return upgradeableItems, hasUpgradeableItems
	end

	-- Check each slot that can have a socket added via Jewelbinder
	for _, slot in ipairs(EnchantCheckConstants.SOCKET_UPGRADES.UPGRADEABLE_SLOTS) do
		local item = items[slot]
		if item.link then
			local totalSockets = item.gems + item.sockets
			if totalSockets < EnchantCheckConstants.SOCKET_UPGRADES.MAX_SOCKETS then
				local socketsNeeded = EnchantCheckConstants.SOCKET_UPGRADES.MAX_SOCKETS - totalSockets
				table.insert(upgradeableItems, {slot = slot, count = socketsNeeded})
				hasUpgradeableItems = true
			end
		end
	end

	return upgradeableItems, hasUpgradeableItems
end

function EnchantCheck:CalculateItemLevels(items, twoHanded)
	local itemLevelMin = 0
	local itemLevelMax = 0
	local itemLevelSum = 0
	local lowLevelItems = {}
	
	for slot = 1, EnchantCheckConstants.EQUIPMENT_SLOTS.TOTAL do
		local item = items[slot]
		if item.link and (slot ~= EnchantCheckConstants.SLOT_IDS.BODY) and (slot ~= EnchantCheckConstants.SLOT_IDS.TABARD) and item.level and item.level > 0 then
			if item.level < itemLevelMin or itemLevelMin == 0 then
				itemLevelMin = item.level
			end
			if item.level > itemLevelMax then
				itemLevelMax = item.level
			end
			itemLevelSum = itemLevelSum + item.level
		end
	end
	
	-- Calculate average item level
	local avgItemLevel = 0
	if itemLevelSum and itemLevelSum > 0 then
		if twoHanded then
			local divisor = EnchantCheckConstants.EQUIPMENT_SLOTS.TWO_HANDED_COUNT
			if divisor and divisor > 0 then
				avgItemLevel = itemLevelSum / divisor
			end
		else
			local divisor = EnchantCheckConstants.EQUIPMENT_SLOTS.ONE_HANDED_COUNT
			if divisor and divisor > 0 then
				avgItemLevel = itemLevelSum / divisor
			end
		end
	end
	
	-- Check for extremely low item levels
	for slot = 1, EnchantCheckConstants.EQUIPMENT_SLOTS.TOTAL do
		local item = items[slot]
		if item.link and item.level and item.level > 0 then
			local shouldWarn = (item.level < avgItemLevel * EnchantCheckConstants.ITEM_LEVEL.LOW_THRESHOLD_MULTIPLIER) and
				(slot ~= EnchantCheckConstants.SLOT_IDS.BODY) and (slot ~= EnchantCheckConstants.SLOT_IDS.TABARD)
			
			-- Check heirloom setting
			if self:GetSetting("ignoreHeirlooms") and item.rarity == EnchantCheckConstants.ITEM_LEVEL.HEIRLOOM_RARITY then
				shouldWarn = false
			end
			
			if shouldWarn then
				table.insert(lowLevelItems, {slot = slot, link = item.link})
			end
		end
	end
	
	return avgItemLevel, itemLevelMin, itemLevelMax, lowLevelItems
end

function EnchantCheck:BuildChatWarnings(unit, results)
	local warnings = {}
	local hasAnyIssues = false

	-- Header
	local displayClass, class = UnitClass(unit)
	local name = UnitName(unit)
	local classColor = ClassColor[class] or "FFFFFF"
	table.insert(warnings, string.format(L["ENCHANT_REPORT_HEADER"],
		"|cff"..classColor..name.."|cffFFFFFF",
		UnitLevel(unit), "|cff"..classColor..displayClass.."|cffFFFFFF"))

	-- Average item level
	local ilvlMsg = string.format(L["AVG_ITEM_LEVEL"], floor(results.avgItemLevel or 0), results.itemLevelMin or 0, results.itemLevelMax or 0)
	table.insert(warnings, self:FormatMessage(ilvlMsg, EnchantCheckConstants.UI.SEVERITY.GOOD))

	-- Low item levels
	if #results.lowLevelItems > 0 and self:GetSetting("warnLowItemLevel") then
		for _, itemData in ipairs(results.lowLevelItems) do
			table.insert(warnings, self:FormatMessage(L["LOW_ITEM_LEVEL"] .. " " .. itemData.link, EnchantCheckConstants.UI.SEVERITY.ERROR))
			hasAnyIssues = true
		end
	end

	-- Missing items
	if #results.missingItems > 0 and self:GetSetting("warnMissingItems") then
		local parts = {}
		for _, slot in ipairs(results.missingItems) do
			table.insert(parts, L["INVSLOT_"..slot])
		end
		table.insert(warnings, self:FormatMessage(L["MISSING_ITEMS"] .. " " .. table.concat(parts, ", "), EnchantCheckConstants.UI.SEVERITY.ERROR))
		hasAnyIssues = true
	end

	-- Missing gems
	if #results.missingGems > 0 and self:GetSetting("warnMissingGems") then
		local parts = {}
		for _, slot in ipairs(results.missingGems) do
			table.insert(parts, L["INVSLOT_"..slot])
		end
		table.insert(warnings, self:FormatMessage(L["MISSING_GEMS"] .. " " .. table.concat(parts, ", "), EnchantCheckConstants.UI.SEVERITY.WARNING))
		hasAnyIssues = true
	end

	-- Purchaseable upgrades
	if #results.upgradeableItems > 0 and self:GetSetting("warnPurchaseableUpgrades") then
		local parts = {}
		for _, itemData in ipairs(results.upgradeableItems) do
			table.insert(parts, L["INVSLOT_"..itemData.slot] .. " (" .. itemData.count .. ")")
		end
		table.insert(warnings, self:FormatMessage(L["UPGRADEABLE_SOCKETS"] .. " " .. table.concat(parts, ", "), EnchantCheckConstants.UI.SEVERITY.WARNING))
		hasAnyIssues = true
	end

	-- Missing enchants
	if #results.missingEnchants > 0 and self:GetSetting("warnMissingEnchants") then
		local parts = {}
		for _, slot in ipairs(results.missingEnchants) do
			table.insert(parts, L["INVSLOT_"..slot])
		end
		table.insert(warnings, self:FormatMessage(L["MISSING_ENCHANTS"] .. " " .. table.concat(parts, ", "), EnchantCheckConstants.UI.SEVERITY.WARNING))
		hasAnyIssues = true
	end

	-- Wrong armor type
	if #results.wrongArmorType > 0 and self:GetSetting("warnWrongArmorType") then
		for _, data in ipairs(results.wrongArmorType) do
			local msg = L["WRONG_ARMOR_TYPE"] .. " " .. L["INVSLOT_"..data.slot] .. " — " .. data.reason
			table.insert(warnings, self:FormatMessage(msg, EnchantCheckConstants.UI.SEVERITY.ERROR))
			hasAnyIssues = true
		end
	end

	-- Wrong stats for spec
	if #results.wrongStats > 0 and self:GetSetting("warnWrongStats") then
		for _, data in ipairs(results.wrongStats) do
			local msg = L["WRONG_STATS"] .. " " .. L["INVSLOT_"..data.slot] .. " — " .. data.reason
			table.insert(warnings, self:FormatMessage(msg, EnchantCheckConstants.UI.SEVERITY.ERROR))
			hasAnyIssues = true
		end
	end

	if not hasAnyIssues then
		table.insert(warnings, self:FormatMessage(L["PROPER_ENCHANTS"], EnchantCheckConstants.UI.SEVERITY.GOOD))
	else
		self:PlayNotificationSound()
	end

	return warnings
end

----------------------------------------------
-- Slot Overlay System
----------------------------------------------

-- Storage for overlay frames: self.slotOverlays[prefix][slotId] = overlayFrame
-- Created lazily per prefix ("Character" or "Inspect")

function EnchantCheck:GetSlotFrame(prefix, slotId)
	local suffix = EnchantCheckConstants.SLOT_FRAME_NAMES[slotId]
	if not suffix then return nil end
	return _G[prefix .. suffix .. "Slot"]
end

function EnchantCheck:CreateSlotOverlay(slotFrame)
	local cfg = EnchantCheckConstants.OVERLAY
	local bs = cfg.BORDER_SIZE

	local overlay = CreateFrame("Frame", nil, slotFrame)
	overlay:SetAllPoints(slotFrame)
	overlay:SetFrameLevel(slotFrame:GetFrameLevel() + 2)

	-- Border using 4 edge textures (top, bottom, left, right)
	local edges = {}
	local top = overlay:CreateTexture(nil, "OVERLAY")
	top:SetPoint("TOPLEFT")
	top:SetPoint("TOPRIGHT")
	top:SetHeight(bs)
	edges[1] = top

	local bottom = overlay:CreateTexture(nil, "OVERLAY")
	bottom:SetPoint("BOTTOMLEFT")
	bottom:SetPoint("BOTTOMRIGHT")
	bottom:SetHeight(bs)
	edges[2] = bottom

	local left = overlay:CreateTexture(nil, "OVERLAY")
	left:SetPoint("TOPLEFT")
	left:SetPoint("BOTTOMLEFT")
	left:SetWidth(bs)
	edges[3] = left

	local right = overlay:CreateTexture(nil, "OVERLAY")
	right:SetPoint("TOPRIGHT")
	right:SetPoint("BOTTOMRIGHT")
	right:SetWidth(bs)
	edges[4] = right

	for _, edge in ipairs(edges) do
		edge:SetColorTexture(1, 0, 0, 0.9)
	end

	overlay.borderEdges = edges

	-- Each issue type owns one corner so position alone communicates type.
	local iconSpecs = {
		{ key = "missingEnchant",     texture = cfg.ICONS.MISSING_ENCHANT,     tooltip = L["TOOLTIP_MISSING_ENCHANT"],     point = "TOPLEFT",     x =  bs, y = -bs },
		{ key = "missingGem",         texture = cfg.ICONS.MISSING_GEM,         tooltip = L["TOOLTIP_MISSING_GEM"],         point = "TOPRIGHT",    x = -bs, y = -bs },
		{ key = "lowIlvl",            texture = cfg.ICONS.LOW_ILVL,            tooltip = L["TOOLTIP_LOW_ILVL"],            point = "BOTTOMLEFT",  x =  bs, y =  bs },
		{ key = "purchaseableUpgrade",texture = cfg.ICONS.PURCHASEABLE_UPGRADE,tooltip = L["TOOLTIP_PURCHASEABLE_UPGRADE"],point = "BOTTOMRIGHT", x = -bs, y =  bs },
	}

	overlay.icons = {}
	for _, spec in ipairs(iconSpecs) do
		local iconFrame = CreateFrame("Frame", nil, overlay)
		iconFrame:SetSize(cfg.ICON_SIZE, cfg.ICON_SIZE)
		iconFrame:SetFrameLevel(overlay:GetFrameLevel() + 1)
		iconFrame:SetPoint(spec.point, overlay, spec.point, spec.x, spec.y)

		local tex = iconFrame:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints()
		tex:SetTexture(spec.texture)
		iconFrame.texture = tex

		local tooltipText = spec.tooltip
		iconFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(tooltipText, 1, 1, 1)
			GameTooltip:Show()
		end)
		iconFrame:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		iconFrame:Hide()
		overlay.icons[spec.key] = iconFrame
	end

	overlay:Hide()
	return overlay
end

function EnchantCheck:CreateAllOverlays(prefix)
	if not self.slotOverlays then
		self.slotOverlays = {}
	end

	-- Already created for this prefix
	if self.slotOverlays[prefix] then return end

	self.slotOverlays[prefix] = {}
	for slotId, _ in pairs(EnchantCheckConstants.SLOT_FRAME_NAMES) do
		local slotFrame = self:GetSlotFrame(prefix, slotId)
		if slotFrame then
			self.slotOverlays[prefix][slotId] = self:CreateSlotOverlay(slotFrame)
		end
	end
end

function EnchantCheck:ClearAllOverlays(prefix)
	if self.slotIssueLines then self.slotIssueLines[prefix] = nil end
	if not self.slotOverlays or not self.slotOverlays[prefix] then return end

	for _, overlay in pairs(self.slotOverlays[prefix]) do
		overlay:Hide()
		for _, icon in pairs(overlay.icons) do
			icon:Hide()
		end
	end
end

function EnchantCheck:BuildSlotIssueLines(prefix, results)
	self.slotIssueLines = self.slotIssueLines or {}
	local lines = {}
	self.slotIssueLines[prefix] = lines

	local SEV = EnchantCheckConstants.UI.SEVERITY
	local function add(slot, text, severity)
		lines[slot] = lines[slot] or {}
		table.insert(lines[slot], { text = text, severity = severity })
	end

	if self:GetSetting("warnLowItemLevel") then
		for _, d in ipairs(results.lowLevelItems) do add(d.slot, L["TOOLTIP_LOW_ILVL"], SEV.ERROR) end
	end
	if self:GetSetting("warnMissingEnchants") then
		for _, slot in ipairs(results.missingEnchants) do add(slot, L["TOOLTIP_MISSING_ENCHANT"], SEV.ERROR) end
	end
	if self:GetSetting("warnMissingGems") then
		for _, slot in ipairs(results.missingGems) do add(slot, L["TOOLTIP_MISSING_GEM"], SEV.ERROR) end
	end
	if self:GetSetting("warnPurchaseableUpgrades") then
		for _, d in ipairs(results.upgradeableItems) do add(d.slot, L["TOOLTIP_PURCHASEABLE_UPGRADE"], SEV.WARNING) end
	end
	if self:GetSetting("warnWrongArmorType") then
		for _, d in ipairs(results.wrongArmorType) do
			add(d.slot, L["WRONG_ARMOR_TYPE"] .. " " .. d.reason, SEV.ERROR)
		end
	end
	if self:GetSetting("warnWrongStats") then
		for _, d in ipairs(results.wrongStats) do
			add(d.slot, L["WRONG_STATS"] .. " " .. d.reason, SEV.ERROR)
		end
	end
end

function EnchantCheck:UpdateSlotOverlays(prefix, results)
	if not self.slotOverlays or not self.slotOverlays[prefix] then
		self:CreateAllOverlays(prefix)
	end
	if not self.slotOverlays or not self.slotOverlays[prefix] then return end

	local cfg = EnchantCheckConstants.OVERLAY

	-- Build per-slot issue map
	local slotIssues = {} -- slotId -> {missingEnchant, missingGem, lowIlvl, purchaseableUpgrade, hasError}

	-- Low item level (error severity)
	if #results.lowLevelItems > 0 and self:GetSetting("warnLowItemLevel") then
		for _, itemData in ipairs(results.lowLevelItems) do
			if not slotIssues[itemData.slot] then slotIssues[itemData.slot] = {} end
			slotIssues[itemData.slot].lowIlvl = true
			slotIssues[itemData.slot].hasError = true
		end
	end

	-- Missing items don't get an overlay icon (the slot is already visibly empty)

	-- Missing enchants (error severity)
	if #results.missingEnchants > 0 and self:GetSetting("warnMissingEnchants") then
		for _, slot in ipairs(results.missingEnchants) do
			if not slotIssues[slot] then slotIssues[slot] = {} end
			slotIssues[slot].missingEnchant = true
			slotIssues[slot].hasError = true
		end
	end

	-- Missing gems (error severity)
	if #results.missingGems > 0 and self:GetSetting("warnMissingGems") then
		for _, slot in ipairs(results.missingGems) do
			if not slotIssues[slot] then slotIssues[slot] = {} end
			slotIssues[slot].missingGem = true
			slotIssues[slot].hasError = true
		end
	end

	-- Purchaseable upgrades (warning severity)
	if #results.upgradeableItems > 0 and self:GetSetting("warnPurchaseableUpgrades") then
		for _, itemData in ipairs(results.upgradeableItems) do
			if not slotIssues[itemData.slot] then slotIssues[itemData.slot] = {} end
			slotIssues[itemData.slot].purchaseableUpgrade = true
		end
	end

	-- Wrong armor type / wrong stats (error severity; red border, no corner icon)
	if #results.wrongArmorType > 0 and self:GetSetting("warnWrongArmorType") then
		for _, data in ipairs(results.wrongArmorType) do
			if not slotIssues[data.slot] then slotIssues[data.slot] = {} end
			slotIssues[data.slot].hasError = true
		end
	end
	if #results.wrongStats > 0 and self:GetSetting("warnWrongStats") then
		for _, data in ipairs(results.wrongStats) do
			if not slotIssues[data.slot] then slotIssues[data.slot] = {} end
			slotIssues[data.slot].hasError = true
		end
	end

	-- Apply overlays
	for slotId, overlay in pairs(self.slotOverlays[prefix]) do
		local issues = slotIssues[slotId]
		if issues then
			-- Set border color based on severity
			local borderColor = issues.hasError and cfg.BORDER_COLORS.ERROR or cfg.BORDER_COLORS.WARNING
			for _, edge in ipairs(overlay.borderEdges) do
				edge:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
			end

			-- Each icon's position is fixed at creation; just toggle visibility.
			for key, icon in pairs(overlay.icons) do
				if issues[key] then
					icon:Show()
				else
					icon:Hide()
				end
			end

			overlay:Show()
		else
			overlay:Hide()
			for _, icon in pairs(overlay.icons) do
				icon:Hide()
			end
		end
	end
end

----------------------------------------------
-- Character Frame Auto-Check
----------------------------------------------
function EnchantCheck:OnCharacterFrameShow()
	self:CheckGear("player")
end

----------------------------------------------
-- Gear Checking System
----------------------------------------------
function EnchantCheck:CheckGear(unit, printWarnings)
	local framePrefix = (unit == "player") and "Character" or "Inspect"

	-- Generation token: a newer scan for this frame invalidates pending
	-- ContinueOnItemLoad callbacks from older scans so stale data can't
	-- overwrite fresh overlays.
	self._scanGens = self._scanGens or {}
	self._scanGens[framePrefix] = (self._scanGens[framePrefix] or 0) + 1
	local gen = self._scanGens[framePrefix]

	local items = {}
	local pending = 1  -- guard so we always finish even if all slots are cached

	local function finish()
		if self._scanGens[framePrefix] ~= gen then return end

		-- Titan's Grip and dual-wield produce both slots occupied; a true 2H
		-- always leaves offhand empty.
		local twoHanded = items[EnchantCheckConstants.SLOT_IDS.MAINHAND].link ~= nil
			and items[EnchantCheckConstants.SLOT_IDS.OFFHAND].link == nil

		local avgItemLevel, itemLevelMin, itemLevelMax, lowLevelItems = self:CalculateItemLevels(items, twoHanded)

		local results = {
			avgItemLevel = avgItemLevel,
			itemLevelMin = itemLevelMin,
			itemLevelMax = itemLevelMax,
			lowLevelItems = lowLevelItems,
			missingItems = self:CheckMissingItems(items, twoHanded),
			missingEnchants = self:CheckMissingEnchants(items),
			missingGems = self:CheckMissingGems(items),
			upgradeableItems = self:CheckPurchaseableUpgrades(items),
			wrongArmorType = self:CheckWrongArmorType(unit, items),
			wrongStats = self:CheckWrongStats(unit, items),
		}

		self:BuildSlotIssueLines(framePrefix, results)
		self:UpdateSlotOverlays(framePrefix, results)

		if printWarnings then
			local warnings = self:BuildChatWarnings(unit, results)
			for _, warning in ipairs(warnings) do
				self:Print(warning)
			end
		end
	end

	for slot = 1, EnchantCheckConstants.EQUIPMENT_SLOTS.TOTAL do
		local item = {
			gems = 0,
			rarity = 0,
			enchant = 0,
			level = 0,
			stats = {},
			sockets = 0,
		}
		item.id = GetInventoryItemID(unit, slot)
		item.link = GetInventoryItemLink(unit, slot)
		items[slot] = item

		if item.link then
			if C_Item.GetItemInfo(item.link) then
				self:ProcessItemData(unit, item, slot)
			else
				pending = pending + 1
				local itemObj = Item:CreateFromEquipmentSlot(slot, unit)
				if itemObj and not itemObj:IsItemEmpty() then
					itemObj:ContinueOnItemLoad(function()
						if self._scanGens[framePrefix] ~= gen then return end
						-- Re-read the link in case the slot changed while we waited.
						item.link = GetInventoryItemLink(unit, slot) or item.link
						if item.link and C_Item.GetItemInfo(item.link) then
							self:ProcessItemData(unit, item, slot)
						end
						pending = pending - 1
						if pending == 0 then finish() end
					end)
				else
					pending = pending - 1
				end
			end
		end
	end

	pending = pending - 1
	if pending == 0 then finish() end
end




----------------------------------------------
-- Debounce(key, delay, fn)
----------------------------------------------
-- Cancels any pending timer stored at self[key] and schedules fn to run
-- after `delay` seconds, clearing the key when it fires. Used to coalesce
-- bursty events (INSPECT_READY, SOCKET_INFO_SUCCESS, UNIT_INVENTORY_CHANGED)
-- into a single deferred rescan.
function EnchantCheck:Debounce(key, delay, fn)
	if self[key] then
		self:CancelTimer(self[key])
	end
	self[key] = self:ScheduleTimer(function()
		self[key] = nil
		fn()
	end, delay)
end

----------------------------------------------
-- INSPECT_READY()
----------------------------------------------
function EnchantCheck:INSPECT_READY(event, guid)
	-- Hook inspect frame hide to clean up overlays (once)
	if InspectFrame and not self.inspectHideHooked then
		self:HookScript(InspectFrame, "OnHide", "InspectFrame_OnHide")
		self.inspectHideHooked = true
	end

	-- INSPECT_READY fires multiple times as item data loads; debounce so we
	-- only run once after all data is available.
	if InspectFrame and InspectFrame.unit then
		local unit = InspectFrame.unit
		self:Debounce("inspectCheckTimer", 0.5, function()
			self:CreateAllOverlays("Inspect")
			self:CheckGear(unit)
		end)
	end
end

----------------------------------------------
-- PLAYER_EQUIPMENT_CHANGED()
----------------------------------------------
-- Fires after the slot has been updated, so GetInventoryItemLink reflects
-- the newly-equipped item. UNIT_INVENTORY_CHANGED fires too early and would
-- scan stale slot data.
function EnchantCheck:PLAYER_EQUIPMENT_CHANGED(event, equipSlot, hasCurrent)
	self:CheckGear("player")
end

----------------------------------------------
-- SOCKET_INFO_SUCCESS()
----------------------------------------------
-- PLAYER_EQUIPMENT_CHANGED does not fire when a gem is socketed into an
-- already-equipped item, so the missing-gem overlay needs its own trigger.
-- The event fires before WoW finishes updating the equipped item's link, so
-- a small delay lets the slot/cache settle before we re-parse. The gen
-- token in CheckGear absorbs any duplicates.
function EnchantCheck:SOCKET_INFO_SUCCESS(event)
	self:Debounce("socketRescanTimer", 0.5, function()
		self:CheckGear("player")
	end)
end

----------------------------------------------
-- UNIT_INVENTORY_CHANGED()
----------------------------------------------
-- Catches enchant application on equipped items (both first-time and
-- replacement), which PLAYER_EQUIPMENT_CHANGED does not reliably fire for.
-- The equipped item's link is briefly stale after this event (same caveat
-- as SOCKET_INFO_SUCCESS), so we delay before re-parsing. The gen token in
-- CheckGear absorbs duplicates from unrelated inventory churn.
function EnchantCheck:UNIT_INVENTORY_CHANGED(event, unit)
	if unit ~= "player" then return end
	self:Debounce("inventoryRescanTimer", 0.5, function()
		self:CheckGear("player")
	end)
end

----------------------------------------------
-- InspectFrame_OnHide()
----------------------------------------------
function EnchantCheck:InspectFrame_OnHide()
	if self.inspectCheckTimer then
		self:CancelTimer(self.inspectCheckTimer)
		self.inspectCheckTimer = nil
	end
	self:ClearAllOverlays("Inspect")
end

----------------------------------------------
-- PLAYER_ENTERING_WORLD()
----------------------------------------------
function EnchantCheck:PLAYER_ENTERING_WORLD(event)
	local inInstance, instanceType = IsInInstance()
	if inInstance and (instanceType ~= "none") and (UnitLevel("player") == GetMaxLevelForPlayerExpansion()) then
		self:CheckGear("player", true)
	end
end

----------------------------------------------
-- PLAYER_LOGIN()
----------------------------------------------
function EnchantCheck:PLAYER_LOGIN(event)
	-- Create overlays and hook character frame for auto-check
	self:CreateAllOverlays("Character")
	self:RegisterTooltipHook()
	if PaperDollFrame then
		self:HookScript(PaperDollFrame, "OnShow", "OnCharacterFrameShow")
	end
end
