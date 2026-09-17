---
name: pr-description
description: "Inspect a Git diff and surrounding code to write or refresh a pull request description in an unstaged pull_request.md file. Use when asked to draft a PR description or summarize changes for a PR; not for code cleanup, a correctness review, or a commit message."
---

# PR Description

Write the pull request description in `pull_request.md` at the repository root.
Leave your changes to this file unstaged. This skill covers writing the
description; it does not include changing the implementation, committing
changes, or publishing the pull request.

## Understand the changes

Start by determining which changes the user would like you to describe. These
may be staged changes, a particular commit, specific files, or a branch compared
with the intended target branch. For branch comparisons, use the merge base. If
the target branch is unclear, check the repository and conversation for that
context before asking the user.

If the user has not specified which changes to describe, review the combined
staged and unstaged changes against HEAD, along with any relevant untracked
files created for the current task. You can read untracked files without staging
them. If there are no local changes, compare the branch with its established
target branch. If you cannot identify a meaningful diff, explain that there are
no changes available to describe. When the user has specified a scope, stay
within it even if it is empty or unclear. Exclude `pull_request.md` itself from
the description.

Read the repository instructions, Git status, and the complete diff. A large
diff may need to be read in several parts so that changes are not lost to
truncated output or a file summary. Read the surrounding code, callers, tests,
configuration, and relevant history to understand how the behavior has changed.
The code you read should match the changes you are describing: use the index for
staged changes, the relevant commit for committed changes, and the working tree
for local changes.

Consider why the change is needed. For a new feature, this may be a capability
that is currently missing; for maintenance work, it may be a specific cost to
developers or operators. Explain which conclusions follow from the available
evidence and which are inferred. If the motivation is still unclear, ask the
user while continuing to inspect the code.

Use any issue, design document, or discussion context provided by the user. If
the changes do not appear to solve the stated problem, explain the discrepancy
rather than claiming that the problem is solved or changing the code yourself.

## Establish testing evidence

Look for command output, test results, CI results, or specific manual checks
from the current task. Recall that a test may exist without having been run, and
a passing test suite may not have executed the changed lines. Where practical,
run relevant existing checks or a minimal reproduction that exercises the
changed behavior. When in doubt, ask the user about manual testing.

## Write the description

Use the level-three headings below as written and in the order shown. Always
include Problem, Solution, and Testing Done. Generally you should also include
Evaluation and Implementation, unless they would add no useful information.
Include the remaining sections when they apply. Omit unused sections rather than
leaving empty headings, template instructions, or placeholders such as "N/A."

The amount of detail should reflect the size and complexity of the change.
Provide a clear explanation of why the change matters, using lists when they
help the reader follow a sequence of events, reproduction steps, or test
results. A file-by-file account of the diff is usually less useful. Describe the
final approach without recounting the conversation used to draft it.

### Background

Provide a clear description of the high-level effort with which this pull
request is associated. Recall that while anyone in the organization can see this
pull request, not everyone necessarily has the same context as you. If
applicable, link to supplied or verified design documents or high-level tracking
epics here.

### Problem

Provide a clear description of the high-level problem you are trying to solve.
The problem statement should be written in terms of a specific symptom that
affects users or the business. The problem statement should not be written in
terms of the solution. If possible, include a [minimal reproducible
example](https://en.wikipedia.org/wiki/Minimal_reproducible_example) (MRE) with
steps to reproduce, expected results, and actual results. Do not claim an
inferred reproduction was executed.

### Evaluation

If the cause of the problem is not obvious, provide a [root-cause
analysis](https://en.wikipedia.org/wiki/Root_cause_analysis) (RCA) grounded in
inspected code and available evidence, ideally using the principles behind the
[Five Whys](https://en.wikipedia.org/wiki/Five_whys) iterative interrogative
technique or some other form of analytical reasoning.

### Solution

Provide a clear description of the high-level solution you have chosen and the
resulting behavior. If there were other possible solutions that you considered
and rejected, mention those along with the corresponding reasoning, when that
context is known. Do not describe implementation details when writing about the
solution; these should go into the implementation section instead.

### Implementation

Describe the implementation details of the solution, including significant code
or configuration changes. Generally the reasoning behind any non-obvious code
should be recorded in code comments. However, code comments should always
describe the current state of the code; in contrast, this section may be useful
to describe the relationship between the original code and the code being
proposed in this pull request.

### Testing Done

Provide a clear description of how this change was tested, including the
commands or procedures used and the observed results established above. Aim for
proof that a computer has executed the changed lines. If that evidence is
unavailable, explicitly state the verification gap. For non-executable changes,
explain why execution is inapplicable and report the checks actually performed.
Ideally this should include an automated test or an explanation as to why this
pull request has no tests. If the reason is unknown, say so. If no checks ran,
say so and explain the limitation. Keep recommended future checks clearly
separate from completed testing.

### Notes to Reviewers

Provide any extra information a reviewer may need to know before evaluating your
pull request. For example, you may wish to describe which files should be
reviewed first or which files are auto-generated. If the review tool cannot
detect a file move, you may wish to link to a patch comparing the old file and
the new file. Include any unresolved concern affecting evaluation of the change.

### Deployment Plan

Describe how the code in this pull request will be deployed. Some deployments
are complicated and may require flag days between multiple repositories or the
provisioning of new infrastructure. Include any relevant ordering, migrations,
rollout controls, or rollback constraints. Describing your deployment plan
allows reviewers to ensure that your work will not cause any unnecessary
interruption to end users. Describe the known plan; do not invent one for
routine changes.

### Future Work

Provide a description of any possible follow-up work that is explicitly not
being done in this pull request. Do not turn speculative improvements into
commitments.

### Bonus

Provide a description of any extra problems you have solved in this pull
request.

## Save and Verify

Save the description to `pull_request.md` at the repository root. Leave this
file unstaged without running `git add`, changing ignore rules, or modifying the
index.

Read the saved description and check that it includes the required headings and
that its claims and testing evidence agree with the changes being described.
Check Git status to confirm that your changes to the description are unstaged.
Provide a link to the file and mention any significant uncertainty or gaps in
testing.
