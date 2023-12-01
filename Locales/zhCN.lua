local L = LibStub("AceLocale-3.0"):NewLocale("EnchantCheck", "zhCN", true)
if not L then return end

L["Version"] = true
L["Authors"] = true

L["ENABLED"] = "启用。"
L["DISABLED"] = "停用。"
L["LOADED"] = "加载。"

L["BTN_CHECK_ENCHANTS"] = "检查装备"
L["BTN_INVITE"] = "邀请"

L["UI_ITEMS_TITLE"] = "装备"
L["UI_GEMS_TITLE"] = "宝石"
L["UI_ENCHANTS_TITLE"] = "附魔"

L["ENCHANT_REPORT_HEADER"] = "替 %s (L%d %s) 执行 |cff00FF00Enchant Check|cffFFFFFF 检查。" -- name, level, class
L["AVG_ITEM_LEVEL"] = "平均装备等级：%d (%d to %d)"
L["MISSING_ITEMS"] = "缺少装备："
L["MISSING_GEMS"] = "缺少宝石："
L["MISSING_ENCHANTS"] = "缺少附魔："
L["LOW_ITEM_LEVEL"] = "低等级装备："
L["MISSING_BELT_BUCKLE"] = "缺少腰带扣？"
L["MISSING_BS_SOCKETS"] = "缺少锻造插槽："

L["PROPER_GEMS"] = "所有插槽均有宝石。"
L["PROPER_ENCHANTS"] = "所有装备均已附魔。"

L["SCAN"] = "扫描中"
L["RESCAN"] = "再次扫描"
L["SCAN_INCOMPLETE"] = "扫描未完成，请稍后再试。"

L["INVSLOT_"..INVSLOT_HEAD] = "头部"
L["INVSLOT_"..INVSLOT_NECK] = "颈部"
L["INVSLOT_"..INVSLOT_SHOULDER] = "肩部"
L["INVSLOT_"..INVSLOT_BACK] = "背部"
L["INVSLOT_"..INVSLOT_CHEST] = "胸部"
L["INVSLOT_"..INVSLOT_BODY] = "衬衣"
L["INVSLOT_"..INVSLOT_TABARD] = "外袍"
L["INVSLOT_"..INVSLOT_WRIST] = "手腕"

L["INVSLOT_"..INVSLOT_HAND] = "手"
L["INVSLOT_"..INVSLOT_WAIST] = "腰部"
L["INVSLOT_"..INVSLOT_LEGS] = "腿部"
L["INVSLOT_"..INVSLOT_FEET] = "脚"
L["INVSLOT_"..INVSLOT_FINGER1] = "戒指 1"
L["INVSLOT_"..INVSLOT_FINGER2] = "戒指 2"
L["INVSLOT_"..INVSLOT_TRINKET1] = "饰品 1"
L["INVSLOT_"..INVSLOT_TRINKET2] = "饰品 2"

L["INVSLOT_"..INVSLOT_MAINHAND] = "主手"
L["INVSLOT_"..INVSLOT_OFFHAND] = "副手"
