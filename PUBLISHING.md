# Publishing EnchantCheck

EnchantCheck uses the BigWigsMods packager for automated publishing to CurseForge, WoWInterface, and Wago Addons. Releases are created automatically via GitHub Actions when you push a git tag.

## Quick Start

```bash
# 1. Commit your changes
git add .
git commit -m "Update for patch 11.2.7"

# 2. Create annotated tag with changelog
git tag -a v11.2.7-1 -m "Release v11.2.7-1

Changes:
- Fixed bug with missing enchant detection
- Updated for WoW patch 11.2.7
- Improved cache performance"

# 3. Push tag to trigger automatic release
git push origin v11.2.7-1
```

GitHub Actions will automatically:
- Package the addon with all dependencies
- Upload to CurseForge
- Upload to WoWInterface (if configured)
- Upload to Wago Addons (if configured)
- Create a GitHub Release

## Prerequisites

### One-Time Setup

1. **Get API Tokens**:
   - CurseForge: [API Tokens Page](https://authors.curseforge.com/account/api-tokens)
   - WoWInterface: [API Tokens](https://www.wowinterface.com/downloads/filecpl.php?action=apitokens) (optional)
   - Wago: [API Keys](https://addons.wago.io/account/apikeys) (optional)

2. **Configure GitHub Secrets**:
   - Go to: https://github.com/whatisboom/EnchantCheck/settings/secrets/actions
   - Add `CF_API_KEY` with your CurseForge API token
   - Add `WOWI_API_TOKEN` if using WoWInterface
   - Add `WAGO_API_TOKEN` if using Wago

3. **Enable Workflow Permissions**:
   - Go to: https://github.com/whatisboom/EnchantCheck/settings/actions
   - Under "Workflow permissions", select "Read and write permissions"

## Version Numbering

Follow this convention:
```
v[WoW-Patch]-[Release]

Examples:
v11.2.7-1  # First release for patch 11.2.7
v11.2.7-2  # Second release for same patch
v11.3.0-1  # First release for patch 11.3.0
```

## Release Process

### Standard Release

```bash
# 1. Update Interface version in TOC files (if WoW patch changed)
# Edit EnchantCheck.toc and EnchantCheck_Mainline.toc
## Interface: 110207

# 2. Test your changes in-game
/reload
/ec check

# 3. Commit all changes
git add .
git commit -m "Descriptive commit message"

# 4. Create release tag with detailed changelog
git tag -a v11.2.7-1 -m "EnchantCheck v11.2.7-1

New Features:
- Added tooltip warnings for missing enchants
- Minimap button now shows gear status

Bug Fixes:
- Fixed false positives for heirloom items
- Corrected enchant detection for crafted gear

Technical:
- Updated for WoW patch 11.2.7
- Improved caching system performance"

# 5. Push tag
git push origin v11.2.7-1

# 6. Monitor GitHub Actions
# Visit: https://github.com/whatisboom/EnchantCheck/actions
```

### Alpha/Beta Release

For testing builds before official release:

```bash
# Alpha release
git tag -a v11.2.7-1-alpha -m "Alpha test build"
git push origin v11.2.7-1-alpha

# Beta release
git tag -a v11.2.7-1-beta -m "Beta test build"
git push origin v11.2.7-1-beta
```

Alpha and beta releases are marked as such on CurseForge automatically.

## Monitoring Releases

### GitHub Actions

Watch the release build progress:
1. Go to https://github.com/whatisboom/EnchantCheck/actions
2. Click on the latest "Package and Release" workflow
3. View build logs and download artifacts

### Release URLs

After successful upload, find your release at:
- **CurseForge**: https://www.curseforge.com/wow/addons/enchant-check
- **WoWInterface**: https://www.wowinterface.com/downloads/info[ID].html
- **Wago**: https://addons.wago.io/addons/enchant-check
- **GitHub**: https://github.com/whatisboom/EnchantCheck/releases

## Troubleshooting

### Build Failed

**Check the workflow logs**:
1. Go to https://github.com/whatisboom/EnchantCheck/actions
2. Click the failed workflow
3. Review error messages

Common issues:
- Missing API token in GitHub Secrets
- Invalid .pkgmeta syntax (use spaces, not tabs)
- External library URL changed or unavailable

### Wrong Version Number

The packager automatically uses the git tag as the version. Ensure:
- Tag is annotated: `git tag -a v1.0.0 -m "Message"` ✓
- Tag is not lightweight: `git tag v1.0.0` ✗

### Changelog Not Showing

The changelog is pulled from the git tag message. Use:
```bash
git tag -a v1.0.0 -m "Detailed changelog here"
```

Not:
```bash
git tag v1.0.0  # No changelog!
```

### Upload Failed

Check that:
- API tokens are valid and not expired
- Tokens are correctly added to GitHub Secrets
- Project IDs are correct in TOC files:
  - `## X-Curse-Project-ID: 461349`

## Local Testing

To test packaging locally without uploading:

```bash
# Setup (one-time)
mkdir .release
cd .release
curl -O https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh
chmod +x release.sh
cd ..

# Test package creation
.release/release.sh -d

# Check generated files
ls -la .release/EnchantCheck/
```

## Project Details

- **CurseForge Project ID**: 461349
- **CurseForge URL**: https://www.curseforge.com/wow/addons/enchant-check
- **GitHub Repository**: https://github.com/whatisboom/EnchantCheck

## Migration from Old Scripts

The old `publish.sh` and `publish-simple.sh` scripts have been deprecated in favor of the automated GitHub Actions workflow. The new system:

- ✓ Automatically detects game versions from TOC files
- ✓ No manual version ID tracking needed
- ✓ Consistent releases across all platforms
- ✓ Automated changelog generation
- ✓ Industry-standard tooling

Old scripts are kept in the repository for reference but should not be used for new releases.

## Additional Resources

- [BigWigsMods Packager Documentation](https://github.com/BigWigsMods/packager)
- [CurseForge Upload API](https://support.curseforge.com/en/support/solutions/articles/9000197321)
- [WoW TOC Format](https://warcraft.wiki.gg/wiki/TOC_format)
