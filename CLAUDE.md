# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# EnchantCheck - World of Warcraft AddOn

## Project Overview
EnchantCheck is a World of Warcraft addon that checks gear for missing enchantments, gems, and optimization issues. It provides smart, context-aware notifications based on content type (leveling, dungeons, mythic+, raids) and integrates with the character and inspect frames for quick gear checking.

## Development Workflow

### Testing in WoW
1. Place addon in `World of Warcraft/_retail_/Interface/AddOns/EnchantCheck/`
2. Launch WoW or `/reload` in-game
3. Test with `/enchantcheck check` or `/ec check`
4. Monitor for Lua errors (use BugSack addon or `/console scriptErrors 1`)

### In-Game Commands
```
/enchantcheck check         - Test gear checking logic
/ec config                  - View current settings
/ec cache                   - Check cache performance
/ec fixhead                 - Force re-check head enchant requirements
```

### Publishing
Releases are automated via GitHub Actions when you push a git tag:

```bash
# 1. Create annotated tag with changelog
git tag -a v11.2.7-1 -m "Release v11.2.7-1

Changes:
- Fixed XYZ
- Updated for WoW patch 11.2.7"

# 2. Push tag to trigger automated release
git push origin v11.2.7-1
```

GitHub Actions automatically packages and uploads to CurseForge (and optionally WoWInterface/Wago).

**Setup (one-time)**:
- Add `CF_API_KEY` to GitHub repository secrets
- Enable "Read and write permissions" in repository Actions settings
- See PUBLISHING.md for complete setup instructions

Version tagging convention: `v11.2.7-1` (WoW patch-addon revision)

## Architecture

### Initialization Order (Critical)
The addon has a strict initialization order due to WoW's global loading system:

1. **constants.lua** - Creates `_G.EnchantCheckConstants` immediately
2. **modules/cache.lua** - Defines `EnchantCheckCache` in global scope
3. **modules/utils.lua** - Utility functions, returns table for access
4. **Locales/** - Loaded via locales.xml, creates translation tables
5. **main.lua** - Creates addon, initializes all systems in `OnInitialize()`

**Important**: constants.lua uses numeric slot indices (1-18) instead of WoW globals (INVSLOT_*) to avoid load-time dependency issues. The mapping happens in main.lua:OnInitialize().

### Core Systems

#### Ace3 Framework Integration
Main addon object (main.lua:4):
```lua
EnchantCheck = LibStub("AceAddon-3.0"):NewAddon("Enchant Check",
    "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
```

Lifecycle hooks:
- `OnInitialize()` - One-time setup, DB initialization, constants loading
- `OnEnable()` - Event registration, UI setup
- `OnDisable()` - Cleanup (rarely used in WoW addons)

#### Cache System (modules/cache.lua)
- **LRU eviction** when exceeding 500 items
- **TTL**: 300s default for item data
- **Hit/miss tracking** for performance monitoring
- Access via `EnchantCheckCache.ItemCache:Get(itemID)`

#### Smart Notification System
Content type detection (main.lua):
- Inspects player's current activity (instance type, difficulty)
- Adjusts strictness: leveling (relaxed) → dungeons → mythic+ → raids (strict)
- Dynamically enables/disables head enchant checks based on WoW season

### File Load Order (EnchantCheck.toc)
```
Libs/* (Ace3, LibStub, LibItemUpgradeInfo, LibDBIcon)
constants.lua
modules/cache.lua
modules/utils.lua
frames.xml (UI definitions)
Locales/locales.xml
main.lua
```

### Package Management
The addon uses BigWigsMods packager for releases:
- **External libraries** defined in `.pkgmeta` are fetched during packaging
- **Version replacement**: `@project-version@` in TOC/Lua files is replaced with git tag
- **Automatic uploads** to CurseForge, WoWInterface, and Wago via GitHub Actions
- See `.pkgmeta` for external library URLs and ignore patterns

## Lua-Specific Patterns

### WoW API Patterns
```lua
-- Item data fetching (asynchronous)
local item = Item:CreateFromItemID(itemID)
item:ContinueOnItemLoad(function()
    local itemLink = item:GetItemLink()
    -- Process item data
end)

-- Tooltip scanning for enchant detection
EnchantCheckTooltip:SetInventoryItem("player", slotID)
local line = _G["EnchantCheckTooltipTextLeft2"]:GetText()
```

### Global State Management
- **Database**: `self.db` (AceDB profile system)
- **Constants**: `_G.EnchantCheckConstants` (global table)
- **Cache**: `EnchantCheckCache.ItemCache` (global table)

### Localization
```lua
local L = LibStub("AceLocale-3.0"):GetLocale("EnchantCheck")
print(L["Missing Enchants"]) -- Uses active locale
```

## Key Technical Details

### Slot Checking Logic
- **CheckSlotEnchant** table (built in OnInitialize) maps slot IDs to enchant requirements
- **CheckSlotMissing** table for detecting empty slots
- **Special cases**: Off-hand (CheckOffHand) - checks if slot should have item based on class/spec

### Head Enchant Season Detection
Head enchants are only required during specific WoW seasons. The addon:
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

## WoW API Version Compatibility
- **Current Interface**: 110207 (WoW 11.2.7, The War Within)
- **Max Level**: 80 (defined in EnchantCheckConstants.MAX_LEVEL)
- Uses modern APIs with no Classic/TBC support

## External Dependencies
- **Ace3**: Core framework (event handling, DB, console, hooks)
- **LibItemUpgradeInfo**: Accurate item level calculations across upgrade tracks
- **LibBabble-Inventory**: Localized item slot names for weapon type detection

## Notes
- ElvUI integration: Checks for ElvUI and adjusts frame positioning
- No automated tests (WoW addons typically require manual in-game testing)
- Debugging: Set `debugLevel` in DB or enable via slash commands
