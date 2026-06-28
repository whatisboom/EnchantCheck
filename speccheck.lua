----------------------------------------------
-- EnchantCheck — Class/Spec Gear Checks
-- Detects gear that is wrong for the unit's class/spec: wrong armor type,
-- and wrong primary stat on weapons and trinkets. Primary stats are read from
-- the unit-aware tooltip (active stat = normal/white line) rather than
-- GetItemStats, which is not unit-aware and reports the wrong primary for
-- inspected primary-stat-flexible gear. Proc/Use primaries are free-form text
-- with no active/inactive coloring, so they are only judged on the player's own
-- character (where the client renders the wearer's actual stat), never inspect.
----------------------------------------------
local L = LibStub("AceLocale-3.0"):GetLocale("EnchantCheck")
local C = EnchantCheckConstants

-- Localized name for a primary stat id (reuses the client's own global string).
local function PrimaryStatName(stat)
	local key = C.PRIMARY_STAT_KEYS[stat]
	return (key and _G[key]) or tostring(stat)
end

-- "/"-joined localized names for a set of primary stat ids, in canonical
-- Strength/Agility/Intellect order.
local PRIMARY_STAT_ORDER = { 1, 2, 4 }
local function PrimaryStatNames(set)
	local names = {}
	for _, stat in ipairs(PRIMARY_STAT_ORDER) do
		if set[stat] then
			names[#names + 1] = PrimaryStatName(stat)
		end
	end
	return table.concat(names, "/")
end

-- True if a tooltip line color is the normal/white of an active stat line.
-- On primary-stat-flexible gear the wearer's stat renders white while the
-- others are greyed (~0.5); proc/Use text renders green (r≈0). Requiring all
-- three components near 1 keeps only active itemized stat lines.
local function IsActiveLineColor(c)
	return c and c.r and c.r > 0.8 and c.g > 0.8 and c.b > 0.8
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

-- Primary stats the wearer actually receives from the item in `slot`, read from
-- the unit-aware tooltip. Only active (white) stat lines count, so the greyed
-- inactive options on primary-stat-flexible gear are ignored and proc/Use text
-- (green) never matches. Returns a set { [statId] = true, ... } or nil.
function EnchantCheck:ActivePrimaryStats(unit, slot)
	if not C_TooltipInfo or not C_TooltipInfo.GetInventoryItem then return nil end
	local data = C_TooltipInfo.GetInventoryItem(unit, slot)
	if not data or not data.lines then return nil end

	local set
	for _, line in ipairs(data.lines) do
		if line.leftText and IsActiveLineColor(line.leftColor) then
			for stat, key in pairs(C.PRIMARY_STAT_KEYS) do
				local name = _G[key]
				if name and line.leftText:find(name, 1, true) then
					set = set or {}
					set[stat] = true
				end
			end
		end
	end
	return set
end

-- Scans a trinket's tooltip for a proc/Use primary stat that isn't the spec's.
-- Returns the wrong stat id when a wrong primary appears and the correct one does
-- not, else nil. Proc text is free-form and not reliably re-rendered for an
-- inspected unit's spec, so callers only use this on the player's own character.
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
	local isPlayer = UnitIsUnit(unit, "player")

	-- An item is wrong only when it grants the wearer an active primary stat and
	-- none of those active stats is the spec's. Flexible gear stays correct as
	-- long as the spec's stat is the active (white) one for this unit.
	local function flag(slot, wrongNames)
		out[#out + 1] = {
			slot = slot,
			reason = string.format(L["WRONG_STAT_DETAIL"], wrongNames, PrimaryStatName(primaryStat)),
		}
	end

	-- Weapons: itemized primary only (true weapons, not shields/held off-hands).
	for _, slot in ipairs({ SLOT.MAINHAND, SLOT.OFFHAND }) do
		local item = items[slot]
		if item and item.link and item.classID == C.ITEM_CLASS.WEAPON then
			local active = self:ActivePrimaryStats(unit, slot)
			if active and not active[primaryStat] then
				flag(slot, PrimaryStatNames(active))
			end
		end
	end

	-- Trinkets: itemized primary first; for the player only, fall back to the
	-- proc/Use scan when the trinket has no itemized primary at all.
	for _, slot in ipairs({ SLOT.TRINKET1, SLOT.TRINKET2 }) do
		local item = items[slot]
		if item and item.link then
			local active = self:ActivePrimaryStats(unit, slot)
			if active then
				if not active[primaryStat] then
					flag(slot, PrimaryStatNames(active))
				end
			elseif isPlayer then
				local wrong = self:TrinketProcWrongPrimary(unit, slot, primaryStat)
				if wrong then
					flag(slot, PrimaryStatName(wrong))
				end
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
	tooltip:AddLine(L["TOOLTIP_HEADER"], 1, 1, 1)
	for _, entry in ipairs(entries) do
		local rgb = SEVERITY_RGB[entry.severity] or SEVERITY_RGB[C.UI.SEVERITY.ERROR]
		tooltip:AddLine("- " .. entry.text, rgb[1], rgb[2], rgb[3], true)
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
