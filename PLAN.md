# Workspace Plan

This repository is a personal experiment workspace.
Each request gets its own folder (treated as a mini-repo) and a dedicated feature branch for review and merge.

---

## Workflow

### 1. New Request → New Folder
- For every new task or experiment, create a new folder at the repo root.
- The folder name should be short and descriptive (e.g. `sre-utils`, `k8s-scripts`, `alerts-config`).
- Keep a `README.md` inside each folder explaining what it contains.

### 2. Feature Branch per Folder/Request
- Always create a feature branch before starting work:
  ```
  git checkout -b feature/<folder-name>
  ```
- All work for that request lives on the feature branch.
- Open a Pull Request for review and merge back to `main`.

### 3. Folder as a Mini-Repo
- Each folder is self-contained: it has its own `README.md`, scripts, configs, and docs.
- No cross-folder imports or dependencies unless explicitly documented.
- Folders do **not** have separate remote origins — they all live in this single remote.

---

## Folder Registry

| Folder | Description | Status |
|--------|-------------|--------|
| `sre-utils` | Utility scripts helpful for Site Reliability Engineering | ✅ Active |

---

## Naming Conventions

| Thing | Convention | Example |
|-------|-----------|---------|
| Folder | `kebab-case` | `sre-utils` |
| Branch | `feature/<folder>` | `feature/sre-utils` |
| Scripts | `snake_case.sh` or `snake_case.py` | `disk_check.sh` |

---

## Adding a New Request

1. Create folder: `mkdir <name>`
2. Add `<name>/README.md`
3. Create branch: `git checkout -b feature/<name>`
4. Do the work, commit, push, open PR.
5. After merge, add a row to the **Folder Registry** table above.
