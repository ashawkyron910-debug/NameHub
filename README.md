# NameHub scripts (protected builds)

Public files here are **packed**, not readable Lua source. The Discord bot loadstrings still use these paths on `main`.

## Edit scripts (local only)

1. Keep readable files in a **`source/`** folder (same layout as release paths):
   - `source/script.lua`
   - `source/dahood/script.lua`
   - `source/dinosim/script.lua`
   - `source/rivals/script.lua`
2. Do **not** commit `source/` (it is gitignored).
3. Push packed output:
   ```bash
   git add -f source/
   git commit -m "update: source"
   git push origin main
   ```
4. GitHub Action **Pack protected scripts** runs, replaces `script.lua` etc., and commits the protected build.

Optional: set repo secret **`NAMEHUB_PACK_KEY`** (random string). If unset, a default key is used.

## Discord updates

Pushes to `main` still notify **`#📢┃updates`** via GitHub Actions.
