----------------------------------------------
-- Module
----------------------------------------------
EnchantCheck = LibStub("AceAddon-3.0"):NewAddon("Enchant Check", 
	"AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0");	

----------------------------------------------
-- Localization
----------------------------------------------
local L = LibStub("AceLocale-3.0"):GetLocale("EnchantCheck", true)
local LI = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()

----------------------------------------------
-- Other libs
----------------------------------------------
local libItemUpgrade = LibStub("LibItemUpgradeInfo-1.0")

----------------------------------------------
-- Version
----------------------------------------------
local _, _, rev = string.find("$Rev: 36 $", "([0-9]+)")
EnchantCheck.version = "0.8 beta (r"..rev..")"
EnchantCheck.authors = "nyyr"

-- Current max level for automated self-checks
local MAX_LEVEL = 100

-- Setup class colors
local ClassColor = {
	["MAGE"] =		"69CCF0",
	["WARLOCK"] =	"9482C9",
	["PRIEST"] =	"FFFFFF",
	["DRUID"] =		"FF7D0A",
	["SHAMAN"] =	"0070DE",
	["PALADIN"] =	"F58CBA",
	["ROGUE"] =		"FFF569",
	["HUNTER"] =	"ABD473",
	["WARRIOR"] =	"C79C6E",
	["DEATHKNIGHT"] = "C41F3B",
	["MONK"] = 		"00FF96"
}

-- What slots need enchants?
local CheckSlotEnchant = {
	[INVSLOT_HEAD] = false,
	[INVSLOT_NECK] = true,
	[INVSLOT_SHOULDER] = false,
	[INVSLOT_BACK] = true,
	[INVSLOT_CHEST] = false,
	[INVSLOT_BODY] = false, -- shirt
	[INVSLOT_TABARD] = false,
	[INVSLOT_WRIST] = false,
	
	[INVSLOT_HAND] = false,
	[INVSLOT_WAIST] = false,
	[INVSLOT_LEGS] = false,
	[INVSLOT_FEET] = false,
	[INVSLOT_FINGER1] = true,
	[INVSLOT_FINGER2] = true,
	[INVSLOT_TRINKET1] = false,
	[INVSLOT_TRINKET2] = false,
	
	[INVSLOT_MAINHAND] = true,
	[INVSLOT_OFFHAND] = true,
}

-- What slots must have an item?
local CheckSlotMissing = {
	[INVSLOT_HEAD] = true,
	[INVSLOT_NECK] = true,
	[INVSLOT_SHOULDER] = true,
	[INVSLOT_BACK] = true,
	[INVSLOT_CHEST] = true,
	[INVSLOT_BODY] = false, -- shirt
	[INVSLOT_TABARD] = false,
	[INVSLOT_WRIST] = true,
	
	[INVSLOT_HAND] = true,
	[INVSLOT_WAIST] = true,
	[INVSLOT_LEGS] = true,
	[INVSLOT_FEET] = true,
	[INVSLOT_FINGER1] = true,
	[INVSLOT_FINGER2] = true,
	[INVSLOT_TRINKET1] = true,
	[INVSLOT_TRINKET2] = true,
	
	[INVSLOT_MAINHAND] = true,
	[INVSLOT_OFFHAND] = true,
}

-- Which main-hand weapons require an off-hand item?
local CheckOffHand = {
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

----------------------------------------------
-- Config options
----------------------------------------------
EnchantCheck.defaults = {
	profile = {
		enable = true,
		rescanTimer = 1,
		rescanCount = 2,
	},
}

----------------------------------------------
-- Debugging levels
--   0 Off
--   1 Warning
--   2 Info
--   3 Notice
----------------------------------------------
local d_warn = 1
local d_info = 2
local d_notice = 3
local debugLevel = d_notice

----------------------------------------------
-- Print debug message
----------------------------------------------
function EnchantCheck:Debug(level, msg, ...)
	if (level <= debugLevel) then
		self:Printf(msg, ...)
	end
end

----------------------------------------------
--- Init
----------------------------------------------
function EnchantCheck:OnInitialize()
	-- Load our database
	self.db = LibStub("AceDB-3.0"):New("EnchantCheckDB", EnchantCheck.defaults, "profile")
	
	EnchantCheckFrameTitle:SetText("Enchant Check v"..self.version)
	
	CharacterFrameEnchantCheckButton:SetText(L["BTN_CHECK_ENCHANTS"])
	InspectFrameEnchantCheckButton:SetText(L["BTN_CHECK_ENCHANTS"])
	InspectFrameInviteButton:SetText(L["BTN_INVITE"])
	
	EnchantCheckItemsFrame.titleFont:SetText(L["UI_ITEMS_TITLE"])
	EnchantCheckGemsFrame.titleFont:SetText(L["UI_GEMS_TITLE"])
	EnchantCheckEnchantsFrame.titleFont:SetText(L["UI_ENCHANTS_TITLE"])
	
	if self.db.profile.enable then
		self:Enable()
	end
	
	self:Debug(d_notice, L["LOADED"])
end

----------------------------------------------
-- OnEnable()
----------------------------------------------
function EnchantCheck:OnEnable()
	self:RegisterEvent("INSPECT_READY")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:Debug(d_notice, L["ENABLED"])
end

----------------------------------------------
-- OnDisable()
----------------------------------------------
function EnchantCheck:OnDisable()
	self:UnregisterEvent("INSPECT_READY")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	self:Debug(d_notice, L["DISABLED"])
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
-- GetActualItemLevel(link)
----------------------------------------------
function EnchantCheck:GetActualItemLevel(link)
	return libItemUpgrade:GetUpgradedItemLevel(link)
end

----------------------------------------------
-- CheckGear(unit)
----------------------------------------------
function EnchantCheck:CheckGear(unit, items, iter, printWarnings)
	local report = {}
	local warnings = {}
	local missingItems = {}
	local missingGems = {}
	local missingEnchants = {}
	local missingBlacksmithGems = {}
	local hasMissingItems, hasMissingEnchants, hasMissingGems, hasMissingBlacksmithGems
	local hasMissingBeltGem
	local twoHanded
	local itemLevelMin = 0
	local itemLevelMax = 0
	local itemLevelSum = 0
	local avgItemLevel = 0
	--local isEnchanter
	--local isBlacksmith
	local doRescan
	
	if not items then items = {} end
	if not iter then iter = 0 end
	
	self.scanInProgress = true
	
	--[[ profession bonuses (no longer existing at level 100)
	if unit == "player" then
		local prof1, prof2 = GetProfessions()
		for i,v in ipairs({prof1, prof2}) do
			local _, _, skillLevel, _, _, _, skillLine = GetProfessionInfo(v)
			if (skillLine == 333) and (skillLevel >= 400) then -- Enchanting, first learned from trainer
				isEnchanter = true
			elseif (skillLine == 164) and (skillLevel >= 400) then -- Blacksmith, first learned from trainer
				isBlacksmith = true
			end
		end
	end
	
	CheckSlotEnchant[INVSLOT_FINGER1] = isEnchanter
	CheckSlotEnchant[INVSLOT_FINGER2] = isEnchanter
	]]
	
	-- iterate over equipment slots
	for i = 1,18 do
		local item = {}
		item.id = GetInventoryItemID(unit, i)
		item.link = GetInventoryItemLink(unit, i)
		
		if item.link then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel,
				itemType, itemSubType, itemStackCount, itemEquipLoc,
				itemTexture, itemSellPrice = GetItemInfo(item.link)

			-- from http://www.wowwiki.com/ItemLink
			local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
				Suffix, Unique, LinkLvl, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
			
			-- item level
			--item.level = itemLevel
			item.level = self:GetActualItemLevel(item.link)
			if (i ~= INVSLOT_BODY) and (i ~= INVSLOT_TABARD) then
				if item.level < itemLevelMin or itemLevelMin == 0 then
					itemLevelMin = item.level
				end
				if item.level > itemLevelMax then
					itemLevelMax = item.level
				end
				itemLevelSum = itemLevelSum + item.level
			end
			
			-- misc
			item.rarity = itemRarity
			item.stats = GetItemStats(item.link)
			
			-- gems and sockets
			item.gems = 0
			if Gem1 and Gem1+0 > 0 then item.gems = item.gems + 1 end
			if Gem2 and Gem2+0 > 0  then item.gems = item.gems + 1 end
			if Gem3 and Gem3+0 > 0  then item.gems = item.gems + 1 end
			if Gem4 and Gem4+0 > 0  then item.gems = item.gems + 1 end
			item.sockets = 
				(item.stats['EMPTY_SOCKET_RED'] or 0) + 
				(item.stats['EMPTY_SOCKET_YELLOW'] or 0) +
				(item.stats['EMPTY_SOCKET_BLUE'] or 0) +
				(item.stats['EMPTY_SOCKET_META'] or 0) +
				(item.stats['EMPTY_SOCKET_PRISMATIC'] or 0)
			
			--[[ belt buckle (no longer available in at level 100)
			if i == INVSLOT_WAIST then
				item.sockets = item.sockets + 1
				hasMissingBeltGem = (item.gems < item.sockets)
			end
			]]
			
			--[[ BS sockets (no longer available in at level 100)
			if isBlacksmith then
				if i == INVSLOT_HAND then
					item.sockets = item.sockets + 1
					if item.gems < item.sockets then
						table.insert(missingBlacksmithGems, i)
						hasMissingBlacksmithGems = true
					end
				elseif i == INVSLOT_WRIST then
					item.sockets = item.sockets + 1
					if item.gems < item.sockets then
						table.insert(missingBlacksmithGems, i)
						hasMissingBlacksmithGems = true
					end
				end
			end
			]]
			
			-- missing gems
			if item.gems < item.sockets then
				table.insert(missingGems, i)
				hasMissingGems = true
			end
			
			-- enchant
			item.enchant = Enchant + 0 -- enchant ID
			if (item.enchant == 0) and CheckSlotEnchant[i] then
				table.insert(missingEnchants, i)
				hasMissingEnchants = true
			end
			
			-- two-hander?
			if i == INVSLOT_MAINHAND then
				twoHanded = not CheckOffHand[itemSubType]
			end
			
		elseif item.id then
			--self:Debug(d_warn, "Item link for ID "..tostring(item.id).." not ready yet!")
			doRescan = true
			
		else
			if CheckSlotMissing[i] and ((i ~= INVSLOT_OFFHAND) or not twoHanded) then
				table.insert(missingItems, i)
				hasMissingItems = true
			end
			
		end
		
		items[i] = item
	end
	
	if doRescan then
		if iter < self.db.profile.rescanCount then
			self:Debug(d_info, "|cffFFFF00" .. L["RESCAN"] .. "|cffFFFFFF")
			self.rescanTimer = self:ScheduleTimer("CheckGear", self.db.profile.rescanTimer, unit, items, iter+1)
			return
		else
			self:Debug(d_warn,  "|cffFF0000" .. L["SCAN_INCOMPLETE"] .. "|cffFFFFFF")
			self.scanInProgress = nil
			return
		end
	end
	
	local items_state = true
	local gems_state = true
	local enchants_state = true
	
	-- header
	table.insert(report, "------------")
	local displayClass, class = UnitClass(unit)
	local name = UnitName(unit)
	table.insert(report, string.format(L["ENCHANT_REPORT_HEADER"], 
		"|cff"..ClassColor[class]..name.."|cffFFFFFF",
		UnitLevel(unit), "|cff"..ClassColor[class]..displayClass.."|cffFFFFFF"))
	
	-- average item level
	if twoHanded then
		avgItemLevel = itemLevelSum / 15
	else
		avgItemLevel = itemLevelSum / 16
	end
	table.insert(report, string.format(L["AVG_ITEM_LEVEL"], floor(avgItemLevel), itemLevelMin, itemLevelMax))
	EnchantCheckItemsFrame.titleInfoFont:SetText(string.format("%d (%d -> %d)", floor(avgItemLevel), itemLevelMin, itemLevelMax))
	
	-- check for extremely low item levels
	for i = 1,18 do
		if items[i].link then
			if (items[i].level < avgItemLevel*0.8) and 
				(i ~= INVSLOT_BODY) and (i ~= INVSLOT_TABARD) and 
				(items[i].rarity ~= 7) -- heirloom
			then
				table.insert(report, "|cffFF0000"..L["LOW_ITEM_LEVEL"].."|cffFFFFFF "..items[i].link)
				table.insert(warnings, report[#report])
				EnchantCheckItemsFrame.messages:AddMessage(report[#report])
				items_state = false
			end
		end
	end
	
	-- check for missing items
	if hasMissingItems then
		local s = ""
		for k,i in ipairs(missingItems) do
			s = s .. L["INVSLOT_"..i]
			if k < #missingItems then
				s = s .. ", "
			end
		end
		table.insert(report, "|cffFF0000" .. L["MISSING_ITEMS"] .. "|cffFFFFFF " .. s)
		table.insert(warnings, report[#report])
		EnchantCheckItemsFrame.messages:AddMessage(report[#report])
		items_state = false
	end
	
	-- check for missing gems
	if hasMissingGems then
		local s = ""
		for k,i in ipairs(missingGems) do
			s = s .. L["INVSLOT_"..i]
			if k < #missingGems then
				s = s .. ", "
			end
		end
		table.insert(report, "|cffFF0000" .. L["MISSING_GEMS"] .. "|cffFFFFFF " .. s)
		table.insert(warnings, report[#report])
		EnchantCheckGemsFrame.messages:AddMessage(report[#report])
		gems_state = false
	else
		table.insert(report, "|cff00FF00" .. L["PROPER_GEMS"] .. "|cffFFFFFF ")
		EnchantCheckGemsFrame.messages:AddMessage(report[#report])
	end
	
	--[[ belt buckle (no longer available in at level 100)
	if hasMissingBeltGem then
		table.insert(report, "|cffFFFF00" .. L["MISSING_BELT_BUCKLE"] .. "|cffFFFFFF")
		table.insert(warnings, report[#report])
		EnchantCheckGemsFrame.messages:AddMessage(report[#report])
	end
	]]
	
	--[[ check for missing blacksmith gems (no longer available in at level 100)
	if hasMissingBlacksmithGems then
		local s = ""
		for k,i in ipairs(missingBlacksmithGems) do
			s = s .. L["INVSLOT_"..i]
			if k < #missingBlacksmithGems then
				s = s .. ", "
			end
		end
		table.insert(report, "|cffFFFF00" .. L["MISSING_BS_SOCKETS"] .. "|cffFFFFFF " .. s)
		table.insert(warnings, report[#report])
		EnchantCheckGemsFrame.messages:AddMessage(report[#report])
	end
	]]
	
	-- check for missing enchants
	if hasMissingEnchants then
		local s = ""
		for k,i in ipairs(missingEnchants) do
			s = s .. L["INVSLOT_"..i]
			if k < #missingEnchants then
				s = s .. ", "
			end
		end
		table.insert(report, "|cffFF0000" .. L["MISSING_ENCHANTS"] .. "|cffFFFFFF " .. s)
		table.insert(warnings, report[#report])
		EnchantCheckEnchantsFrame.messages:AddMessage(report[#report])
		enchants_state = false
	else
		table.insert(report, "|cff00FF00" .. L["PROPER_ENCHANTS"] .. "|cffFFFFFF ")
		EnchantCheckEnchantsFrame.messages:AddMessage(report[#report])
	end
	
	-- footer
	table.insert(report, "------------")
	
	self:SetCheckFrame(EnchantCheckItemsFrame, items_state)
	self:SetCheckFrame(EnchantCheckGemsFrame, gems_state)
	self:SetCheckFrame(EnchantCheckEnchantsFrame, enchants_state)
	
	-- print to self
	if printWarnings then
		for i,v in ipairs(warnings) do
			self:Print(v)
		end
	end
	
	self.scanInProgress = nil
end

----------------------------------------------
-- CheckCharacter()
----------------------------------------------
function EnchantCheck:CheckCharacter()
	if not self.scanInProgress then	
		if EnchantCheckFrame:GetParent() ~= CharacterModelFrame then
			EnchantCheckFrame:Hide()
			EnchantCheckFrame:SetParent(CharacterModelFrame)
			EnchantCheckFrame:ClearAllPoints()
			EnchantCheckFrame:SetAllPoints()
		elseif EnchantCheckFrame:IsShown() then
			EnchantCheckFrame:Hide()
			return
		end
		EnchantCheck:ClearCheckFrame(EnchantCheckItemsFrame)
		EnchantCheck:ClearCheckFrame(EnchantCheckGemsFrame)
		EnchantCheck:ClearCheckFrame(EnchantCheckEnchantsFrame)
		EnchantCheckFrame:Show()
		
		self:CheckGear("player")
	end
end

----------------------------------------------
-- CheckInspected()
----------------------------------------------
function EnchantCheck:CheckInspected()
	if InspectFrame.unit and CanInspect(InspectFrame.unit) then
		if not self.scanInProgress then
			if EnchantCheckFrame:GetParent() ~= InspectModelFrame then
				EnchantCheckFrame:Hide()
				EnchantCheckFrame:SetParent(InspectModelFrame)
				EnchantCheckFrame:ClearAllPoints()
				EnchantCheckFrame:SetAllPoints()
			elseif EnchantCheckFrame:IsShown() then
				EnchantCheckFrame:Hide()
				return
			end
			EnchantCheck:ClearCheckFrame(EnchantCheckItemsFrame)
			EnchantCheck:ClearCheckFrame(EnchantCheckGemsFrame)
			EnchantCheck:ClearCheckFrame(EnchantCheckEnchantsFrame)
			EnchantCheckFrame:Show()
			
			self:Debug(d_info, "|cff00FF00" .. L["SCAN"] .. "|cffFFFFFF")
			NotifyInspect(InspectFrame.unit)
			self.pendingInspection = true
		end
	else
		self:Debug(d_warn, "No inspected unit found!")
	end
end

----------------------------------------------
-- InviteInspected()
----------------------------------------------
function EnchantCheck:InviteInspected()
	if InspectFrame.unit then
		InviteUnit(UnitName(InspectFrame.unit))
	end
end

----------------------------------------------
-- ClearCheckFrame(frame)
----------------------------------------------
function EnchantCheck:ClearCheckFrame(frame)
	-- clean up
	frame.titleFont:SetTextColor(1, 1, 0)
	frame.titleInfoFont:SetText("")
	frame.readyTex:Hide()
	frame.notReadyTex:Hide()
	frame.waitingTex:Show()
	frame.messages:Clear()
end

----------------------------------------------
-- SetCheckFrame(frame, value)
-- value: nil/false - red, 1/true - green, anything else - yellow
----------------------------------------------
function EnchantCheck:SetCheckFrame(frame, value)
	if value == 1 or value == true then
		frame.titleFont:SetTextColor(0, 1, 0)
		frame.readyTex:Show()
		frame.notReadyTex:Hide()
		frame.waitingTex:Hide()
	elseif not value then
		frame.titleFont:SetTextColor(1, 0, 0)
		frame.readyTex:Hide()
		frame.notReadyTex:Show()
		frame.waitingTex:Hide()
	else
		frame.titleFont:SetTextColor(1, 1, 0)
		frame.readyTex:Hide()
		frame.notReadyTex:Hide()
		frame.waitingTex:Show()
	end
end

----------------------------------------------
-- INSPECT_READY()
----------------------------------------------
function EnchantCheck:INSPECT_READY(event, guid)
	-- inspect frame is load-on-demand, add buttons once it is loaded
	if not InspectFrameEnchantCheckButton:GetParent() and InspectPaperDollFrame then
		InspectFrameEnchantCheckButton:SetParent(InspectPaperDollFrame)
		InspectFrameEnchantCheckButton:ClearAllPoints()
		InspectFrameEnchantCheckButton:SetPoint("LEFT", InspectPaperDollFrame, "BOTTOMLEFT", 10, 20)
		InspectFrameEnchantCheckButton:Show()
		
		InspectFrameInviteButton:SetParent(InspectPaperDollFrame)
		InspectFrameInviteButton:ClearAllPoints()
		InspectFrameInviteButton:SetPoint("RIGHT", InspectPaperDollFrame, "BOTTOMRIGHT", -12, 20)
		InspectFrameInviteButton:Show()
		
		self:HookScript(InspectFrame, "OnHide", "InspectFrame_OnHide")
		
		--self:Debug(d_notice, "Added inspect buttons")
	end
	
	--self:Debug(d_notice, "INSPECT_READY")
	
	if self.pendingInspection and (UnitGUID(InspectFrame.unit) == guid) then
		if EnchantCheckFrame:IsShown() then
			self:CheckGear(InspectFrame.unit)
		end
		self.pendingInspection = nil
	end
end

----------------------------------------------
-- UNIT_INVENTORY_CHANGED()
----------------------------------------------
function EnchantCheck:UNIT_INVENTORY_CHANGED(event, unit)
	if EnchantCheckFrame:IsShown() then
		EnchantCheckFrame:Hide()
		EnchantCheck:ClearCheckFrame(EnchantCheckItemsFrame)
		EnchantCheck:ClearCheckFrame(EnchantCheckGemsFrame)
		EnchantCheck:ClearCheckFrame(EnchantCheckEnchantsFrame)
	end
end

----------------------------------------------
-- InspectFrame_OnHide()
----------------------------------------------
function EnchantCheck:InspectFrame_OnHide()
	if EnchantCheckFrame:IsShown() then
		EnchantCheckFrame:Hide()
		EnchantCheck:ClearCheckFrame(EnchantCheckItemsFrame)
		EnchantCheck:ClearCheckFrame(EnchantCheckGemsFrame)
		EnchantCheck:ClearCheckFrame(EnchantCheckEnchantsFrame)
	end
end

----------------------------------------------
-- PLAYER_ENTERING_WORLD()
----------------------------------------------
function EnchantCheck:PLAYER_ENTERING_WORLD(event)
	inInstance, instanceType = IsInInstance()
	if inInstance and (instanceType ~= "none") and (UnitLevel("player") == MAX_LEVEL) then
		self:CheckGear("player", nil, nil, true)
	end
end
