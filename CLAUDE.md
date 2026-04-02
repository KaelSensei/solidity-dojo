# Project Instructions

## Project Philosophy

- Prefer **simple solutions over clever ones**
- Avoid over-engineering
- If something can be done locally, **do it locally** (when appropriate)
- Always consider **offline-first** behavior when applicable
- Projects should be **useful**, **maintainable**, and **easy to understand**
- Keep it simple. Keep it working.

## Coding Style

- Prefer readable code over short code
- Explicit > implicit
- Avoid magic abstractions
- Comment only when useful
- Use modern language features and best practices
- Follow consistent formatting and style patterns across all files
- When the language supports it, use strong typing (TypeScript strict, Python type hints, Go, Rust, etc.)

## Security Rules

- Never introduce hidden logic, obfuscated code, or unnecessary indirection
- Avoid dynamic code execution (`eval`, `Function`, dynamic imports, unsafe reflection)
- Avoid uncontrolled access to the filesystem or device APIs
- Assume all dependencies may be compromised unless verified
- No new network calls to unknown or undocumented endpoints
- Respect project-defined allowed domains and external services
- Use secure communication protocols (HTTPS, TLS) by default
- Avoid post-install/build scripts that execute arbitrary code
- Use package lock files for reproducible builds
- Do not introduce any background tracking, analytics, or hidden telemetry
- Treat all external data (APIs, scraping) as **untrusted input** — validate and sanitize before use
- Never approve or suggest merging code that has not passed security review
- Security > convenience > performance

## Data & Persistence

- Database should be the **single source of truth** when appropriate
- Prefer simple schemas with explicit indexes for performance-critical queries
- Avoid heavy ORMs; keep queries clear and localized
- Download once, cache locally when appropriate
- Never depend on remote URLs at runtime when offline behavior is expected
- Handle common failure cases (missing fields, layout changes, HTTP errors) gracefully

## Documentation

- Update documentation automatically after every code change
- Include documentation updates in the same commit as code changes
- Update progress docs (PROGRESS.md, CHANGELOG.md) for any create/change/update/delete
- Update README.md if features, build instructions, or dependencies change
- Update USER_GUIDE.md for new user-facing features
- Use relative paths only in docs (never absolute/machine-specific paths)

## Version Management

- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `perf:`, `style:`
- Never commit to main/master directly — always use feature branches
- Branch naming: `feature/description` or `fix/description`
- Group related changes in a single commit when they're part of the same task

## Test-Driven Development (TDD)

- **Always use TDD** when implementing features, fixing bugs, or building modules
- Follow the Red-Green-Refactor cycle: write a failing test first, make it pass, then refactor
- Before coding, create a test list: enumerate the behaviors the code should have
- Write the simplest test that fails, then write the simplest code that passes
- Never write production code without a failing test driving it
- Refactor only when tests are green — never change tests and code at the same time
- Use the `tdd` skill for guidance on the workflow

## Completion Checklist

After every feature, fix, or setup, run `/done` to verify:
1. All tests pass (write new tests if missing)
2. Linter and type checker pass
3. No security issues in changed code
4. No dead code or obvious quality issues
5. Documentation updated if needed
6. Build succeeds

## Quality Standards

- Provide clear doc comments for public functions and important utility helpers
- Prefer small, testable units for complex logic
- Add or update tests when changing behavior that touches:
  - External data access
  - Database queries
  - Critical business logic
  - Security-sensitive code

## Workflow

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately — don't keep pushing
- Use subagents to keep main context window clean; offload research and parallel analysis
- One task per subagent for focused execution
- Never mark a task complete without proving it works (run tests, check logs, demonstrate correctness)
- When given a bug report: just fix it. Point at logs, errors, failing tests — then resolve them autonomously
- For non-trivial changes: pause and ask "is there a more elegant way?" — skip this for simple fixes
- After ANY correction from the user: capture the lesson so the same mistake doesn't repeat
- **Simplicity First**: make every change as simple as possible, impact minimal code
- **No Laziness**: find root causes. No temporary fixes. Senior developer standards
- **Minimal Impact**: changes should only touch what's necessary
