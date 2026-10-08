# vpm

A package manager for [Vidar](https://github.com/saenai255/vidar-lang), written in Vidar.
Modules work like Go's (git repositories named by path, versions are git tags, a shared
module cache); the project layout works like npm's (`project.toml`, `vpm.lock`, `deps/`).

```bash
./out/vpm run build     # or: vidar build cmd/vpm -o out/src && odin build out/src -out:out/vpm
./run.sh <command>      # run from source
vidar test lib/semver   # unit tests
```

## Usage

```bash
vpm init                                  # write project.toml, add deps/ to .gitignore
vpm get github.com/user/repo              # newest tag, saved as ^X.Y.Z (no tags: "latest", the default branch)
vpm get github.com/user/repo@v1.2.3       # also ^1.2.0, ~1.2.0, >=1.0.0, latest, a branch or a commit
vpm get github.com/user/repo@none         # remove it, Go style
vpm get git@host:user/repo@^1.0.0         # any git URL; the URL is kept in the spec
vpm get mylib=file:///path/to/repo        # install under a name of your choosing
vpm install                               # install what project.toml and vpm.lock say
vpm update [module...]                    # newest versions within the ranges
vpm remove github.com/user/repo
vpm list
vpm run [script] [args...]                # scripts from project.toml, run with sh in the project root
vpm <script> [args...]                    # same, when no vpm command has that name
vpm clean [--cache]
```

Every installed module is added to `[collections]` in `vidar.toml` under its repository name
(`repo = "./deps/user/repo"`), so any package in the project imports it the same way:

```odin
import "repo:package"
```

## Example

`examples/diamond/setup.sh` turns `examples/diamond/libs/` into local git repositories, installs them
and runs the app. `widget` and `sprocket` both depend on `gadget` (`^1.0.0` and `~1.0.0`), and so does
the app; all three share one `gadget` v1.0.0.

## Files

- `project.toml`: name, version, description, author, license, scripts, and `dependencies` mapping a module to a spec.
  A spec is a version range or git ref, optionally after a source URL: `"<url>#<range>"`.
- `vpm.lock`: every installed module, with its source URL and the resolved version and commit.
  `vpm install` reuses locked commits; `vpm update` re-resolves them.
- `vidar.toml`: `[collections]` is rewritten on every install, one alias per module.
- `deps/<user>/<repo>/`: installed sources (the host is left out of the path). Every module is installed
  once, like Go: the newest version that meets every requirement on it. When none does, the version
  `project.toml` asks for wins, with a warning; without one there, `vpm` fails and names the conflict.
  Each module's own `deps/` holds symlinks to the shared copies, so its relative imports resolve as when
  it was developed and every importer shares one package (vidar treats a symlinked package as its target).
- `~/.vpm/cache/<module>@<commit>/`: shared cache of fetched commits (`VPM_CACHE` overrides it).

Requires `git` on PATH.

## Layout

| Path | |
|---|---|
| `cmd/vpm` | CLI entry point |
| `lib/vpm` | manifest and lock files, resolution, installing, commands |
| `lib/semver` | versions and ranges |
| `lib/git` | `ls-remote` and shallow fetches |
| `lib/sh` | running processes |
| `lib/errs` | the shared error type |
