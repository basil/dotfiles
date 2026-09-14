---
name: simplify-code
description: "Review and simplify recent code changes when the user explicitly requests cleanup or simplification, covering reuse, complexity, efficiency, and abstraction boundaries. Not for correctness reviews."
license: MIT
metadata:
  version: 1.0.0
  author: Basil Crow (inspired by Hermes Agent)
  platforms: [linux, macos, windows]
  tags: [code-review, cleanup, refactor, delegation, subagent, parallel, simplify]
---

# Simplify Code -- Parallel Review & Cleanup

Review your recent code changes with four focused reviewers running in
parallel, aggregate their findings, and apply the fixes worth applying.

**This is a cleanup pass, not a bug hunt.** You are improving the quality of
code that already works -- removing duplication, flattening needless
complexity, cutting waste, and deepening band-aid fixes. Do not go hunting
for correctness bugs here; that's what `subagent-review` is for.

**Core principle:** Four narrow reviewers beat one broad reviewer. Each one
deeply searches the codebase for a single class of problem -- reuse, quality,
efficiency, altitude -- without diluting its attention across all four. They
run concurrently, so you pay the latency of one review, not four.

## When to Use

Trigger this skill only when the user explicitly requests simplification or
cleanup, such as:

- "simplify" / "simplify my changes" / "simplify these changes"
- "clean up my code" / "clean up my changes"

Optional modifiers the user may add -- honor them:

- **Focus:** "simplify focus on efficiency" - run only the efficiency reviewer
  (or weight the aggregation toward it). Recognized focuses: `reuse`,
  `quality` (also accepts `simplification`), `efficiency`, `altitude`.
- **Dry run:** "simplify but don't change anything" / "just report" - run the
  selected reviewers, present findings in all three risk tiers, apply NOTHING.
  Ask before applying.
- **Scope:** "simplify the last commit" / "simplify staged" / "simplify
  src/foo.py" - narrow the diff source accordingly (see Phase 1).

## The Process

### Phase 1 -- Identify the changes

Review tracked staged and unstaged changes by default, plus untracked files
created in this session. Include untracked files as additions without staging
them; leave unrelated untracked files out.

Honor an explicit scope such as staged changes, the last commit, a branch/PR,
or named files. Named-file scopes include matching untracked files; staged,
commit, and branch scopes do not. For branch/PR reviews, use the requested
base or the established target branch. Ask if the base is unclear.

If an explicit scope is empty or cannot be resolved, report that and stop;
do not substitute a different scope. Without an explicit scope, fall back
to files edited in this session when there is no diff or repository. If
there is nothing to review, say so and stop.

Capture the full diff text. Note its size: if it's very large (say >2000
changed lines), warn the user that four subagents each carrying the full diff
will be token-heavy, and offer to scope it down (per-directory, per-commit)
before proceeding.

### Phase 2 -- Launch four reviewers in parallel

Launch up to four independent reviewers concurrently using the host agent's
delegation mechanism. Four is the intended fan-out for this pattern, but do
not exceed the concurrency available in the current environment.

**No delegation available?** If delegation or sufficient concurrency is
unavailable, do NOT skip the review or drop selected angles. Work through all
selected reviewer angles yourself, sequentially or in later waves -- same search
standards, same finding format.

Give **every** reviewer the **complete diff** (not fragments -- cross-file
issues hide in the gaps) plus the absolute repo path so they can search the
wider codebase. Give reviewers access to the repository and the available
tools needed to inspect files, search code, and run read-only Git commands.

Give reviewers the selected scope and version. They must inspect surrounding
code from that same version: the index for staged changes, the reviewed
commit for commit/branch scopes, or the working tree for default/file scopes.
Do not mix unrelated local edits into findings. If the code changes during
review, recheck affected findings before aggregation. Fold applicable project
instructions (such as AGENTS.md or CLAUDE.md) and linter rules into reviewer
prompts.

Tell each reviewer to:
- Stay read-only: report findings without editing files or applying fixes.
  Only the coordinating agent applies fixes in Phase 3, after aggregation.
- Search the existing codebase for `file:line` evidence (don't reason from
  the diff alone). Dead-code tools such as `knip`, `ts-prune`, and `depcheck`
  can miss dynamic uses; search for the symbol before proposing removal.
- **Apply Chesterton's Fence:** understand why code exists before suggesting
  its removal. Use surrounding code, comments, and history as needed. If its
  purpose remains unclear, mark it `confidence: low` -- don't guess.
- Report findings as structured output with the concrete cost, confidence,
  and risk:
  ```
  file:line - problem - cost (what's duplicated/wasted/harder to maintain) - suggested fix | confidence: high/medium/low | risk: SAFE/CAREFUL/RISKY
  ```
  The **cost** field forces each finding to justify itself -- a finding that
  can't articulate what the problem actually costs is probably a nit.
  Include the risk-tier definitions from Phase 3 in each reviewer prompt.
- Skip nits and style-only churn. Only flag things that materially improve
  the code.
- Report incidentally discovered correctness bugs prominently and separately
  from cleanup findings. Do not fold them into cleanup fixes.
- An empty catch block or ignored error might be intentional -- the error is
  expected and benign in that context. Flag it, don't remove it; let the human
  decide.

Pass these four goals (drop any the user's focus excludes):

**Reviewer 1 -- Code Reuse**
> Review this diff for code that duplicates functionality already in the
> codebase. Search utility modules, shared helpers, and adjacent files
> (use the available code-search tool, such as `rg` or `grep`) for existing
> functions, constants, or patterns
> the new code could call instead of reimplementing. Flag: new functions
> that duplicate existing ones; hand-rolled logic that an existing utility
> already does (manual string/path manipulation, custom env checks, ad-hoc
> type guards, re-implemented parsing). For each, name the existing thing to
> use and where it lives.

**Reviewer 2 -- Code Quality**
> Review this diff for quality problems. Look for: redundant state (values
> that duplicate or could be derived from existing state; caches that don't
> need to exist); parameter sprawl (new params bolted on where the function
> should have been restructured); copy-paste-with-variation (near-duplicate
> blocks that should share an abstraction); leaky abstractions (exposing
> internals, breaking an existing encapsulation boundary); stringly-typed
> code (raw strings where a constant/enum/registry already exists -- check the
> canonical registries before flagging); deeply nested conditionals (ternary
> chains, 3+-level if/else pyramids -- flatten with guard clauses, early
> returns, or a lookup table); AI-generated slop patterns (extra
> comments restating obvious code like `// increment counter` above `count++`;
> unnecessary defensive null-checks on already-validated inputs; `as any`
> casts that bypass the type system; patterns inconsistent with the rest of
> the file). For each, give the concrete refactor.

**Reviewer 3 -- Efficiency**
> Review this diff for efficiency problems. Look for: unnecessary work
> (redundant computation, repeated file reads, duplicate API calls, N+1
> access patterns); missed concurrency (independent ops run sequentially);
> hot-path bloat (heavy/blocking work on startup or per-request paths);
> TOCTOU anti-patterns (existence pre-checks before an op instead of doing
> the op and handling the error); memory issues (unbounded growth, missing
> cleanup, listener/handle leaks; long-lived closures that retain unneeded
> objects). Check what the language/runtime actually captures and show evidence
> of unwanted retention before recommending narrower captures, a class, or a
> struct; do not assume closures retain their entire enclosing scope. Look for
> overly broad reads (loading whole files when a slice would do); silent
> failures (empty catch blocks, ignored error returns, `except: pass`,
> `.catch(() => {})` with no handling, error propagation gaps -- these hide
> bugs and should at minimum log before swallowing). For each, give the
> concrete fix and why it's faster or safer.

**Reviewer 4 -- Altitude**
> Review this diff for changes implemented at the wrong depth -- band-aids
> layered on top of shared infrastructure instead of fixes to the
> infrastructure itself. Signs of a too-shallow fix: a special case added to
> a generic code path to handle one caller (an `if (caller == X)` branch, a
> type check, a magic-value escape hatch); a symptom patched at the call
> site while sibling call sites keep the same flaw; a workaround stacked on
> an earlier workaround; a wrapper added to avoid touching the thing that
> actually needs changing; configuration or flags introduced to route around
> a broken default instead of fixing the default. For each, identify the
> underlying mechanism the change is dodging and describe the deeper fix --
> generalize the shared path, fix the root default, or fix the whole bug
> class -- and honestly note when the deeper fix is large enough that it
> should be its own task rather than part of this cleanup. Check the
> surrounding code and intent first: what looks like a band-aid is
> sometimes a deliberate boundary (compat shims, staged migrations,
> vendored-code isolation). Don't flag those.

### Phase 3 -- Aggregate and apply

Wait for every launched review to finish.

1. **Merge** the findings into one list, deduping where reviewers overlap --
   when two findings target the same line or the same underlying mechanism,
   collapse them into one.
2. **Discard false positives** -- you have the most context; you don't have to
   argue with a reviewer, just drop weak, wrong, or unsupported suggestions
   silently.
3. **Resolve conflicts.** Reviewers can disagree (Reviewer 1: "use existing
   util X"; Reviewer 3: "X is slow, inline it"). Default resolution order:
   **correctness > the user's stated focus > readability/reuse > micro-perf.**
   Don't apply a perf "fix" that hurts clarity unless the path is genuinely
   hot. When two suggestions are mutually exclusive and both defensible, pick
   the one that touches less code and note the alternative.
4. **Revalidate before applying.** Apply only findings that still hold in the
   current files. Skip fixes that would change intended behavior or require
   changes well outside the reviewed diff; report worthwhile follow-ups with
   the reason they were skipped. Limit edits to the reviewed changes plus the minimal
   surrounding changes a fix requires, preserving unrelated edits. Skip obsolete
   findings and report conflicts with unrelated edits. Do not replace current
   files with reviewed snapshots or stage changes unless asked. When undoing
   a failed fix, revert only your own edits.
5. **Apply in risk-tier order:**
   Establish a baseline with the relevant checks before editing so existing
   failures can be distinguished from regressions. If checks cannot run,
   record the reason and follow the disclosure rule in step 6.

   - **SAFE first** (proven not to affect behavior; auto-apply): unused imports,
     commented-out code, pass-through wrappers, redundant type assertions.
   - **CAREFUL next** (preserves semantics; apply with attempted verification):
     rename locals, flatten ternaries, extract helpers, consolidate dupes.
     Apply all dependent edits
     for a finding across the affected files before checking it. Batch
     independent low-risk fixes when appropriate; isolate findings when their
     risk or interactions warrant separate verification.
   - **RISKY last** (may change behavior or break public contracts; flag for
     review, do NOT auto-apply): N+1 restructuring, public API changes,
     concurrency fixes, error-handling changes, memory lifecycle changes.
     Contracts include export names, API routes, DB columns, and config keys.
     Present each with risk description and test coverage status. Altitude findings
     usually land here -- when a deeper fix exceeds the reviewed scope,
     present it and let the user decide whether to do it now or as a follow-up.
6. **Verify** with checks appropriate to the affected behavior and repository
   requirements. Prefer targeted tests and relevant lint/type checks; run the
   full suite when required or when it provides the appropriate coverage.
   Once checks pass, repeat or broaden them only for new edits, failures, or
   unresolved concerns. Revert only fixes that introduce failures, preserving edits as
   described above; report pre-existing failures separately. If tests are
   missing, dependencies are unavailable, or checks otherwise cannot run,
   retain the fixes and explicitly list the affected fixes, checks not run,
   and reasons in the final summary. If a check runs and fails, use the baseline
   and targeted checks to distinguish pre-existing failures from regressions.
   If attribution remains unresolved, undo the affected cleanup edits while
   preserving pre-existing changes and independently verified fixes. Report
   the proposed fixes and the unresolved failure blocking verification;
   do not claim verification passed.
7. **Summarize** what you changed: a short list of applied fixes grouped by
   reviewer category and risk tier, plus any findings you deliberately skipped
   and why. Disclose if the review used inline work or later waves instead of
   the full parallel fan-out.
