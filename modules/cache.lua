----------------------------------------------
-- EnchantCheck Cache Module
-- Handles item data caching and performance optimization
----------------------------------------------

local EnchantCheckCache = {}

----------------------------------------------
-- Item Cache Implementation
----------------------------------------------

-- Enhanced cache with configurable size and TTL
local ItemCache = {
	data = {},
	timestamps = {},
	accessCount = {},
	maxSize = 500, -- Increased from 200 for better performance
	ttl = 300, -- 5 minutes TTL
	hits = 0,
	misses = 0
}

function ItemCache:Get(key)
	if not key then return nil end
	
	local now = GetTime()
	local timestamp = self.timestamps[key]
	
	-- Check if cached data exists and is not expired
	if self.data[key] and timestamp and (now - timestamp) < self.ttl then
		self.accessCount[key] = (self.accessCount[key] or 0) + 1
		self.hits = self.hits + 1
		return self.data[key]
	end
	
	-- Clean up expired entry
	if self.data[key] then
		self:Remove(key)
	end
	
	self.misses = self.misses + 1
	return nil
end

function ItemCache:Set(key, value)
	if not key or not value then return end
	
	-- Ensure we don't exceed max size
	if self:Size() >= self.maxSize then
		self:Cleanup()
	end
	
	local now = GetTime()
	self.data[key] = value
	self.timestamps[key] = now
	self.accessCount[key] = 1
end

function ItemCache:Remove(key)
	if not key then return end
	
	self.data[key] = nil
	self.timestamps[key] = nil
	self.accessCount[key] = nil
end

function ItemCache:Size()
	local count = 0
	for _ in pairs(self.data) do
		count = count + 1
	end
	return count
end

function ItemCache:Clear()
	self.data = {}
	self.timestamps = {}
	self.accessCount = {}
end

-- LRU-based cleanup when cache is full
function ItemCache:Cleanup()
	local now = GetTime()
	local entriesRemoved = 0
	local targetRemoval = math.floor(self.maxSize * 0.25) -- Remove 25% when full
	
	-- First pass: remove expired entries
	for key, timestamp in pairs(self.timestamps) do
		if (now - timestamp) >= self.ttl then
			self:Remove(key)
			entriesRemoved = entriesRemoved + 1
		end
	end
	
	-- Second pass: remove least accessed entries if needed
	if entriesRemoved < targetRemoval then
		local entries = {}
		for key, accessCount in pairs(self.accessCount) do
			table.insert(entries, {key = key, accessCount = accessCount, timestamp = self.timestamps[key]})
		end
		
		-- Sort by access count ascending (least accessed first)
		table.sort(entries, function(a, b)
			if a.accessCount == b.accessCount then
				return a.timestamp < b.timestamp -- Older first if same access count
			end
			return a.accessCount < b.accessCount
		end)
		
		-- Remove least accessed entries
		local toRemove = targetRemoval - entriesRemoved
		for i = 1, math.min(toRemove, #entries) do
			self:Remove(entries[i].key)
		end
	end
end

function ItemCache:GetStats()
	return {
		size = self:Size(),
		maxSize = self.maxSize,
		hits = self.hits,
		misses = self.misses,
		hitRate = self.hits > 0 and (self.hits / (self.hits + self.misses)) * 100 or 0,
		ttl = self.ttl
	}
end

function ItemCache:SetMaxSize(size)
	if size and size > 0 then
		self.maxSize = size
		if self:Size() > self.maxSize then
			self:Cleanup()
		end
	end
end

function ItemCache:SetTTL(ttl)
	if ttl and ttl > 0 then
		self.ttl = ttl
	end
end

----------------------------------------------
-- Slot-Level Caching for Active Scans
----------------------------------------------

local ScanCache = {
	data = {},
	scanId = nil,
	unit = nil
}

function ScanCache:StartScan(unit)
	self.scanId = GetTime() .. "_" .. (unit or "unknown")
	self.unit = unit
	self.data = {}
end

function ScanCache:GetSlotData(slot)
	if not self.scanId or not slot then return nil end
	return self.data[slot]
end

function ScanCache:SetSlotData(slot, data)
	if not self.scanId or not slot or not data then return end
	self.data[slot] = data
end

function ScanCache:EndScan()
	-- Explicitly nil out entries to prevent memory leak
	for k in pairs(self.data) do
		self.data[k] = nil
	end
	self.scanId = nil
	self.unit = nil
end

function ScanCache:IsActive()
	return self.scanId ~= nil
end

----------------------------------------------
-- Cache Configuration
----------------------------------------------

function EnchantCheckCache:Initialize(maxSize, ttl)
	ItemCache:SetMaxSize(maxSize or 500)
	ItemCache:SetTTL(ttl or 300)
end

function EnchantCheckCache:ConfigureFromSettings(settings)
	if not settings then return end
	
	local cacheSize = settings.cacheSize or 500
	local cacheTTL = settings.cacheTTL or 300
	
	ItemCache:SetMaxSize(cacheSize)
	ItemCache:SetTTL(cacheTTL)
end

----------------------------------------------
-- High-Level Cache Interface
----------------------------------------------

function EnchantCheckCache:GetItemData(itemLink)
	return ItemCache:Get(itemLink)
end

function EnchantCheckCache:SetItemData(itemLink, data)
	if not itemLink or not data then return end
	
	-- Add cache metadata
	local cacheData = {
		gems = data.gems,
		rarity = data.rarity,
		enchant = data.enchant,
		level = data.level,
		stats = data.stats,
		sockets = data.sockets,
		cached_at = GetTime()
	}
	
	ItemCache:Set(itemLink, cacheData)
end

function EnchantCheckCache:ClearItemCache()
	ItemCache:Clear()
end

function EnchantCheckCache:GetCacheStats()
	return ItemCache:GetStats()
end

-- Scan-specific caching
function EnchantCheckCache:StartScanCache(unit)
	ScanCache:StartScan(unit)
end

function EnchantCheckCache:GetScanSlotData(slot)
	return ScanCache:GetSlotData(slot)
end

function EnchantCheckCache:SetScanSlotData(slot, data)
	ScanCache:SetSlotData(slot, data)
end

function EnchantCheckCache:EndScanCache()
	ScanCache:EndScan()
end

function EnchantCheckCache:IsScanCacheActive()
	return ScanCache:IsActive()
end

----------------------------------------------
-- Cache Maintenance
----------------------------------------------

function EnchantCheckCache:PerformMaintenance()
	-- Clean up old entries
	ItemCache:Cleanup()
	
	-- Force garbage collection if cache is large
	if ItemCache:Size() > ItemCache.maxSize * 0.8 then
		collectgarbage("collect")
	end
end

-- Periodic maintenance timer
local maintenanceTimer = nil

function EnchantCheckCache:StartMaintenanceTimer(interval)
	if maintenanceTimer then
		return -- Already running
	end
	
	local function maintenanceTask()
		self:PerformMaintenance()
		
		-- Schedule next maintenance
		maintenanceTimer = C_Timer.NewTimer(interval or 60, maintenanceTask)
	end
	
	maintenanceTimer = C_Timer.NewTimer(interval or 60, maintenanceTask)
end

function EnchantCheckCache:StopMaintenanceTimer()
	if maintenanceTimer then
		maintenanceTimer:Cancel()
		maintenanceTimer = nil
	end
end

----------------------------------------------
-- Cache Validation
----------------------------------------------

function EnchantCheckCache:ValidateCacheEntry(itemLink, data)
	if not itemLink or not data then return false end
	
	-- Check required fields
	local requiredFields = {"gems", "rarity", "enchant", "level", "stats", "sockets"}
	for _, field in ipairs(requiredFields) do
		if data[field] == nil then
			return false
		end
	end
	
	-- Check data types
	if type(data.gems) ~= "number" or 
	   type(data.rarity) ~= "number" or 
	   type(data.enchant) ~= "number" or 
	   type(data.level) ~= "number" or 
	   type(data.stats) ~= "table" or 
	   type(data.sockets) ~= "number" then
		return false
	end
	
	-- Check reasonable value ranges
	if data.gems < 0 or data.gems > 4 or
	   data.rarity < 0 or data.rarity > 7 or
	   data.enchant < 0 or
	   data.level < 0 or data.level > 1000 or
	   data.sockets < 0 or data.sockets > 4 then
		return false
	end
	
	return true
end

----------------------------------------------
-- Export Module
----------------------------------------------
_G.EnchantCheckCache = EnchantCheckCache

-- Export ItemCache for backward compatibility
_G.ItemCache = ItemCache