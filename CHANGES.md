## Greek Snippet Overhaul

- Introduced double-letter triggers for Greek symbols (e.g. `aa` → `\alpha`, `AA` → `\Alpha`) and exposed `latex_command_overrides` via `lua/luasnip-latex-snippets/math_rA_no_backslash.lua` for reuse.
- Added case-insensitive handling for those triggers, including the variant symbols (`ve`, `vf`, `vr`, `vt`) and ensured the postfix completions consult the override table before emitting commands.
- Updated the accent snippets in `lua/luasnip-latex-snippets/math_iA.lua` so they accept either the double-letter triggers or the resulting LaTeX commands (e.g. `aa` → `\alpha `, then `dot` → `\dot{\alpha}`) without requiring intermediate whitespace.
- Adjusted the backslash guard to allow recognised Greek commands to chain into accent snippets while still blocking unrelated backslashed text.
- Normalised accent regs to tolerate optional leading backslashes and spaces, preventing outputs like `\\dot{\gamma}`.
- Added `cal`/`bf` postfix snippets that wrap either plain Latin characters (`Dcal` → `\mathcal{D}`) or previously expanded Greeks (`\alphabf` → `\mathbf{\alpha}`) using the shared command lookup.
- Introduced an autosnippet for `(` that expands to `(${1:${TM_SELECTED_TEXT}})$0`, enabling nested bracket navigation that exits to the outer context on the final `<Tab>` press while suppressing triggers after escaped sequences such as `\(`.

### Developer Convenience

- Added a suggested `:ReloadSnips` helper (see conversation) that unregisters cached modules, reruns setup, and replays `FileType` autocommands so snippet edits can be reloaded without restarting Neovim.
