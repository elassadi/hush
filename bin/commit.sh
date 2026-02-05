#!/usr/bin/env bash

echo "Running pre-commit hook"
#./scripts/run-rubocop.bash
./bin/run-rubocop.rb

# $? stores exit value of the last command
if [ $? -ne 0 ]; then
 echo "Code must be clean before commiting"
 exit 1
fi

git diff --no-renames --no-prefix --unified=0  | sed  '/^diff/d;/@@/d;/^index/d;/^+++/d;/^---/d' > changes.txt
json=$(jq -n --arg diff "$(sed 's/"/\\"/g' changes.txt)" '{"diff": $diff}')

content=$(curl -X POST -H "Content-Type: application/json" -d "$json" http://localhost:5678/webhook/c0475e7b-89dd-4261-bb8d-d962553fcf08 | jq -r '.[0].message.content')


commit_message=$(echo "$content" | jq -r '.commit')
description=$(echo "$content" | jq -r '.description')

echo "====================================="
echo "commit_message $commit_message"
echo "description $description"
echo "====================================="

echo ""
echo "Use the following commit message?:"
echo "====================================="
# Prompt the user for confirmation
echo "$commit_message "
echo "====================================="
read -p "[y/n]:" answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  # The user confirmed, use the default commit message
  echo "Using commit message: $commit_message"
else
  # The user did not confirm, ask for a new commit message
  read -p "Enter a new commit message: " new_commit_message
  commit_message="$new_commit_message"
  echo "Using new commit message: $commit_message"
fi

# Commit the changes
git ac "$commit_message"


# Prompt the user for confirmation
read -p "Create a Pull request? [y/n] " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Creating a PR"
else
  exit 0
fi

echo ""
echo "Use the following description?:"
echo "====================================="
echo "$description"
echo "====================================="
read -p "? [y/n]:" answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  # The user confirmed, use the default commit message
else
  # The user did not confirm, ask for a new commit message
  read -p "Enter a new description message: " new_description
  description="$new_description"
  echo "Using new description: $description"
fi



hub pull-request -b develop -m $commit_message -m $description

