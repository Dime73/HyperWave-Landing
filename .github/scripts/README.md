# Sensitive Information Scanner

This directory contains scripts for scanning the repository for sensitive information before commits.

## Usage

### Manual Scan

To manually scan the repository for sensitive information:

```bash
./.github/scripts/check-sensitive-info.sh
```

### Automated Checks

The sensitive information scanner runs automatically on:
- Every pull request to the `main` branch
- Every push to the `main` branch
- Manual workflow dispatch via GitHub Actions

See `.github/workflows/sensitive-info-check.yml` for the automated workflow configuration.

### Setting Up Pre-Commit Hook (Optional)

To automatically scan for sensitive information before every commit, you can set up a Git pre-commit hook:

```bash
# Create or edit the pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Run sensitive information scanner
.github/scripts/check-sensitive-info.sh
EOF

# Make it executable
chmod +x .git/hooks/pre-commit
```

## What Gets Scanned

The scanner checks for:

### Personally Identifiable Information (PII)
- Email addresses (except allowed public emails)
- Phone numbers
- Social Security Numbers
- Credit card numbers

### Authentication & Security
- API keys
- Bearer tokens
- AWS access keys
- Private keys
- Generic secrets and passwords

### Network Information
- Private IP addresses

## Allowed Exceptions

The following are explicitly allowed and won't trigger warnings:
- `waitlist@hyperwave.audio` - Public contact email used in the landing page
- `localhost` and `127.0.0.1` references
- Common placeholder values (e.g., "example@example.com", "YOUR_API_KEY_HERE")

## What to Do If Issues Are Found

If the scanner detects potential sensitive information:

1. **Review the findings** - Check if they are legitimate concerns or false positives
2. **Remove sensitive data** - Delete or redact actual sensitive information
3. **Use environment variables** - For credentials and API keys
4. **Use placeholders** - For examples and documentation
5. **Update .gitignore** - Ensure sensitive files (like `.env`) are excluded

## Customization

To add new patterns or exceptions, edit `.github/scripts/check-sensitive-info.sh` and update:
- The `PATTERNS` array for new detection patterns
- The exception filtering logic for allowed values

## Agent Instructions

For detailed agent instructions on sensitive information checking, see:
`.github/agents/sensitive-info-checker.md`
