# Handoff: procedure motion and imenu for oberon-mode

## Goal
In Emacs `oberon-mode` (https://github.com/emacsorphanage/oberon, package version
20120715.909, installed at `~/.emacs.d/elpa/oberon-20120715.909/`), make `C-M-a` / `C-M-e`
(beginning-of-defun / end-of-defun) and related commands work with indented and nested
`PROCEDURE`s, and make imenu list nested procedures. Do NOT edit the package source; the fix
lives in user code hooked via `oberon-mode-hook`. (The elpa directory's extra files
`oberon-pkg.el` and `oberon-autoloads.el` are just package.el boilerplate; `oberon.el` is the
real source.)

## Repository
This directory is `/home/tkb/Repos/Emacs/oberon-mode-tweaks`; it was renamed from
`oberon-mode` on 2026-10-28. It is a git repo on `main`. Since 2026-10-28 it has been
pushed to the public GitHub repo https://github.com/tkurtbond/oberon-mode-tweaks (remote
`origin`), and `main` tracks `origin/main`. The first commit, `477a205`, contains everything below. `.gitignore` excludes Emacs backups (`.~/`, `*~`,
`#*#`, `.#*`) and poc build output (`*.sym`, `*.ll`, `*.o`). Commit and push when the user asks.

## Current state: DONE and tested in batch Emacs 30.2
All code is in `oberon-defun.el` in this directory. Test file: `Example.Mod`
(module with TYPE R1 and R2 = RECORD (R1), VAR section, type-bound `Print` for each, procedure
f1 containing nested f2 and f3, module body). It is written for the Peaseblossom Oberon Compiler
(`poc`), not `voc`. The current file passes `poc -check` and runs correctly (see `AGENTS.md`).

**How the user installs it:** they copy `oberon-defun.el` into the git repo that holds
their real Emacs configuration and load it from there. This directory is the development
copy, so the `init.el` here does not (and need not) load it. After changing
`oberon-defun.el`, remind the user to copy it into their config repo again; the live copy is
otherwise out of date. Ask them where that repo is if you need it; it's not recorded here.
The latest features (Index as an Oberon submenu, C-M-a stopping at MODULE) aren't confirmed
yet in interactive Emacs; ask how they went.

## What `oberon-defun.el` provides
| Key / feature | Function | Mechanism |
|---|---|---|
| C-M-a | `my-obn-beginning-of-defun` | `beginning-of-defun-function` |
| C-M-e | `my-obn-end-of-defun` | `[remap end-of-defun]` in `oberon-mode-map` |
| C-M-h | `my-obn-mark-defun` | `[remap mark-defun]` |
| C-x n d | `my-obn-narrow-to-defun` | `[remap narrow-to-defun]` |
| other `end-of-defun` callers | `my-obn-end-of-defun-function` | `end-of-defun-function` |
| imenu (`M-x imenu`, `which-function-mode`) | `my-obn-imenu-create-index` | `imenu-create-index-function` in hook |
| Oberon → Index submenu | `my-obn--index-menu` | `:filter` menu item added with `define-key-after` to `[menu-bar oberon]` |

The remaps are installed with `with-eval-after-load "oberon"`; the rest are in
`oberon-mode-hook`.

## Design
- `my-obn-beginning-of-defun`: a line-based regexp search for `obn-module-proc-heading-re`
  (PROCEDURE or MODULE headings), backward for ARG > 0 and forward for ARG < 0. The user
  confirmed it works (from the end of f1: f3 → f2 → f1). On 2026-10-28 it was changed from
  `obn-proc-heading-re` so it also stops at MODULE: before the first procedure, C-M-a goes to
  the start of the module. It lands in column 0, which is how Emacs's `beginning-of-defun`
  always behaves. It is not structural: from the module body it goes to the nearest heading
  above (f3), not to MODULE.
- `my-obn--blocks`: the core. It scans the buffer for `MODULE`/`PROCEDURE`/`END`, skipping
  comments and strings via `syntax-ppss`, and uses a stack to pair each heading with its
  `END Name;`/`END Name.`. For each block it returns
  `(START HEADING-END END QNAME KW-POS KIND RECEIVER EXPORTED)`:
  - START: beginning of the heading line.
  - HEADING-END: end of the line holding the name.
  - END: just after `END Name;`/`.`.
  - QNAME: qualified by the enclosing procedures, not the module, e.g. `f1.f2`.
  - KW-POS: position of the keyword.
  - KIND: `module`/`procedure`.
  - RECEIVER: e.g. `(VAR r: R)`, with whitespace collapsed, or nil.
  - EXPORTED: non-nil if the name has `*`.

  Blocks are listed in the order they END, not buffer order.

  Parsing rules: a heading must be first on its line. `PROCEDURE ^` forward declarations and
  procedure types are skipped, while receivers and `PROCEDURE*` are accepted. An `END` followed
  by a name that isn't open (e.g. `END UNTIL`) is ignored. Blocks left unclosed inside a
  closed one are dropped.
  - Gotcha already fixed: `syntax-ppss` moves point, so the loop does `(goto-char kw-end)`
    afterwards. Without that it loops forever.
- `my-obn--next-block` rule, which C-M-e, C-M-h and C-x n d share:
  1. On the heading line of the innermost block containing point: that block.
  2. Else the next procedure after point, if it is inside the innermost block (or there is no
     enclosing block).
  3. Else the innermost enclosing block (procedure or module).
- `my-obn--landing`: after the END, go to the start of the next line if only blanks follow
  (Emacs's convention).
- Why remap rather than rely on `end-of-defun-function`: Emacs's own `end-of-defun` starts
  from the nearest heading above point, which picks the wrong block with nested procedures.
  That was the original bug: stuck at f1's BEGIN, and an error on the MODULE line or in
  declarations. Emacs's `mark-defun` similarly marked f3 from f1's body.
- Index submenu: originally `imenu-add-menubar-index` (a separate top-level "Index" menu); the
  user asked for it to be a submenu of Oberon instead. `imenu-update-menubar` is hard-wired to
  `[menu-bar index]`, so the submenu is a `menu-item` with `:filter my-obn--index-menu`. The
  filter rebuilds the keymap from `my-obn-imenu-create-index` each time the menu opens, and
  each entry calls `(imenu entry)`. It is placed after a separator at the bottom of the Oberon
  menu. If there are no procedures it shows a disabled "No procedures" entry. Verified in
  `emacs -nw` under tmux: F10 → Oberon → Index lists the 5 procedures, and choosing f1 goes
  to L29.
- imenu entry name = RECEIVER + " " + QNAME + "*" if exported, sorted by buffer position.
  Only procedures are listed (not the module). The package's own
  `obn-imenu-generic-expression` only matched top-level procedures, so it is replaced.

## Verified results (batch Emacs 30.2)
Results below were run on the earlier, shorter Example.Mod (f1/f2/f3 only), unless marked
**[new]**. The **[new]** rows are on the current file: TYPE R1, R2 = RECORD (R1) (L4-10);
VAR (L12-16); `(VAR r: R1) Print` (L18-21); `(VAR r: R2) Print` (L23-27, calls
`r.Print^`); f1 (L29-41) containing f2 (L30-33) and f3 (L34-37); module body (L44-50);
"51" = end of file.

**[new]** C-M-e:

| Start | Repeated C-M-e |
|---|---|
| L1 MODULE | 51, then "No more procedures" |
| L12 VAR | 22 (end R1.Print), 28, 42 |
| L23 / L25 (R2.Print) | 28, 42, 51 |
| L42 (after f1) | 51 |

**[new]** C-M-a from end of file: 34, 30, 29, 23, 18, 1, then stays at 1.

**[new]** imenu: `(VAR r: R1) Print`, `(VAR r: R2) Print`, `f1`, `f1.f2`, `f1.f3`.

Old file (f1 at L8-20, f2 L9-12, f3 L13-16, end of file 28):
- C-M-e from the f2 heading: 13, 17, 21, 28. From f1's body (L18): 21, 28.
- C-M-a from L21: 13, 9, 8, 1. From the declarations (L2, L4) or the start of f1's heading
  line (L8): 1. `C-u -1 C-M-a` from L1: 8, then 9.
- C-M-h / C-x n d: L1 → whole module, module declarations → f1, inside f2 → f2, f1 body →
  f1, module body → module.
- `C-u -1 C-M-e` from end of buffer → end of f1.
- imenu, on other test files from the scratchpad (not kept):

  | Source | Entries |
  |---|---|
  | Three levels deep | `a a.b a.b.c a.d b` |
  | Type-bound procedure with a nested procedure | `(VAR r: R) m*`, `m.inner` |
  | Heading split across lines | `(s: S) n` |
  | `PROCEDURE q *;` | `q*` |
  | `PROCEDURE r (* c *);` | `r` (the comment is not taken for a mark) |
  | Comment containing `PROCEDURE fake ... END fake;` | not listed |
  | `PROCEDURE ^ g` | not listed |

  Comments, strings, the forward declaration, procedure types and `END UNTIL` were all
  handled correctly.

## Known limits / possible next steps
- From a procedure's own VAR section (not its heading line), C-M-e goes to the end of its
  first nested procedure, not its own end. This follows from rule 2, which is also why module
  declarations go to the end of f1. That is what the user asked for at module level.
- C-M-a from the module body (or any procedure body after nested procedures) goes to the
  nearest heading above, not the enclosing block's heading. A structural version could use
  `my-obn--blocks`, but the user liked the current backward walk.
- A procedure without a matching `END Name;` gets no C-M-e target and no imenu entry.
- Headings must start their line (`END f2; PROCEDURE f3;` on one line isn't recognised).
- The whole buffer is rescanned on each command and each imenu rescan. That's fine for
  normal module sizes.
- The batch test scripts and the extra .Mod files were in the session scratchpad and were
  not kept. To re-test, run `emacs -Q --batch` with
  `(add-to-list 'load-path (expand-file-name "~/.emacs.d/elpa/oberon-20120715.909"))`,
  `(require 'oberon)`, `(require 'imenu)`, load `oberon-defun.el`, `find-file` the .Mod file,
  then **call `(oberon-mode)` explicitly** (`-Q` has no auto-mode-alist entry for `.Mod`).
  Then drive `(call-interactively (key-binding (kbd "C-M-e")))` or
  `(funcall imenu-create-index-function)`.
