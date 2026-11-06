---
name: feature-planning
description: Collaborate on a feature spec and a dependency-ordered, commit-sized task plan ready for independent review and implementation.
---

# Feature planning

Use this skill only when the user explicitly requests it. Ordinary planning requests and references from other skills do not invoke it.

- Plan in the main checkout. Investigate relevant source, tests, project guidance, architecture docs, existing requirements and related active or accepted plans. Distinguish implemented behavior, accepted proposals and speculative ideas.
- Discuss the problem, scope, non-goals, acceptance scenarios and relevant failure cases. Ask about material ambiguity; recommend approaches with tradeoffs. Record confirmed decisions, assumptions and unresolved questions separately. Stay conversational until asked to capture the plan; do not implement during planning.
- Explain concrete implementation details: affected components and likely files, interfaces, data flow, responsibility boundaries, dependency direction and integration with existing architecture. Cover applicable compatibility, migration and rollout concerns, and important alternatives with rationale.
- Prefer the simplest approach that meets the requirements. Reuse existing mechanisms where appropriate; justify generalization with concrete needs rather than hypothetical future flexibility.
- Store each feature in `docs/features/<feature-slug>/` relative to the repository root, using a stable descriptive kebab-case slug. `plan.md` contains the feature requirements, acceptance scenarios, design and relevant references; `tasks.md` contains the executable task checklist. The owner adds `progress.md` during execution. Use these canonical paths in handoffs. Do not create a second competing feature plan in OpenSpec or another folder, or install/initialize a planning framework implicitly. Scale detail to complexity; avoid duplicated requirements and exhaustive mechanical instructions.

## Executable task plan

Produce a Markdown checklist with stable task IDs. Each task is a coherent, reviewable commit-sized increment, not a file-sized chore or an entire feature. Include:

- ID, title and completion checkbox.
- Explicit prerequisite task IDs, or `none`.
- Intended change and bounded scope, including relevant components and likely files.
- Observable acceptance criteria and relevant verification.
- Intended commit purpose; leave completion evidence and commit hashes for execution.

Include relevant tests and wiring with their implementation task so commits build and pass applicable checks. Cover integration work and documentation updates. Identify independently executable work where useful, accounting for shared-file conflicts; a task does not imply a separate agent or worktree. Dependencies must reference existing IDs and form an acyclic graph. Distinguish prerequisites from a merely preferred ordering.

Example task shape; adapt numbering to existing project conventions:

```markdown
### T03 — Persist appearance preference
- [ ] Complete
- Depends on: T01, T02
- Change/scope: Persist and restore selection through the existing settings service; include related tests.
- Acceptance: Selection survives restart; an unset preference follows the system.
- Verify: Settings tests and an application restart.
- Commit intent: Persist appearance preference.
```

## Review and handoff

- Make the spec self-contained for a new implementer: explain decisions and link relevant repository context rather than relying on chat history. Do discovery during planning; leave only specific, bounded investigations for genuinely unresolved questions.
- Obtain independent plan review using `feature-review` in plan mode. Launch a fresh Herdr `reviewer` with no inherited conversation, author summary or suggested conclusions; supply the spec/task paths and relevant repository references. Follow global Herdr launch instructions. If assigned only a drafting role, return the artifacts to the owner to arrange that review.
- Address findings in the original planning conversation; explain evidence-backed disagreements. Resolve blocking product and architecture decisions before declaring the plan ready. Material revisions require review of the affected plan.
- Handoff includes artifact paths, dependency-ordered tasks, review outcome, remaining nonblocking assumptions and the intended execution base. Reviewer acceptance is not user authorization to implement. Execution belongs to `development-workflow` when the user authorizes it.
