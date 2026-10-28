# AGENTS.md

User-side Emacs Lisp that improves the `oberon-mode` package (MELPA `oberon` 20120715.909,
installed at `~/.emacs.d/elpa/oberon-20120715.909/`). It provides defun motion (C-M-a,
C-M-e, C-M-h, C-x n d) and imenu support for nested and type-bound procedures. Read
`HANDOFF.md` for the current state, design and test results, and update it when that changes.

## Files
- `oberon-defun.el`: all the code. It hooks in via `oberon-mode-hook` and `[remap ...]` in
  `oberon-mode-map`.
- `Example.Mod`: Oberon test module. It has records with type-bound procedures, nested
  procedures, and a module body.
- `init.el`: a copy of the user's Oberon-related init settings. It does not load
  `oberon-defun.el`.
- `HANDOFF.md`: session-to-session state.

The user copies `oberon-defun.el` into the git repo with their real Emacs config and loads it
from there, so this directory is the development copy. After changing `oberon-defun.el`,
remind them to copy it over again.

## Rules
- Don't edit the installed package's `oberon.el`; all fixes go in `oberon-defun.el`.

## Oberon compiler: poc, not voc
`Example.Mod` is written for the **Peaseblossom Oberon Compiler, `poc`** (`/usr/bin/poc`,
0.10.0). It uses `poc` extensions such as `SYSTEM.CARD16`/`SYSTEM.CARD8`, `VAR`
initializers (`i: SYSTEM.CARD16 := 65535`) and `Out.Card`. Vishap Oberon (`voc`) is also
installed but rejects those lines, so don't use it to judge whether the file is valid.

Build outside this directory so `.sym`/`.ll`/`.o`/executable files don't land here:

```sh
poc -check Example.Mod                    # check only, writes nothing
cp Example.Mod "$TMP"/ && cd "$TMP" && poc -output-dir . -o Example Example.Mod && ./Example
```

Expected output: `65535`, `255`, `R1.a = 1`, `R1.a = 2`, `R2.b = 3`.

## Testing the Emacs Lisp
Use batch Emacs (30.2):

```sh
emacs -Q --batch --eval '(progn
  (add-to-list (quote load-path) (expand-file-name "~/.emacs.d/elpa/oberon-20120715.909"))
  (require (quote oberon)) (require (quote imenu))
  (load (expand-file-name "oberon-defun.el"))
  (find-file "Example.Mod") (oberon-mode)
  ...)'
```

- `-Q` has no `auto-mode-alist` entry for `.Mod`, so call `(oberon-mode)` explicitly.
  Otherwise the remapped keys aren't active, and the old C-M-a can loop forever.
- Drive commands with `(call-interactively (key-binding (kbd "C-M-e")))` so the remaps are
  exercised. Test the index with `(funcall imenu-create-index-function)`.
- Wrap batch runs in `timeout`.
- If you change `Example.Mod`, update the line numbers in `HANDOFF.md`'s results.
