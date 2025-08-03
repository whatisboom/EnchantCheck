local L = LibStub("AceLocale-3.0"):NewLocale("EnchantCheck", "ruRU")
if not L then return end

L["Version"] = "Версия"
L["Authors"] = "Авторы"

L["ENABLED"] = "включено."
L["DISABLED"] = "отключено."
L["LOADED"] = "загружен."

L["BTN_CHECK_ENCHANTS"] = "Проверить экипировку"
L["BTN_INVITE"] = "Пригласить"

L["UI_ITEMS_TITLE"] = "Экипировка"
L["UI_GEMS_TITLE"] = "Камни"
L["UI_ENCHANTS_TITLE"] = "Чары"

L["ENCHANT_REPORT_HEADER"] = "|cff00FF00Проверка чар|cffFFFFFF для %s (L%d %s):" -- name, level, class
L["AVG_ITEM_LEVEL"] = "Средний уровень предметов: %d (%d к %d)"
L["MISSING_ITEMS"] = "Отсутствующие предметы:"
L["MISSING_GEMS"] = "Отсутствующие камни:"
L["MISSING_ENCHANTS"] = "Отсутствующие чары:"
L["LOW_ITEM_LEVEL"] = "Низкий уровень предметов:"
L["MISSING_BELT_BUCKLE"] = "Отсутствует поясная пряжка?"
L["MISSING_BS_SOCKETS"] = "Отсутствующие кузнечные гнезда (?):"

L["PROPER_GEMS"] = "Во всех гнездах есть камни."
L["PROPER_ENCHANTS"] = "Все предметы зачарованы."

L["SCAN"] = "Сканирование..."
L["RESCAN"] = "Повторное сканирование..."
L["SCAN_INCOMPLETE"] = "Сканирование не завершено, повторите попытку позже."

L["INVSLOT_"..INVSLOT_HEAD] = "Голова"
L["INVSLOT_"..INVSLOT_NECK] = "Шея"
L["INVSLOT_"..INVSLOT_SHOULDER] = "Плечо"
L["INVSLOT_"..INVSLOT_BACK] = "Спина"
L["INVSLOT_"..INVSLOT_CHEST] = "Грудь"
L["INVSLOT_"..INVSLOT_BODY] = "Рубашка"
L["INVSLOT_"..INVSLOT_TABARD] = "Гербовая накидка"
L["INVSLOT_"..INVSLOT_WRIST] = "Запястья"

L["INVSLOT_"..INVSLOT_HAND] = "Кисти рук"
L["INVSLOT_"..INVSLOT_WAIST] = "Пояс"
L["INVSLOT_"..INVSLOT_LEGS] = "Ноги"
L["INVSLOT_"..INVSLOT_FEET] = "Ступни"
L["INVSLOT_"..INVSLOT_FINGER1] = "Кольцо 1"
L["INVSLOT_"..INVSLOT_FINGER2] = "Кольцо 2"
L["INVSLOT_"..INVSLOT_TRINKET1] = "Аксессуар 1"
L["INVSLOT_"..INVSLOT_TRINKET2] = "Аксессуар 2"

L["INVSLOT_"..INVSLOT_MAINHAND] = "Правая рука"
L["INVSLOT_"..INVSLOT_OFFHAND] = "Левая рука"
