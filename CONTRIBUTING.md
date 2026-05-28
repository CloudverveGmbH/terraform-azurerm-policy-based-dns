# Contributing

## Overview

This module uses a **human-authored changelog** workflow. Commit messages are not the changelog. Instead, you write the changelog directly in the PR description and the CI bot commits it for you.

---

## Making a change

### 1. Open a Pull Request targeting `main`

Use the PR template — it pre-fills the required markers. Fill in the `<!-- KEEPACHANGELOG -->` block with Keep-a-Changelog–style entries describing what changed from a user's perspective:

```markdown
<!-- KEEPACHANGELOG -->
### Added
- `service_overrides` now accepts `existing_zone_id` to reference zones in other resource groups.

### Fixed
- Zone deduplication no longer fails when two services share the same `zone_name` with `create_zone = false`.
<!-- /KEEPACHANGELOG -->
```

Empty sub-sections (e.g. `### Changed` with just a bare `-` and nothing else) are removed automatically — no need to clean them up yourself.

### 2. Automation (`pr-changelog.yml`)

On every push to the PR branch the `PR Changelog` workflow runs:

1. Extracts the content between `<!-- KEEPACHANGELOG -->` and `<!-- /KEEPACHANGELOG -->` from the PR description.
2. Drops any empty sub-sections (`### Heading` with no real content).
3. Appends a `([#N](…/pull/N))` link to every top-level bullet (`- …`) so the entry is traceable back to the PR.
4. Replaces the `## [Unreleased]` block in `CHANGELOG.md` with the result.
5. Commits `CHANGELOG.md` back to the PR branch as `chore: update CHANGELOG for PR #N`.

So the entry above would land in `CHANGELOG.md` as:

```markdown
### Added
- `service_overrides` now accepts `existing_zone_id` to reference zones in other resource groups. ([#42](https://github.com/CloudverveGmbH/policy-based-dns/pull/42))

### Fixed
- Zone deduplication no longer fails when two services share the same `zone_name` with `create_zone = false`. ([#42](https://github.com/CloudverveGmbH/policy-based-dns/pull/42))
```

If the markers are missing the workflow warns in the step summary but does **not** fail — the PR can still be merged, but `CHANGELOG.md` won't be updated.

### 3. CI (`ci.yml`)

Runs on the same trigger and validates:
- `terraform fmt -check`
- `terraform validate` (via the `examples/ci-validate` wrapper)
- `terraform test` (full test suite — 17 runs)

The PR cannot be merged until all checks pass.

---

## Merging and releasing

### On merge to `main` → `auto-tag.yml`

Automatically bumps the semver tag:

| PR title / body contains | Bump |
|---|---|
| `[major]` | `v1.0.0 → v2.0.0` |
| `[minor]` | `v1.0.0 → v1.1.0` |
| _(anything else)_ | `v1.0.0 → v1.0.1` (patch) |

The new tag is pushed to `main`, which triggers `release.yml`.

### `release.yml` (triggered by Auto Tag)

1. **Test gate** — full CI suite runs against the new tag. Release is aborted if any test fails.
2. **Stamp CHANGELOG.md** — `## [Unreleased]` is rewritten to `## [vX.Y.Z] — YYYY-MM-DD` and a fresh empty `## [Unreleased]` is inserted above it. Committed directly to `main`.
3. **GitHub Release** — created with the content of the stamped changelog block as release notes, plus a vendored ALZ policy metadata table and a usage snippet.

---

## Version bump markers

To control the semver bump, add a marker anywhere in the PR title, PR description, or last commit message:

```
[minor] add support for management group assignment scopes
[major] remove legacy zone lookup fallback
```

Patch is the default — no marker needed for bug fixes or small changes.

---

## Drift detection (`drift-check.yml`)

Runs every Monday and opens a GitHub Issue if the vendored ALZ policy JSON (`policy_definitions/Deploy-Private-DNS-Generic.*.json`) differs from the upstream `Azure/Enterprise-Scale` main branch by version or content hash.

When you see a drift issue: download the updated JSON, replace the vendored file, update the SHA256 and tag references in `policies.tf` and `CHANGELOG.md`, then open a PR.
