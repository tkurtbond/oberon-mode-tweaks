# oberon-mode-tweaks

`oberon-defun.el` adds better procedure handling to the Emacs `oberon-mode` package
(MELPA `oberon`, version 20120715.909). It improves defun motion and adds a procedure
index. Both handle indented, nested and type-bound procedures. The package itself is not
modified; everything is done from user code through hooks and key remaps.

## Features

- **C-M-a** (`beginning-of-defun`): moves back to the previous `PROCEDURE` heading, even
  when it is indented or nested. Before the first procedure it goes to the `MODULE` line.
- **C-M-e** (`end-of-defun`): moves to the end of the right block by matching `END Name`.
  - On a heading line: the end of that procedure.
  - Otherwise: the end of the next procedure inside the current block, or the end of the
    block that encloses point.
  - From inside a nested procedure, it no longer stops at the enclosing procedure's
    `BEGIN`.
  - On the `MODULE` line or in the module's declarations, it no longer fails with
    "No matching END".
- **C-M-h** (`mark-defun`) and **C-x n d** (`narrow-to-defun`): act on the same block
  that C-M-e picks.
- **imenu** (`M-x imenu`, and the **Oberon → Index** submenu): lists every procedure,
  including nested ones, in file order.
  - Nested procedures get qualified names such as `f1.f2`.
  - Type-bound procedures include their receiver, such as `(VAR r: R1) Print`.
  - Exported procedures keep their `*` export mark.

Comments (including nested `(* … *)`) and strings are skipped when looking for
`PROCEDURE`, `MODULE` and `END`.

## Installation

Install the `oberon` package, then load this file after it, for example:

```elisp
(with-eval-after-load "oberon"
  (load "/path/to/oberon-defun.el"))
```

Or put `oberon-defun.el` on your `load-path` and `(load "oberon-defun")`. It sets things up
in `oberon-mode-hook` and in `oberon-mode-map`. Buffers that are already in `oberon-mode`
need `M-x oberon-mode` again to pick up the hook settings.

## Limitations

- A `PROCEDURE` heading must be the first thing on its line.
- A procedure with no matching `END Name` is left out of the index.
- From a procedure's `VAR` section, C-M-e goes to the end of the first nested procedure,
  not the enclosing one.
- From the module body, C-M-a goes to the nearest heading above, not to `MODULE`.

## Files

- `oberon-defun.el`: the code.
- `Example.Mod`: a test module with records, type-bound procedures, nested procedures and
  a module body. It is written for the Peaseblossom Oberon Compiler (`poc`); Vishap Oberon
  (`voc`) rejects some of its extensions.
- `init.el`: sample Oberon settings (file associations, indentation, font-lock).
- `AGENTS.md`, `HANDOFF.md`: development notes and test results.
