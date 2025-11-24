#!/bin/bash

set -e

if [ "$CI" != "true" ]; then
    echo "Not running in CI, skipping publish"
    exit 0
fi

VERSION="${1:-}"
FORK_REPO="${2:-damienbutt/extensions}"
CREATE_PR="${3:-true}"
EXTENSION_NAME="zed-netlinx"
UPSTREAM_REPO="zed-industries/extensions"
UPSTREAM_BRANCH="main"

if [[ -z "$VERSION" ]]; then
    echo "Error: Version is required"
    exit 1
fi

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format vX.Y.Z (e.g., v0.1.0)"
    exit 1
fi

echo "Publishing $EXTENSION_NAME extension version $VERSION"
echo "Fork repository: $FORK_REPO"

# Create temporary directory for the fork
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Cloning fork repository..."
if ! git clone --recurse-submodules "https://github.com/$FORK_REPO.git" "$TEMP_DIR"; then
    echo "Error: Failed to clone fork repository"
    exit 1
fi

# Configure git
git -C "$TEMP_DIR" config user.name "github-actions[bot]" || {
    echo "Failed to configure git user.name"
    exit 1
}
git -C "$TEMP_DIR" config user.email "github-actions[bot]@users.noreply.github.com" || {
    echo "Failed to configure git user.email"
    exit 1
}

# Create branch for update
BRANCH_NAME="update-netlinx-$VERSION"
echo "Creating branch: $BRANCH_NAME"

if ! git -C "$TEMP_DIR" checkout -b "$BRANCH_NAME"; then
    echo "Error: Failed to create branch"
    exit 1
fi

# Update submodule reference
echo "Updating submodule reference to $VERSION..."

if [ ! -d "$TEMP_DIR/extensions/$EXTENSION_NAME" ]; then
    echo "Error: Extension directory extensions/$EXTENSION_NAME not found in fork"
    exit 1
fi

SUBMODULE_PATH="$TEMP_DIR/extensions/$EXTENSION_NAME"

if ! git -C "$SUBMODULE_PATH" fetch origin; then
    echo "Error: Failed to fetch from extension repository"
    exit 1
fi

if ! git -C "$SUBMODULE_PATH" checkout "$VERSION"; then
    echo "Error: Version tag $VERSION not found in extension repository"
    exit 1
fi

if ! git -C "$TEMP_DIR" add "extensions/$EXTENSION_NAME"; then
    echo "Error: Failed to stage changes"
    exit 1
fi

# Commit changes
echo "Committing changes..."

if ! git -C "$TEMP_DIR" commit -m "Update $EXTENSION_NAME extension to $VERSION"; then
    echo "Error: Failed to commit changes"
    exit 1
fi

# Push to fork
echo "Pushing to fork..."

if ! git -C "$TEMP_DIR" push origin "$BRANCH_NAME"; then
    echo "Error: Failed to push to fork"
    exit 1
fi

# Create PR if requested
if [[ "$CREATE_PR" == "true" ]]; then
    echo "Creating pull request..."

    PR_BODY="This updates the $EXTENSION_NAME extension to version $VERSION.

## Changes
- Updates submodule reference to $VERSION

## Repository
https://github.com/Norgate-AV/$EXTENSION_NAME

## Changelog
See [release notes](https://github.com/Norgate-AV/$EXTENSION_NAME/releases/tag/$VERSION)"

    # Extract fork owner from FORK_REPO
    FORK_OWNER="${FORK_REPO%%/*}"

    if ! gh pr create \
        --repo "$UPSTREAM_REPO" \
        --title "Update $EXTENSION_NAME extension to $VERSION" \
        --body "$PR_BODY" \
        --head "$FORK_OWNER:$BRANCH_NAME" \
        --base "$UPSTREAM_BRANCH"; then
        echo "Error: Failed to create pull request"
        exit 1
    fi
fi

echo "Publish complete!"
echo "  Version: $VERSION"
echo "  Branch: $BRANCH_NAME"
if [[ "$CREATE_PR" == "true" ]]; then
    echo "  PR: Created"
else
    echo "  PR: Skipped (create manually)"
fi
