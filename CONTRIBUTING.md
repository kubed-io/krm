# Contributing

**Kubed KRM** is the base image / devcontainer feature / workspace for managing
Kubernetes resources: `kubectl`, `kustomize`, `krew`, and the custom `kubectl-*`
plugins under [kubectl/](kubectl/). Running environments get these on PATH at
`/kubed/bin` (the Dockerfile does `COPY ./kubectl ./bin`).

## The flow: PR → merge → publish

```
branch + PR ─► pr.yml fails if CHANGELOG [Unreleased] has no new entry
             + image.yml builds the image (does it still build?)
     │
   merge ───► image / feature artifacts publish from main
     │
 publish  ──► Actions → 🧁 Publish Version → pick patch/minor/major
  (manual)   duplocloud/version-bump: roll changelog → tag vX.Y.Z → GitHub Release
```

### 1. Branch and open a PR

- **`pr.yml`** runs `tarides/changelog-check-action` — the PR **fails** unless you
  added a line under `## [Unreleased]` in [CHANGELOG.md](CHANGELOG.md).
- **`image.yml`** builds the base image so breakage is caught before merge.

### 2. Publish a release (manual, intentional)

1. Actions → **🧁 Publish Version**.
2. Pick the bump: `patch` / `minor` / `major` (or a `pre*`).
3. **First run with `push: false`** (dry run — computes the next version, changes
   nothing).
4. **Second run with `push: true`** — `duplocloud/version-bump` rolls
   `[Unreleased]` into a dated `## [vX.Y.Z]` section, commits it, tags, and the
   GitHub Release is created. Publish runs as the GitHub App
   (`vars.GH_APP_ID` / `secrets.GH_APP_KEY`) so it can commit to `main`.

## The kubectl plugins

Each `kubectl/kubectl-<name>` is a plugin invoked as `kubectl <name>`. `build`,
`up`, `down`, and `plan` derive name/namespace/server-side/applyset from an app's
`kustomization.yaml` — see the table in [AGENTS.md](AGENTS.md). When editing:

- Shebang is `#!/usr/bin/env bash`; **test with `bash`**, not the interactive
  shell — array/`read -a` semantics differ under zsh.
- Keep the terse style of the existing scripts; add a header comment explaining
  any non-obvious behavior (e.g. why `plan` reconstructs applyset prune itself).
- `/kubed/bin` is a *copy* of `kubectl/` baked into the image; changes ship on
  the next image build. To iterate live in a pod, copy the edited file into
  `/kubed/bin` too.

## Changelog, versions, tags

- **Changelog**: every change adds one line under `## [Unreleased]`, grouped
  `Added` / `Changed` / `Fixed` / `Removed` / `Deprecated` / `Security`. **The
  changelog is the release notes** — one line per entry, written for a reader of
  "what's new," never a paragraph. Length tracks impact; `**BREAKING:**` may
  stretch. **Only ever edit `[Unreleased]`** — versioned sections are immutable.
- **Versioning**: SemVer; the git tag is the version of record. Don't bump
  versions in a feature PR.
- **Tags**: `v<major>.<minor>.<patch>`, applied by `publish.yml` via
  `duplocloud/version-bump`.

## Conventions

- Before pinning any third-party `uses:` action, verify with
  `gh api repos/<owner>/<repo>/releases/latest`. (`duplocloud/version-bump` is
  first-party and deliberately floats on `@main`.)
- In `run:` blocks, bind GitHub expressions to `env:` and read `$VAR` — don't
  inline `${{ }}` into bash.
