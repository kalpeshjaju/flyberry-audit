#!/bin/bash

# LLM Cross-Verification Script (Maker-Checker Pattern)
# Purpose: Allow one LLM to review another LLM's work before merging
# Author: Claude
# Date: 2025-11-16

set -e

echo "🔍 LLM Cross-Verification System (Maker-Checker)"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current directory (should be main repo)
MAIN_REPO=$(pwd)

# Check if in git repo
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Function to show available branches for review
show_available_work() {
    echo -e "${BLUE}📋 Available LLM branches:${NC}"
    echo ""

    git branch -a | grep -E "(claude|cursor|gemini|codex|feature)/" | while read branch; do
        # Remove leading whitespace and 'remotes/origin/'
        clean_branch=$(echo "$branch" | sed 's/^[* ]*//' | sed 's/remotes\/origin\///')

        # Get last commit info
        last_commit=$(git log -1 --format="%h - %s (%ar)" "$clean_branch" 2>/dev/null || echo "No commits")

        echo -e "  ${GREEN}•${NC} $clean_branch"
        echo -e "    ${YELLOW}└─${NC} $last_commit"
        echo ""
    done
}

# Function to create verification branch
create_verification_branch() {
    local maker_branch=$1
    local checker_llm=$2
    local verification_branch="verify/${checker_llm}-reviews-${maker_branch//\//-}"

    echo -e "${BLUE}Creating verification branch: ${verification_branch}${NC}"

    # Create verification branch from maker's work
    git checkout -b "$verification_branch" "$maker_branch"

    echo -e "${GREEN}✅ Verification branch created!${NC}"
    echo ""
    echo -e "${YELLOW}🎯 Next steps for ${checker_llm}:${NC}"
    echo -e "  1. Review the code in this branch"
    echo -e "  2. Run tests: ${BLUE}npm test${NC}"
    echo -e "  3. Check types: ${BLUE}npm run type-check${NC}"
    echo -e "  4. Review changes: ${BLUE}git diff main${NC}"
    echo -e "  5. Add review comments to: ${BLUE}REVIEW-${checker_llm}.md${NC}"
    echo -e "  6. If approved, merge to main"
    echo -e "  7. If issues found, create fixes on this branch"
    echo ""
}

# Function to generate review template
generate_review_template() {
    local maker_branch=$1
    local checker_llm=$2
    local review_file="REVIEW-${checker_llm}.md"

    cat > "$review_file" <<EOF
# Code Review: ${maker_branch}

**Reviewer**: ${checker_llm}
**Date**: $(date +%Y-%m-%d)
**Status**: IN_REVIEW

---

## Summary of Changes
<!-- What did the maker LLM build? -->


## Files Changed
\`\`\`bash
$(git diff main --name-only)
\`\`\`

## Review Checklist

### Functionality
- [ ] Code runs without errors
- [ ] Tests pass (\`npm test\`)
- [ ] Type-check passes (\`npm run type-check\`)
- [ ] Lint passes (\`npm run lint\`)

### Code Quality
- [ ] Functions are well-documented
- [ ] No \`any\` types (use \`unknown\`)
- [ ] Error handling is comprehensive
- [ ] No console.log in production code
- [ ] Files <600 lines, functions <120 lines

### Security
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No SQL injection risks
- [ ] No XSS vulnerabilities

### Multi-LLM Standards
- [ ] File-level documentation present
- [ ] Function documentation includes WHY/HOW
- [ ] Edge cases documented
- [ ] Confidence scores included

---

## Issues Found

### Critical (Must Fix)
<!-- Issues that block merge -->

**None** ✅

### Medium (Should Fix)
<!-- Issues that should be fixed before merge -->

**None** ✅

### Low (Nice to Have)
<!-- Suggestions for improvement -->

**None** ✅

---

## Test Results

\`\`\`bash
# npm test output:


# npm run type-check output:


# npm run lint output:

\`\`\`

---

## Recommendations

### Approve for Merge?
- [ ] ✅ YES - Approve and merge to main
- [ ] ⚠️  CONDITIONAL - Approve after fixes
- [ ] ❌ REJECT - Major issues, needs rework

### Confidence Score
**Confidence**: [VERIFIED/HIGH/MEDIUM/LOW] (0.XX)
**Reason**: [Why this score]

---

## Review Notes
<!-- Additional comments, suggestions, observations -->


---

**Reviewed by**: ${checker_llm}
**Signature**: [LLM name + date]
EOF

    echo -e "${GREEN}✅ Review template created: ${review_file}${NC}"
}

# Function to show diff between maker and main
show_diff_summary() {
    local maker_branch=$1

    echo -e "${BLUE}📊 Changes from main:${NC}"
    echo ""

    # Show file changes
    echo -e "${YELLOW}Files changed:${NC}"
    git diff main.."$maker_branch" --stat
    echo ""

    # Show commit summary
    echo -e "${YELLOW}Commits:${NC}"
    git log main.."$maker_branch" --oneline
    echo ""
}

# Main menu
echo -e "${YELLOW}What would you like to do?${NC}"
echo ""
echo "  1. List available work to review"
echo "  2. Start verification (maker-checker)"
echo "  3. Show diff summary"
echo "  4. Approve and merge to main"
echo ""
read -p "Choose option (1-4): " option

case $option in
    1)
        show_available_work
        ;;

    2)
        show_available_work
        echo ""
        read -p "Enter maker branch to review (e.g., claude/main): " maker_branch
        read -p "Enter your LLM name (checker): " checker_llm

        # Fetch latest
        git fetch origin

        # Create verification branch
        create_verification_branch "$maker_branch" "$checker_llm"

        # Generate review template
        generate_review_template "$maker_branch" "$checker_llm"

        # Show diff
        show_diff_summary "$maker_branch"
        ;;

    3)
        show_available_work
        echo ""
        read -p "Enter branch to compare: " compare_branch
        git fetch origin
        show_diff_summary "$compare_branch"
        ;;

    4)
        echo ""
        read -p "Enter branch to merge (e.g., claude/main): " merge_branch

        # Show summary
        echo -e "${BLUE}About to merge:${NC}"
        git log main.."$merge_branch" --oneline
        echo ""

        read -p "Confirm merge? (y/n): " confirm
        if [ "$confirm" = "y" ]; then
            git checkout main
            git merge "$merge_branch" --no-ff -m "Merge $merge_branch (reviewed and approved)"

            echo -e "${GREEN}✅ Merged to main!${NC}"
            echo -e "${YELLOW}Don't forget to:${NC}"
            echo -e "  • Run tests: ${BLUE}npm test${NC}"
            echo -e "  • Push to origin: ${BLUE}git push origin main${NC}"
        else
            echo -e "${RED}❌ Merge cancelled${NC}"
        fi
        ;;

    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Done!${NC}"
