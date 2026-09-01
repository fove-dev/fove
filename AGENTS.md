# Project

Fove is a reactive UI framework for Luau.

The project is currently in early development.

Fove prioritizes:
- simplicity
- predictable behavior
- strong typing
- fine-grained reactivity
- minimal runtime overhead
- first-class Roblox and UI Labs support

## Development principles

- Keep the public API simple and predictable.
- Prefer complexity inside Fove over complexity in user code.
- Avoid global side effects.
- Avoid unnecessary allocations and reactive executions.
- Keep the reactive core independent from Roblox-specific APIs.
- Keep lifecycle and cleanup deterministic.
- Do not introduce new APIs, abstractions, or features unless required by the task.
- New behavior should be covered by tests.

## Code style

- Use Luau strict typing.
- Use camelCase for local variables and functions.
- Use PascalCase for exported types.
- Use UPPER_SNAKE_CASE for true constants.
- Prefer guard clauses over deeply nested conditions.
- Avoid unnecessary `else` branches.
- Preserve intentional vertical spacing.
- Do not aggressively reformat existing code.
- Follow the style of the surrounding code.

## Structure

- `src/core/` — reactive runtime
- `src/roblox/` — Roblox integration and rendering
- `tests/` — automated tests

## Workflow

Before changing code:

1. Understand the existing implementation.
2. Keep changes small and focused.
3. Avoid unrelated refactors.
4. Preserve existing behavior unless the task requires changing it.
5. Add or update tests when behavior changes.

## Commits

Use Conventional Commits:

- `feat`
- `fix`
- `refactor`
- `perf`
- `test`
- `docs`
- `chore`
- `build`
- `ci`

Example:

`feat(core): add signal primitive`