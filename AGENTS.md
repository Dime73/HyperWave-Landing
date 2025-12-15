# Repository Guidelines

> Note: This is a public repository — always double-check for sensitive information before committing or opening a PR.

## Project Structure & Assets
- `index.html` — single-page landing site; all HTML/CSS/JS lives here.
- `synth.png`, `HyperWaveV3.mp3` — hero image and demo audio referenced by the page; keep filenames stable to avoid broken links.
- `.github/` — GitHub Actions and scripts. `workflows/deploy.yml` handles Pages deploys; `scripts/check-sensitive-info.sh` scans for secrets; `agents/` holds agent instructions.

## Local Preview & Builds
- No build step; serve the root folder directly. Quick preview: `python3 -m http.server 8000` then open `http://localhost:8000`.
- If you add tooling (e.g., bundlers), keep the output out of git or document new commands here.

## Quality Checks
- Secrets scan: `./.github/scripts/check-sensitive-info.sh` (runs on PRs and pushes to `main`). Run locally before committing when you touch text/HTML/CSS.
- Manual sweep: confirm media links in `index.html` resolve (image + audio paths) and that `waitlist@hyperwave.audio` mailto remains intact.

## Coding Style & Naming
- Keep everything in `index.html` tidy: 4-space indent, trailing whitespace stripped, and semantic sectioning (`header`, `section`, `footer`).
- Prefer descriptive class names (`hero`, `compatibility-grid`) and consistent kebab-case for new classes/IDs.
- Inline CSS currently drives the page; if you split into external files, keep colors, gradients, and typography consistent.

## Testing Guidelines
- No automated UI tests yet. For changes, verify locally in a modern Chromium and Safari/Firefox if available.
- Audio: ensure the `audio` element plays `HyperWaveV3.mp3` after changes that touch media paths.

## Commit & Pull Request Guidelines
- Follow the concise, imperative style used in history (e.g., “Update hero image”, “Add sensitive info scan”).
- One focused change per commit; include context in the body if needed.
- PRs: include a short summary, before/after screenshots for visual changes, mention manual browser(s) tested, and note if the secrets scan was run.

## Security & Secrets
- Never commit credentials or personal data. Use environment variables or redacted placeholders in examples.
- If the scanner flags something, resolve before opening a PR; see `.github/scripts/README.md` for allowed exceptions and patterns.

## Deployment Notes
- GitHub Pages auto-deploys on push to `main` via `.github/workflows/deploy.yml`. No additional steps required.
