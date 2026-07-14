# AGENTS.md

Guidance for AI agents (and humans skimming) working in this repo. **Kubed KRM**
is the base image and workspace for managing Kubernetes resources — it ships
`kubectl`, `kustomize`, `krew`, and this repo's custom `kubectl-*` plugins. It is
consumed as a container image and a devcontainer feature; `/kubed/bin` in running
environments is populated from `kubectl/` here (`COPY ./kubectl ./bin`).

## Read first

- [README.md](README.md) — what the image/workspace provides.
- [CONTRIBUTING.md](CONTRIBUTING.md) — the full PR → merge → release flow.
- [CHANGELOG.md](CHANGELOG.md) — every PR adds a line under `## [Unreleased]`.

## The custom kubectl plugins (`kubectl/`)

Each file `kubectl/kubectl-<name>` becomes `kubectl <name>` on PATH. The core trio
reads `metadata.name`, namespace, and the `kubectl.kubernetes.io/{server-side,apply-set}`
annotations from an app's `kustomization.yaml`:

| Command | Does |
|---------|------|
| `kubectl build <dir>` | `kustomize build` with alpha plugins + helm + exec + network |
| `kubectl up <dir>` | build → `kubectl apply` (applyset + prune, server-side per annotation) |
| `kubectl down <dir>` | build → `kubectl delete` |
| `kubectl plan <dir>` | build → `kubectl diff` (create/update) + a membership-based applyset prune preview — read-only |

## Rules

- **The changelog IS the release notes.** One line per entry under
  `## [Unreleased]`, grouped `Added`/`Changed`/`Fixed`/`Removed`/`Security`,
  written for a reader of "what's new." **Only ever edit `[Unreleased]`** —
  versioned sections are immutable. A PR with no new entry fails CI.
- **Never bump versions in a feature PR.** `publish.yml`
  (`duplocloud/version-bump`) owns versioning and tags; the git tag is the
  version of record.
- **Plugins run under `#!/usr/bin/env bash`.** Keep them POSIX-ish bash and test
  with `bash`, not the interactive shell (which may be zsh — `read -a`/arrays
  differ). Match the terse style of the existing scripts.
- **`kubectl plan` is read-only** (server-side dry-run + a get-only prune pass) —
  safe to run anytime. Prune preview is reconstructed from the live applyset
  parent's membership; `kubectl diff` has no `--applyset` flag.
- **Verify external references.** Before pinning any `uses:` action, check
  `gh api repos/<owner>/<repo>/releases/latest`. (`duplocloud/version-bump` is a
  first-party action and deliberately floats on `@main`.)
- **Bind GitHub expressions to `env:` in `run:` blocks** — read `$VAR`, don't
  inline `${{ }}` into bash.
