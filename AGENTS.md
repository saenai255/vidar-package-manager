# AGENTS.md

vpm is a package manager for [Vidar](https://github.com/saenai255/vidar-lang), written in Vidar.

## Language

Vidar syntax is Odin plus the additions documented in
[SYNTAX.md](https://github.com/saenai255/vidar-lang/blob/main/SYNTAX.md). Read it before writing or editing `.vidar` files.

## Commands

```bash
vidar build cmd/vpm -o out/src && odin build out/src -out:out/vpm   # build
vidar test lib/semver && vidar test lib/toml                        # test
```

## Layout

See the Layout table in [README.md](README.md).
