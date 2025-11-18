----------------------------------------------
-- EnchantCheck Utilities Module
-- Common utility functions and helpers
----------------------------------------------

local EnchantCheckUtils = {}

----------------------------------------------
-- Safe API Call Wrappers
----------------------------------------------

-- Safe wrapper for item info retrieval with modern API fallback
function EnchantCheckUtils:GetSafeItemInfo(itemLink)
	if not itemLink then return nil end
	
	local success, itemName, itemLink, itemRarity, itemLevel, itemMinLevel,
		itemType, itemSubType, itemStackCount, itemEquipLoc,
		itemTexture, itemSellPrice
	
	if C_Item and C_Item.GetItemInfo then
		success, itemName, itemLink, itemRarity, itemLevel, itemMinLevel,
			itemType, itemSubType, itemStackCount, itemEquipLoc,
			itemTexture, itemSellPrice = pcall(C_Item.GetItemInfo, itemLink)
	else
		-- Fallback to legacy API
		success, itemName, itemLink, itemRarity, itemLevel, itemMinLevel,
			itemType, itemSubType, itemStackCount, itemEquipLoc,
			itemTexture, itemSellPrice = pcall(GetItemInfo, itemLink)
	end
	
	if not success then
		return nil
	end
	
	return itemName, itemLink, itemRarity, itemLevel, itemMinLevel,
		itemType, itemSubType, itemStackCount, itemEquipLoc,
		itemTexture, itemSellPrice
end

-- Safe wrapper for item stats retrieval
function EnchantCheckUtils:GetSafeItemStats(itemLink)
	if not itemLink then return {} end
	
	local success, stats = pcall(C_Item.GetItemStats, itemLink)
	return (success and stats) and stats or {}
end

-- Safe wrapper for getting actual item level with upgrade info
function EnchantCheckUtils:GetActualItemLevel(itemLink)
	if not itemLink or itemLink == "" then
		return 0
	end
	
	-- Try LibItemUpgradeInfo first
	local success, itemLevel = pcall(function()
		local libItemUpgrade = LibStub("LibItemUpgradeInfo-1.0", true)
		if libItemUpgrade then
			return libItemUpgrade:GetUpgradedItemLevel(itemLink)
		end
		return nil
	end)
	
	if success and itemLevel and itemLevel > 0 then
		return itemLevel
	else
		-- Fallback to basic item level
		local _, _, _, basicLevel = self:GetSafeItemInfo(itemLink)
		return basicLevel or 0
	end
end

----------------------------------------------
-- String Processing Utilities
----------------------------------------------

-- Optimized string splitting for item strings
function EnchantCheckUtils:StringSplit(delimiter, str)
	if not str or str == "" then return {} end
	
	local result = {}
	local pattern = string.format("([^%s]+)", delimiter)
	
	for part in string.gmatch(str, pattern) do
		table.insert(result, part)
	end
	
	return result
end

-- Convert string value to number with fallback
function EnchantCheckUtils:SplitValue(str)
	if not str or str == "" then return 0 end
	return tonumber(str) or 0
end

-- Optimized table concatenation for string building
function EnchantCheckUtils:ConcatStrings(parts, separator)
	if not parts or #parts == 0 then return "" end
	return table.concat(parts, separator or "")
end

----------------------------------------------
-- Item Link Processing
----------------------------------------------

-- Parse and validate item links
function EnchantCheckUtils:GetItemLinkInfo(link)
	if not link or type(link) ~= "string" or link == "" then
		return nil, nil, nil
	end
	
	-- Validate item link format
	if not link:match("|Hitem:") then
		return nil, nil, nil
	end
	
	-- Single optimized pattern for better performance
	local itemColor, itemString, itemName = link:match("(|c%x+)|Hitem:([-%d:]*)|h%[(.-)%]|h|r")
	
	if not itemString or itemString == "" then
		return nil, nil, nil
	end
	
	return itemColor, itemString, itemName
end

-- Extract enchant information from item link
function EnchantCheckUtils:GetEnchantInfoFromLink(itemLink)
	if not itemLink then return nil, 0 end
	
	local _, itemString = self:GetItemLinkInfo(itemLink)
	if not itemString then return nil, 0 end
	
	local ids = self:StringSplit(":", itemString)
	if not ids or #ids < 2 then return nil, 0 end
	
	local enchantId = self:SplitValue(ids[2] or "0")
	local enchantName = nil
	
	-- Try to get enchant name if enchanted
	if enchantId > 0 then
		-- This would need enchant ID -> name mapping, simplified for now
		enchantName = "Enchanted (ID: " .. enchantId .. ")"
	end
	
	return enchantName, enchantId
end

-- Get gem information from item link
function EnchantCheckUtils:GetGemInfoFromLink(itemLink)
	if not itemLink then return {} end
	
	local gems = {}
	for i = 1, 4 do
		local _, gemLink = GetItemGem(itemLink, i)
		if gemLink then
			local gemName = GetItemInfo(gemLink)
			if gemName then
				table.insert(gems, gemName)
			end
		end
	end
	return gems
end

-- Count sockets in item efficiently
function EnchantCheckUtils:GetSocketCountFromLink(itemLink)
	if not itemLink then return 0 end
	
	local stats = self:GetSafeItemStats(itemLink)
	if not stats then return 0 end
	
	local socketCount = 0
	for label in pairs(stats) do
		if label and label:find("EMPTY_SOCKET_", 1, true) then -- faster than regex
			socketCount = socketCount + 1
		end
	end
	
	return socketCount
end

----------------------------------------------
-- Performance Utilities
----------------------------------------------

-- Memory cleanup helper (deprecated - WoW's GC is already optimized)
function EnchantCheckUtils:CleanupMemory()
	-- No-op: Manual GC calls can cause stuttering
end

-- Performance timing helper
function EnchantCheckUtils:CreateTimer()
	return {
		startTime = GetTime(),
		elapsed = function(self)
			return GetTime() - self.startTime
		end,
		reset = function(self)
			self.startTime = GetTime()
		end
	}
end

-- Frame state management helper
function EnchantCheckUtils:SetFrameState(frame, state, texture)
	if not frame then return end
	
	-- Clear all state textures
	if frame.readyTex then frame.readyTex:Hide() end
	if frame.notReadyTex then frame.notReadyTex:Hide() end
	if frame.waitingTex then frame.waitingTex:Hide() end
	
	-- Show appropriate texture
	if state == "ready" and frame.readyTex then
		frame.readyTex:Show()
	elseif state == "notready" and frame.notReadyTex then
		frame.notReadyTex:Show()
	elseif state == "waiting" and frame.waitingTex then
		frame.waitingTex:Show()
	end
end

----------------------------------------------
-- Validation Utilities
----------------------------------------------

-- Validate unit exists and is valid for inspection
function EnchantCheckUtils:IsValidUnit(unit)
	if not unit then return false end
	return UnitExists(unit) and not UnitIsUnit(unit, "player") or unit == "player"
end

-- Check if item link is valid format
function EnchantCheckUtils:IsValidItemLink(link)
	if not link or type(link) ~= "string" or link == "" then
		return false
	end
	return link:match("|Hitem:") ~= nil
end

-- Validate item slot number
function EnchantCheckUtils:IsValidSlot(slot)
	if not slot or type(slot) ~= "number" then return false end
	return slot >= 1 and slot <= 18 -- INVSLOT range
end

----------------------------------------------
-- Export Module
----------------------------------------------
_G.EnchantCheckUtils = EnchantCheckUtils