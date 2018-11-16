
;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
;;; Code:
(setq gc-cons-threshold 50000000)

(defun jl/reset-gc-threshold ()
  "Reset `gc-cons-threshold' to its default value."
  (setq gc-cons-threshold 800000))

;; reset frequency of garbage collection once emacs has booted
(add-hook 'emacs-startup-hook #'jl/reset-gc-threshold)

;; the toolbar is just a waste of valuable screen estate
;; in a tty tool-bar-mode does not properly auto-load, and is
;; already disabled anyway
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))

(when window-system
  (scroll-bar-mode -1))

;; avoid annoying resizes during startup
(set-face-attribute 'default nil :family "Consolas" :height 110)

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
(load custom-file)


(when (eq system-type 'windows-nt)
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

;; This is only needed once, near the top of the file
(eval-when-compile
  (require 'use-package))

(use-package diminish                ;; if you use :diminish
  :ensure t)

(use-package bind-key                ;; if you use any :bind variant
  :ensure t)

(use-package paradox
  :ensure t
  :config  (paradox-enable)
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
  :init
  (setq-default sml/vc-mode-show-backend t
		sml/theme 'respectful
                sm/name-with 30))

(use-package paren
  :config
  (show-paren-mode +1))

(use-package smartparens
  :ensure t
  :hook ((lisp-mode emacs-lisp-mode) . turn-on-smartparens-strict-mode)
  :config
  (require 'smartparens-config)
  (setq sp-base-key-bindings 'paredit
          sp-autoskip-closing-pair 'always
          sp-hybrid-kill-entire-symbol nil
          sp-show-pair-delay 0
          )
  (sp-use-paredit-bindings)
  (show-smartparens-global-mode +1)
  (smartparens-global-mode t)
  :diminish (smartparens-mode .  "()"))

(use-package abbrev
  :init
  (setq save-abbrevs 'silently
        abbrev-mode t)
  :config
  (if (file-exists-p abbrev-file-name)
      (quietly-read-abbrev-file)))


(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward)
  (setq uniquify-separator "/")
  ;; rename after killing uniquified
  (setq uniquify-after-kill-buffer-p t)
  ;; don't muck with special buffers
  (setq uniquify-ignore-buffers-re "^\\*"))


;; saveplace remembers your location in a file when saving files
(require 'saveplace)
(use-package saveplace
  :config
  (setq save-place-file (expand-file-name "saveplace" jonatan-savefile-dir))
  ;; activate it for all buffers
  (setq-default save-place t))

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
         ;;("M-o" . crux-smart-open-line)
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
         ("s-r" . crux-recentf-find-file)
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
  :bind (([remap query-replace] . anzu-query-replace)
         ([remap query-replace-regexp] . anzu-query-replace-regexp))
  :diminish ""
  :init
  (setq anzu-cons-mode-line-p nil)
  :config
  (global-anzu-mode))


(use-package avy
  :ensure t
  :bind (("s-." . avy-goto-word-or-subword-1)
         ("s-," . avy-goto-char))
  ;; :chords (("jj" . avy-goto-line)
  ;;          ("jk" . avy-goto-word)
  ;;         )
  :config
  (setq avy-background t
        avy-style 'at-full))



;; needed to tweak the matching algorithm used by ivy
(use-package flx
  :ensure t)

(use-package smex
  :ensure t
  :init
  (setq-default smex-history-length 32
                smex-save-file (expand-file-name "smex-items" jonatan-savefile-dir)))

(use-package ivy
  :ensure t
  :init
  (setq ivy-use-virtual-buffers t
        ivy-count-format ""
        ivy-extra-directories ())
  :config
  (ivy-mode 1)

  ;; use flx matching instead of the default
  ;; see https://oremacs.com/2016/01/06/ivy-flx/ for details
  ;;(setq ivy-re-builders-alist
        ;;'((t . ivy--regex-fuzzy)))
  ;(setq ivy-initial-inputs-alist nil)
  ;(setq enable-recursive-minibuffers t)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "<f6>") 'ivy-resume))

(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "s-w") 'ace-window)
  (global-set-key [remap other-window] 'ace-window))


(use-package swiper
  :ensure t
  :config
  (global-set-key "\C-s" 'swiper))

(use-package counsel
  :ensure t
  :init
  (setq counsel-find-file-at-point t)
  :config
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  (global-set-key (kbd "<f1> l") 'counsel-find-library)
  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-c g") 'counsel-git)
  (global-set-key (kbd "C-c j") 'counsel-git-grep)
  (global-set-key (kbd "C-c a") 'counsel-ag)
  (global-set-key (kbd "C-c r") 'counsel-rg)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history))


(use-package wgrep
  :ensure t
  )


;; temporarily highlight changes from yanking, etc
(use-package volatile-highlights
  :ensure t
  :config
  (volatile-highlights-mode +1))


(use-package dired
  :config
  ;; dired - reuse current buffer by pressing 'a'

  ;; always delete and copy recursively
  (setq dired-recursive-deletes 'always)
  (setq dired-recursive-copies 'always)

  ;; if there is a dired buffer displayed in the next window, use its
  ;; current subdir, instead of the current subdir of this dired buffer
  (setq dired-dwim-target t)

  ;; enable some really cool extensions like C-x C-j(dired-jump)
  (require 'dired-x))

(use-package company
  :ensure t
  :diminish company-mode
  :bind (:map company-active-map
              ("C-e" . company-other-backend)
              ("C-n" . company-select-next-or-abort)
              ("C-p" . company-select-previous-or-abort)
              )
  :init
  (setq company-idle-delay 0.5    ; decrease delay before
                                        ; autocompletion popup shows
        company-echo-delay 0     ; remove annoying blinking
        company-tooltip-limit 10
        company-tooltip-flip-when-above t
        company-minimum-prefix-length 2
        company-dabbrev-downcase nil
        )
  ;; (add-hook 'after-init-hook #'global-company-mode)
  :hook ((prog-mode) . company-mode)
  :config
  ;; set default `company-backends'
  (setq company-backends
        '((company-files
          company-capf
          company-yasnippet) company-dabbrev))

  )

(add-hook 'prog-mode-hook
          (lambda () (add-to-list (make-local-variable 'company-backends)
                                  'company-keywords)))
(use-package company-flx
  :ensure t
  :config (company-flx-mode +1)
  )



(use-package expand-region
  :ensure t
:bind ("C-=" . er/expand-region))

(use-package which-key
  :ensure t
  :config
  (which-key-mode +1))


(use-package discover-my-major
  :ensure t
  :commands (discover-my-major discover-my-mode)
  )


(use-package undo-tree
  :ensure t
  :config
  ;; autosave the undo-tree history
  (setq undo-tree-history-directory-alist
        `((".*" . ,temporary-file-directory)))
  (setq undo-tree-auto-save-history t))


(use-package projectile
  :ensure t
  :init
  (setq projectile-completion-system 'ivy
        projectile-enable-caching t
        projectile-cache-file (expand-file-name  "projectile.cache" jonatan-savefile-dir)
        projectile-svn-command "find . -type f -not -iwholename '*.svn/*' -print0")
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (projectile-global-mode))

(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode t)
  (setq flycheck-checker-error-threshold 500)
  (setq flycheck-check-syntax-automatically '(save))
  )

(use-package inf-ruby
  :ensure t
  :config
  (add-to-list 'inf-ruby-implementations '("ruby" . "irb-2.3.1 --prompt default --noreadline -r irb/completion"))
  (setq inf-ruby-default-implementation "ruby")
  :hook (ruby-mode . inf-ruby-minor-mode))

(use-package ruby-mode
  :init (setq ruby-indent-level 2
              ruby-indent-tabs-mode nil)
  (add-to-list 'flycheck-disabled-checkers 'ruby-reek)
  :config
  (push 'company-robe company-backends)
  :hook subword-mode
  (use-package smartparens-ruby)
  :interpreter "ruby"
  :bind
  (([(meta down)] . ruby-forward-sexp)
   ([(meta up)]   . ruby-backward-sexp)
   (("C-c C-e"    . ruby-send-region)))
  )

(use-package robe
  :ensure t
  :bind (:map ruby-mode-map
              ("C-M-." . robe-jump))
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
  :ensure t)

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
  :hook jl/web-mode-hook
  )

(defun jl/web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2) 
  (web-mode-edit-element-minor-mode)

  )

(use-package json-mode
  :ensure t
  :mode (("\\.json\\'" . json-mode)
         ("\\.tmpl\\'" . json-mode)
         ("\\.eslintrc\\'" . json-mode))
  :init (setq-default js-indent-level 2))


;; highlight the current line
;(global-hl-line-mode +1)

(use-package diff-hl                    ; Show changes in fringe
  :ensure t
  :init
  ;; Highlight changes to the current file in the fringe
  (global-diff-hl-mode)
  ;; Highlight changed files in the fringe of Dired
  :hook (dired-mode . diff-hl-dired-mode)
  )

(use-package whitespace
  :init (setq whitespace-line-column 80

              ))
;  :hook (asm-mode . whitespace-mode)


(setq gud-gdb-command-name "gdb-multiarch -i=mi --annotate=1")

(use-package asm-mode
  :mode ("\\.i\\'" "\\.s\\'")
  :init (setq comment-column 40)
  :hook jl/asm-mode-hook)

(add-hook 'asm-mode-hook #'jl/asm-mode-hook)

(defun jl/asm-mode-hook ()
  ;; you can use `comment-dwim' (M-;) for this kind of behaviour anyway
  (local-unset-key (vector asm-comment-char))
  ;; asm-mode sets it locally to nil, to "stay closer to the old TAB behaviour".
  (setq tab-always-indent (default-value 'tab-always-indent)
        comment-column 40
        tab-stop-list (number-sequence 8 64 8)
        )
  )

;; FIX prevent bug in smartparens       
(setq sp-escape-quotes-after-insert nil)

(use-package c++-mode
  :hook jl/c++-mode-hook
  )

(defun jl/c++-mode-hook (setq-local sp-escape-quotes-after-insert nil))

(use-package general
  :ensure t
)

(general-define-key
 "s-2" '(er/mark-word :which-key "mark word")
 "s-x" 'execute-extended-command
 "C-x C-m" 'execute-extended-command
 "C-w" 'backward-kill-word
 "C-x C-k" 'kill-region
 "C-x O" '(other-window-prev :which-key "previous window")
 ;; use hippie-expand instead of dabbrev
 "M-/" 'hippie-expand
 "s-/" 'hippie-expand
 ;; replace buffer-menu with ibuffer
 "C-x C-b" 'ibuffer
 ;; align code
 "C-x \\" 'align-regexp
 ;; mark-end-of-sentence is normally unassigned
 "M-p" 'mark-end-of-sentence
 "M-o" #'jl/open-folder-in-explorer
  )


;; show the cursor when moving after big movements in the window
(use-package beacon
  :ensure t
  :diminish beacon-mode
  :config
  (beacon-mode +1)
  )

;; show available keybindings after you start typing
(use-package which-key
  :ensure t
  :diminish ""
  :config (which-key-mode +1)
  )

;; edit grep-buffers, e.g., ivy-occur
(use-package wgrep
  :commands wgrep-mode
  ;:init (add-hook 'ivy-occur-grep-mode-hook (lambda ()
  ;(key-chord-define wgrep-mode-map "dd" 'wgrep-mark-deletion)))
  )

(use-package ws-butler
:ensure t
:config
(setq ws-butler-keep-whitespace-before-point nil)

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
  (eldoc-mode +1)
  (jl/recompile-elc-on-save)
                                        ;(rainbow-mode +1)
  (smartparens-strict-mode +1)
  (rainbow-delimiters-mode +1)
  )

(use-package lisp-mode
:bind
  (:map emacs-lisp-mode-map
        ("C-c C-c" . eval-defun)
        ("C-c C-b" . eval-buffer))
  :hook  ((emacs-lisp-mode . jl/el-mode-hook)
          (emacs-lisp-mode . eldoc-mode)
          (lisp-interaction-mode . eldoc-mode)
          (eval-expression-minibuffer-setup . eldoc-mode))
  )



(put 'dired-find-alternate-file 'disabled nil)


(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1)
)


(use-package arm-lookup
  :load-path "lisp/arm-lookup"
  :bind (:map asm-mode-map
              ("M-." . arm-lookup))
  :init (setq arm-lookup-txt "d:/work/trunk/armdoc/DDI0487D_a_armv8_arm.txt"
              arm-lookup-browse-pdf-function 'arm-lookup-browse-pdf-sumatrapdf
              ))

(unless (file-expand-wildcards (concat package-user-dir "/org-[0-9]*"))
  (package-install (elt (cdr (assoc 'org package-archive-contents)) 0)))
(require 'org)

(use-package org
  :init (setq org-export-backends '(ascii html md))
  )

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
  :mode "CMakeLists.txt")

(use-package multiple-cursors
  :ensure t
  :bind (("C-c m c" . mc/edit-lines)
         ("C->" . mc/mark-next-symbol-like-this)
         ("C-<" . mc/mark-previous-symbol-like-this)
         ("M-C->" . mc/mark-next-like-this-word))
  )


(defun jl/magit-log-edit-mode-hook ()
      (setq fill-column 72)
      (turn-on-auto-fill))

(use-package magit
  :ensure t
  :defer t
  :bind (("C-x g" . magit-status))
  :config
  :hook (magit-log-edit-mode . jl/magit-log-edit-mode-hook)
  )
