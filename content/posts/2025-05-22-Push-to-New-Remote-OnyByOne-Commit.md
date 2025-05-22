---
title: "Push to New Remote OnyByOne Commit"
date: 2025-05-22T09:49:26+08:00
author: v2less
tags: ["git"]
draft: false
---
```bash
#!/bin/bash

# Configuration
# ==============================================================================
NEW_REMOTE_NAME="new"         # Name of your new remote (e.g., 'new', 'gitea')
SOURCE_BRANCH="master"        # The local branch you want to push (e.g., 'master', 'main', 'develop')
TARGET_BRANCH="master"        # The branch name on the new remote (e.g., 'master', 'main')
DELAY_SECONDS=3               # Delay in seconds between each push and fetch operation

# --- IMPORTANT ---
# Set this to the URL of your new remote repository.
# Example: NEW_REMOTE_URL="git@your-new-git-host.com:your-user/your-repo.git"
# Or: NEW_REMOTE_URL="https://your-new-git-host.com/your-user/your-repo.git"
NEW_REMOTE_URL=" "
# ==============================================================================



# --- Script Start ---
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- Starting Git Incremental Push Script ---"
echo "New Remote Name: $NEW_REMOTE_NAME"
echo "Source Branch: $SOURCE_BRANCH"
echo "Target Branch on New Remote: $TARGET_BRANCH"
echo "Delay between pushes: ${DELAY_SECONDS}s"

# 1. Check if NEW_REMOTE_URL is set
if [ -z "$NEW_REMOTE_URL" ]; then
    echo "Error: NEW_REMOTE_URL is not set in the script configuration."
    echo "Please edit the script and set NEW_REMOTE_URL to your new repository's URL."
    exit 1
fi

# 2. Add the new remote if it doesn't exist
if ! git remote -v | grep -q "$NEW_REMOTE_NAME"; then
    echo "Remote '$NEW_REMOTE_NAME' not found. Adding it now..."
    if ! git remote add "$NEW_REMOTE_NAME" "$NEW_REMOTE_URL"; then
        echo "Error: Failed to add remote '$NEW_REMOTE_NAME' with URL '$NEW_REMOTE_URL'."
        echo "Please check the URL and your Git configuration."
        exit 1
    fi
    echo "Remote '$NEW_REMOTE_NAME' added successfully."
else
    echo "Remote '$NEW_REMOTE_NAME' already exists."
    # Verify the URL is correct for the existing remote
    EXISTING_URL=$(git remote get-url "$NEW_REMOTE_NAME")
    if [ "$EXISTING_URL" != "$NEW_REMOTE_URL" ]; then
        echo "Warning: Existing remote '$NEW_REMOTE_NAME' has a different URL ($EXISTING_URL) than configured ($NEW_REMOTE_URL)."
        read -p "Do you want to update the remote URL? (y/N): " UPDATE_REMOTE_URL
        if [[ "$UPDATE_REMOTE_URL" =~ ^[Yy]$ ]]; then
            echo "Updating remote URL..."
            if ! git remote set-url "$NEW_REMOTE_NAME" "$NEW_REMOTE_URL"; then
                echo "Error: Failed to update remote URL."
                exit 1
            fi
            echo "Remote URL updated."
        else
            echo "Proceeding with existing remote URL. Please ensure it's correct."
            NEW_REMOTE_URL="$EXISTING_URL" # Use the existing URL for consistency
        fi
    fi
fi

# 3. Fetch from the new remote to get its current state (if any)
echo "Fetching from new remote '$NEW_REMOTE_NAME'..."
if ! git fetch "$NEW_REMOTE_NAME"; then
    echo "Warning: Failed to fetch from '$NEW_REMOTE_NAME'. This might be expected if the remote is completely empty."
    echo "Proceeding, but please ensure network connectivity and remote repository existence."
fi

# 4. Get the SHA of the latest commit on the target branch in the new remote
# We use 'git ls-remote' to directly query the remote, which is robust.
# If the branch doesn't exist on the remote, this will be empty.
LAST_PUSHED_SHA=$(git ls-remote --heads "$NEW_REMOTE_NAME" "$TARGET_BRANCH" | awk '{print $1}')

if [ -z "$LAST_PUSHED_SHA" ]; then
    echo "Target branch '$TARGET_BRANCH' does not exist on remote '$NEW_REMOTE_NAME' yet. Will push all commits."
else
    echo "Target branch '$TARGET_BRANCH' on '$NEW_REMOTE_NAME' currently points to commit: $LAST_PUSHED_SHA"
fi

# 5. Get all commits from the source branch, ordered oldest to newest
# --reverse ensures oldest commits are processed first.
ALL_COMMITS=$(git log --reverse --pretty=format:"%H" "$SOURCE_BRANCH")

if [ -z "$ALL_COMMITS" ]; then
    echo "Error: No commits found on local branch '$SOURCE_BRANCH'."
    exit 1
fi

echo "--- Starting incremental push of commits ---"
COMMITS_PUSHED_COUNT=0
for COMMIT_SHA in $ALL_COMMITS; do
    echo "----------------------------------------------------"
    echo "Processing commit: $COMMIT_SHA"
    git log -1 --pretty=format:"Author: %an%nDate:   %ad%nSubject: %s" "$COMMIT_SHA"

    # Check if this commit or an ancestor is already on the remote
    # We use git merge-base --is-ancestor to robustly check if LAST_PUSHED_SHA
    # is an ancestor of the current commit, meaning the current commit is already
    # part of the remote's history or is the same as the remote's head.
    if [ -n "$LAST_PUSHED_SHA" ] && git merge-base --is-ancestor "$COMMIT_SHA" "$LAST_PUSHED_SHA"; then
        echo "Commit $COMMIT_SHA (or an ancestor) is already present on ${NEW_REMOTE_NAME}/${TARGET_BRANCH}. Skipping."
        # Update LAST_PUSHED_SHA to current commit for the next iteration if it's the same or an ancestor.
        # This prevents re-checking the same remote state repeatedly.
        LAST_PUSHED_SHA="$COMMIT_SHA"
        echo "----------------------------------------------------"
        continue
    fi

    # Push the individual commit
    # We push 'COMMIT_SHA:refs/heads/TARGET_BRANCH'.
    # This means "make the remote's TARGET_BRANCH point to COMMIT_SHA".
    # For incremental pushes from oldest to newest, this is typically a fast-forward operation on the remote.
    echo "Attempting to push commit $COMMIT_SHA to ${NEW_REMOTE_NAME}/${TARGET_BRANCH}..."
    if ! git push "$NEW_REMOTE_NAME" "$COMMIT_SHA:refs/heads/$TARGET_BRANCH" --force; then
        echo "Error: Failed to push commit $COMMIT_SHA."
        echo "This could be due to network issues, repository size limits, or permissions."
        echo "You can try to resume the script after resolving the issue."
        exit 1
    fi
    echo "Successfully pushed commit $COMMIT_SHA."
    COMMITS_PUSHED_COUNT=$((COMMITS_PUSHED_COUNT + 1))

    # After a successful push, update the LAST_PUSHED_SHA to the current commit.
    LAST_PUSHED_SHA="$COMMIT_SHA"

    # Fetch from the new remote to ensure local tracking branch is up-to-date
    # This is important for the 'git merge-base --is-ancestor' check in the next iteration.
    echo "Fetching from '$NEW_REMOTE_NAME' to update local tracking branch..."
    if ! git fetch "$NEW_REMOTE_NAME"; then
        echo "Warning: Failed to fetch from '$NEW_REMOTE_NAME' after pushing. Local tracking branch for new remote might be outdated."
        echo "Consider running 'git fetch $NEW_REMOTE_NAME' manually later."
    fi

    echo "Waiting for ${DELAY_SECONDS} seconds before next operation..."
    sleep "$DELAY_SECONDS"
    echo "----------------------------------------------------"
done

echo "--- All reachable commits from $SOURCE_BRANCH have been processed. ---"

# Final push to ensure the target branch on the remote points to the exact head of the source branch
# This covers any commits that might have been added to SOURCE_BRANCH during script execution
# or ensures the remote is exactly in sync with the local head after all individual pushes.
echo "Performing final push to ensure ${NEW_REMOTE_NAME}/${TARGET_BRANCH} is exactly in sync with ${SOURCE_BRANCH}..."
if ! git push "$NEW_REMOTE_NAME" "$SOURCE_BRANCH:$TARGET_BRANCH"; then
    echo "Warning: Final push failed. This might indicate a non-fast-forward issue or other problem."
    echo "Please check the remote state manually or attempt a 'git push ${NEW_REMOTE_NAME} ${SOURCE_BRANCH}:${TARGET_BRANCH}'."
else
    echo "Final push successful. ${NEW_REMOTE_NAME}/${TARGET_BRANCH} is now synced with ${SOURCE_BRANCH}."
fi

echo "--- Script Finished ---"
echo "Total commits pushed in this run: $COMMITS_PUSHED_COUNT"
echo "You can now verify the history on your new remote repository."

```







## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2025-05-22T09:49:26+08:00
