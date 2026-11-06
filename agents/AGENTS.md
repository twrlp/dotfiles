# Development

- Use Herdr for delegated coding agents. Before delegating, read `hc --skill`, run `hc templates`, and use the appropriate named template.
- Use the global `development-workflow` skill to implement an approved feature spec or when the user requests that workflow. Ordinary small changes do not automatically require the pipeline or independent review.
- Use `feature-planning` only when the user explicitly requests that skill; ordinary planning does not invoke it. Use `feature-review` for assigned plan or code reviews.
- Plan in the main checkout; execute feature workflows in a feature worktree. Follow project instructions for project-specific details.
