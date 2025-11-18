# EnchantCheck

Never enter a raid with missing enchants again! EnchantCheck is a World of Warcraft addon that instantly shows you missing enchantments, gems, and gear issues with a single click.

## Why EnchantCheck?

- **One-Click Gear Audit**: Instantly see all missing enchants, empty gem sockets, and gear problems
- **Smart Notifications**: Get warnings based on your content type - no spam while leveling, strict checks for raids
- **Visual Overlay**: Clear, easy-to-read overlay shows exactly what needs fixing
- **Works on Inspect**: Check other players' gear optimization before inviting them to groups
- **Character Frame Integration**: Convenient "Check" button right on your character sheet

## Features

### 🎯 Smart Content Detection
Automatically adjusts warnings based on what you're doing:
- **Leveling**: Relaxed checks, ignores heirlooms
- **Dungeons**: Standard enchant requirements
- **Mythic+**: Strict requirements for competitive content  
- **Raids**: Maximum optimization checks
- **PvP**: PvP-specific requirements

### 🔍 Comprehensive Gear Analysis
- Missing enchantments on all enchantable slots
- Empty gem sockets
- Significantly under-leveled items
- Missing gear slots
- Belt buckle reminders (when applicable)

### 💡 Quality of Life
- **Enhanced Tooltips**: See enchant/gem status directly on item tooltips
- **Character & Inspect Buttons**: Quick access from character and inspect frames
- **Context-Aware**: Head enchants only required during specific seasons
- **Performance Optimized**: Smart caching system prevents lag
- **Multi-Language**: Supports English, German, Russian, Chinese (Simplified & Traditional)

## Commands

- `/enchantcheck` or `/ec` - Open configuration
- `/ec check` - Manually check your gear
- `/ec config` - Show current settings
- `/ec toggle smartNotifications` - Toggle smart notifications
- `/ec set minItemLevelForWarnings 450` - Set minimum item level for warnings

## Installation

1. Download the latest release
2. Extract to `World of Warcraft/_retail_/Interface/AddOns/`
3. Restart World of Warcraft or reload UI (`/reload`)

## Configuration

Configure via slash commands (`/ec config`):

- **Smart Notifications**: Enable/disable content-aware warnings
- **Item Level Threshold**: Set minimum item level for warnings (default: 400)
- **Ignore Heirlooms**: Skip heirloom items during checks
- **Suppress Leveling Warnings**: Reduce notifications while leveling
- **Enhanced Tooltips**: Show enchant/gem info on item tooltips
- **Enhanced Dungeon Checks**: Stricter requirements for dungeon content

## Screenshots

*Coming soon*

## Support

Found a bug or have a suggestion? Please [open an issue](https://github.com/whatisboom/EnchantCheck/issues).

## License

This addon is licensed under the GNU General Public License v3.0. See LICENSE file for details.

## Credits

Created by whatisboom

Special thanks to the WoW addon community and all contributors.