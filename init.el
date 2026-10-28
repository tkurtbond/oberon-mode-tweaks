

(add-to-list 'auto-mode-alist '("\\.def$" . oberon-mode))
(add-to-list 'auto-mode-alist '("\\.obn$" . oberon-mode))
(add-to-list 'auto-mode-alist '("\\.Mod$" . oberon-mode))
(add-to-list 'auto-mode-alist '("\\.m$"   . oberon-mode))
(eval-after-load "oberon" '(setq oberon-indent-level 2))
(add-hook 'oberon-mode-hook (lambda () (font-lock-mode 1)))


