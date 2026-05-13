# Tech-Stack Knowledge

The `knowledge/` directory holds CLAUDE.md files for specific tech stacks. Import one into a new project so Claude starts with the right conventions, preferred libraries, and patterns from day one — without having to re-explain them every time.

## Directory structure

```
knowledge/
├── fastapi/
│   └── CLAUDE.md
├── react/
│   └── CLAUDE.md
├── nextjs/
│   └── CLAUDE.md
└── ...
```

Each stack gets its own directory with a `CLAUDE.md` that captures everything Claude should know when working on a project using that stack.

## Using a knowledge file

Import it into your project's `CLAUDE.md` using the `@` syntax:

```markdown
# my-project/CLAUDE.md

@~/dev/mlziade-booilerplate/knowledge/fastapi/CLAUDE.md

## Project-specific notes
- API runs on port 8000
- Use the `dev` database for local development
```

The imported file is loaded at session start alongside the rest of your CLAUDE.md. You can import multiple stacks if the project uses more than one.

## What a knowledge file should contain

Keep each knowledge file focused on what Claude needs to be immediately productive with that stack. Good candidates:

- **Project structure** — where things go, naming conventions for files and directories
- **Preferred libraries** — which packages to reach for (and which to avoid)
- **Common commands** — how to run, test, build, and lint
- **Patterns** — idiomatic ways to do common things in this stack
- **Gotchas** — non-obvious behavior, footguns, or things that differ from defaults
- **Testing conventions** — framework, file location, naming, what to test

Avoid:
- Generic programming advice that applies everywhere
- Content that belongs in a skill (multi-step procedures)
- Things already obvious from the stack's own documentation

## Creating a knowledge file

1. Create a directory under `knowledge/` named after the stack.
2. Add a `CLAUDE.md` with your conventions.
3. Keep it under 200 lines. Longer files consume more context and reduce adherence.

### Example: `knowledge/fastapi/CLAUDE.md`

```markdown
# FastAPI

## Project structure
- `app/main.py` — entry point, app factory
- `app/routers/` — one file per resource (users.py, items.py)
- `app/models/` — SQLAlchemy models
- `app/schemas/` — Pydantic request/response schemas
- `app/dependencies.py` — shared FastAPI dependencies
- `tests/` — mirrors app structure

## Preferred libraries
- ORM: SQLAlchemy (async) with alembic for migrations
- Validation: Pydantic v2 (already bundled)
- Auth: python-jose for JWT, passlib for password hashing
- Testing: pytest + httpx (AsyncClient)
- Env: python-dotenv + pydantic-settings

## Commands
- Run: `uvicorn app.main:app --reload`
- Test: `pytest -v`
- Migrate: `alembic upgrade head`
- New migration: `alembic revision --autogenerate -m "description"`

## Patterns
- Use dependency injection for DB sessions and auth
- Return Pydantic schemas from endpoints, never raw ORM objects
- Prefix all routers: `router = APIRouter(prefix="/users", tags=["users"])`
- Async endpoints by default: `async def`

## Gotchas
- Pydantic v2 uses `model_validate` not `parse_obj`
- SQLAlchemy async requires `AsyncSession` and `await session.execute()`
- `response_model` on the endpoint strips extra fields from the response
```

## Tips

- Version your knowledge files alongside your preferences — they'll evolve as your conventions do.
- If a convention is project-specific (a particular team's standards), put it in the project's own CLAUDE.md instead of here.
- Use path-scoped rules (`.claude/rules/`) when you want instructions to load only for certain file types within a project, rather than always.
