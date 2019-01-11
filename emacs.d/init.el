;; -*- lexical-binding: t -*-

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

(defun jl/reset-gc-threshold ()
  "Reset `gc-cons-threshold' to its default value."
  (setq gc-cons-threshold 800000))

;; reset frequency of garbage collection once emacs has booted
(add-hook 'emacs-startup-hook #'jl/reset-gc-threshold)


(defvar *is-mac* (eq system-type 'darwin))
(defvar *is-win* (eq system-type 'windows-nt))


;;;;; put early, avoid annoying resizes during startup

;; the toolbar is just a waste of valuable screen estate
;; in a tvty tool-bar-mode does not properly auto-load, and is
;; already disabled anyway
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))

(when window-system
  (scroll-bar-mode -1))

;; try the following for unicode characters
;; (setq inhibit-compacting-font-caches t)

;; Default font
(cond (*is-win* (set-face-attribute 'default nil :family "Consolas" :height 110))
      (*is-mac* (set-face-attribute 'default nil :family "Menlo" :height 140))
)




(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-appearance . light))
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))






;; TRY: check if this prevents freezing during command evaluation
(defun jl/minibuffer-setup-hook ()
  (setq gc-cons-threshold most-positive-fixnum))

(defun jl/minibuffer-exit-hook ()
  (setq gc-cons-threshold 800000))

;;(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
;;(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
;; keep the installed packages in .emacs.d
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
(package-initialize)
;; update the package metadata is the local cache is missing
(unless package-archive-contents
  (package-refresh-contents))

(defconst jonatan-savefile-dir (expand-file-name "savefile" user-emacs-directory))
(defconst jonatan-personal-dir (expand-file-name "personal" user-emacs-directory))

;; create the savefile dir if it doesn't exist
(unless (file-exists-p jonatan-savefile-dir)
  (make-directory jonatan-savefile-dir))

;; create the savefile dir if it doesn't exist
(unless (file-exists-p jonatan-personal-dir)
  (make-directory jonatan-personal-dir))

;; config changes made through the customize UI will be store here
(setq custom-file (expand-file-name "custom.el" jonatan-personal-dir))

;; load the personal settings (this includes `custom-file')
(when (file-exists-p jonatan-personal-dir)
  (message "Loading personal configuration files in %s..." jonatan-personal-dir)
  (mapc 'load (directory-files jonatan-personal-dir 't "^[^#].*el$")))

;; (load custom-file)


(when *is-win*
  (setq w32-pass-lwindow-to-system nil
       w32-pass-rwindow-to-system nil
       w32-lwindow-modifier 'super ;; Left Windows key
       w32-rwindow-modifier 'super ;; Right Windows key
       w32-apps-modifier 'hyper) ;; Menu key
  )





;; Windows explorer to go to the file in the current buffer
;; either use subst-char-in-string to get backslash, or define
;; (defun w32-shell-dos-semantics() t)
(defun jl/open-folder-in-explorer ()
  "Open windows explorer in the current directory and select the current file."
  (interactive)
  (w32-shell-execute
    "open" "explorer"
    (concat "/e,/select," (subst-char-in-string ?/ ?\\ (convert-standard-filename buffer-file-name)))
  )
)

;; Always load newest byte code
(setq load-prefer-newer t)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

;; the blinking cursor is nothing, but an annoyance
(blink-cursor-mode -1)

;; disable the annoying bell ring
(setq ring-bell-function 'ignore)

;; disable startup screen
(setq inhibit-startup-screen t)

;; Time-stamp: <> in the first 8 lines?
(add-hook 'before-save-hook 'time-stamp)

;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; mode line settings
(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

;; enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)

;; show trailing whitespace in editor
(setq-default show-trailing-whitespace t)
(setq-default show-tabs)

;; more useful frame title, that show either a file or a
;; buffer name (if the buffer isn't visiting a file)
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

;; Emacs modes typically provide a standard means to change the
;; indentation width -- eg. c-basic-offset: use that to adjust your
;; personal indentation width, while maintaining the style (and
;; meaning) of any files you load.
(setq-default indent-tabs-mode nil)   ;; don't use tabs to indent
(setq-default tab-width 2)            ;; but maintain correct appearance

;; Newline at end of file
(setq require-final-newline t)

;; delete the selection with a keypress
;; (delete-selection-mode t)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)


;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

(global-auto-revert-mode 1)


(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(setq use-package-verbose t)

;; This is only needed once, near the top of the file
(eval-when-compile
  (require 'use-package))

(use-package diminish                ;; if you use :diminish
  :ensure t)

(use-package bind-key                ;; if you use any :bind variant
  :ensure t)

(use-package paradox
  :disabled
  :ensure t
  :config  (paradox-enable)
)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :ensure t
  ;; make it faster (assuming all envs in .zshenv)
  :custom (exec-path-from-shell-arguments '("-l" "-d"))
  :config
  (exec-path-from-shell-copy-envs '("LC_ALL" "PYTHONPATH"))
  (exec-path-from-shell-initialize)
  )


(use-package color-theme-sanityinc-tomorrow
  :ensure t
  :init
  (if window-system
      (load-theme 'sanityinc-tomorrow-day)
    (load-theme 'sanityinc-tomorrow-night)
    ))

(use-package smart-mode-line
  :ensure t
  :custom
  (sml/vc-mode-show-backend t)
  (sml/theme 'respectful)
  (sml/name-width 30)
  )

(use-package paren
  :config
  (show-paren-mode +1))

(use-package smartparens
  :ensure t
  :hook ((lisp-mode emacs-lisp-mode) . smartparens-strict-mode)
  :custom
  (sp-base-key-bindings 'paredit)
  (sp-autoskip-closing-pair 'always)
  (sp-hybrid-kill-entire-symbol nil)
  (sp-show-pair-delay 0)
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  (sp-use-paredit-bindings)
  (show-smartparens-global-mode +1)
  :diminish (smartparens-mode .  "()"))

(use-package abbrev
  :init
  (setq save-abbrevs 'silently
        abbrev-mode t)
  :config
  (if (file-exists-p abbrev-file-name)
      (quietly-read-abbrev-file)))


(use-package uniquify
  :custom
  (uniquify-separator "/")
  (uniquify-buffer-name-style 'forward)
  ;; rename after killing uniquified
  (uniquify-after-kill-buffer-p t)
  ;; don't muck with special buffers
  (uniquify-ignore-buffers-re "^\\*")
  )


;; saveplace remembers your location in a file when saving files
(require 'saveplace)
(use-package saveplace
  :ensure t
  :custom
  (save-place-file (expand-file-name "saveplace" jonatan-savefile-dir))
  ;; activate it for all buffers
  (save-place t)
  )

(use-package savehist
  :config
  (setq savehist-additional-variables
        ;; search entries
        '(search-ring regexp-search-ring)
        ;; save every minute
        savehist-autosave-interval 60
        ;; keep the home clean
        savehist-file (expand-file-name "savehist" jonatan-savefile-dir))
  (savehist-mode +1))

(use-package recentf
  :config
  (setq recentf-save-file (expand-file-name "recentf" jonatan-savefile-dir)
        recentf-max-saved-items 500
        recentf-max-menu-items 15
        ;; disable recentf-cleanup on Emacs start, because it can cause
        ;; problems with remote files
        recentf-auto-cleanup 'never)
  (recentf-mode +1))

(use-package crux
  :ensure t
  :bind (("C-c o" . crux-open-with)
         ("C-c n" . crux-cleanup-buffer-or-region)
         ("C-c f" . crux-recentf-find-file)
         ("C-M-z" . crux-indent-defun)
         ("C-c u" . crux-view-url)
         ("C-c e" . crux-eval-and-replace)
         ("C-c w" . crux-swap-windows)
         ("C-c D" . crux-delete-file-and-buffer)
         ("C-c R" . crux-rename-buffer-and-file)
         ("C-c t" . crux-visit-term-buffer)
         ("C-c k" . crux-kill-other-buffers)
         ("C-c TAB" . crux-indent-rigidly-and-copy-to-clipboard)
         ("C-c I" . crux-find-user-init-file)
         ("C-c S" . crux-find-shell-init-file)
         ("s-j" . crux-top-join-line)
         ("C-^" . crux-top-join-line)
         ("s-k" . crux-kill-whole-line)
         ("C-<backspace>" . crux-kill-line-backwards)
         ("s-o" . crux-smart-open-line-above)
         ([remap move-beginning-of-line] . crux-move-beginning-of-line)
         ([(shift return)] . crux-smart-open-line)
         ([(control shift return)] . crux-smart-open-line-above)
         ([remap kill-whole-line] . crux-kill-whole-line)
         ("C-c s" . crux-ispell-word-then-abbrev)))


(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))


(use-package anzu
  :ensure t
  :bind
  ([remap query-replace] . anzu-query-replace)
  ([remap query-replace-regexp] . anzu-query-replace-regexp)
  ("H-q" . anzu-query-replace-at-cursor-thing)
  :diminish ""
  :init
  (setq anzu-cons-mode-line-p nil)
  :config
  (global-anzu-mode))


(use-package avy
  :ensure t
  :custom
  (avy-style 'de-bruijn)
  (avy-background t)
  :bind (("H-." . avy-goto-word-or-subword-1)
         ("H-," . avy-goto-char)
         ("M-g g" . avy-goto-line)
         )
  ;; :chords (("jj" . avy-goto-line)
  ;;          ("jk" . avy-goto-word)

  )


;; needed to tweak the matching algorithm used by ivy
(use-package flx
  :ensure t)

(use-package smex
  :ensure t
  :init
  (setq-default smex-history-length 32
                smex-save-file (expand-file-name "smex-items" jonatan-savefile-dir)))


;; use flx matching instead of the default
  ;; see https://oremacs.com/2016/01/06/ivy-flx/ for details
  ;;(setq ivy-re-builders-alist
        ;;'((t . ivy--regex-fuzzy)))
  ;(setq ivy-initial-inputs-alist nil)
  ;(setq enable-recursive-minibuffers t)

(use-package ivy
  :ensure t
  :custom
  (ivy-extra-directories nil)
  (ivy-use-virtual-buffers t)
  (ivy-virtual-abbreviate 'abbreviate)
  (ivy-count-format "")
  :init
  (ivy-mode)
  :bind
  ("s-b" . ivy-switch-buffer)
  ("H-b" . ivy-switch-buffer)
  ("C-c C-r" . 'ivy-resume)
  (:map ivy-switch-buffer-map
        ("H-k" . ivy-switch-buffer-kill))
  )

(use-package ace-window
  :ensure t
  :bind
  (("s-w" . ace-window)
   ([remap other-window] . ace-window))
  )


(use-package swiper
  :ensure t
  :custom
  (swiper-action-recenter t)
  )

(use-package counsel
  :ensure t
  :custom
  (counsel-find-file-at-point t)
  (counsel-grep-base-command
   "rg -i -M 120 --no-heading --line-number --color never %s %s")
  (counsel-grep-swiper-limit 30000)
  :init
  (w32-register-hot-key [s-r])
  :bind
  (("M-x" . counsel-M-x)
   ("C-x C-f" . counsel-find-file)
   ("<f1> f" . counsel-describe-function)
   ("<f1> v" . counsel-describe-variable)
   ("<f1> l" . counsel-find-library)
   ("<f2> i" . counsel-info-lookup-symbol)
   ("<f2> u" . counsel-unicode-char)
   ("C-c g" . counsel-git)
   ("C-c j" . counsel-git-grep)
   ("C-c a" . counsel-ag)
   ("C-c r" . counsel-rg)
   ("C-x l" . counsel-locate)
   ("s-r" . counsel-recentf)
   ([remap isearch-forward]  . counsel-grep-or-swiper)
   ([remap isearch-backward] . counsel-grep-or-swiper)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history))
  )


;; temporarily highlight changes from yanking, etc
(use-package volatile-highlights
  :ensure t
  :config
  (volatile-highlights-mode +1))


(use-package dired
  :custom
  ;; always delete and copy recursively
  (dired-recursive-deletes 'always)
  (dired-recursive-copies 'always)
  (dired-dwim-target t)
  :config
  ;; enable some really cool extensions like C-x C-j(dired-jump)
  (require 'dired-x))

(put 'dired-find-alternate-file 'disabled nil)

(use-package company
  :ensure t
  :diminish (company-mode . "(c)")
  :commands company-mode
  :custom (company-minimum-prefix-length 2)
  (company-global-modes '(not text-mode))
    ;; set default `company-backends'
  (company-backends
        '((company-files
           company-capf
           company-yasnippet) company-dabbrev))
  :bind
  (:map company-active-map
        ("C-e" . company-other-backend)
        ("C-n" . company-select-next-or-abort)
        ("C-p" . company-select-previous-or-abort))
  :init
  (setq company-idle-delay 0.5    ; decrease delay before
                                        ; autocompletion popup shows
        company-echo-delay 0     ; remove annoying blinking
        company-tooltip-limit 10
        company-tooltip-flip-when-above t
        company-dabbrev-downcase nil
        )
  ;; (add-hook 'after-init-hook #'global-company-mode)
  :hook ((after-init . global-company-mode)
         (prog-mode . jl/prog-mode-hook))
  )

(defun jl/prog-mode-hook ()
  (make-local-variable 'company-backends)
  (push 'company-keywords company-backends))

(use-package company-flx
  :ensure t
  :after (company)
  :config (company-flx-mode +1)
  )


;(use-package expand-region
;  :bind* ("C-," . er/expand-region))
(use-package expand-region
  :ensure t
  :bind*
  ("H-0" . er/expand-region)
  ("C-," . er/mark-word)
  )

(use-package change-inner
  :ensure t
  :bind
  ("M-i" . change-inner)
  ;("M-o" . change-outer)
  :config
  (advice-add 'change-inner* :around #'delete-region-instead-of-kill-region))



(use-package symbol-overlay
  :ensure t
  :custom
  (symbol-overlay-idle-time 1.5)
  :bind
  ("M-n" . symbol-overlay-jump-next)
  ("M-p" . symbol-overlay-jump-prev)
  :hook
  (prog-mode . symbol-overlay-mode))


;; show available keybindings after you start typing
(use-package which-key
  :ensure t
  :diminish ""
  :config (which-key-mode +1)
  )

(use-package discover-my-major
  :ensure t
  :commands (discover-my-major discover-my-mode)
  )


(use-package undo-tree
  :ensure t
  :custom
  ;; autosave the undo-tree history
  (undo-tree-auto-save-history t)
  (undo-tree-history-directory-alist
   `((".*" . ,temporary-file-directory)))
  )

(w32-register-hot-key [s-p])

(use-package projectile
  :ensure t
  :custom
  (projectile-mode-line-prefix " P")
  (projectile-completion-system 'ivy)
  (projectile-enable-caching t)
  (projectile-cache-file (expand-file-name  "projectile.cache" jonatan-savefile-dir))
  (projectile-svn-command "find . -type f -not -iwholename '*.svn/*' -print0")
  ;; on windows,
  :bind
  (:map projectile-mode-map
        ("s-p" . projectile-command-map)
        ("s-p r" . projectile-ripgrep))

  :init
  (projectile-mode +1)
  )

(use-package counsel-projectile
  :ensure t
  :after (projectile counsel)
  :config
  (counsel-projectile-mode))

(use-package flycheck
  :ensure t
  :custom
  (flycheck-checker-error-threshold 500)
  (flycheck-check-syntax-automatically '(save))
  (flycheck-mode-line-prefix "FC")
  :init (global-flycheck-mode t)
  )

(use-package flycheck-clang-tidy
  :if (executable-find "clang-tidy")
  :custom (flycheck-clang-tidy-build-path "../../_build")
  :after (flycheck)
  :ensure t
  :hook (c++-mode . flycheck-clang-tidy-setup)
)

(use-package inf-ruby
  :ensure t
  :config
  (add-to-list 'inf-ruby-implementations '("ruby" . "irb-2.3.1 --prompt default --noreadline -r irb/completion"))
  (setq inf-ruby-default-implementation "ruby")
  :hook (ruby-mode . inf-ruby-minor-mode))

(use-package ruby-mode
  :ensure t
  :init
  (add-to-list 'flycheck-disabled-checkers 'ruby-reek)
  :config
  (use-package smartparens-ruby)
  :hook (ruby-mode . subword-mode)
  :interpreter "ruby"
  :bind
  (([(meta down)] . ruby-forward-sexp)
   ([(meta up)]   . ruby-backward-sexp)
   (("C-c C-e"    . ruby-send-region)))
  )

(use-package yard-mode
  :ensure t
  :diminish yard-mode
  :after ruby-mode
  :hook ruby-mode)

(use-package robe
  :ensure t
  :after (ruby-mode inf-ruby)
  :bind (:map ruby-mode-map
              ("C-M-." . robe-jump))
  :config
  (make-local-variable 'company-backends)
  (push 'company-robe company-backends)
  (inf-ruby-console-auto)
  :hook (ruby-mode . robe-mode)
  ;; :config
  ;; (defadvice inf-ruby-console-auto
  ;;   (before activate-rvm-for-robe activate)
  ;;  (rvm-activate-corresponding-ruby))
  )


(use-package ruby-tools
  :ensure t
  :commands ruby-tools-mode
  :hook (ruby-mode . ruby-tools-mode)
  :diminish ruby-tools-mode)

(use-package markdown-mode
  :ensure t
  :custom (markdown-fontify-code-block-natively t)
    :mode (("\\.md\\'" . gfm-mode)
           ("\\.markdown\\'" . gfm-mode)))

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (setq web-mode-ac-sources-alist
        '(("css" . (ac-source-css-property))
          ("html" . (ac-source-words-in-buffer ac-source-abbrev))))

  (setq web-mode-enable-auto-closing t)
  (setq web-mode-tag-auto-close-style 2)
  (setq web-mode-enable-auto-quoting t)
  (use-package web-mode-edit-element :ensure t)
  :hook (web-mode . jl/web-mode-hook)
  )

(defun jl/web-mode-hook ()
  "Hooks for Web mode."
  (progn
    (setq web-mode-markup-indent-offset 2)
    (web-mode-edit-element-minor-mode))
  )

(use-package json-mode
  :ensure t
  :mode (("\\.json\\'" . json-mode)
         ("\\.tmpl\\'" . json-mode)
         ("\\.eslintrc\\'" . json-mode))
  :init (setq-default js-indent-level 2))


;; Show changes in fringe
(use-package diff-hl
  :ensure t
  :init
  ;; Highlight changes to the current file in the fringe
  (global-diff-hl-mode)
  ;; Highlight changed files in the fringe of Dired
  :hook (dired-mode . diff-hl-dired-mode)
  )

(use-package whitespace
  :init (setq whitespace-line-column 80))
;  :hook (asm-mode . whitespace-mode)

(require 'ansi-color)
(defun colorize-compilation-buffer ()
  "Support for ansi colors in comint buffers."
  (read-only-mode)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (read-only-mode))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(setq gud-gdb-command-name "gdb-multiarch -i=mi --annotate=1")

(defun jl/asm-mode-hook ()
  ;; you can use `comment-dwim' (M-;) for this kind of behaviour anyway

  ;;(local-unset-key (vector asm-comment-char))
  ;; asm-mode sets it locally to nil, to "stay closer to the old TAB behaviour".
  (setq tab-always-indent (default-value 'tab-always-indent)
        comment-column 40
        tab-stop-list (number-sequence 8 64 8)
        ))


(use-package asm-mode
  :mode ("\\.i\\'" "\\.s\\'")
  :init (setq comment-column 40
              asm-comment-char ?/)
  :config
  ;; Hack to get a // comment in asm-mode.
  (defadvice asm-comment (after extra-slash activate)
    (insert-char ?/))
  :hook (asm-mode . jl/asm-mode-hook))

(add-hook 'asm-mode-hook #'jl/asm-mode-hook)

;; FIX prevent bug in smartparens
;; (setq sp-escape-quotes-after-insert nil)

(use-package irony
  :ensure t
  :commands irony-mode
  :bind ((:map irony-mode-map
      ([remap completion-at-point] . counsel-irony))
         )
  :config
  (unless (or *is-win* (irony--find-server-executable))
    (call-interactively #'irony-install-server))
  (setq w32-pipe-read-delay 0)
  :hook ((irony-mode . irony-cdb-autosetup-compile-options)
         (c++-mode . irony-mode))
  )

(use-package company-irony
  :after irony
  :ensure t
  :hook (irony-mode . (lambda ()
                        (add-to-list (make-local-variable 'company-backends) 'company-irony)))
  )

(use-package irony-eldoc
  :after irony
  :ensure t
  :hook irony-mode
  )

(defun jl/c++-mode-hook ()
    "FIX prevent bug in smartparens."
    (setq-local sp-escape-quotes-after-insert nil))

(use-package c++-mode
  :after (smartparens)
  :bind
  ([remap kill-sexp] . sp-kill-hybrid-sexp)
;;  :hook (c++-mode . jl/c++-mode-hook)
  )


(use-package general
  :ensure t
)

(general-define-key
 "s-x" 'counsel-M-x
 "C-x C-m" 'counsel-M-x
 "C-w" 'backward-kill-word
 "C-x C-k" 'kill-region
 "C-x O" '(other-window-prev :which-key "previous window")
 ;; use hippie-expand instead of dabbrev
 "M-/" 'hippie-expand
 "s-/" 'hippie-expand
 ;; align code
 "C-x \\" 'align-regexp
 ;; mark-end-of-sentence is normally unassigned
 "M-p" 'mark-end-of-sentence
 )


;;; open current file in explorer/finder
(when *is-win*
      (general-define-key
       "M-o" #'jl/open-folder-in-explorer
       ))

(use-package reveal-in-osx-finder
  :ensure t
  :if *is-mac*
  :bind ("M-o" . reveal-in-osx-finder)
)




(use-package c++-mode
  :hook jl/c++-mode-hook
  )

(defun jl/c++-mode-hook (setq-local sp-escape-quotes-after-insert nil))


(use-package clang-format
  :ensure t
  :commands clang-format clang-format-buffer
  :bind (:map c++-mode-map
              ("C-c f" . clang-format-region)
              )
  )

(general-define-key
 :keymaps 'c++-mode-map
 "C-c C-o" '(ff-find-other-file :which-key "toggle header/impl file")
 )

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer)
  :init (setq ibuffer-saved-filter-groups
              '(("home"
	               ("Org" (or (mode . org-mode)
		                        (filename . "OrgMode")))
                 ("Subversion" (name . "\*svn"))
	               ("Magit" (name . "\*magit"))
   	             ("Help" (or (name . "\*Help\*")
		                         (name . "\*Apropos\*")
		                         (name . "\*info\*")))))

              ibuffer-show-empty-filter-groups t
              )
  :hook jl/ibuffer-mode-hook
  )

(defun jl/ibuffer-mode-hook ()
  (ibuffer-auto-mode 1)
	(ibuffer-switch-to-saved-filter-groups "home"))

;; show the cursor when moving after big movements in the window
(use-package beacon
  :ensure t
  :diminish beacon-mode
  :config
  (beacon-mode +1)
  )


;; edit grep-buffers, e.g., ivy-occur
(use-package wgrep
  :commands wgrep-mode
  ;:init (add-hook 'ivy-occur-grep-mode-hook (lambda ()
  ;(key-chord-define wgrep-mode-map "dd" 'wgrep-mark-deletion)))
  )

(use-package ws-butler
  :ensure t
  :custom
  (ws-butler-keep-whitespace-before-point nil)
  :config
  (ws-butler-global-mode)
)

(defun jl/recompile-elc-on-save ()
  "Recompile your elc when saving an elisp file."
  (add-hook 'after-save-hook
            (lambda ()
              (when (and
                     (string-prefix-p jonatan-personal-dir (file-truename buffer-file-name))
                     (file-exists-p (byte-compile-dest-file buffer-file-name)))
                (emacs-lisp-byte-compile)))
            nil
            t))


(defun jl/el-mode-hook ()
  (jl/recompile-elc-on-save)
  (smartparens-strict-mode +1)
  (rainbow-delimiters-mode +1)
  )

(use-package lisp-mode
:bind
  (:map emacs-lisp-mode-map
        ("C-c C-c" . eval-defun)
        ("C-c C-b" . eval-buffer))
  :hook  ((emacs-lisp-mode . jl/el-mode-hook)
          ;;((eval-expression-minibuffer-setup lisp-interaction-mode emacs-lisp-mode) . eldoc-mode)
          )
  )






(use-package yasnippet
  :ensure t
  :commands (yas-minor-mode)
  :hook (prog-mode . yas-minor-mode)
  :config (yas-reload-all)
  )


(use-package arm-lookup
  :load-path "lisp/arm-lookup"
  :custom
  (arm-lookup-txt "d:/work/trunk/armdoc/DDI0487D_a_armv8_arm.txt")
  (arm-lookup-browse-pdf-function 'arm-lookup-browse-pdf-sumatrapdf)
  :commands (arm-lookup)
                                        ;:bind (:map asm-mode-map ("M-." . arm-lookup))
  :bind (("M-." . arm-lookup))
  )

(use-package burs-mode
  :load-path "lisp/burs-mode"
  :mode ("\\.tg\\'")
  :commands (burs-mode)
  )



(unless (file-expand-wildcards (concat package-user-dir "/org-[0-9]*"))
  (package-install (elt (cdr (assoc 'org package-archive-contents)) 0)))

(use-package org
  :ensure t
  :mode ("\\.org\\'" . org-mode)
  :custom (org-export-backends '(ascii html md)))

(use-package mediawiki
  :ensure t
  :commands (mediawiki-mode)
  :init
  ;; workaround, unable to run mediawiki-open otherwise
  (setq url-user-agent "EMACS" ;
        ))

(use-package alert
  :if window-system
  :ensure t
  :commands (alert)
  :init
  (setq alert-default-style 'notifier))

(use-package slack
  :if window-system
  :commands (slack-start)
  :init
  (setq slack-prefer-current-team t)
  )

(use-package cmake-mode
  :ensure t
  :config
  (make-local-variable 'company-backends)
  (push 'company-cmake company-backends)
  :mode "CMakeLists.txt")

(use-package multiple-cursors
  :ensure t
  :bind (("C-c m c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this-symbol)
         ("C-<" . mc/mark-previous-like-this-symbol)
         ("M-C->" . mc/mark-next-like-this-word))
  )



(setq delete-by-moving-to-trash t)
(when *is-mac* (setq trash-directory "~/.Trash")) ;; not necessary on windows


(defun jl/magit-log-edit-mode-hook ()
  (setq fill-column 72)
  (turn-on-auto-fill))


(use-package magit
  :ensure t
  :defer t
  :bind (("C-x g" . magit-status))
  :config
  )


(use-package magit-svn
  :ensure t
  :diminish magit-svn-mode
  :commands (magit-svn-mode turn-on-magit-svn)
  )


(defun clang-format-defun ()
  "Run clang-format on the current defun."
  (interactive)
  (save-excursion
    (mark-defun)
    (clang-format (region-beginning) (region-end))))

(use-package esup
  :ensure t
  :commands esup
  )

(provide 'init)
;;; init.el ends here
