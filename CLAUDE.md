# EnchantCheck - World of Warcraft AddOn

## Project Overview
EnchantCheck is a World of Warcraft addon that helps players quickly check their gear or inspected players' gear for missing enchantments, gems, and equipment optimization issues. It provides automated warnings and smart notifications based on content type and player level.

## Key Features
- **Gear Analysis**: Scans all equipment slots for missing enchants, gems, and low-level items
- **Smart Notifications**: Context-aware warnings based on content type (leveling, dungeons, mythic+, raids)
- **Player & Inspect Support**: Check your own gear or inspect other players
- **Minimap Integration**: Visual status indicator and quick access menu
- **Enhanced Tooltips**: Show enchant and gem status directly in item tooltips
- **Performance Optimized**: Caching system and batch processing for better game performance

## Technical Architecture

### Core Files
- `main.lua` - Main addon logic, gear checking system, UI management (2,256 lines)
- `constants.lua` - Configuration constants, slot definitions, and settings
- `EnchantCheck.toc` / `EnchantCheck_Mainline.toc` - Addon metadata and load order

### Module System
- `modules/cache.lua` - Item data caching with TTL and LRU eviction
- `modules/utils.lua` - Utility functions and helpers

### UI Framework
- `frames.xml` - UI frame definitions and layout
- `embeds.xml` - External library integration
- `Locales/` - Multi-language support (deDE, enUS, ruRU, zhCN, zhTW)

### Dependencies
- **Ace3 Framework**: AceAddon, AceConsole, AceDB, AceEvent, AceHook, AceTimer
- **LibStub**: Library management
- **LibItemUpgradeInfo**: Item level calculations
- **LibDBIcon**: Minimap button support

## Smart Notification System
The addon features an intelligent notification system that adapts warnings based on:
- **Content Type Detection**: Automatically detects leveling, dungeons, mythic+, raids, PVP
- **Item Level Thresholds**: Configurable minimum item levels for warnings
- **Heirloom Support**: Option to ignore heirloom items during leveling
- **Dynamic Enchant Requirements**: Head enchants required only in specific seasons

## Configuration System
- **Profile-based settings** with AceDB
- **Real-time configuration updates** 
- **Chat command interface** (`/enchantcheck`)
- **Context menu integration**

## Cache Performance
- **Item data caching** with configurable TTL (300s default)
- **LRU eviction** when cache exceeds size limits (500 items default)
- **Hit/miss statistics** for performance monitoring
- **Automatic cleanup** and maintenance timers

## Development Commands
```
/enchantcheck help          - Show available commands
/enchantcheck check         - Check your gear
/enchantcheck config        - Show current settings
/enchantcheck cache         - Show cache statistics  
/enchantcheck fixhead       - Force re-check head enchant requirements
```

## Version Information
- **Current Version**: v11.1.7-1
- **WoW Interface**: 110105 (supports current retail version)
- **Author**: whatisboom
- **License**: GNU General Public License v3.0

## File Structure
```
EnchantCheck/
├── main.lua                    # Main addon logic
├── constants.lua               # Configuration constants
├── EnchantCheck.toc           # Addon metadata
├── LICENSE                    # GPL v3.0 license
├── Libs/                      # External libraries
│   ├── Ace3/                 # Ace3 framework components
│   ├── LibStub/              # Library management
│   └── LibItemUpgradeInfo/   # Item level utilities
├── Locales/                   # Internationalization
├── modules/                   # Modular components
│   ├── cache.lua             # Caching system
│   └── utils.lua             # Utility functions
├── frames.xml                 # UI definitions
└── embeds.xml                # Library embedding
```

## Notes for Development
- The addon uses modern WoW APIs with fallbacks for compatibility
- Extensive debug logging system with configurable levels
- Memory management with garbage collection hints
- Thread-safe caching with proper cleanup
- ElvUI integration for UI positioning