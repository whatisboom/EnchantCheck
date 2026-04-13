# CLAUDE.md

## Project Overview

EnchantCheck is a World of Warcraft addon that checks gear for missing enchantments, gems, and optimization issues. Provides smart, context-aware notifications based on content type (leveling, dungeons, mythic+, raids).

## Development Workflow

### Testing in WoW
1. Place addon in `World of Warcraft/_retail_/Interface/AddOns/EnchantCheck/`
2. Launch WoW or `/reload` in-game
3. Test with `/enchantcheck check` or `/ec check`
4. Monitor for Lua errors (use BugSack addon or `/console scriptErrors 1`)

### Commands
```
/enchantcheck check    - Test gear checking logic
/ec config             - View current settings
/ec cache              - Check cache performance
/ec fixhead            - Force re-check head enchant requirements
```

### Publishing
Releases are automated via GitHub Actions when you push a git tag:

```bash
git tag -a v11.2.7-1 -m "Release v11.2.7-1

Changes:
- Fixed XYZ"

git push origin v11.2.7-1
```

GitHub Actions packages and uploads to CurseForge. Version convention: `v11.2.7-1` (WoW patch-addon revision)

**Setup (one-time):** Add `CF_API_KEY` to GitHub secrets. See PUBLISHING.md.

## Initialization Order (Critical)

WoW addons have strict global loading requirements:

1. **constants.lua** - Creates `_G.EnchantCheckConstants` immediately
2. **modules/cache.lua** - Defines `EnchantCheckCache` in global scope
3. **modules/utils.lua** - Utility functions, returns table
4. **Locales/** - Loaded via locales.xml, creates translation tables
5. **main.lua** - Creates addon, initializes all systems in `OnInitialize()`

**Important**: constants.lua uses numeric slot indices (1-18) instead of WoW globals (INVSLOT_*) to avoid load-time dependency issues.

## File Load Order (EnchantCheck.toc)

```
Libs/* (Ace3, LibStub, LibItemUpgradeInfo, LibDBIcon)
constants.lua
modules/cache.lua
modules/utils.lua
frames.xml (UI definitions)
Locales/locales.xml
main.lua
```

## External Dependencies

- **Ace3**: Core framework (event handling, DB, console, hooks)
- **LibItemUpgradeInfo**: Accurate item level calculations
- **LibBabble-Inventory**: Localized item slot names for weapon type detection

## WoW API Compatibility

- **Interface**: 110207 (WoW 11.2.7, The War Within)
- **Max Level**: 80 (defined in EnchantCheckConstants.MAX_LEVEL)
- Uses modern APIs, no Classic/TBC support

## Notes

- ElvUI integration: Adjusts frame positioning when detected
- No automated tests (WoW addons require manual in-game testing)
- Debugging: Set `debugLevel` in DB or enable via slash commands

## Reference Documentation

For patterns and modifications, see:
- [docs/patterns.md](./docs/patterns.md) - Lua patterns, WoW API, cache system, common modifications
