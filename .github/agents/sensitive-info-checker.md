# Sensitive Information Checker Agent Instructions

## Purpose
This agent is responsible for scanning all content before commits to ensure no sensitive information is accidentally included in the repository. The agent should check all files, commit messages, and progress reports.

## Scope
Check for the following types of sensitive information:

### 1. Personally Identifiable Information (PII)
- **Email addresses** (except public contact emails like waitlist@hyperwave.audio)
- **Phone numbers** (format: +1-XXX-XXX-XXXX, (XXX) XXX-XXXX, XXX-XXX-XXXX, etc.)
- **Physical addresses** (street addresses, ZIP codes)
- **Social Security Numbers** (XXX-XX-XXXX format)
- **Credit card numbers** (16-digit sequences)
- **Names with context** (e.g., "John Doe's personal account")
- **Date of birth information**
- **Government-issued ID numbers**

### 2. Authentication & Security Credentials
- **API keys** (patterns like `api_key=`, `apikey:`, `API_KEY=`)
- **Access tokens** (OAuth tokens, bearer tokens, JWT tokens)
- **Passwords** (patterns like `password=`, `pwd:`, `passwd=`)
- **Private keys** (PEM files, SSH keys, `-----BEGIN PRIVATE KEY-----`)
- **Secret keys** (patterns like `secret_key=`, `SECRET=`)
- **Database connection strings** (with embedded credentials)
- **AWS credentials** (`AKIA...`, `aws_secret_access_key`)
- **Other cloud provider credentials** (Azure, GCP)

### 3. Proprietary Product Information
- **Internal architecture details** not meant for public release
- **Unreleased feature specifications**
- **Pricing strategies and profit margins**
- **Trade secrets or proprietary algorithms**
- **Internal server URLs or IP addresses** (except localhost)
- **Internal company information**
- **Beta tester personal information**
- **Customer data or analytics**
- **Private business metrics or KPIs**

### 4. Development Artifacts
- **Hardcoded credentials in configuration files**
- **Debug information containing sensitive paths**
- **Comments containing TODO items with sensitive context**
- **Stack traces revealing internal architecture**

## Files to Check
- All source code files (`.html`, `.js`, `.css`, `.json`, `.yml`, `.yaml`, etc.)
- Documentation files (`.md`, `.txt`)
- Configuration files (`.env`, `.config`, etc.)
- Commit messages and PR descriptions
- Progress reports before they are committed

## Files to Exclude
- Media files (`.mp3`, `.jpeg`, `.png`, `.jpg`, `.gif`, `.mp4`)
- Binary files
- Dependencies (node_modules, vendor directories)
- Build artifacts (dist, build directories)

## Detection Strategy

### Regular Expression Patterns
Use the following patterns to detect sensitive information:

```regex
# Email addresses (exclude allowed public emails)
(?i)(?!waitlist@hyperwave\.audio)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}

# Phone numbers
(?:\+?1[-.\s]?)?(?:\(\d{3}\)|\d{3})[-.\s]?\d{3}[-.\s]?\d{4}

# SSN format
\b\d{3}-\d{2}-\d{4}\b

# API keys
(?i)(api[_-]?key|apikey|api[_-]?secret)[\s]*[=:]\s*['\"]?[a-zA-Z0-9_\-]{20,}

# Bearer tokens
(?i)bearer\s+[a-zA-Z0-9_\-\.=]+

# AWS keys
(?i)(AKIA[0-9A-Z]{16})

# Private keys
-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----

# Generic secrets
(?i)(secret|password|passwd|pwd|token)[\s]*[=:]\s*['\"]?[^\s'\"]{8,}

# Credit card (basic pattern)
\b(?:\d{4}[-\s]?){3}\d{4}\b

# IP addresses (private ranges)
\b(?:10\.\d{1,3}\.\d{1,3}\.\d{1,3}|172\.(?:1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3})\b
```

## Action Steps

### Before Every Commit:
1. **Scan all modified files** for patterns matching sensitive information
2. **Check commit message** for sensitive data
3. **Review progress reports** and PR descriptions for sensitive content
4. **Verify configuration files** don't contain hardcoded secrets

### If Sensitive Information is Detected:
1. **STOP the commit process immediately**
2. **Alert the developer** with:
   - The type of sensitive information detected
   - The file and line number where it was found
   - Suggested remediation steps
3. **Provide alternatives:**
   - Use environment variables for credentials
   - Use `.env` files (and ensure they're in `.gitignore`)
   - Use placeholder values in examples
   - Redact or anonymize PII
   - Remove proprietary details not needed for public consumption

### Allowed Exceptions:
- **Public contact email**: `waitlist@hyperwave.audio` (used in the landing page)
- **Example/placeholder values** clearly marked as such (e.g., `example@example.com`, `YOUR_API_KEY_HERE`)
- **Localhost URLs**: `http://localhost`, `127.0.0.1`
- **Public repository references**

## Remediation Guidelines

### For Credentials:
- Move to environment variables
- Use secret management systems
- Document required environment variables in README without exposing actual values

### For PII:
- Use anonymized or fictional data for examples
- Redact actual personal information
- Use generic placeholders

### For Proprietary Information:
- Review what truly needs to be public
- Remove or generalize internal details
- Keep trade secrets out of public repositories

## Implementation Notes
- This check should run **automatically** before every commit
- Manual review should be performed for borderline cases
- Keep this agent instruction updated as new sensitive data patterns emerge
- Regular audits should be performed on the repository history

## Contact for Questions
If unsure whether information is sensitive, err on the side of caution and flag it for review.
