local L = LibStub("AceLocale-3.0"):NewLocale("EnchantCheck", "zhTW", true)
if not L then return end

L["Version"] = true
L["Authors"] = true

L["ENABLED"] = "啟用。"
L["DISABLED"] = "停用。"
L["LOADED"] = "載入。"

L["BTN_CHECK_ENCHANTS"] = "檢查裝備"
L["BTN_INVITE"] = "邀請"

L["UI_ITEMS_TITLE"] = "裝備"
L["UI_GEMS_TITLE"] = "寶石"
L["UI_ENCHANTS_TITLE"] = "附魔"

L["ENCHANT_REPORT_HEADER"] = "替 %s (L%d %s) 執行 |cff00FF00Enchant Check|cffFFFFFF 檢查。" -- name, level, class
L["AVG_ITEM_LEVEL"] = "平均裝備等級：%d (%d to %d)"
L["MISSING_ITEMS"] = "缺少裝備："
L["MISSING_GEMS"] = "缺少寶石："
L["MISSING_ENCHANTS"] = "缺少附魔："
L["LOW_ITEM_LEVEL"] = "低等級裝備："
L["MISSING_BELT_BUCKLE"] = "缺少腰帶扣？"
L["MISSING_BS_SOCKETS"] = "缺少鍛造插槽："

L["PROPER_GEMS"] = "所有插槽均有寶石。"
L["PROPER_ENCHANTS"] = "所有裝備均已附魔。"

L["SCAN"] = "掃描中"
L["RESCAN"] = "再次掃描"
L["SCAN_INCOMPLETE"] = "掃描未完成，請稍後再試。"

L["INVSLOT_"..INVSLOT_HEAD] = "頭部"
L["INVSLOT_"..INVSLOT_NECK] = "頸部"
L["INVSLOT_"..INVSLOT_SHOULDER] = "肩部"
L["INVSLOT_"..INVSLOT_BACK] = "背部"
L["INVSLOT_"..INVSLOT_CHEST] = "胸部"
L["INVSLOT_"..INVSLOT_BODY] = "襯衣"
L["INVSLOT_"..INVSLOT_TABARD] = "外袍"
L["INVSLOT_"..INVSLOT_WRIST] = "手腕"

L["INVSLOT_"..INVSLOT_HAND] = "手"
L["INVSLOT_"..INVSLOT_WAIST] = "腰部"
L["INVSLOT_"..INVSLOT_LEGS] = "腿部"
L["INVSLOT_"..INVSLOT_FEET] = "腳"
L["INVSLOT_"..INVSLOT_FINGER1] = "戒指 1"
L["INVSLOT_"..INVSLOT_FINGER2] = "戒指 2"
L["INVSLOT_"..INVSLOT_TRINKET1] = "飾品 1"
L["INVSLOT_"..INVSLOT_TRINKET2] = "飾品 2"

L["INVSLOT_"..INVSLOT_MAINHAND] = "主手"
L["INVSLOT_"..INVSLOT_OFFHAND] = "副手"
