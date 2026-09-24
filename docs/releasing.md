# Release distribution

For ordinary PRs, including Dependabot and these automation changes, review and
merge passing checks normally. Those merges never publish an upstream release.

For fv-ssh-unlock, release once from the source repository's Prepare tagged
release workflow. This tap checks published releases hourly (minute 17) through
Sync fv-ssh-unlock release, or you can run it immediately on main with an explicit
version tag. All source binding, publisher, signature, checksum and container
checks must pass before the workflow opens a formula-only PR. No cross-repository
write token or local signing key is needed.

The reviewed `.github/fv-release-channel.json` defaults to `preview`, matching the
existing release-candidate feed. `preview` includes stable releases; `stable`
excludes prereleases. Versions never downgrade, and already current versions do
not recreate PRs. Set channel by a normal config PR or a manual sync override.

## Approve package publication

Wait for both macOS and Linux **brew test-bot** checks on the formula PR. GitHub
may require clicking **Approve workflows to run** on a bot-created PR. Then a
repository writer comments this, replacing the placeholder with that PR's full
40-character head SHA:

```
/publish FULL_CURRENT_HEAD_SHA
```

Alternatively run **Publish verified fv-ssh-unlock bottles** on main with the PR
number and full head SHA. The permission check uses the author's current repository
access, not just their comment association. Bots cannot authorize publication.
The preflight rejects unrelated formula code changes, a changed/stale head/base,
failed/pending/neutral checks, outstanding change-request reviews, and missing,
expired or wrong-source bottle artifacts. It re-verifies the upstream release.

The publisher incorporates the approved formula through `brew pr-pull`, uploads
its tested bottles, and makes a non-forced main push. It does not silently rebase
onto another main after testing. Do not squash-merge these **formula version PRs**
when using bottle publication. The resulting PR may show Closed rather than a
normal GitHub merge: confirm the new formula/bottles and successful publisher.
The original manual **brew pr-pull** workflow remains available for other formulae;
use the new guarded workflow for fv-ssh-unlock.

Publication explicitly starts the read-only **Feed installation smoke test** even
when the main push uses GITHUB_TOKEN. The test installs real published bottles on
macOS and Linux, forbids source fallback, checks the version, and runs `brew test`.
The upstream Release distribution status issue closes after this and Scoop's
current-main installation check both pass.

## Setup and recovery

Merge the source release-tools PR first, then this automation PR. The shared action
is full-SHA pinned; review future pin updates. An administrator may need to enable
Actions' **Allow GitHub Actions to create and approve pull requests** setting to
permit PR creation. No workflow approves reviews or changes repository settings.
The hourly schedule is best effort, not immediate delivery; manual Sync is the
fast/recovery path. Sync refuses to overwrite hand-edited generated PR branches.

Never rerun a successful publisher or overwrite existing bottle assets. If upload
succeeded but the main push failed, inspect and reconcile the already-published
metadata rather than rebuilding/reuploading. A changed PR needs fresh checks and
a new exact-head approval. A closed generated PR is not automatically reopened.
For routine checking, rerun **Sync** (dry-run for no writes) or **Feed installation
smoke test**, not the publisher. The already completed rc.4 release is not changed
by merging these automation files.
