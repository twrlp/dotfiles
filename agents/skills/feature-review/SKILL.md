---
name: feature-review
description: Independently review a feature spec and task plan, or its implementation, for correctness, simplicity, architectural fit, maintainability and verification quality. Use for an assigned plan or code review.
---

# Feature review

Review the assigned scope in **plan** or **code** mode. Use project guidance and actual repository evidence. Return findings without editing the reviewed artifacts or implementation, delegating, or running the development pipeline.

## Independence and inputs

- Spec/plan review must run in a fresh agent with no inherited conversation context. The caller supplies artifact paths and relevant repository references, not the author's chat history, a persuasive summary or suggested conclusions. Read the spec itself as the starting point. If you participated in authoring or inherited the planning conversation, tell the caller to launch a fresh reviewer; do not claim an independent spec review.
- Fresh means no prior conversation, not no access to source or documentation. Read the relevant requirements, architecture docs, source, tests and related active or accepted plans. Missing decisions and explanations must be discoverable from the artifacts and their references.
- For code review, use an independent reviewer, the approved artifacts, intended base branch/commit and current implementation. Inspect the assembled feature diff and relevant callers, consumers and surrounding code, not just isolated changed lines.

## Shared criteria

- **Correctness and completeness:** Intended behavior, acceptance scenarios, scope coverage, relevant edge cases, failure handling and regressions.
- **Architecture and integration:** Coherent responsibilities, interfaces, dependency direction, state ownership and compatibility with the existing system and relevant accepted work. Question existing patterns when copying them would perpetuate a concrete problem.
- **Simplicity and maintainability:** Unnecessary state, indirection, coupling, dependencies and duplication; clarity of control/data flow and ease of changing or testing the result.
- **Appropriate generalization:** Prefer existing mechanisms or a small shared abstraction when concrete uses or consistency needs justify it. Apply KISS and YAGNI: hypothetical flexibility is insufficient, and small duplication alone does not justify a framework. State the actual benefit and cost of a proposed abstraction.
- **Verification and documentation:** Meaningful acceptance checks, relevant test coverage, platform-appropriate UX validation and accurate project knowledge. Evaluate security, privacy, accessibility, performance, migration and rollout where relevant to the change.

## Plan mode

- Briefly restate the intended behavior and implementation approach from the artifacts to expose misunderstandings. Check that a fresh implementer could proceed without the author's conversation, while retaining freedom over routine coding decisions.
- Verify concrete integration points and architectural decisions against the repository. Surface contradictions, unsupported assumptions and missing decisions; do not invent new requirements or demand implementation-level detail without a reason.
- Check task scope and granularity, prerequisite validity and cycles, acceptance coverage, working commit boundaries, integration tasks, documentation, and shared-file conflicts in proposed parallel work. Tests should accompany behavior changes. Check that all intended behavior has an implementation and verification path.

## Code mode

- Trace requirements and scenarios to actual behavior and relevant checks. Inspect test quality and meaningful gaps; completed checkboxes or passing unrelated tests are not proof.
- Evaluate the assembled implementation against the design and existing architecture. A justified deviation may require updating the design rather than reverting code; unexplained material scope or behavior changes need resolution.
- Distinguish static inspection, checks you executed, evidence reported by others and runtime/UX behavior not verified. Code review does not replace the workflow's UX validation.

## Findings and return

- Give a concise outcome, actionable findings and verification limitations. Each finding identifies its location, evidence or triggering scenario, impact and suggested direction. Separate blocking issues, optional improvements and unresolved questions.
- Prioritize concrete defects and material architectural costs. Avoid taste-based rewrites, speculative concerns and pressure to produce criticism; no findings is valid. State uncertainty when evidence is insufficient.
- Return findings to the assigning agent, or the user for a standalone review. The original planner/implementer handles fixes and evidence-backed disagreements; the owner handles routing, re-review limits and escalation. A review outcome does not authorize implementation, merge or cleanup.
