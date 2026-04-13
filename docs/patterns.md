# Lua & WoW API Patterns

## WoW API Patterns

### Item Data Fetching (Asynchronous)
```lua
local item = Item:CreateFromItemID(itemID)
item:ContinueOnItemLoad(function()
    local itemLink = item:GetItemLink()
    -- Process item data
end)
```

### Tooltip Scanning for Enchant Detection
```lua
EnchantCheckTooltip:SetInventoryItem("player", slotID)
local line = _G["EnchantCheckTooltipTextLeft2"]:GetText()
```

## Global State Management

- **Database**: `self.db` (AceDB profile system)
- **Constants**: `_G.EnchantCheckConstants` (global table)
- **Cache**: `EnchantCheckCache.ItemCache` (global table)

## Localization
```lua
local L = LibStub("AceLocale-3.0"):GetLocale("EnchantCheck")
print(L["Missing Enchants"]) -- Uses active locale
```

## Ace3 Framework Integration

Main addon object (main.lua:4):
```lua
EnchantCheck = LibStub("AceAddon-3.0"):NewAddon("Enchant Check",
    "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
```

Lifecycle hooks:
- `OnInitialize()` - One-time setup, DB initialization, constants loading
- `OnEnable()` - Event registration, UI setup
- `OnDisable()` - Cleanup (rarely used in WoW addons)

## Cache System (modules/cache.lua)

- **LRU eviction** when exceeding 500 items
- **TTL**: 300s default for item data
- **Hit/miss tracking** for performance monitoring
- Access via `EnchantCheckCache.ItemCache:Get(itemID)`

## Smart Notification System

Content type detection (main.lua):
- Inspects player's current activity (instance type, difficulty)
- Adjusts strictness: leveling (relaxed) → dungeons → mythic+ → raids (strict)
- Dynamically enables/disables head enchant checks based on WoW season

## Key Technical Details

### Slot Checking Logic
- **CheckSlotEnchant** table (built in OnInitialize) maps slot IDs to enchant requirements
- **CheckSlotMissing** table for detecting empty slots
- **Special cases**: Off-hand (CheckOffHand) - checks if slot should have item based on class/spec

### Head Enchant Season Detection
1. Checks `EnchantCheckConstants.ENCHANT_SLOTS[1]` (head slot)
2. Dynamically updates based on game version and season flags
3. `/ec fixhead` forces re-evaluation

### Performance Considerations
- **Batch processing**: Gear checks throttled to avoid frame drops
- **Cache warming**: Pre-loads common item IDs on login
- **Memory management**: Manual `collectgarbage()` hints after major operations
- **Event throttling**: Uses AceTimer to debounce rapid events

## Common Modifications

### Adding New Slots to Check
1. Update `EnchantCheckConstants.ENCHANT_SLOTS` in constants.lua
2. Update initialization in main.lua:OnInitialize() to map slot correctly
3. Test with various gear configurations

### Changing Smart Notification Thresholds
Modify logic in main.lua smart notification detection functions (search for "content type")

### Adding Localization
1. Add key-value pairs to Locales/enUS.lua (base locale)
2. Add translations to other locale files (deDE.lua, ruRU.lua, etc.)
3. Use `L["YourKey"]` in code
