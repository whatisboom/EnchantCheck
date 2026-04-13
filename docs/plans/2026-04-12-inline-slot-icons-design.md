# Inline Slot Icons Design

## Context

EnchantCheck currently shows gear issues via a report panel that overlays the character model, toggled by a "Check Gear" button. This requires an explicit click and obscures the character. The goal is to replace this with inline icons directly on paperdoll item slots, providing at-a-glance issue visibility without any manual trigger.

## Design

### Visual treatment

Each paperdoll slot with issues gets:
- **Colored border** around the slot: red for errors (missing item, low ilvl), yellow for warnings (missing enchant/gem, purchaseable upgrade)
- **Small badge icons** (~12x12px) along the bottom edge of the slot, one per issue type

If a slot has both error and warning issues, the border uses the highest severity (red).

Slots with no issues get no overlay at all.

### Icon types

| Issue | Texture | Severity |
|-------|---------|----------|
| Missing enchant | `Interface\Icons\INV_Enchant_FormulaSuperior_01` | Warning (yellow) |
| Missing gem | `Interface\Icons\INV_Misc_Gem_01` | Warning (yellow) |
| Low item level | `Interface\Icons\Spell_ChargeDown` | Error (red) |
| Purchaseable upgrade | `Interface\Icons\INV_Misc_Coin_01` | Warning (yellow) |

Icons stack horizontally from right to left in the bottom-right corner of the slot.

### Trigger

- **Character frame:** Icons appear automatically when the character frame opens. Hook `PaperDollFrame:Show` or the `PLAYER_EQUIPMENT_CHANGED` event.
- **Inspect frame:** Icons appear when `INSPECT_READY` fires (existing event handler).
- **Inventory change:** Icons refresh on `UNIT_INVENTORY_CHANGED` if the character frame is open.
- **No button** needed. No manual trigger.

### Chat output

`/ec check` continues to print warnings to chat. This is the only remaining "report" output.

### What gets removed

- `frames.xml` (entire file deleted, removed from .toc)
- `EnchantCheckFrame`, `EnchantCheckItemsFrame`, `EnchantCheckGemsFrame`, `EnchantCheckEnchantsFrame`
- `CharacterFrameEnchantCheckButton`, `InspectFrameEnchantCheckButton`
- `GenerateReport()` — replaced by `UpdateSlotOverlays()`
- `SetCheckFrame()`, `ClearCheckFrame()`, `ShowProgressUpdate()`
- `CheckCharacter()`, `CheckInspected()` — replaced by auto-trigger hooks

### What gets added

**constants.lua:**
- `SLOT_FRAME_NAMES` — maps slot ID to frame name suffix: `[1] = "Head"`, `[2] = "Neck"`, etc.
- `OVERLAY_ICONS` — texture paths and sizing for each issue type
- Border color constants for error/warning severity

**main.lua:**
- `CreateSlotOverlay(slotFrame)` — creates a child frame on a slot with border texture + 4 icon textures, all hidden by default
- `CreateAllOverlays()` — iterates all slots, creates overlays for both character and inspect frames
- `UpdateSlotOverlays(prefix, missingItems, missingEnchants, missingGems, lowLevelItems, upgradeableItems)` — shows/hides icons per slot based on issue data
- `ClearAllOverlays(prefix)` — hides all overlays for a given prefix
- `RunCheck(unit, prefix)` — runs CheckGear and feeds results to UpdateSlotOverlays
- Hooks on PaperDollFrame show, INSPECT_READY, UNIT_INVENTORY_CHANGED

### Data flow

```
Character frame opens
  -> RunCheck("player", "Character")
    -> CheckGear("player") [existing, produces per-slot issue lists]
    -> UpdateSlotOverlays("Character", issues...)
      -> For each slot with issues:
        -> Show border (red or yellow)
        -> Show relevant icons (enchant, gem, ilvl, upgrade)
      -> For each slot without issues:
        -> Hide overlay
```

### Implementation approach

Overlays are Lua-only (no XML). Each overlay is a Frame parented to the slot frame with:
- A border Texture child (covers the slot edges)
- 4 icon Texture children (one per issue type), anchored to BOTTOMRIGHT and offsetting left for each additional icon

The prefix system ("Character" vs "Inspect") maps to WoW's naming convention:
- `_G["CharacterHeadSlot"]` for the character frame
- `_G["InspectHeadSlot"]` for the inspect frame

### Verification

1. Open character frame with fully enchanted/gemmed gear -> no icons visible
2. Unenchant an item -> yellow border + scroll icon on that slot
3. Remove a gem -> yellow border + gem icon on that slot
4. Equip a very low ilvl item -> red border + down arrow
5. Check jewelry without max sockets -> yellow border + coin icon
6. `/ec check` -> warnings still print to chat
7. Inspect another player -> icons appear on their slots
8. Close and reopen character frame -> icons refresh correctly
