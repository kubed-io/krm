# Kubed KRM

[![📸 Image Builder](https://github.com/kubed-io/krm/actions/workflows/image.yml/badge.svg)](https://github.com/kubed-io/krm/actions/workflows/image.yml)
[![🧁 Publish Version](https://github.com/kubed-io/krm/actions/workflows/publish.yml/badge.svg)](https://github.com/kubed-io/krm/actions/workflows/publish.yml)

A base image and workspace for managing Kubernetes Resources. Includes kubectl,
kustomize, and krew, plus this repo's custom `kubectl-*` plugins.

## kubectl plugins

Files under [kubectl/](kubectl/) install as `kubectl <name>` (baked into
`/kubed/bin`). They read name/namespace/server-side/applyset from an app's
`kustomization.yaml`:

| Command | Does |
|---------|------|
| `kubectl build <dir>` | render (`kustomize build` with alpha plugins + helm + exec + network) |
| `kubectl up <dir>` | build → apply (applyset + prune) |
| `kubectl down <dir>` | build → delete |
| `kubectl plan <dir>` | build → diff (create/update) + applyset prune preview — read-only |

## Contributing

PR → merge → publish, with a changelog gate on every PR. See
[CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md);
release notes in [CHANGELOG.md](CHANGELOG.md).
