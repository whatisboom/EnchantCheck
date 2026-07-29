# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/whatisboom/EnchantCheck/compare/v12.0.7-2...HEAD
[12.0.7-2]: https://github.com/whatisboom/EnchantCheck/releases/tag/v12.0.7-2
