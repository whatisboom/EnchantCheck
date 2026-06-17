----------------------------------------------
-- EnchantCheck — Class/Spec Gear Checks
-- Detects gear that is wrong for the unit's class/spec: wrong armor type,
-- and wrong primary stat on weapons and trinkets (base stats + trinket procs).
----------------------------------------------
local L = LibStub("AceLocale-3.0"):GetLocale("EnchantCheck")
local C = EnchantCheckConstants

-- Localized name for a primary stat id (reuses the client's own global string).
local function PrimaryStatName(stat)
	local key = C.PRIMARY_STAT_KEYS[stat]
	return (key and _G[key]) or tostring(stat)
end

-- Which primary stat, if any, this item's base stat block carries.
local function BasePrimaryStat(stats)
	if not stats then return nil end
	for stat, key in pairs(C.PRIMARY_STAT_KEYS) do
		if stats[key] and stats[key] > 0 then
			return stat
		end
	end
	return nil
end

----------------------------------------------
-- Unit resolution
----------------------------------------------

-- Returns the unit's primary stat (1=Str, 2=Agi, 4=Int) or nil if unknown
-- (e.g. inspect data not yet loaded).
function EnchantCheck:GetUnitPrimaryStat(unit)
	local specID
	if UnitIsUnit(unit, "player") then
		local idx = GetSpecialization()
		if idx then
			specID = GetSpecializationInfo(idx)
		end
	else
		specID = GetInspectSpecialization(unit)
	end
	if not specID or specID == 0 then return nil end

	-- Hybrid classes resolved by spec; all others by class.
	local stat = C.SPEC_PRIMARY_STAT[specID]
	if stat then return stat end

	local _, _, _, _, _, classFile = GetSpecializationInfoByID(specID)
	return (classFile and C.CLASS_PRIMARY_STAT[classFile]) or nil
end

-- Returns the unit's preferred armor subclass (1-4) or nil.
function EnchantCheck:GetUnitArmorType(unit)
	local _, classFile = UnitClass(unit)
	return (classFile and C.CLASS_ARMOR_TYPE[classFile]) or nil
end

----------------------------------------------
-- Detection
----------------------------------------------

-- Armor pieces whose type doesn't match the class. Returns { {slot, reason}, ... }.
function EnchantCheck:CheckWrongArmorType(unit, items)
	local out = {}
	if not self:GetSetting("warnWrongArmorType") then return out end

	local want = self:GetUnitArmorType(unit)
	if not want then return out end

	for _, slot in ipairs(C.ARMOR_TYPE_SLOTS) do
		local item = items[slot]
		if item and item.link and item.classID == C.ITEM_CLASS.ARMOR
			and item.subclassID and item.subclassID ~= want then
			local haveName = C_Item.GetItemSubClassInfo(C.ITEM_CLASS.ARMOR, item.subclassID)
			local wantName = C_Item.GetItemSubClassInfo(C.ITEM_CLASS.ARMOR, want)
			out[#out + 1] = {
				slot = slot,
				reason = string.format(L["WRONG_ARMOR_TYPE_DETAIL"], haveName or "?", wantName or "?"),
			}
		end
	end
	return out
end

-- Scans a trinket's tooltip for a primary stat that isn't the spec's. Returns
-- the wrong stat id when a wrong primary appears and the correct one does not,
-- else nil. Catches proc/on-use stats that aren't in the base stat block.
function EnchantCheck:TrinketProcWrongPrimary(unit, slot, primaryStat)
	if not C_TooltipInfo or not C_TooltipInfo.GetInventoryItem then return nil end
	local data = C_TooltipInfo.GetInventoryItem(unit, slot)
	if not data or not data.lines then return nil end

	local correctName = PrimaryStatName(primaryStat)
	local foundWrong, hasCorrect

	for _, line in ipairs(data.lines) do
		local text = line.leftText
		if text then
			if text:find(correctName, 1, true) then
				hasCorrect = true
			end
			for stat in pairs(C.PRIMARY_STAT_KEYS) do
				if stat ~= primaryStat and text:find(PrimaryStatName(stat), 1, true) then
					foundWrong = stat
				end
			end
		end
	end

	if foundWrong and not hasCorrect then
		return foundWrong
	end
	return nil
end

-- Weapons and trinkets carrying the wrong primary stat. Returns { {slot, reason}, ... }.
function EnchantCheck:CheckWrongStats(unit, items)
	local out = {}
	if not self:GetSetting("warnWrongStats") then return out end

	local primaryStat = self:GetUnitPrimaryStat(unit)
	if not primaryStat then return out end

	local SLOT = C.SLOT_IDS

	-- Weapons: base stat block only.
	for _, slot in ipairs({ SLOT.MAINHAND, SLOT.OFFHAND }) do
		local item = items[slot]
		if item and item.link and item.classID == C.ITEM_CLASS.WEAPON then
			local base = BasePrimaryStat(item.stats)
			if base and base ~= primaryStat then
				out[#out + 1] = {
					slot = slot,
					reason = string.format(L["WRONG_STAT_DETAIL"], PrimaryStatName(base), PrimaryStatName(primaryStat)),
				}
			end
		end
	end

	-- Trinkets: base stat block, then proc/on-use tooltip scan.
	for _, slot in ipairs({ SLOT.TRINKET1, SLOT.TRINKET2 }) do
		local item = items[slot]
		if item and item.link then
			local base = BasePrimaryStat(item.stats)
			local wrong = (base and base ~= primaryStat) and base or nil
			if not wrong then
				wrong = self:TrinketProcWrongPrimary(unit, slot, primaryStat)
			end
			if wrong then
				out[#out + 1] = {
					slot = slot,
					reason = string.format(L["WRONG_STAT_DETAIL"], PrimaryStatName(wrong), PrimaryStatName(primaryStat)),
				}
			end
		end
	end

	return out
end

----------------------------------------------
-- Tooltip injection
----------------------------------------------

-- Tooltip RGB per severity (AddLine needs floats, not the chat color codes).
local SEVERITY_RGB = {
	[C.UI.SEVERITY.GOOD]    = { 0, 1, 0 },
	[C.UI.SEVERITY.INFO]    = { 0, 1, 1 },
	[C.UI.SEVERITY.WARNING] = { 1, 1, 0 },
	[C.UI.SEVERITY.ERROR]   = { 1, 0, 0 },
}

function EnchantCheck:OnItemTooltip(tooltip)
	if tooltip ~= GameTooltip then return end

	local owner = tooltip:GetOwner()
	if not owner or not owner.GetName then return end
	local name = owner:GetName()
	if not name then return end

	local prefix
	if name:find("^Character") then
		prefix = "Character"
	elseif name:find("^Inspect") then
		prefix = "Inspect"
	else
		return
	end

	local slotId = owner.GetID and owner:GetID()
	if not slotId or slotId == 0 then return end

	local byPrefix = self.slotIssueLines and self.slotIssueLines[prefix]
	local entries = byPrefix and byPrefix[slotId]
	if not entries then return end

	tooltip:AddLine(" ")
	for _, entry in ipairs(entries) do
		local rgb = SEVERITY_RGB[entry.severity] or SEVERITY_RGB[C.UI.SEVERITY.ERROR]
		tooltip:AddLine(entry.text, rgb[1], rgb[2], rgb[3], true)
	end
end

function EnchantCheck:RegisterTooltipHook()
	if self.tooltipHooked then return end
	if not (TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
		and Enum and Enum.TooltipDataType) then
		return
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip)
		EnchantCheck:OnItemTooltip(tooltip)
	end)
	self.tooltipHooked = true
end
