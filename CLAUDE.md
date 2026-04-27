# CLAUDE.md

## Project Overview

EnchantCheck is a World of Warcraft addon that checks gear for missing enchantments, gems, and optimization issues. Provides smart, context-aware notifications based on content type (leveling, dungeons, mythic+, raids).

## Development Workflow

### Testing in WoW
1. Place addon in `World of Warcraft/_retail_/Interface/AddOns/EnchantCheck/`
2. Launch WoW or `/reload` in-game
3. Run `/ec help` in-game for the current command list
4. Monitor for Lua errors (use BugSack addon or `/console scriptErrors 1`)

### Publishing

Releases are automated via GitHub Actions when you push a git tag matching `v<wow-patch>-<addon-revision>` (see `git log --oneline v*` for prior tags). GitHub Actions packages and uploads to CurseForge.

**Setup (one-time):** Add `CF_API_KEY` to GitHub secrets. See PUBLISHING.md.

**Before tagging:** ask the user whether this release is alpha/beta/stable.

## Manifest Validation

There are two `.toc` files (`EnchantCheck.toc` and `EnchantCheck_Mainline.toc`) that must stay in sync with the actual files on disk. A pre-commit hook enforces this.

**Install once:** `bash scripts/install-hooks.sh`

The hook runs `scripts/validate-manifests.sh`, which checks:
1. Every entry in every `.toc` points at a real file
2. Every `<Script file="..."/>` / `<Include file="..."/>` in addon `.xml` resolves
3. Every non-Libs `.lua` is referenced by some manifest (no orphans)

When adding/removing/renaming a `.lua` or `.xml`, update **both** `.toc` files.

## Initialization Order (Critical)

WoW addons have strict load-order constraints. File load order lives in the `.toc` files — check there for authoritative order. The invariant to preserve:

- `constants.lua` must load first and create `_G.EnchantCheckConstants` at file scope (not inside a function), because `main.lua` captures references to constants fields at file scope.
- `Locales/locales.xml` must load before `main.lua` so the locale table exists when `main.lua` calls `GetLocale`.

`constants.lua` uses numeric slot indices (1-18) instead of WoW globals (`INVSLOT_*`) to avoid load-time dependency issues — WoW's slot globals may not be defined yet when constants are evaluated.

## External Dependencies

- **Ace3** — core framework (addon skeleton, events, DB, console, hooks, timers)
- **LibItemUpgradeInfo** — accurate item level calculations across upgrades

## Notes

- ElvUI integration: addon adjusts frame positioning when ElvUI is detected.
- No automated tests — changes are validated manually in-game before commit.
- Debugging: set `debugLevel` in the DB or toggle via slash commands.

## Reference Documentation

For patterns and modifications, see:
- [docs/patterns.md](./docs/patterns.md) - Lua patterns, WoW API, common modifications
