;; The oberon mode package is in melpa.
(use-package oberon)

(add-to-list 'auto-mode-alist '("\\.def$" . oberon-mode))
(add-to-list 'auto-mode-alist '("\\.obn$" . oberon-mode))
(add-to-list 'auto-mode-alist '("\\.Mod$" . oberon-mode)) ; This leaves .mod for Modula-2.
(add-to-list 'auto-mode-alist '("\\.m$"   . oberon-mode))
(eval-after-load "oberon" '(setq oberon-indent-level 2))
(add-hook 'oberon-mode-hook (lambda () (font-lock-mode 1)))

;; Remember to edit the following line to where you put oberon-defun.el.
(load-file "oberon-defun.el")
