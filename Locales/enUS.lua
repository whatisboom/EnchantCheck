local L = LibStub("AceLocale-3.0"):NewLocale("EnchantCheck", "enUS", true)
if not L then return end

L["Version"] = true
L["Authors"] = true

L["ENABLED"] = "enabled."
L["DISABLED"] = "disabled."
L["LOADED"] = "loaded."

L["BTN_CHECK_ENCHANTS"] = "Check"
L["BTN_INVITE"] = "Invite"

L["UI_ITEMS_TITLE"] = "Gear"
L["UI_GEMS_TITLE"] = "Gems"
L["UI_ENCHANTS_TITLE"] = "Enchants"

L["ENCHANT_REPORT_HEADER"] = "|cff00FF00Enchant Check|cffFFFFFF for %s (L%d %s):" -- name, level, class
L["AVG_ITEM_LEVEL"] = "Average item level: %d (%d to %d)"
L["MISSING_ITEMS"] = "Missing items:"
L["MISSING_GEMS"] = "Missing gems:"
L["MISSING_ENCHANTS"] = "Missing enchants:"
L["LOW_ITEM_LEVEL"] = "Low item level:"
L["PROPER_GEMS"] = "All sockets have gems."
L["PROPER_ENCHANTS"] = "All items are enchanted."

L["SCAN"] = "Scanning..."
L["RESCAN"] = "Re-scanning..."
L["SCAN_INCOMPLETE"] = "Scan incomplete, please try again later."

L["INVSLOT_"..INVSLOT_HEAD] = "Head"
L["INVSLOT_"..INVSLOT_NECK] = "Neck"
L["INVSLOT_"..INVSLOT_SHOULDER] = "Shoulder"
L["INVSLOT_"..INVSLOT_BACK] = "Back"
L["INVSLOT_"..INVSLOT_CHEST] = "Chest"
L["INVSLOT_"..INVSLOT_BODY] = "Shirt"
L["INVSLOT_"..INVSLOT_TABARD] = "Tabard"
L["INVSLOT_"..INVSLOT_WRIST] = "Wrist"

L["INVSLOT_"..INVSLOT_HAND] = "Hand"
L["INVSLOT_"..INVSLOT_WAIST] = "Waist"
L["INVSLOT_"..INVSLOT_LEGS] = "Legs"
L["INVSLOT_"..INVSLOT_FEET] = "Feet"
L["INVSLOT_"..INVSLOT_FINGER1] = "Ring 1"
L["INVSLOT_"..INVSLOT_FINGER2] = "Ring 2"
L["INVSLOT_"..INVSLOT_TRINKET1] = "Trinket 1"
L["INVSLOT_"..INVSLOT_TRINKET2] = "Trinket 2"

L["INVSLOT_"..INVSLOT_MAINHAND] = "Main-Hand"
L["INVSLOT_"..INVSLOT_OFFHAND] = "Off-Hand"
