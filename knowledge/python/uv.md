# Python

## Package manager

Always use **uv**. Never use pip, pip-tools, poetry, or conda directly.

**uv** is a Rust-based Python package and project manager from [Astral](https://astral.sh). It replaces pip, pip-tools, virtualenv, and pyenv in a single tool — 10–100x faster than pip, with a built-in lockfile, Python version management, and Docker-friendly workflows.

**Documentation**
- [Overview](https://docs.astral.sh/uv/)
- [Managing projects](https://docs.astral.sh/uv/guides/projects/)
- [Managing dependencies](https://docs.astral.sh/uv/concepts/projects/dependencies/)
- [Docker integration](https://docs.astral.sh/uv/guides/integration/docker/)
- [Python version management](https://docs.astral.sh/uv/concepts/python-versions/)

## Project setup

```bash
uv init my-project
cd my-project
uv run main.py   # runs inside the managed venv automatically
```

## Managing dependencies

```bash
# Add a runtime dependency
uv add requests
uv add 'requests==2.31.0'   # pin version

# Add a dev-only dependency (not published, not in production installs)
uv add --dev pytest ruff

# Add to a custom group
uv add --group lint ruff mypy

# Remove a dependency
uv remove requests
uv remove --dev pytest

# Upgrade a specific package
uv lock --upgrade-package requests

# Sync the environment to match the lockfile exactly
uv sync
```

## The lockfile

`uv.lock` is the source of truth for reproducible installs. Always commit it.

- `pyproject.toml` — declares broad requirements (what you manage)
- `uv.lock` — exact pinned versions for every dependency (what uv manages, do not edit manually)

Never modify `uv.lock` by hand. Every `uv add` / `uv remove` / `uv sync` keeps it up to date automatically.

## Running commands

`uv run` verifies the lockfile and environment are in sync before every invocation — no need to manually activate the venv.

```bash
uv run main.py
uv run pytest
uv run -- uvicorn app.main:app --reload
```

## Docker

Use the official uv image to copy the binary, then use `--locked` to install exactly what's in `uv.lock`.

```dockerfile
FROM python:3.12-slim

# Copy uv binary from the official image — pin the version for reproducibility
COPY --from=ghcr.io/astral-sh/uv:0.6.14 /uv /uvx /bin/

WORKDIR /app

# Install dependencies first (separate layer for Docker cache efficiency)
# Bind-mount the lockfile and pyproject.toml so they don't need to be COPY'd yet
RUN --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev

# Now copy source and do the full install
COPY . .
RUN uv sync --locked --no-dev

CMD ["uv", "run", "main.py"]
```

Key flags:
- `--locked` — fail if `uv.lock` is not up to date with `pyproject.toml` (enforces the frozen file)
- `--no-dev` — exclude dev dependencies from production images
- `--no-install-project` — install only dependencies in the first layer, deferring the project itself; keeps the dependency layer cacheable

Add `.venv` to `.dockerignore` to prevent the local virtual environment from being copied into the image.

## Python version

Pin the Python version per project:

```bash
uv python pin 3.12
```

This creates a `.python-version` file that must be committed.