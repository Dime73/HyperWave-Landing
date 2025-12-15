#!/bin/bash

# Sensitive Information Scanner
# This script scans staged files for sensitive information before commits
# Usage: Run this script before committing changes

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🔍 Scanning for sensitive information..."

FOUND_ISSUES=0

# Get list of staged files (or all files if no git)
if git rev-parse --git-dir > /dev/null 2>&1; then
    FILES=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || git ls-files)
else
    FILES=$(find . -type f -not -path '*/\.*' -not -path '*/node_modules/*' -not -path '*/dist/*')
fi

# Exclude binary and media files
EXCLUDED_EXTENSIONS='\.(mp3|mp4|wav|flac|jpeg|jpg|png|gif|bmp|ico|svg|woff|woff2|ttf|eot|pdf|zip|tar|gz)$'

# Create temporary file for results
TEMP_RESULTS=$(mktemp)

# Allowed exceptions
ALLOWED_EMAIL="waitlist@hyperwave\.audio"

# Define patterns to search for
declare -A PATTERNS=(
    ["Email (potential PII)"]="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
    ["Phone Number"]="(\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}"
    ["SSN Format"]="[0-9]{3}-[0-9]{2}-[0-9]{4}"
    ["API Key Pattern"]="(api[_-]?key|apikey|api[_-]?secret)[\s]*[=:]\s*['\"]?[a-zA-Z0-9_\-]{20,}"
    ["Bearer Token"]="[Bb]earer\s+[a-zA-Z0-9_\-\.=]{20,}"
    ["AWS Access Key"]="AKIA[0-9A-Z]{16}"
    ["Private Key"]="-----BEGIN.*PRIVATE KEY-----"
    ["Generic Secret"]="(secret|password|passwd|pwd|token)[\s]*[=:]\s*['\"]?[a-zA-Z0-9_\-]{16,}"
    ["Credit Card Pattern"]="[0-9]{4}[-\s]?[0-9]{4}[-\s]?[0-9]{4}[-\s]?[0-9]{4}"
    ["IPv4 Private"]="(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3})"
)

# Scan each file
for file in $FILES; do
    # Skip if file doesn't exist or is excluded
    if [ ! -f "$file" ] || echo "$file" | grep -qE "$EXCLUDED_EXTENSIONS"; then
        continue
    fi
    
    # Skip binary files
    if file "$file" | grep -q "binary"; then
        continue
    fi
    
    # Skip this script and the agents directory
    if [[ "$file" == *"check-sensitive-info.sh"* ]] || [[ "$file" == *".github/agents/"* ]]; then
        continue
    fi
    
    # Check each pattern
    for pattern_name in "${!PATTERNS[@]}"; do
        pattern="${PATTERNS[$pattern_name]}"
        
        # Search for pattern in file
        matches=$(grep -nEi "$pattern" "$file" 2>/dev/null || true)
        
        if [ -n "$matches" ]; then
            # Filter out allowed exceptions
            if [[ "$pattern_name" == "Email (potential PII)" ]]; then
                matches=$(echo "$matches" | grep -vE "$ALLOWED_EMAIL" || true)
            fi
            
            # Filter out common false positives
            if [[ "$pattern_name" == "Generic Secret" ]]; then
                # Skip if it's a comment about passwords or placeholder
                matches=$(echo "$matches" | grep -viE "(example|placeholder|your_|todo|xxx|password123|secret123)" || true)
            fi
            
            if [ -n "$matches" ]; then
                echo -e "${RED}❌ Found $pattern_name in $file:${NC}" | tee -a "$TEMP_RESULTS"
                echo "$matches" | while IFS= read -r line; do
                    echo -e "${YELLOW}   $line${NC}" | tee -a "$TEMP_RESULTS"
                done
                echo "" | tee -a "$TEMP_RESULTS"
                FOUND_ISSUES=$((FOUND_ISSUES + 1))
            fi
        fi
    done
done

# Report results
if [ $FOUND_ISSUES -gt 0 ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}⚠️  WARNING: Potential sensitive information detected!${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Found $FOUND_ISSUES potential issue(s).${NC}"
    echo ""
    echo -e "${YELLOW}Please review the findings above and take action:${NC}"
    echo "  • Remove or redact sensitive information"
    echo "  • Use environment variables for credentials"
    echo "  • Use placeholder values for examples"
    echo "  • Move secrets to .env files (ensure .env is in .gitignore)"
    echo ""
    echo -e "${YELLOW}If these are false positives, please verify carefully before proceeding.${NC}"
    echo ""
    
    # Clean up
    rm -f "$TEMP_RESULTS"
    exit 1
else
    echo -e "${GREEN}✅ No sensitive information detected.${NC}"
    rm -f "$TEMP_RESULTS"
    exit 0
fi
