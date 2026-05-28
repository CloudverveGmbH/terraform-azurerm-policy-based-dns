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

### Version stamping — before you open the PR

`release.yml` has no write access to `main`. It only reads `CHANGELOG.md` and creates the GitHub Release. This means **the version heading must already be correct in `CHANGELOG.md` on `main` at the time the release runs**.

The cleanest way to achieve this is to stamp the version while the PR is still open:

**Option A — PR label (recommended)**

Apply one of these labels to the PR:

| Label | Effect |
|---|---|
| `bump:patch` | `v1.0.0 → v1.0.1` |
| `bump:minor` | `v1.0.0 → v1.1.0` |
| `bump:major` | `v1.0.0 → v2.0.0` |

The `pr-changelog.yml` workflow detects the label, reads the current latest tag, computes the next version, and uses it as the `CHANGELOG.md` heading (e.g. `## [v0.0.6] — 2026-05-28`) instead of `## [Unreleased]`. The commit to the PR branch happens automatically.

**If two PRs are open at the same time**, both may compute the same next version from the current latest tag. The second one to merge will be off by one. After the first PR is merged and tagged, re-apply the label on the second PR — the workflow re-runs and recalculates from the now-updated latest tag.

**Option B — edit manually**

Directly edit `CHANGELOG.md` on your PR branch and change `## [Unreleased]` to `## [v0.0.6] — 2026-05-28`. No label needed.

**Without any label**, the heading stays as `## [Unreleased]`. The release will still be created, using the `[Unreleased]` block content as release notes — but the heading in `CHANGELOG.md` on `main` won't be versioned until someone manually fixes it.

### On merge to `main` → `auto-tag.yml`

Automatically bumps the semver tag using the same bump-label logic (or commit message markers as fallback):

| PR label or text in title/body | Bump |
|---|---|
| `bump:major` / `[major]` | `v1.0.0 → v2.0.0` |
| `bump:minor` / `[minor]` | `v1.0.0 → v1.1.0` |
| _(anything else)_ | `v1.0.0 → v1.0.1` (patch) |

The new tag is pushed, which triggers `release.yml`.

### `release.yml` (triggered by Auto Tag)

1. **Test gate** — full CI suite runs against the tag. Release is blocked on failure.
2. **GitHub Release** — the topmost `## [...]` block in `CHANGELOG.md` on `main` is extracted as release notes, combined with the vendored ALZ policy metadata table and a usage snippet.

---

## Version bump markers

PR labels (`bump:patch`, `bump:minor`, `bump:major`) are the primary way to control the bump. Both `pr-changelog.yml` (for pre-stamping) and `auto-tag.yml` (for the actual tag) read the labels.\n\nAs a fallback, `auto-tag.yml` also scans the PR title, PR body, and last commit message for text markers:\n\n```\n[minor] add support for management group assignment scopes\n[major] remove legacy zone lookup fallback\n```\n\nPatch is the default — no label or marker needed for bug fixes or small changes.

---

## Drift detection (`drift-check.yml`)

Runs every Monday and opens a GitHub Issue if the vendored ALZ policy JSON (`policy_definitions/Deploy-Private-DNS-Generic.*.json`) differs from the upstream `Azure/Enterprise-Scale` main branch by version or content hash.

When you see a drift issue: download the updated JSON, replace the vendored file, update the SHA256 and tag references in `policies.tf` and `CHANGELOG.md`, then open a PR.
