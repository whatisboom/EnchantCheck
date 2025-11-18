# Deprecated Publishing Scripts

The scripts in this directory are **deprecated** and should not be used for new releases.

## Migration to BigWigsMods Packager

As of the 11.2.7-1 release, EnchantCheck uses the industry-standard BigWigsMods packager for automated publishing via GitHub Actions.

### Old Workflow (Deprecated)
```bash
export CURSEFORGE_API_TOKEN='...'
./publish.sh v11.2.7-1
```

**Problems with old approach:**
- Required manual tracking of CurseForge game version IDs
- Version IDs changed with every WoW patch
- Manual uploads prone to errors
- No multi-platform support
- Inconsistent with industry standards

### New Workflow (Current)
```bash
git tag -a v11.2.7-1 -m "Release notes"
git push origin v11.2.7-1
```

**Benefits of new approach:**
- ✓ Automatic version detection from TOC files
- ✓ No manual version ID tracking
- ✓ Automated uploads to multiple platforms
- ✓ Consistent with major WoW addons
- ✓ Better changelog integration
- ✓ GitHub Actions CI/CD

## Migration Guide

See [PUBLISHING.md](../PUBLISHING.md) for complete instructions on:
- Setting up GitHub secrets for API tokens
- Creating releases with git tags
- Monitoring build status
- Troubleshooting common issues

## Why Keep These Scripts?

These scripts are preserved for:
1. **Historical reference** - understanding the old workflow
2. **Emergency fallback** - in case GitHub Actions is unavailable
3. **Documentation** - showing the evolution of the publishing process

## If You Must Use These Scripts

⚠️ **Not recommended**, but if necessary:

1. The scripts reference outdated game version IDs
2. You'll need to manually update `GAME_VERSION_ID` in `publish.sh`
3. Find current version IDs by querying the CurseForge API
4. Environment variable is `CURSEFORGE_API_TOKEN` (not `CF_API_KEY`)

**Instead, please migrate to the automated workflow described in PUBLISHING.md**
