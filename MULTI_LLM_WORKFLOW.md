# Multi-LLM Parallel Workflow Guide

> **Problem Solved**: Multiple LLMs (Claude, Cursor, Gemini, Codex) working simultaneously without conflicts

**Date**: 2025-11-16
**Author**: Claude
**Status**: Production Ready

---

## 🎯 The Problem

**Before** (Current State):
```
Development/
├── flyberry_22_oct_2025/      ❌ Duplicate
├── flyberry_oct_restart/      ❌ Duplicate
├── flyberry_oct_restart_copy/ ❌ Duplicate
├── flyberry_platform/         ❌ Duplicate
└── ui-ux-audit-tool/          ✅ Main repo
```

**Issues**:
- 🔥 Multiple copies = wasted disk space
- 🔥 No shared git history
- 🔥 Merge conflicts when combining work
- 🔥 LLMs overwrite each other's changes

---

## ✅ The Solution: Git Worktrees

**After** (Worktree Strategy):
```
Development/
├── ui-ux-audit-tool/          ← Main repo (branch: main)
├── ui-ux-audit-tool-claude/   ← Claude's workspace (branch: claude/main)
├── ui-ux-audit-tool-cursor/   ← Cursor's workspace (branch: cursor/main)
├── ui-ux-audit-tool-gemini/   ← Gemini's workspace (branch: gemini/main)
└── ui-ux-audit-tool-codex/    ← Codex's workspace (branch: codex/main)
```

**Benefits**:
- ✅ All share same `.git` directory (no duplication)
- ✅ Each LLM has isolated workspace
- ✅ Easy to merge work between LLMs
- ✅ No conflicts during parallel work

---

## 🚀 Quick Start

### Step 1: Run Setup Script
```bash
cd /Users/kalpeshjaju/Development
chmod +x setup-multi-llm-worktrees.sh
./setup-multi-llm-worktrees.sh
```

### Step 2: Assign LLMs to Worktrees
```bash
# Claude works here
cd ui-ux-audit-tool-claude/

# Cursor works here (different terminal/window)
cd ui-ux-audit-tool-cursor/

# Gemini works here (different session)
cd ui-ux-audit-tool-gemini/

# Codex works here (different session)
cd ui-ux-audit-tool-codex/
```

### Step 3: Work Independently
Each LLM can:
- Make changes
- Commit
- Push to their branch
- **No conflicts!**

---

## 🔄 Workflow: Day-to-Day

### Morning: Start Work
```bash
# Each LLM in their worktree
cd ui-ux-audit-tool-claude/

# Pull latest from main
git fetch origin
git merge origin/main

# Start working...
```

### During Day: Independent Work
```bash
# Claude commits
git add -A
git commit -m "feat: Add trust enhancement system"
git push origin claude/main

# Cursor commits (at same time, no conflict!)
git add -A
git commit -m "fix: Auto-complete for TypeScript"
git push origin cursor/main
```

### End of Day: Merge Work
```bash
# Go to main repo
cd /Users/kalpeshjaju/Development/ui-ux-audit-tool

# Review Claude's work
git fetch origin
git merge origin/claude/main

# Review Cursor's work
git merge origin/cursor/main

# Push combined work
git push origin main
```

---

## 🎭 LLM-Specific Workflows

### Claude (Deep Features)
**Best for**: New features, complex logic, architecture

```bash
cd ui-ux-audit-tool-claude/

# Create feature branch
git checkout -b feature/trust-system

# Build feature
# ... (Claude does deep implementation)

# Commit
git add -A
git commit -m "feat: Trust enhancement with 6 plugins"
git push origin feature/trust-system

# Merge to claude/main
git checkout claude/main
git merge feature/trust-system
git push origin claude/main
```

### Cursor (Auto-Complete, Quick Fixes)
**Best for**: Type fixes, lint errors, imports, small refactors

```bash
cd ui-ux-audit-tool-cursor/

# Pull latest
git pull origin main

# Cursor auto-fixes TypeScript errors
# ... (Cursor suggests fixes inline)

# Commit quick fixes
git add -A
git commit -m "fix: Resolve 15 TypeScript errors"
git push origin cursor/main
```

### Gemini (Code Review, Exploration)
**Best for**: Finding bugs, suggesting improvements, exploring codebase

```bash
cd ui-ux-audit-tool-gemini/

# Pull Claude's latest work
git fetch origin
git merge origin/claude/main

# Gemini reviews code
# Finds: "trust-system.ts:45 - Missing error handling"

# Create fix
git checkout -b fix/error-handling
# ... (Gemini fixes issues)

git add -A
git commit -m "fix: Add error handling to trust system"
git push origin fix/error-handling
```

### Codex (Optimization, Refactoring)
**Best for**: Performance tuning, code cleanup, optimizations

```bash
cd ui-ux-audit-tool-codex/

# Pull latest
git pull origin main

# Codex optimizes performance
# ... (Codex refactors for speed)

git add -A
git commit -m "perf: Optimize artifact processing (300KB → 30KB)"
git push origin codex/main
```

---

## 🔀 Merging Strategies

### Strategy 1: Sequential Merge (Safest)
```bash
cd ui-ux-audit-tool/  # Main repo

# Merge one at a time
git merge origin/claude/main   # Review, test
git merge origin/cursor/main   # Review, test
git merge origin/gemini/main   # Review, test
git merge origin/codex/main    # Review, test

# Push all
git push origin main
```

### Strategy 2: Feature Branch (For Big Features)
```bash
# Claude builds feature
cd ui-ux-audit-tool-claude/
git checkout -b feature/ui-audit-v2
# ... work ...
git push origin feature/ui-audit-v2

# Create PR on GitHub
gh pr create --base main --head feature/ui-audit-v2

# Gemini reviews PR
# Cursor auto-fixes PR
# Merge when ready
```

### Strategy 3: Daily Sync (For Fast Iteration)
```bash
# Every morning: sync all worktrees
cd ui-ux-audit-tool/
git pull origin main

# Update all worktrees
git worktree list | while read worktree branch hash; do
    cd "$worktree"
    git pull origin main
done
```

---

## 🚨 Conflict Resolution

### When Claude + Cursor edit same file:
```bash
# In main repo
git merge origin/claude/main   # ✅ Success
git merge origin/cursor/main   # ❌ Conflict!

# Git shows:
# <<<<<<< HEAD
# Code from Claude
# =======
# Code from Cursor
# >>>>>>> cursor/main

# Options:
# 1. Keep Claude's version (git checkout --ours file.ts)
# 2. Keep Cursor's version (git checkout --theirs file.ts)
# 3. Manually merge (edit file, keep both)
```

**Best Practice**: Assign different files to different LLMs
- Claude: `src/features/`
- Cursor: `src/types/`
- Gemini: `tests/`
- Codex: `src/utils/`

---

## 📊 Directory Structure

### Main Repo (Source of Truth)
```
ui-ux-audit-tool/  (branch: main)
├── .git/          ← Shared by all worktrees
├── src/
├── tests/
└── docs/
```

### Claude's Worktree
```
ui-ux-audit-tool-claude/  (branch: claude/main)
├── .git → ../ui-ux-audit-tool/.git  ← Symlink!
├── src/           ← Can diverge from main
├── tests/
└── docs/
```

**Key Point**: All worktrees share `.git` but have independent working directories

---

## 🧹 Cleanup

### Remove Worktree (When Done)
```bash
# List worktrees
git worktree list

# Remove specific worktree
git worktree remove ui-ux-audit-tool-claude

# Remove branch (optional)
git branch -D claude/main
git push origin --delete claude/main
```

### Clean Up Old Duplicates
```bash
# After setting up worktrees, delete old duplicates:
cd /Users/kalpeshjaju/Development

# Backup first!
mv flyberry_22_oct_2025 ~/Desktop/backup/
mv flyberry_oct_restart ~/Desktop/backup/
mv flyberry_oct_restart_copy ~/Desktop/backup/

# Verify worktrees work, then delete backups
```

---

## 📋 Checklist: Setting Up Multi-LLM Workflow

**One-time setup**:
- [ ] Run `./setup-multi-llm-worktrees.sh`
- [ ] Verify worktrees created: `git worktree list`
- [ ] Test each worktree: `cd ui-ux-audit-tool-claude && npm test`
- [ ] Document which LLM uses which worktree (in README)
- [ ] Clean up old duplicate directories

**Daily workflow**:
- [ ] Morning: Sync all worktrees with `main`
- [ ] During day: Each LLM commits to their branch
- [ ] End of day: Merge branches to `main`
- [ ] Push `main` to origin

---

## 🎯 Example: Full Day Workflow

### 9:00 AM - Morning Sync
```bash
# Claude syncs
cd ui-ux-audit-tool-claude/
git pull origin main

# Cursor syncs
cd ui-ux-audit-tool-cursor/
git pull origin main

# Gemini syncs
cd ui-ux-audit-tool-gemini/
git pull origin main
```

### 10:00 AM - 5:00 PM - Parallel Work
```bash
# Claude builds new feature (5 hours)
cd ui-ux-audit-tool-claude/
# ... implements trust-enhancement system ...
git commit -m "feat: Trust enhancement"
git push origin claude/main

# Cursor fixes types (30 min, concurrent with Claude)
cd ui-ux-audit-tool-cursor/
# ... auto-fixes TypeScript errors ...
git commit -m "fix: TypeScript errors"
git push origin cursor/main

# Gemini reviews code (2 hours, concurrent)
cd ui-ux-audit-tool-gemini/
# ... finds 3 bugs ...
git commit -m "fix: 3 bugs found in review"
git push origin gemini/main
```

### 6:00 PM - End of Day Merge
```bash
# Main repo: merge all work
cd ui-ux-audit-tool/

git merge origin/claude/main   # ✅ Trust system added
git merge origin/cursor/main   # ✅ Types fixed
git merge origin/gemini/main   # ✅ Bugs fixed

# Run tests
npm test  # ✅ All pass

# Push combined work
git push origin main
```

---

## 🔐 Security Notes

**Worktrees share `.git/config`**, so:
- ✅ Git credentials shared (good - no re-auth)
- ✅ Git hooks shared (good - consistent pre-commit)
- ⚠️ Be careful with `.env` files (not shared, each worktree has own)

**Best Practice**: Use `.env.example` in main repo, each worktree copies to `.env`

---

## 📚 Additional Resources

- Git Worktrees Docs: https://git-scm.com/docs/git-worktree
- Multi-LLM Standards: `~/.claude/CLAUDE.md`
- Merge Strategies: https://git-scm.com/docs/merge-strategies

---

## ✅ Success Metrics

**You know it's working when**:
- ✅ Multiple LLMs work simultaneously without conflicts
- ✅ No duplicate directories (just worktrees)
- ✅ Easy to merge work at end of day
- ✅ Disk space saved (worktrees are ~10% size of full clone)
- ✅ Git history clean (all work in one repo)

---

**Version**: 1.0.0
**Last Updated**: 2025-11-16
**Tested with**: Claude, Cursor, Gemini, Codex
