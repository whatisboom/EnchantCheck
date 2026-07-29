local L = LibStub("AceLocale-3.0"):NewLocale("EnchantCheck", "enUS", true)
if not L then return end

L["Version"] = true
L["Authors"] = true

L["ENABLED"] = "enabled."
L["DISABLED"] = "disabled."
L["LOADED"] = "loaded."

L["OPT_SECTION_GENERAL"] = "General"
L["OPT_ENABLE"] = "Enable EnchantCheck"
L["OPT_ENABLE_DESC"] = "Master switch for the addon."

L["OPT_SECTION_SMART_FILTERING"] = "Smart Filtering"
L["OPT_SMART_NOTIFICATIONS"] = "Smart Notifications"
L["OPT_SMART_NOTIFICATIONS_DESC"] = "Only warn about Epic-quality gear or better on a character at max level, so leveling doesn't generate noise."
L["OPT_IGNORE_HEIRLOOMS"] = "Ignore Heirlooms"
L["OPT_IGNORE_HEIRLOOMS_DESC"] = "Exclude heirloom items from low item level warnings."

L["OPT_SECTION_WARNINGS"] = "Warnings"
L["OPT_WARN_MISSING_ITEMS"] = "Missing Items"
L["OPT_WARN_MISSING_ITEMS_DESC"] = "Warn about empty equipment slots."

L["OPT_WARN_MISSING_GEMS"] = "Missing Gems"
L["OPT_WARN_MISSING_GEMS_DESC"] = "Warn about empty gem sockets."
L["OPT_WARN_LOW_ITEM_LEVEL"] = "Low Item Level"
L["OPT_WARN_LOW_ITEM_LEVEL_DESC"] = "Warn about items more than 20% below your average item level."
L["OPT_WARN_WRONG_ARMOR_TYPE"] = "Wrong Armor Type"
L["OPT_WARN_WRONG_ARMOR_TYPE_DESC"] = "Warn when equipped armor doesn't match your class's armor type."
L["OPT_WARN_WRONG_STATS"] = "Wrong Stats"
L["OPT_WARN_WRONG_STATS_DESC"] = "Warn when a weapon or trinket grants a primary stat that doesn't match your spec."

L["OPT_SECTION_SEVERITY"] = "Severity"
L["OPT_SEVERITY_OFF"] = "Off"
L["OPT_SEVERITY_WARNING"] = "Warning"
L["OPT_SEVERITY_ERROR"] = "Error"

L["OPT_PRIMARY_ENCHANT_SEVERITY"] = "Primary Enchant"
L["OPT_PRIMARY_ENCHANT_SEVERITY_DESC"] = "Weapon, Chest, Legs, and Rings carry real stat-affecting enchants. Off disables this warning entirely."
L["OPT_PRIMARY_ENCHANT_ICON_ONLY"] = "Icon Only"
L["OPT_PRIMARY_ENCHANT_ICON_ONLY_DESC"] = "Keep the corner icon but drop the colored slot border."
L["OPT_SECONDARY_ENCHANT_SEVERITY"] = "Secondary Enchant"
L["OPT_SECONDARY_ENCHANT_SEVERITY_DESC"] = "Head, Shoulder, and Feet only carry tertiary-stat enchants (leech, avoidance, speed). Off disables this warning entirely."
L["OPT_SECONDARY_ENCHANT_ICON_ONLY"] = "Icon Only"
L["OPT_SECONDARY_ENCHANT_ICON_ONLY_DESC"] = "Keep the corner icon but drop the colored slot border."
L["OPT_SOCKET_UPGRADE_SEVERITY"] = "Socket Upgrade"
L["OPT_SOCKET_UPGRADE_SEVERITY_DESC"] = "Warn when Head, Wrist, or Waist could receive a purchaseable socket upgrade. Off disables this warning entirely."
L["OPT_SOCKET_UPGRADE_ICON_ONLY"] = "Icon Only"
L["OPT_SOCKET_UPGRADE_ICON_ONLY_DESC"] = "Keep the corner icon but drop the colored slot border."

L["OPT_SECTION_SOUNDS"] = "Sounds"
L["OPT_ENABLE_SOUNDS"] = "Enable Sound Alert"
L["OPT_ENABLE_SOUNDS_DESC"] = "Play a sound when warnings are generated."
L["OPT_SOUND"] = "Alert Sound"
L["OPT_SOUND_DESC"] = "Sound played when warnings are generated (LibSharedMedia)."
L["OPT_SOUND_DESC_EXPANDABLE"] = "More choices appear automatically if you install a SharedMedia sound pack or another addon that registers sounds."
L["OPT_SOUND_PREVIEW"] = "Preview"
L["OPT_SOUND_PREVIEW_DESC"] = "Play the selected alert sound."

L["OPT_SECTION_ADVANCED"] = "Advanced"
L["OPT_DEBUG_LEVEL"] = "Debug Level"
L["OPT_DEBUG_LEVEL_DESC"] = "Verbosity of chat log messages."
L["OPT_DEBUG_LEVEL_OFF"] = "Off"
L["OPT_DEBUG_LEVEL_WARNING"] = "Warning"
L["OPT_DEBUG_LEVEL_INFO"] = "Info"
L["OPT_DEBUG_LEVEL_NOTICE"] = "Notice"

L["ENCHANT_REPORT_HEADER"] = "|cff00FF00Enchant Check|cffFFFFFF for %s (L%d %s):" -- name, level, class
L["AVG_ITEM_LEVEL"] = "Average item level: %d (%d to %d)"
L["MISSING_ITEMS"] = "Missing items:"
L["MISSING_GEMS"] = "Missing gems:"
L["MISSING_ENCHANTS"] = "Missing enchants:"
L["LOW_ITEM_LEVEL"] = "Low item level:"
L["MISSING_BELT_BUCKLE"] = "Missing belt buckle?"
L["MISSING_BS_SOCKETS"] = "Missing blacksmith sockets (?):"
L["UPGRADEABLE_SOCKETS"] = "Can add socket:"

L["PROPER_GEMS"] = "All sockets have gems."
L["PROPER_ENCHANTS"] = "All items are enchanted."

L["TOOLTIP_MISSING_ENCHANT"] = "Missing enchant"
L["TOOLTIP_MISSING_GEM"] = "Missing gem"
L["TOOLTIP_LOW_ILVL"] = "Low item level"
L["TOOLTIP_PURCHASEABLE_UPGRADE"] = "Can add socket"
L["TOOLTIP_HEADER"] = "Issues with this item (Enchant Check):"

L["WRONG_ARMOR_TYPE"] = "Wrong armor type:"
L["WRONG_STATS"] = "Wrong stats for spec:"
L["WRONG_ARMOR_TYPE_DETAIL"] = "%s (your class wears %s)"      -- have, want
L["WRONG_STAT_DETAIL"] = "grants %s, your spec uses %s"        -- have, want

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
