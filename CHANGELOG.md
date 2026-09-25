# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [12.1.0-2]

### Fixed
- BoomForge is now declared as a required dependency on each CurseForge upload, so the CurseForge app installs it automatically alongside EnchantCheck.

## [12.1.0-1]

### Changed
- Bumped Interface version to 120100 for patch 12.1.0.

### Fixed
- False "Average item level: 0" / all-slots-missing report when zoning into an instance right after a loading screen, before the client's inventory cache repopulated.
- Notification sound no longer plays for warning-only reports (e.g. missing gems, warning-tier missing enchants); it now only fires when the highest issue found is error severity.

## [12.0.7-3-beta]

### Added
- Full settings panel (`/ec` or `/ec config`, or via Interface > AddOns > EnchantCheck) replacing the old slash-command-only config surface.
- Independently configurable severity (Off/Warning/Error) and display (Icon Only) for Primary enchant slots (Weapon/Chest/Legs/Rings), Secondary enchant slots (Head/Shoulder/Feet), and socket-upgrade warnings.
- Sound picker (with Preview) backed by LibSharedMedia, replacing the old hardcoded alert sound.

### Changed
- Smart Notifications now gates every warning type (not just missing enchants) behind max level + Epic+ rarity, so leveling gear doesn't generate noise across the board.
- `/ec set`/`/ec toggle`/`/ec reset` stay in sync with an open settings panel.

### Fixed
- Settings now actually persist across `/reload` and logout (the `.toc` files never declared `SavedVariables` before this release).

## [12.0.7-2]

### Added
- Quick-check your own gear or the gear of whoever you're currently inspecting, no separate window — issues are shown directly on the Character/Inspect frame slots and in item tooltips.
- Detects missing enchants on enchantable slots (skips heirlooms; only warns on Epic+ gear when Smart Notifications is on).
- Detects empty gem sockets.
- Detects item level more than 20% below your average equipped item level, correctly accounting for two-handed vs. one-handed/dual-wield weapon setups.
- Detects empty equipment slots.
- Flags Head/Wrist/Waist items that could receive a purchasable socket upgrade.
- Flags armor whose type (cloth/leather/mail/plate) doesn't match your class.
- Flags weapons/trinkets granting a primary stat that doesn't match your spec.
- Automatic rescans when you open your Character frame, inspect someone, change equipment, socket a gem, or your inventory changes (debounced to avoid rescanning on every event in a burst).
- `/ec check` (or `/enchantcheck check`) prints a full colored chat summary on demand.
- Smart Notifications toggle (default on) — suppresses enchant warnings on sub-Epic gear so leveling items don't generate noise.
- Ignore Heirlooms toggle (default on) — excludes heirlooms from low-item-level warnings.
- Optional sound alert when warnings are generated (default off).
- Full slash-command config system: `/ec config`, `/ec set <setting> <value>`, `/ec toggle <setting>`, `/ec reset`.
- Localized into English, German, Russian, Simplified Chinese, and Traditional Chinese.

[Unreleased]: https://github.com/whatisboom/EnchantCheck/compare/v12.1.0-1...HEAD
[12.1.0-1]: https://github.com/whatisboom/EnchantCheck/compare/v12.0.7-3-beta...v12.1.0-1
[12.0.7-3-beta]: https://github.com/whatisboom/EnchantCheck/compare/v12.0.7-2...v12.0.7-3-beta
[12.0.7-2]: https://github.com/whatisboom/EnchantCheck/releases/tag/v12.0.7-2
