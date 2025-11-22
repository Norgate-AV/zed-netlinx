#!/bin/bash

set -e

if [ "$CI" != "true" ]; then
    echo "Not running in CI, skipping version bump"
    exit 0
fi

TAG="${1}"
if [ -z "$TAG" ]; then
    echo "Usage: $0 <tag>"
    echo "Example: $0 v0.6.0"
    exit 1
fi

# Strip 'v' prefix to get version
VERSION="${TAG#v}"

if [ -z "$VERSION" ]; then
    echo "Failed to extract version from tag: $TAG"
    exit 1
fi

# Files to update
FILES=("extension.toml" "Cargo.toml")

# Check if all files exist before attempting to modify them
for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: $file not found"
        exit 1
    fi
done

# Update version in each file
for file in "${FILES[@]}"; do
    sed -i "s/^version = \".*\"/version = \"$VERSION\"/" "$file" || {
        echo "Failed to update version in $file"
        exit 1
    }
done

# Verify the changes were made
for file in "${FILES[@]}"; do
    if ! grep -q "version = \"$VERSION\"" "$file"; then
        echo "Error: Version was not updated in $file"
        exit 1
    fi
done

echo "Version bumped to $VERSION in ${FILES[*]}"

# Update Cargo.lock to reflect the new version
echo "Updating Cargo.lock..."
cargo update --workspace --offline 2>/dev/null || cargo update --workspace || {
    echo "Failed to update Cargo.lock"
    exit 1
}

echo "Cargo.lock updated successfully"
