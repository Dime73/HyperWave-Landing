# HyperWave-Landing

Landing page for HyperWave audio plugin.

## Deployment

This site is automatically deployed to GitHub Pages when changes are pushed to the `main` branch.

### Setup GitHub Pages

To enable GitHub Pages for this repository:

1. Go to repository **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. The site will be automatically deployed on the next push to `main`

The site will be available at: `https://dime73.github.io/HyperWave-Landing/`

## Security

### Sensitive Information Scanning

This repository includes automated scanning for sensitive information to prevent accidental commits of:
- Personally identifiable information (PII)
- API keys, tokens, and passwords
- Private keys and certificates
- Proprietary product information

The scanner runs automatically on all pull requests and pushes to `main`. You can also run it manually:

```bash
./.github/scripts/check-sensitive-info.sh
```

For more details, see [`.github/scripts/README.md`](.github/scripts/README.md) and [`.github/agents/sensitive-info-checker.md`](.github/agents/sensitive-info-checker.md).