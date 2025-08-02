#!/bin/bash

# EnchantCheck CurseForge Publishing Script
# Project ID: 461349

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}EnchantCheck CurseForge Publisher${NC}"
echo "=================================="

# Check for API key
if [ -z "$CURSEFORGE_API_KEY" ]; then
    echo -e "${RED}Error: CURSEFORGE_API_KEY environment variable not set${NC}"
    echo "Please set your CurseForge API key:"
    echo "  export CURSEFORGE_API_KEY='your-api-key-here'"
    exit 1
fi

# Get version from tag or command line
VERSION=${1:-$(git describe --tags --abbrev=0 2>/dev/null)}
if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: No version specified and no git tags found${NC}"
    echo "Usage: ./publish.sh [version]"
    echo "  or create a git tag first"
    exit 1
fi

# Remove 'v' prefix if present
VERSION=${VERSION#v}

echo -e "${YELLOW}Publishing version: ${VERSION}${NC}"

# Project configuration
PROJECT_ID="461349"
ADDON_NAME="EnchantCheck"

# Create release package
echo -e "\n${YELLOW}Creating release package...${NC}"
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TEMP_DIR/$ADDON_NAME"
ZIP_FILE="${ADDON_NAME}-${VERSION}.zip"

# Copy addon files
mkdir -p "$PACKAGE_DIR"
cp -r *.lua *.toc *.xml *.md LICENSE "$PACKAGE_DIR/" 2>/dev/null || true
cp -r Libs Locales modules "$PACKAGE_DIR/" 2>/dev/null || true

# Remove any development files
find "$PACKAGE_DIR" -name ".DS_Store" -delete 2>/dev/null || true
find "$PACKAGE_DIR" -name "*.bak" -delete 2>/dev/null || true
rm -f "$PACKAGE_DIR/publish.sh" "$PACKAGE_DIR/.gitignore" 2>/dev/null || true

# Create zip
cd "$TEMP_DIR"
zip -r "$ZIP_FILE" "$ADDON_NAME" -q
cd - > /dev/null

echo -e "${GREEN}✓ Package created: ${ZIP_FILE}${NC}"

# Get changelog from git tag or latest commits
echo -e "\n${YELLOW}Generating changelog...${NC}"
CHANGELOG=""
if git tag -l "$VERSION" | grep -q "$VERSION"; then
    # Try to get tag message
    CHANGELOG=$(git tag -l -n1000 "$VERSION" | sed "s/^$VERSION[[:space:]]*//")
fi

if [ -z "$CHANGELOG" ]; then
    # Fallback to recent commits
    CHANGELOG=$(git log --pretty=format:"- %s" -n 10)
fi

# Determine game version
GAME_VERSION="10.2.0"  # Default
if [[ "$VERSION" == *"11."* ]]; then
    GAME_VERSION="11.0.0"
fi

# Prepare metadata
METADATA=$(cat <<EOF
{
  "changelog": $(echo "$CHANGELOG" | jq -Rs .),
  "changelogType": "markdown",
  "displayName": "${ADDON_NAME} ${VERSION}",
  "gameVersions": [${GAME_VERSION}],
  "releaseType": "release"
}
EOF
)

# Upload to CurseForge
echo -e "\n${YELLOW}Uploading to CurseForge...${NC}"
echo "Project ID: $PROJECT_ID"
echo "Game Version: $GAME_VERSION"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -H "X-Api-Token: ${CURSEFORGE_API_KEY}" \
  -F "metadata=${METADATA}" \
  -F "file=@${TEMP_DIR}/${ZIP_FILE}" \
  "https://minecraft.curseforge.com/api/projects/${PROJECT_ID}/upload-file")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq "200" ] || [ "$HTTP_CODE" -eq "201" ]; then
    FILE_ID=$(echo "$BODY" | jq -r '.id' 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Successfully uploaded to CurseForge!${NC}"
    echo -e "File ID: ${FILE_ID}"
    echo -e "URL: https://www.curseforge.com/wow/addons/enchant-check"
    
    # Copy zip to current directory
    cp "$TEMP_DIR/$ZIP_FILE" .
    echo -e "\n${GREEN}✓ Release package saved: ${ZIP_FILE}${NC}"
else
    echo -e "${RED}✗ Upload failed with status code: ${HTTP_CODE}${NC}"
    echo "Response: $BODY"
    exit 1
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}✓ Publishing complete!${NC}"