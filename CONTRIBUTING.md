# Contributing

## Overview

This module uses a **human-authored changelog** workflow. Commit messages are not the changelog. Instead, you write the changelog directly in the PR description and the CI bot commits it for you.

---

## Making a change

### 1. Open a Pull Request targeting `main`

Use the PR template. It pre-fills the required markers. Fill in the `<!-- KEEPACHANGELOG -->` block with Keep-a-Changelog-style entries describing what changed from a user's perspective:

```markdown
<!-- KEEPACHANGELOG -->
### Added
- `service_overrides` now accepts `existing_zone_id` to reference zones in other resource groups.

### Fixed
- Zone deduplication no longer fails when two services share the same `zone_name` with `create_zone = false`.
<!-- /KEEPACHANGELOG -->
```

Empty sub-sections (for example, `### Changed` with just a bare `-` and nothing else) are removed automatically. No need to clean them up yourself.

### 2. Apply exactly one bump label

Every PR must carry exactly one version bump label before it can be merged:

| Label | Effect |
|---|---|
| `bump:patch` | `v1.0.0 -> v1.0.1` |
| `bump:minor` | `v1.0.0 -> v1.1.0` |
| `bump:major` | `v1.0.0 -> v2.0.0` |

Patch is not the implicit default. Use `bump:patch` explicitly for bug fixes and small changes.

### 3. Automation (`pr-changelog.yml`)

On every PR update, the `PR Changelog` workflow runs:

1. Verifies that exactly one `bump:patch`, `bump:minor`, or `bump:major` label is present.
2. Extracts the content between `<!-- KEEPACHANGELOG -->` and `<!-- /KEEPACHANGELOG -->` from the PR description.
3. Drops any empty sub-sections (`### Heading` with no real content).
4. Appends a `([#N](.../pull/N))` link to every top-level bullet (`- ...`) so the entry is traceable back to the PR.
5. Reads the latest `vX.Y.Z` tag, computes the next version from the bump label, and replaces the top `CHANGELOG.md` block with a versioned heading.
6. Commits `CHANGELOG.md` back to the PR branch as `chore: update CHANGELOG for PR #N` when the file changed.

So the entry above would land in `CHANGELOG.md` as:

```markdown
## [1.0.1] - 2026-09-01
### Added
- `service_overrides` now accepts `existing_zone_id` to reference zones in other resource groups. ([#42](https://github.com/CloudverveGmbH/policy-based-dns/pull/42))

### Fixed
- Zone deduplication no longer fails when two services share the same `zone_name` with `create_zone = false`. ([#42](https://github.com/CloudverveGmbH/policy-based-dns/pull/42))
```

The workflow fails if no bump label is present, multiple bump labels are present, or the changelog markers are missing. Configure the `PR Changelog / Update CHANGELOG.md` status check as required in the `main` branch protection rule or ruleset so failing checks block merges.

If the workflow commits `CHANGELOG.md`, it does not create an endless loop: GitHub does not recursively trigger normal workflow runs from the default `GITHUB_TOKEN`, and the commit step is guarded by `git diff --staged --quiet` so reruns do not push another commit when the generated changelog is already current.

### 4. CI (`ci.yml`)

Runs on pull requests targeting `main` and validates:
- `terraform fmt -check`
- `terraform validate` via the `examples/ci-validate` wrapper
- `terraform test` full test suite

The PR cannot be merged until all required checks pass.

---

## Merging and releasing

### On merge to `main` -> `release.yml`

When a PR is merged to `main`, the `Release` workflow runs automatically:

1. **Version guard**: reads the topmost `## [...]` heading in `CHANGELOG.md`. If it is still `[Unreleased]`, the release is skipped.
2. **Test gate**: runs the full Terraform validation and test suite against `main`. Release is blocked on failure.
3. **Tag and GitHub Release**: creates `vX.Y.Z` and publishes the matching `CHANGELOG.md` block as release notes, combined with the vendored ALZ policy metadata table and a usage snippet.

If two PRs are open at the same time, both may compute the same next version from the current latest tag. The second one to merge will be off by one. After the first PR is merged and tagged, re-apply the bump label on the second PR. The workflow re-runs and recalculates from the now-updated latest tag.

If a PR was force-merged without a versioned changelog heading, open a follow-up PR that fixes the top `CHANGELOG.md` heading and rerun the release workflow only after confirming that the intended tag does not already exist.

---

## Drift detection (`drift-check.yml`)

Runs every Monday and opens a GitHub Issue if the vendored ALZ policy JSON (`policy_definitions/Deploy-Private-DNS-Generic.*.json`) differs from the upstream `Azure/Enterprise-Scale` main branch by version or content hash.

When you see a drift issue: download the updated JSON, replace the vendored file, update the SHA256 and tag references in `policies.tf` and `CHANGELOG.md`, then open a PR.
