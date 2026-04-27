# Lua & WoW API Patterns

Non-obvious patterns worth keeping in head. Anything that's already obvious from reading the code isn't here — check the code.

## Item data readiness

`C_Item.GetItemInfo(link)` returns `nil` when the server hasn't delivered full item data yet (first-open race). The addon's rescan loop handles this: it requests data via `C_Item.RequestLoadItemDataByID` and retries up to `rescanCount` times within a single frame. If you add a code path that reads item data, either go through `CheckGear`'s readiness gate or tolerate nil returns.

## Item string format

`|Hitem:ID:ENCHANT:GEM1:GEM2:GEM3:GEM4:SUFFIX:UNIQUE:LVL:SPEC:UPGRADE:DIFF:NUM_BONUS:...`

`ParseEnchantAndGems` in main.lua extracts the enchant ID and first four gem slots directly via pattern match. If you need other fields, extend the pattern rather than splitting on `:` — fields can be empty (`::`) and gsub-based split handles that fragilely.

## Localization

```lua
local L = LibStub("AceLocale-3.0"):GetLocale("EnchantCheck")
print(L["MISSING_ENCHANTS"])
```

When adding a new user-facing string: add it to `Locales/enUS.lua` (base locale, which defines the canonical keys), then add translations to the other locale files. Missing translations fall through to the key name.

## Ace3 lifecycle

- `OnInitialize()` — DB setup, runs after all files load but before any events fire.
- `OnEnable()` — event registration, timer starts.
- `OnDisable()` — event unregistration, overlay teardown.

Ace3 handlers dispatched by name (`self:RegisterEvent("INSPECT_READY")` calls `self:INSPECT_READY(event, ...)`).

## Content type detection

`DetectContentType` inspects instance type and difficulty. Thresholds come from `EnchantCheckConstants.CONTENT_ILVL_REQUIREMENTS`. Update constants when a new season shifts item level bands, not scattered conditionals.

## Slot frames (paperdoll overlays)

Frame globals follow the pattern `_G[prefix .. SLOT_FRAME_NAMES[slotId] .. "Slot"]` where prefix is `"Character"` or `"Inspect"`. The suffix table in constants.lua is the authoritative mapping — Blizzard's frame names don't always match slot names (e.g. slot 10 = "Hands" frame, slot 12 = "Finger1" frame).
