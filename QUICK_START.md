# Multi-LLM Workflow - Quick Start

> **TL;DR**: How to work with multiple LLMs in parallel without conflicts

---

## 🚀 One-Time Setup (5 minutes)

```bash
cd /Users/kalpeshjaju/Development

# 1. Run setup
chmod +x setup-multi-llm-worktrees.sh
./setup-multi-llm-worktrees.sh

# 2. Verify
git worktree list
# Should show: main, claude, cursor, gemini, codex worktrees
```

---

## 📁 Where Each LLM Works

```bash
# Main repo (source of truth)
/Users/kalpeshjaju/Development

# Claude's workspace
/Users/kalpeshjaju/Development-claude

# Cursor's workspace
/Users/kalpeshjaju/Development-cursor

# Gemini's workspace
/Users/kalpeshjaju/Development-gemini

# Codex's workspace
/Users/kalpeshjaju/Development-codex
```

---

## 🔄 Daily Workflow

### Morning: Sync
```bash
# Each LLM syncs with main
cd Development-claude    # (or cursor/gemini/codex)
git pull origin main
```

### During Day: Work
```bash
# Each LLM works independently
cd Development-claude
# ... make changes ...
git add -A
git commit -m "feat: your feature"
git push origin claude/main
```

### End of Day: Review & Merge
```bash
# Go to main repo
cd Development

# Review work
./llm-cross-verify.sh
# Choose option 2: Start verification
# Enter maker: claude/main
# Enter checker: gemini

# After review: merge
git checkout main
git merge claude/main
git push origin main
```

---

## 🔍 Maker-Checker (Cross-Verification)

### Maker (Claude builds feature)
```bash
cd Development-claude
# ... build feature ...
git push origin claude/main
```

### Checker (Gemini reviews)
```bash
cd Development
chmod +x llm-cross-verify.sh
./llm-cross-verify.sh

# Choose: Start verification
# Maker: claude/main
# Checker: gemini

# Run tests
npm test
npm run type-check

# Fill review
vim REVIEW-gemini.md

# Approve or reject
```

---

## 🎯 Command Cheat Sheet

```bash
# List all worktrees
git worktree list

# List work to review
./llm-cross-verify.sh  # Option 1

# Start review
./llm-cross-verify.sh  # Option 2

# Show diff
./llm-cross-verify.sh  # Option 3

# Merge to main
./llm-cross-verify.sh  # Option 4

# Remove worktree (when done)
git worktree remove Development-claude
```

---

## 🚨 Common Issues

### Issue: "Already exists"
```bash
# Worktree already exists
git worktree remove Development-claude  # Remove old
./setup-multi-llm-worktrees.sh          # Re-create
```

### Issue: "Merge conflict"
```bash
# Two LLMs edited same file
git merge claude/main  # Conflict!

# Fix manually
vim conflicted-file.ts
git add conflicted-file.ts
git commit -m "merge: Resolve conflict"
```

### Issue: "Branch behind"
```bash
# Your worktree is outdated
cd Development-claude
git pull origin main  # Sync with latest
```

---

## ✅ Definition of Done

Before merging to `main`:
- [ ] Tests pass (`npm test`)
- [ ] Type-check passes (`npm run type-check`)
- [ ] Lint passes (`npm run lint`)
- [ ] Review document created (`REVIEW-{llm}.md`)
- [ ] Different LLM reviewed (maker-checker)
- [ ] Confidence score stated

---

## 📚 Full Docs

- Setup: `setup-multi-llm-worktrees.sh`
- Workflow: `MULTI_LLM_WORKFLOW.md`
- Maker-Checker: `MAKER_CHECKER_WORKFLOW.md`
- Verification: `llm-cross-verify.sh`

---

**Version**: 1.0.0
**Last Updated**: 2025-11-16
