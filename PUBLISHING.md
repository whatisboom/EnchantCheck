# Publishing EnchantCheck

## Prerequisites

1. Get your CurseForge API key from [CurseForge Core API](https://authors.curseforge.com/knowledge-base/projects/529-api-key)
2. Set environment variable:
   ```bash
   export CURSEFORGE_API_KEY='your-api-key-here'
   ```

## Publishing Process

### Option 1: Simple Script
```bash
./publish-simple.sh [version]
```

### Option 2: Full Script (with better formatting)
```bash
./publish.sh [version]
```

If no version is specified, it will use the latest git tag.

## Manual Process

1. **Tag the release:**
   ```bash
   git tag -a v11.1.7-2 -m "Release notes here"
   git push origin v11.1.7-2
   ```

2. **Create GitHub release:**
   ```bash
   gh release create v11.1.7-2 --title "EnchantCheck v11.1.7-2" --notes "Release notes"
   ```

3. **Publish to CurseForge:**
   ```bash
   ./publish.sh v11.1.7-2
   ```

## Project Details

- **CurseForge Project ID:** 461349
- **Project URL:** https://www.curseforge.com/wow/addons/enchant-check
- **GitHub URL:** https://github.com/whatisboom/EnchantCheck

## Notes

- Scripts automatically create zip packages with proper structure
- Changelog is extracted from git tag annotations
- Supports WoW 11.0.0+ (The War Within)
- Generated zip files are excluded from git via .gitignore