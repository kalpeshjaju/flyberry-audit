# Multi-LLM Maker-Checker Workflow

> **Problem Solved**: Cross-verification between LLMs to ensure quality before merging to main

**Date**: 2025-11-16
**Author**: Claude
**Status**: Production Ready

---

## 🎯 The Maker-Checker Pattern

**Maker**: LLM that builds the feature (Claude, Cursor, Gemini, Codex)
**Checker**: Different LLM that reviews the work before merge

**Benefits**:
- ✅ Catch bugs before they reach `main`
- ✅ Different LLMs have different strengths (Claude = architecture, Gemini = bugs, GPT = optimization)
- ✅ Knowledge transfer between LLMs
- ✅ Higher quality code
- ✅ Compliance-ready audit trail

---

## 🔄 Workflow Overview

```
┌─────────────┐
│   MAKER     │  Claude builds feature in worktree
│   (Claude)  │  └─> Commits to claude/main
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  REVIEW     │  Gemini reviews Claude's work
│  (Gemini)   │  └─> Creates verify/gemini-reviews-claude-main
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  APPROVE    │  If OK: merge to main
│             │  If NOT: add fixes to verification branch
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    MAIN     │  Production-ready code
└─────────────┘
```

---

## 🚀 Quick Start

### Step 1: Maker Creates Feature
```bash
# Claude works in their worktree
cd /Users/kalpeshjaju/Development-claude

# Build feature
# ... (implement feature) ...

# Commit
git add -A
git commit -m "feat: Add trust enhancement system"
git push origin claude/main
```

### Step 2: Checker Reviews Feature
```bash
# Go to main repo
cd /Users/kalpeshjaju/Development

# Run cross-verification tool
chmod +x llm-cross-verify.sh
./llm-cross-verify.sh

# Choose option 2: Start verification
# Enter maker branch: claude/main
# Enter your LLM name: gemini
```

**This will**:
1. Create verification branch: `verify/gemini-reviews-claude-main`
2. Generate review template: `REVIEW-gemini.md`
3. Show diff summary

### Step 3: Checker Performs Review
```bash
# You're now on verification branch
# Review the code

# Run tests
npm test

# Check types
npm run type-check

# Check lint
npm run lint

# Review changes
git diff main

# Fill out REVIEW-gemini.md
```

### Step 4: Checker Decides

#### Option A: Approve (No Issues)
```bash
# Fill out review as APPROVED
vim REVIEW-gemini.md

# Commit review
git add REVIEW-gemini.md
git commit -m "review: Gemini approves claude/main"
git push origin verify/gemini-reviews-claude-main

# Merge to main
git checkout main
git merge verify/gemini-reviews-claude-main --no-ff
git push origin main
```

#### Option B: Conditional Approval (Minor Fixes)
```bash
# Fix issues found
# ... (Gemini makes small fixes) ...

# Commit fixes
git add -A
git commit -m "fix: Address review issues from Gemini"

# Update review
vim REVIEW-gemini.md  # Mark as CONDITIONAL → APPROVED

# Commit review
git add REVIEW-gemini.md
git commit -m "review: Gemini conditionally approves (fixes applied)"

# Merge to main
git checkout main
git merge verify/gemini-reviews-claude-main --no-ff
git push origin main
```

#### Option C: Reject (Major Issues)
```bash
# Document issues
vim REVIEW-gemini.md  # Mark as REJECTED

git add REVIEW-gemini.md
git commit -m "review: Gemini rejects claude/main - major issues found"
git push origin verify/gemini-reviews-claude-main

# Notify maker (Claude) to fix
# Claude pulls verification branch, sees issues, fixes them
```

---

## 📋 Review Checklist (Auto-Generated)

The script generates `REVIEW-{checker}.md` with:

### Functionality Checks
- [ ] Code runs without errors
- [ ] Tests pass
- [ ] Type-check passes
- [ ] Lint passes

### Code Quality Checks
- [ ] Functions well-documented
- [ ] No `any` types
- [ ] Error handling comprehensive
- [ ] No debug code (console.log)
- [ ] File/function size limits

### Security Checks
- [ ] No hardcoded secrets
- [ ] Input validation
- [ ] No injection risks

### Multi-LLM Standards
- [ ] Documentation clear
- [ ] Edge cases covered
- [ ] Confidence scores included

---

## 🎭 LLM Specializations (Who Checks What)

### Claude Reviews
**Best for**: Architecture, business logic, complex workflows
```bash
# Gemini builds UI component
cd Development-gemini
# ... builds UI ...
git push origin gemini/main

# Claude reviews architecture
cd Development
./llm-cross-verify.sh  # Claude verifies gemini/main
```

### Gemini Reviews
**Best for**: Bug detection, edge cases, test coverage
```bash
# Claude builds payment flow
cd Development-claude
# ... builds feature ...
git push origin claude/main

# Gemini reviews for bugs
cd Development
./llm-cross-verify.sh  # Gemini verifies claude/main
```

### GPT-5/Codex Reviews
**Best for**: Performance, optimization, code style
```bash
# Claude builds feature
cd Development-claude
# ... builds feature ...
git push origin claude/main

# GPT reviews for optimization
cd Development
./llm-cross-verify.sh  # GPT verifies claude/main
```

### Cursor Reviews
**Best for**: TypeScript correctness, auto-complete suggestions
```bash
# Claude builds feature
cd Development-claude
# ... builds feature ...
git push origin claude/main

# Cursor reviews types
cd Development
./llm-cross-verify.sh  # Cursor verifies claude/main
```

---

## 🔀 Advanced Workflows

### Multi-Stage Review (2+ Checkers)
```bash
# Claude builds feature
git push origin claude/main

# Gemini reviews (first check)
./llm-cross-verify.sh  # gemini verifies
# Result: verify/gemini-reviews-claude-main

# GPT-5 reviews Gemini's review (second check)
./llm-cross-verify.sh  # gpt verifies verify/gemini-reviews-claude-main
# Result: verify/gpt-reviews-gemini-reviews-claude-main

# Both approved? Merge to main
git checkout main
git merge verify/gpt-reviews-gemini-reviews-claude-main
git push origin main
```

### Ping-Pong Review (Maker Fixes Issues)
```bash
# Claude builds feature (round 1)
cd Development-claude
git push origin claude/main

# Gemini reviews, finds issues
cd Development
./llm-cross-verify.sh  # gemini verifies
# Creates: verify/gemini-reviews-claude-main
# Status: REJECTED

# Claude sees issues, fixes them
cd Development-claude
git fetch origin
git checkout verify/gemini-reviews-claude-main
# ... fixes issues ...
git commit -m "fix: Address Gemini's review comments"
git push origin verify/gemini-reviews-claude-main

# Gemini re-reviews (round 2)
cd Development
git checkout verify/gemini-reviews-claude-main
# ... verifies fixes ...
# Status: APPROVED

# Merge to main
git checkout main
git merge verify/gemini-reviews-claude-main --no-ff
git push origin main
```

### Cross-Team Review (External LLM)
```bash
# Your team's Claude builds feature
git push origin claude/main

# Client's Gemini reviews (external verification)
# (Client clones your repo)
git clone https://github.com/your/repo.git
cd repo
./llm-cross-verify.sh  # Client's Gemini verifies

# Client pushes review
git push origin verify/client-gemini-reviews-claude-main

# You review the review
git fetch origin
git checkout verify/client-gemini-reviews-claude-main
# ... review client's feedback ...
```

---

## 🔍 Review Quality Metrics

### High-Quality Review (Example)
```markdown
# Code Review: claude/main

**Reviewer**: Gemini
**Date**: 2025-11-16
**Status**: APPROVED

## Summary
Claude implemented trust enhancement system with 6 plugins.
Excellent documentation, comprehensive tests, clean code.

## Issues Found
### Critical: None ✅
### Medium: 2 (fixed)
- trust-system.ts:45 - Missing null check (FIXED)
- trust-system.ts:67 - Potential race condition (FIXED)

### Low: 1
- Consider extracting magic numbers to constants

## Test Results
✅ All 127 tests pass
✅ Type-check: 0 errors
✅ Lint: 0 warnings

## Recommendations
✅ APPROVE - Ready to merge

**Confidence**: VERIFIED (0.95)
**Reason**: Tested thoroughly, issues fixed, excellent quality
```

### Low-Quality Review (Avoid This)
```markdown
# Code Review: claude/main

**Reviewer**: Gemini

Looks good.

✅ APPROVE
```
❌ **Why bad**: No checklist, no tests run, no specific issues documented

---

## 🚨 Red Flags (Auto-Reject)

**Checker MUST reject if**:
- ❌ Tests fail
- ❌ Type-check fails
- ❌ Lint fails
- ❌ Hardcoded secrets found
- ❌ `any` types used
- ❌ No documentation
- ❌ Console.log in production code
- ❌ Files >800 lines
- ❌ Functions >150 lines

---

## 📊 Audit Trail

Every review creates permanent record:

```
verify/gemini-reviews-claude-main
├── REVIEW-gemini.md           ← Review document
├── commit history              ← All changes
└── merge commit                ← Links to original work
```

**Benefits for compliance**:
- ✅ Who reviewed (Gemini)
- ✅ What was reviewed (claude/main)
- ✅ When reviewed (commit timestamp)
- ✅ What issues found (REVIEW-gemini.md)
- ✅ What was fixed (commit history)
- ✅ Final decision (APPROVED/REJECTED)

---

## 🔧 Customization

### Add Custom Checks
Edit `llm-cross-verify.sh` to add your checks:

```bash
# Example: Security scan
run_security_scan() {
    echo "Running security scan..."
    npm audit --audit-level=moderate
    if [ $? -ne 0 ]; then
        echo "❌ Security vulnerabilities found"
        return 1
    fi
    return 0
}
```

### Integration with CI/CD
```yaml
# .github/workflows/review.yml
name: LLM Review Required

on:
  pull_request:
    branches: [main]

jobs:
  check-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check for REVIEW file
        run: |
          if [ ! -f REVIEW-*.md ]; then
            echo "❌ No review file found"
            exit 1
          fi
      - name: Verify review approved
        run: |
          if ! grep -q "APPROVE" REVIEW-*.md; then
            echo "❌ Review not approved"
            exit 1
          fi
```

---

## 🎯 Example: Full Maker-Checker Flow

### Day 1: Claude Builds Feature
```bash
# 9:00 AM - Claude starts work
cd Development-claude
git checkout -b feature/payment-idempotency

# 10:00 AM - 4:00 PM - Implementation
# ... builds payment idempotency ...

# 5:00 PM - Ready for review
git add -A
git commit -m "feat: Add payment idempotency"
git push origin feature/payment-idempotency

# Notify team: "Ready for review"
```

### Day 2: Gemini Reviews
```bash
# 9:00 AM - Gemini starts review
cd Development
./llm-cross-verify.sh

# Choose: Start verification
# Maker branch: feature/payment-idempotency
# Checker: gemini

# 9:30 AM - Run tests
npm test  # 3 tests fail ❌

# 10:00 AM - Review code
git diff main  # Finds: missing error handling

# 11:00 AM - Document issues
vim REVIEW-gemini.md
# Status: CONDITIONAL (needs fixes)

# 11:30 AM - Apply fixes
# ... fixes 3 test failures + error handling ...
git add -A
git commit -m "fix: Address review issues (tests + error handling)"

# 12:00 PM - Re-run tests
npm test  # All pass ✅

# 12:15 PM - Update review
vim REVIEW-gemini.md
# Status: APPROVED (with fixes)

git add REVIEW-gemini.md
git commit -m "review: Gemini approves feature/payment-idempotency"
git push origin verify/gemini-reviews-feature-payment-idempotency
```

### Day 2: Merge to Main
```bash
# 1:00 PM - Final merge
git checkout main
git merge verify/gemini-reviews-feature-payment-idempotency --no-ff
git push origin main

# Done! ✅
```

---

## ✅ Success Metrics

**You know it's working when**:
- ✅ Every merge to `main` has a review
- ✅ Review documents show thorough checking
- ✅ Issues are caught before `main`
- ✅ Knowledge sharing between LLMs
- ✅ Code quality improves over time
- ✅ Audit trail is complete

---

## 🚫 Common Mistakes

### Mistake 1: Self-Review
```bash
# ❌ BAD: Claude reviews Claude's work
cd Development-claude
./llm-cross-verify.sh  # Reviews own work
```
**Why bad**: No independent verification

**Fix**: Different LLM must review
```bash
# ✅ GOOD: Gemini reviews Claude's work
cd Development
./llm-cross-verify.sh  # Gemini verifies claude/main
```

### Mistake 2: Rubber-Stamp Review
```markdown
# ❌ BAD
Looks good. APPROVED.
```
**Why bad**: No actual review performed

**Fix**: Use full checklist
```markdown
# ✅ GOOD
## Review Checklist
✅ Tests pass (127/127)
✅ Type-check clean
✅ 3 issues found and fixed
✅ Performance tested

APPROVED with confidence 0.95
```

### Mistake 3: Skipping Tests
```bash
# ❌ BAD: Approve without running tests
./llm-cross-verify.sh
# (approves immediately)
```

**Fix**: Always run full test suite
```bash
# ✅ GOOD
npm test
npm run type-check
npm run lint
# THEN approve
```

---

## 📚 Additional Resources

- Multi-LLM Workflow: `MULTI_LLM_WORKFLOW.md`
- LLM Standards: `~/.claude/CLAUDE.md`
- Git Worktrees: https://git-scm.com/docs/git-worktree

---

**Version**: 1.0.0
**Last Updated**: 2025-11-16
**Tested with**: Claude, Cursor, Gemini, Codex
