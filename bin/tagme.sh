#!/bin/bash
set -e

# Check if the -y option was provided
auto_confirm=false
if [ "$1" == "-y" ]; then
    auto_confirm=true
fi

# Fetch all tags from the remote repository
git fetch --tags

# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check if the current branch is main
if [ "$current_branch" != "main" ]; then
    echo "You are currently on branch: $current_branch"
    if [ "$auto_confirm" = false ]; then
        read -p "Are you sure you want to proceed with tagging on this branch? ([y]/n): " branch_confirm
        if [ "$branch_confirm" == "n" ]; then
            echo "Operation cancelled."
            exit 1
        fi
    else
        echo "Proceeding with tagging on branch: $current_branch"
    fi
fi

# Get the latest version tag, now considering both 3-part and 4-part version tags
latest_tag=$(git tag | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$' | sort -V | tail -n 1)

# If no tags exist, start from version 0.0.0.0
if [ -z "$latest_tag" ]; then
    latest_tag="v0.0.0.0"
    echo "No tags found. Starting from version 0.0.0.0"
fi

# Remove the 'v' prefix from the version tag
current_version=${latest_tag#v}
echo "Current version: $current_version"

# Split the version into its components
IFS='.' read -r -a version_parts <<< "$current_version"

# Handle both 3-part and 4-part versions
major=${version_parts[0]}
minor=${version_parts[1]}
patch=${version_parts[2]}
bugfix=${version_parts[3]:-0}  # If the bugfix part is missing, default it to 0

# Prompt for the type of version increment
if [ "$auto_confirm" = false ]; then
    echo "Choose the type of version increment (default is Bugfix):"
    echo "1) Major"
    echo "2) Minor"
    echo "3) Patch"
    echo "4) Bugfix"
    read -p "Enter your choice (1/2/3/4): " choice
fi

# Default to bugfix if no choice is made
if [ -z "$choice" ] || [ "$auto_confirm" = true ]; then
    choice=4
fi

case $choice in
    1)
        major=$((major + 1))
        minor=0
        patch=0
        bugfix=0
        ;;
    2)
        minor=$((minor + 1))
        patch=0
        bugfix=0
        ;;
    3)
        patch=$((patch + 1))
        bugfix=0
        ;;
    4)
        bugfix=$((bugfix + 1))
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac

# Construct the new version
new_version="$major.$minor.$patch.$bugfix"
echo "Old version: $current_version"
echo "New version: $new_version"

# Prompt for the optional message
if [ "$auto_confirm" = false ]; then
    read -p "Enter an optional message: " message
fi

# Use the first 50 characters from the last commit message if no message is provided
if [ -z "$message" ]; then
    message=$(git log -1 --pretty=%B | head -c 50)
fi

# Final confirmation
echo "The following tag will be applied: v$new_version with message: \"$message\""
if [ "$auto_confirm" = false ]; then
    read -p "Do you want to proceed? ([y]/n): " confirm
else
    read -p "Do you want to proceed? (press Enter to confirm or n to cancel): " confirm
    confirm=${confirm:-y}
fi

if [ "$confirm" == "n" ]; then
    echo "Operation cancelled."
    exit 1
fi

# Run the git tag command
git tag -a "v$new_version" -m "$message"

# Push the tags to the remote repository
SKIP_TEST=true git push --tags

echo "The new version v$new_version has been tagged and pushed."