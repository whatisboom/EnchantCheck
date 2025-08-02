#!/bin/bash

# Simple EnchantCheck CurseForge Publisher
# Usage: ./publish-simple.sh [version]

VERSION=${1:-$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')}
PROJECT_ID="461349"
ADDON_NAME="EnchantCheck"

if [ -z "$CURSEFORGE_API_TOKEN" ]; then
    echo "Error: Set CURSEFORGE_API_TOKEN environment variable"
    exit 1
fi

if [ -z "$VERSION" ]; then
    echo "Error: No version specified"
    echo "Usage: ./publish-simple.sh [version]"
    exit 1
fi

echo "Publishing $ADDON_NAME v$VERSION to CurseForge..."

# Create package
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TEMP_DIR/$ADDON_NAME"
ZIP_FILE="${ADDON_NAME}-${VERSION}.zip"

mkdir -p "$PACKAGE_DIR"
cp -r *.lua *.toc *.xml *.md LICENSE Libs Locales modules "$PACKAGE_DIR/" 2>/dev/null
find "$PACKAGE_DIR" -name ".DS_Store" -delete 2>/dev/null || true

cd "$TEMP_DIR" && zip -r "$ZIP_FILE" "$ADDON_NAME" -q && cd -

# Get changelog
CHANGELOG=$(git tag -l -n1000 "v$VERSION" | sed "s/^v$VERSION[[:space:]]*//" || echo "Release v$VERSION")

# Upload
curl -H "X-Api-Token: $CURSEFORGE_API_TOKEN" \
     -F "metadata={\"changelog\":\"$CHANGELOG\",\"changelogType\":\"text\",\"displayName\":\"$ADDON_NAME $VERSION\",\"gameVersions\":[11.0.0],\"releaseType\":\"release\"}" \
     -F "file=@$TEMP_DIR/$ZIP_FILE" \
     "https://minecraft.curseforge.com/api/projects/$PROJECT_ID/upload-file"

cp "$TEMP_DIR/$ZIP_FILE" .
rm -rf "$TEMP_DIR"
echo "✓ Package saved: $ZIP_FILE"