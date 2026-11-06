---
name: development-workflow
description: Implement an approved feature spec using Herdr agents, review, platform-appropriate UX validation, and documentation updates. Also use when the user explicitly requests this development pipeline for a smaller task.
---

# Development workflow

## Shared rules

- Read the assigned brief/spec and existing project instructions. All roles read these shared rules and their assigned section; workers do not run the whole pipeline.
- Use `hc --skill` for current launch, messaging and waiting mechanics; discover role templates with `hc templates`. Start agents interactively with `hc run --bg`, an explicit checkout and the first assignment in the launch task.
- Assign a role, bounded scope, relevant artifact paths and the parent's terminal address. Check `first_message.sent`; if delivery failed, inspect readiness before sending again.
- Workers report results or blockers with `hc send <parent> "<summary or artifact path>"` and remain available for follow-up. Only the feature owner delegates unless explicitly assigned otherwise.
- Wait with `hc wait`, inspect reports and actual evidence, and do not infer success from idle/done status. Surface permission requests and blockers; never bypass them to advance the workflow.
- Keep implementation in the assigned feature checkout. Workers do not merge into main, remove worktrees, push or open PRs on their own.

## Entry and handoff

- Feature planning artifacts live at `docs/features/<feature-slug>/plan.md` and `docs/features/<feature-slug>/tasks.md` relative to the repository root; runtime coordination lives in `progress.md` in the same folder. Accept these approved artifacts, task dependencies and any prior review. Use `feature-planning` only when the user explicitly requests that skill; otherwise plan normally. Also accept a plain-language task. A smaller task needs no formal spec; use this pipeline for it only when requested.
- In the main checkout, agree on scope and commit relevant approved planning files before branching so they reach the feature checkout. Preserve unrelated changes.
- Create a feature branch and Git worktree from the intended base. Open it as a Herdr space using `herdr-app do space.new` with its folder; do not edit Herdr's layout files to arrange agents.
- Launch `feature-owner` there with `hc run --bg --outlive-parent --cwd <worktree>`, passing the feature folder, explicit plan/task paths, main checkout, base branch and any prior review. Use the new space/tab IDs as `herdr.space` and `herdr.tab` labels so the owner appears in that feature space.
- Give the user the feature space and owner's terminal address as the place to continue the conversation. The main-checkout agent can return to planning other work.
- If already assigned as owner in a suitable feature worktree, continue there; do not create another owner or worktree.

## Feature owner

- Own delivery and user communication; use the named worker templates below. Read the spec, design, tasks and relevant existing architecture guidance.
- For a feature spec, obtain `feature-review` in plan mode before implementation unless the current plan already received it. Launch a fresh `reviewer` with no inherited conversation context, author summary or suggested conclusions; supply artifact paths and relevant repository references. Resolve material findings and blocking decisions first.
- Run the sequence: implementation and relevant checks → required review and fixes → applicable UX validation and fixes → documentation → completion summary. Recheck affected behavior after fixes; material implementation changes after review require review within the limit below.
- Use `implementer` for code, `reviewer` for plan/code review, `ux-validator` for user-facing journeys, and `docs-writer` for relevant documentation. Run deterministic checks directly; a test command does not need its own agent step.
- Feature-spec workflows always receive independent implementation review. For work without a feature spec, independent review happens only at the user's request.
- Allow at most two implementation review passes. Send findings back to the original implementer, then request the second pass. If issues remain or new changes still need review after that, stop and ask the user; do not silently accept them or start another loop.
- Every user-facing feature requires UX validation appropriate to its platform. Skip only when no user-facing behavior changes, and record why. Missing tools or failed validation are blockers to report, not successful skips.
- For a feature spec/plan, keep `docs/features/<feature-slug>/progress.md` concise: stage, worker addresses, review round, outstanding findings and next action. Keep implementation checkboxes and commit evidence in the task checklist; no extra state schema. Without a spec, no new planning folder is necessary solely for a progress note.
- On resume, reconcile task evidence with actual commits, checkout state and worker state before dispatching more work; reuse workers and existing work when possible. Discuss material scope/design changes with the user, update the plan (using `feature-planning` only if explicitly requested), and obtain review of affected planning decisions before continuing.
- Keep required checks passing, address validation findings, and check the final diff against the agreed scope before declaring completion.

## Task execution

- The owner assigns only incomplete tasks whose explicit prerequisites are complete. Default to sequential execution in the feature worktree; a task does not require its own agent or worktree. Parallelize only when edits and responsibilities can be separated safely.
- Pass task IDs, relevant spec/design/task paths, bounded scope, prerequisite results and expected verification. Reuse an implementer for a coherent sequence of tasks where useful.
- Aim for a coherent, checked commit per task, with relevant tests and wiring. Allow a justified split or combination and record the task-to-commit mapping rather than forcing artificial commits.
- The owner inspects results, relevant checks and commits before marking tasks complete and recording commit hashes beside them. Implementation completion is distinct from feature review and UX acceptance. Workers report evidence instead of changing shared coordination state.
- When dependencies or task boundaries need to change, update the checklist explicitly; do not silently skip prerequisites. Missing/cyclic dependencies or blocking decisions require resolution before dispatch.

## Implementer

- Implement the assigned tasks in the feature checkout, following project conventions and the approved design. Run relevant checks and commit the intended implementation changes.
- Report assigned task IDs, what changed, commit hashes, checks run, outcomes and blockers. Explain any justified task/commit split or combination. Leave task completion checkboxes and pipeline progress coordination to the owner.
- When the owner returns review or UX findings, read them, fix the issues, rerun affected checks and report back. Preserve the existing implementation and conversation.
- Ask the owner about missing decisions or scope changes. Do not delegate or perform final integration.

## Reviewer

- Read `~/.agents/skills/feature-review/SKILL.md` and use the assigned plan or code mode. Review only the assigned scope without editing the reviewed artifacts/implementation or delegating.
- Spec/plan review requires a fresh agent with no inherited conversation context. If you participated in authoring or inherited the planning conversation, request a fresh reviewer instead.
- Report the outcome, actionable findings and verification limitations using that skill; distinguish blocking findings from optional improvements.
- Report to the parent; the owner handles feedback routing and the two-pass implementation-review limit.

## UX validator

- Validate actual user-facing acceptance journeys in the project's runtime, including relevant error/empty states and usability. Read applicable project guidance and available platform skills.
- For web apps, use the installed terminal-browser skill and browser. For iOS apps, use Xcode MCP and Simulator. For other platforms, use the corresponding project environment.
- Report what was exercised, observed outcomes, evidence and actionable UX findings. Clearly identify unavailable tools or untested behavior; do not claim checks from static inspection alone.
- Send findings to the owner for the implementer to address. Do not change implementation files, delegate or merge.

## Documentation writer

- Update relevant existing docs and spec artifacts to reflect the accepted implementation; do not invent a new documentation structure.
- Keep the feature plan and task artifacts in `docs/features/<feature-slug>/` consistent with the accepted implementation. Never mark incomplete or unvalidated requirements as complete.
- Review documentation changes against the actual implementation, commit the relevant updates on the feature branch, and report the commit and any gaps to the owner.

## Completion and approval

- After implementation, required reviews, checks, UX validation and documentation, give the user a concise summary of what was built, what was validated and any limitations.
- Ask for explicit confirmation before squash merging into local `main` and removing the worktree and its checkout folder. Wait for that confirmation. Do not push or open a PR by default.
- After confirmation, integrate from the main checkout. Check its current state, preserve unrelated work, and resolve conflicts or new failures before claiming success. If main has changed materially, revalidate the integrated result.
- Squash merge the feature into local `main` and commit the result. Only after successful integration, remove the feature worktree with Git, which removes its checkout folder and worktree registration. Never force-delete uncommitted work; leave branch deletion to a separate request.
- End only workflow-owned workers after their results are accepted. Move your terminal out of the feature checkout before removing it. Report the merge commit and cleanup outcome.
