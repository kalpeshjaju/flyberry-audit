#!/bin/bash

# Multi-LLM Worktree Setup Script
# Purpose: Create isolated workspaces for Claude, Cursor, Gemini, Codex
# Author: Claude
# Date: 2025-11-16

set -e  # Exit on error

echo "🤖 Multi-LLM Worktree Setup"
echo "============================"
echo ""

# Get current directory (main repo)
MAIN_REPO=$(pwd)
PARENT_DIR=$(dirname "$MAIN_REPO")
REPO_NAME=$(basename "$MAIN_REPO")

echo "📁 Main repo: $MAIN_REPO"
echo "📁 Parent dir: $PARENT_DIR"
echo ""

# Check if we're in a git repo
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check if remote exists
if ! git remote get-url origin &> /dev/null; then
    echo "❌ Error: No git remote 'origin' found"
    echo "   Run: gh repo create <name> --public --source=. --remote=origin"
    exit 1
fi

echo "✅ Git remote found: $(git remote get-url origin)"
echo ""

# Function to create worktree
create_worktree() {
    local llm_name=$1
    local branch_name=$2
    local worktree_path="${PARENT_DIR}/${REPO_NAME}-${llm_name}"

    echo "Creating worktree for ${llm_name}..."

    # Check if branch exists, create if not
    if ! git show-ref --verify --quiet refs/heads/${branch_name}; then
        echo "  📝 Creating new branch: ${branch_name}"
        git branch ${branch_name}
    fi

    # Create worktree
    if [ -d "$worktree_path" ]; then
        echo "  ⚠️  Worktree already exists: $worktree_path"
    else
        git worktree add "$worktree_path" ${branch_name}
        echo "  ✅ Created: $worktree_path"
    fi

    echo ""
}

# Create worktrees for each LLM
echo "🏗️  Creating LLM-specific worktrees..."
echo ""

create_worktree "claude" "claude/main"
create_worktree "cursor" "cursor/main"
create_worktree "gemini" "gemini/main"
create_worktree "codex" "codex/main"

# Create feature-specific worktrees (optional)
echo "📦 Optional: Create feature-specific worktrees? (y/n)"
read -r create_features

if [ "$create_features" = "y" ]; then
    echo ""
    echo "Feature worktrees (for specific tasks):"
    create_worktree "feature-ui-audit" "feature/ui-audit"
    create_worktree "feature-deepeyes" "feature/deepeyes"
    create_worktree "feature-brand-builder" "feature/brand-builder"
fi

# List all worktrees
echo ""
echo "📋 Current worktrees:"
git worktree list

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. Each LLM should work in its own directory:"
echo "     - Claude:  cd ${PARENT_DIR}/${REPO_NAME}-claude"
echo "     - Cursor:  cd ${PARENT_DIR}/${REPO_NAME}-cursor"
echo "     - Gemini:  cd ${PARENT_DIR}/${REPO_NAME}-gemini"
echo "     - Codex:   cd ${PARENT_DIR}/${REPO_NAME}-codex"
echo ""
echo "  2. When work is done, merge branches:"
echo "     git checkout main"
echo "     git merge claude/main"
echo "     git push origin main"
echo ""
echo "  3. Clean up worktrees when done:"
echo "     git worktree remove ${PARENT_DIR}/${REPO_NAME}-claude"
echo ""
