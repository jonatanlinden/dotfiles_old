;; -*- lexical-binding: t -*-

;; For inspiration: https://emacs.nasy.moe/
;; https://ladicle.com/post/config

(defvar before-init-time (current-time) "Time when init.el was started")

(message "Starting emacs %s" (current-time-string))

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

(defun jl/reset-gc-threshold ()
  "Reset `gc-cons-threshold' to its default value."
  (setq gc-cons-threshold 800000))

;; reset frequency of garbage collection once emacs has booted
(add-hook 'emacs-startup-hook #'jl/reset-gc-threshold)

(add-hook 'after-init-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

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

(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; try the following for unicode characters
;; (setq inhibit-compacting-font-caches t)

;; List available fonts in *Messages* buffer
;;(message
;; (mapconcat (quote identity)
;;            (sort (font-family-list) #'string-lessp) "\n"))

;; Avoid emacs frame resize after font change for speed
(setq frame-inhibit-implied-resize t)

;; Default font
(cond (*is-win* (set-frame-font "Consolas 11" nil t))
      (*is-mac* (set-face-attribute 'default nil :family "Menlo" :height 140)))


(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-appearance . light))
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

;; Avoid eager loading of packages dependent on ...
(setq initial-major-mode 'fundamental-mode)

;; TRY: check if this prevents freezing during command evaluation
(defun jl/minibuffer-setup-hook ()
  (setq gc-cons-threshold most-positive-fixnum))

(defun jl/minibuffer-exit-hook ()
  (setq gc-cons-threshold 800000))

;;(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
;;(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)

(defconst jonatan-savefile-dir (expand-file-name "savefile" user-emacs-directory))
(defconst jonatan-personal-dir (expand-file-name "personal" user-emacs-directory))

(defconst jonatan-personal-preload (expand-file-name "personal/preload.el" user-emacs-directory))

(when (file-exists-p jonatan-personal-preload)
  (load jonatan-personal-preload))

;; create the savefile dir if it doesn't exist
(unless (file-exists-p jonatan-savefile-dir)
  (make-directory jonatan-savefile-dir))

;; create the savefile dir if it doesn't exist
(unless (file-exists-p jonatan-personal-dir)
  (make-directory jonatan-personal-dir))

(setq auth-sources
    '((:source "~/.emacs.d/.authinfo.gpg")))

(when *is-win*
  (setq w32-pass-lwindow-to-system nil
       w32-pass-rwindow-to-system nil
       w32-lwindow-modifier 'super ;; Left Windows key
       w32-rwindow-modifier 'super ;; Right Windows key
       w32-apps-modifier 'hyper) ;; Menu key
  )

(when *is-win*
  (progn
    (w32-register-hot-key [s-r])
    (w32-register-hot-key [s-p])
    (w32-register-hot-key [s-f])
    (w32-register-hot-key [s-0])
    ))



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

;; warn when opening files bigger than 10MB
(setq large-file-warning-threshold 10000000)

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
;;(setq-default show-trailing-whitespace t)

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

;; config changes made through the customize UI will be store here
(setq custom-file (expand-file-name "custom.el" jonatan-personal-dir))

;; (load custom-file)

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
;; keep the installed packages in .emacs.d
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
(package-initialize)
;; update the package metadata is the local cache is missing
(unless package-archive-contents
  (package-refresh-contents))

;; It seems this setting has to be before bootstrapping straight, to avoid
;; a "malformed cache"
(setq straight-use-symlinks t)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
       (bootstrap-version 5))
   (unless (file-exists-p bootstrap-file)
     (with-current-buffer
         (url-retrieve-synchronously
          "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
          'silent 'inhibit-cookies)
       (goto-char (point-max))
       (eval-print-last-sexp)))
   (load bootstrap-file nil 'nomessage))

;; No other configuration should be necessary to make this work;
;; however, you may wish to call straight-prune-build occasionally,
;; since otherwise this cache file may grow quite large over time.
(setq straight-cache-autoloads t)
;; (setq straight-use-package-by-default t)

(straight-use-package 'use-package)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(setq use-package-verbose t)

(eval-when-compile
  (require 'use-package))


;; load the personal settings (this includes `custom-file')
(when (file-exists-p jonatan-personal-dir)
  (message "Loading personal configuration files in %s..." jonatan-personal-dir)
  (mapc 'load (directory-files jonatan-personal-dir 't "^[^#].*el$")))


(use-package diminish                ;; if you use :diminish
  :ensure t)

(use-package bind-key                ;; if you use any :bind variant
  :ensure t)

;; manage elpa keys
(use-package gnu-elpa-keyring-update
  :ensure t
  )

(use-package server
  :if *is-win*
  :init
  (server-mode 1)
  :config
  (unless (server-running-p)
    (server-start)))

(with-eval-after-load 'server
  (when (equal window-system 'w32)
    ;; Suppress error "directory  ~/.emacs.d/server is unsafe". It is needed
    ;; needed for the server to start on Windows.
    (defun server-ensure-safe-dir (dir) "Noop" t)))


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

(use-package which-func
  :ensure nil
  :config
  ;; Show the current function name in the header line, not in mode-line
  (let ((which-func '(which-func-mode ("" which-func-format " "))))
    (setq-default mode-line-format (remove which-func mode-line-format))
    (setq-default mode-line-misc-info (remove which-func mode-line-misc-info))
    (setq-default header-line-format which-func))
  (which-function-mode)
)

;; (setq mode-line-misc-info
            ;; We remove Which Function Mode from the mode line, because it's mostly
            ;; invisible here anyway.
            ;;(assq-delete-all 'which-func-mode mode-line-misc-info))

(use-package paren
  :hook (after-init . show-paren-mode)
  :custom
  (show-paren-when-point-inside-paren t)
  (show-paren-when-point-in-periphery t))

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
  ;; :diminish (smartparens-mode .  "()")
  :diminish smartparens-mode
  )

(use-package abbrev
  :diminish ""
  :custom (save-abbrevs 'silently)
  :init (setq abbrev-mode t)
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

(use-package saveplace
  :custom
  (save-place-file (expand-file-name "saveplace" jonatan-savefile-dir))
  ;; activate it for all buffers
  (save-place t)
  :hook (after-init . save-place-mode)
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
  :custom (recentf-max-saved-items 500)
  (recentf-max-menu-items 15)
  ;; disable recentf-cleanup on Emacs start, because it can cause
  ;; problems with remote files
  (recentf-auto-cleanup 'never)
  (recentf-save-file (expand-file-name "recentf" jonatan-savefile-dir))
  (recentf-exclude '(".*-autoloads\\.el\\'" "COMMIT_EDITMSG\\'"))
  :hook (after-init . recentf-mode))

(use-package crux
  :ensure t
  :bind (("C-c o" . crux-open-with)
         ("C-c n" . crux-cleanup-buffer-or-region)
         ;;("C-c f" . crux-recentf-find-file)
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
         ("C-o" . crux-smart-open-line-above)
         ([remap open-line] . crux-smart-open-line-above)
         ([remap move-beginning-of-line] . crux-move-beginning-of-line)
         ([(shift return)] . crux-smart-open-line)
         ([remap kill-whole-line] . crux-kill-whole-line)
         ("C-c s" . crux-ispell-word-then-abbrev)))


(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package highlight-parentheses
  :ensure t
  :diminish highlight-parentheses-mode
  :init (setq hl-paren-highlight-adjacent t)
  :hook ((after-init . global-highlight-parentheses-mode)))


(use-package parinfer
  :ensure t
  :bind (("C-." . parinfer-toggle-mode))
  :init (setq parinfer-extensions
              '(defaults       ; should be included.
                 pretty-parens  ; different paren styles for different modes.
                 ;; evil           ; If you use Evil.
                 ;; lispy          ; If you use Lispy. With this extension, you should install Lispy and do not enable lispy-mode directly.
                 ;; paredit        ; Introduce some paredit commands.
                 smart-tab      ; C-b & C-f jump positions and smart shift with tab & S-tab.
                 smart-yank))   ; Yank behavior depend on mode.
  :hook lisp-modes-hooks)

(use-package anzu
  :ensure t
  :bind
  ([remap query-replace] . anzu-query-replace)
  ([remap query-replace-regexp] . anzu-query-replace-regexp)
  ("H-q" . anzu-query-replace-at-cursor-thing)
  :diminish ""
  :init
  (setq anzu-cons-mode-line-p nil)
  :hook
  (after-init . global-anzu-mode))

(use-package avy
  :ensure t
  :custom
  (avy-style 'de-bruijn)
  (avy-background t)
  :bind (("H-." . avy-goto-word-or-subword-1)
         ("H-," . avy-goto-char)
         ("M--" . avy-goto-line)
         ([remap goto-line] . avy-goto-line)
         )
  :config
  (avy-setup-default)
  ;;(global-set-key (kbd "C-c C-j") 'avy-resume)
  ;; :chords (("jj" . avy-goto-line)
  ;;          ("jk" . avy-goto-word)

  )


;; needed to tweak the matching algorithm used by ivy
(use-package flx
  :ensure t)

(use-package amx
  :ensure t
  :init (setq-default amx-save-file (expand-file-name "smex-items" jonatan-savefile-dir))
  :bind (("<remap> <execute-extended-command>" . amx)))


;; use flx matching instead of the default
;; see https://oremacs.com/2016/01/06/ivy-flx/ for details
;;(setq ivy-re-builders-alist
;;'((t . ivy--regex-fuzzy)))
                                        ;(setq ivy-initial-inputs-alist nil)
                                        ;(setq enable-recursive-minibuffers t)

(use-package ivy
  :ensure t
  :diminish
  :custom
  (ivy-extra-directories nil)
  (ivy-use-virtual-buffers t)
  (ivy-virtual-abbreviate 'abbreviate)
  (ivy-count-format "(%d/%d) ")
  (ivy-initial-inputs-alist nil)
  :hook
  (after-init . ivy-mode)
  (ivy-mode . counsel-mode)
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
   ;([remap other-window] . ace-window))
   ))


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
  :config
  (if *is-win*
      (setq counsel-git-log-cmd "set GIT_PAGER=cat && git log --grep \"%s\""))
  :bind
  (("M-x" . counsel-M-x)
   ("C-x C-f" . counsel-find-file)
   ("<f1> f" . counsel-describe-function)
   ("<f1> v" . counsel-describe-variable)
   ("<f1> l" . counsel-find-library)
   ;;("C-c g" . counsel-git)
   ("C-c j" . counsel-git-grep)
   ("C-c r" . counsel-rg)
   ("C-x l" . counsel-locate)
   ("s-r" . counsel-recentf)

   ([remap isearch-forward]  . swiper-isearch)
   ([remap isearch-backward] . counsel-grep-or-swiper)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history)
   :map counsel-find-file-map
   ("C-w" . counsel-up-directory))
  )

;; TODO: use https://github.com/yqrashawn/counsel-fd.git
;; after having straight.el

;; temporarily highlight changes from yanking, etc
(use-package volatile-highlights
  :diminish
  :ensure t
  :hook
  (after-init . volatile-highlights-mode)
  )


;; (use-package fd-dired
;;   :ensure t
;; )

;;(use-package counsel-fd
;;  :ensure t)

(use-package dired
  :defer t
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
  ;; :diminish (company-mode . "(c)")
  :diminish company-mode
  :commands company-mode
  :custom (company-minimum-prefix-length 2)
  (company-global-modes '(not text-mode)
                        )
  (company-dabbrev-downcase nil)
    ;; set default `company-backends'
  (company-backends
        '((company-files
           company-capf
           company-yasnippet) company-dabbrev company-dabbrev-code))
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

        )
  :hook ((after-init . global-company-mode)
         (prog-mode . jl/prog-mode-hook))
  )

(defun jl/prog-mode-hook ()
  (make-local-variable 'company-backends)
  (push 'company-keywords company-backends)
  ;; show trailing whitespace in editor
  (setq show-trailing-whitespace t)
  ;;(setq show-tabs)
  )

(use-package company-flx
  :ensure t
  :after (company)
  :init (company-flx-mode +1)
  )


;(use-package expand-region
;  :bind* ("C-," . er/expand-region))
(use-package expand-region
  :ensure t
  :bind
  ("H-0" . er/expand-region)
  ("H-§" . er/expand-region)
  ("s-0" . er/expand-region)
  ("C-," . er/mark-word)
  :config
  (unbind-key "M-@" global-map)
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
  :diminish symbol-overlay-mode
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
  :diminish which-key-mode
  :hook (after-init . which-key-mode)
  )

(use-package discover-my-major
  :ensure t
  :commands (discover-my-major discover-my-mode)
  )


(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode
  :custom
  (undo-tree-enable-undo-in-region t)
  ;; autosave the undo-tree history
  (undo-tree-auto-save-history t)
  (undo-tree-history-directory-alist
   `((".*" . ,temporary-file-directory)))
  :bind
  (("C-z" . 'undo)
   ("C-S-z" . 'undo-tree-redo))
  :config
  (global-undo-tree-mode)
  )

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
  (flycheck-checker-error-threshold 1605)
  (flycheck-check-syntax-automatically '(save))
  (flycheck-mode-line-prefix "FC")
  :init (global-flycheck-mode t)
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LANGUAGES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package lsp-mode
  :ensure t
  :custom (lsp-prefer-flymake nil)
  :commands lsp
  :hook (ruby-mode . lsp))

(use-package company-lsp
  :ensure t
  :after (company lsp-mode)
  :commands company-lsp
  :custom
  (company-lsp-async t)
  (company-lsp-enable-recompletion t)
  (company-transformers nil)
  (company-lsp-enable-snippet t)
  (company-lsp-cache-candidates nil)
  :init
  (with-eval-after-load 'company-mode
    (general-pushnew
     '(company-lsp
       company-files
       company-dabbrev-code
;       company-gtags
       ;company-etags
       company-keywords
       :with company-yasnippet)
     company-backends))
  )


;; lsp-ui: This contains all the higher level UI modules of lsp-mode, like flycheck support and code lenses.
;; https://github.com/emacs-lsp/lsp-ui
(use-package lsp-ui
  :ensure t
  :custom
  (lsp-ui-sideline-enable nil)
  (lsp-ui-doc-enable nil)
  (lsp-ui-imenu-enable t)
  (lsp-ui-sideline-ignore-duplicate t)
  :after (lsp)
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  )

(use-package flycheck-clang-tidy
  :if (executable-find "clang-tidy")
  :custom (flycheck-clang-tidy-build-path "../../build")
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
  :custom (ruby-align-chained-calls t)
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

(use-package css-mode
  :mode ("\\.css\\'" "\\.scss\\'" "\\.sass\\'")
  :custom (css-indent-offset 2)
  )

(use-package com-css-sort
  :ensure t
  :after css-mode
  :custom (com-css-sort-sort-type 'alphabetic-sort)
  :bind (:map css-mode-map
              ("C-c s" . com-css-sort-attributes-block))
  )

(defun jl/web-mode-hook ()
  "Hooks for Web mode."
  (progn
    (setq web-mode-markup-indent-offset 2)
    (web-mode-edit-element-minor-mode))
  )

(use-package web-mode
  :ensure t
  :custom (web-mode-css-indent-offset 2)
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

;; TODO: Evaluate, use local binaries from, e.g., yarn, npm
(use-package find-local-executable
  :disabled t
  )

(use-package json-mode
  :ensure t
  :mode ("\\.json\\'" "\\.tmpl\\'" "\\.eslintrc\\'")
  :init (setq-default js-indent-level 2))


;; Show changes in fringe
(use-package diff-hl
  :ensure t
  :bind (("C-c g n" . diff-hl-next-hunk)
         ("C-c g p" . diff-hl-previous-hunk))
  :init
  ;; Highlight changes to the current file in the fringe
  (global-diff-hl-mode)
  ;; Highlight changed files in the fringe of Dired
  :hook ((dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  )

(use-package hl-todo
  :ensure t
  )

(use-package whitespace
  :commands (whitespace-mode)
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

;;(defun jl/asm-mode-hook ()
  ;; you can use `comment-dwim' (M-;) for this kind of behaviour anyway
;;(local-unset-key (vector asm-comment-char))
  ;; asm-mode sets it locally to nil, to "stay closer to the old TAB behaviour".
;;  (setq tab-always-indent (default-value 'tab-always-indent)
  ;;      comment-column 40
    ;;    tab-stop-list (number-sequence 8 64 8)
      ;;  ))

(use-package string-inflection
  :ensure t
  )

(use-package arm-mode
  :load-path "lisp/arm-mode"
  :mode ("\\.i\\'" "\\.s\\'")
  :bind (:map arm-mode-map
              ("M-." . xref-posframe-dwim)
              ("M-," . xref-posframe-pop))
)

;; (use-package asm-mode
;;   :mode ("\\.i\\'" "\\.s\\'")
;;   :bind (:map asm-mode-map
;;               ("M-." . xref-posframe-dwim)
;;               ("M-," . xref-posframe-pop))
;;   :init (setq comment-column 40
;;               asm-comment-char ?/)
;;   :config
;;   ;; Hack to get a // comment in asm-mode.
;;   (defadvice asm-comment (after extra-slash activate)
;;     (insert-char ?/))
;;   :hook (asm-mode . jl/asm-mode-hook))

;; (add-hook 'asm-mode-hook #'jl/asm-mode-hook)

(defun jl/c-mode-common-hook ()
  (require 'smartparens-c)
  )

(use-package hideif
  :diminish hide-ifdef-mode
  :custom (hide-ifdef-shadow 't)
  :hook (c-mode-common . hide-ifdef-mode)
  )

(add-hook 'c-mode-common-hook #'jl/c-mode-common-hook)

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
                        (add-to-list (make-local-variable 'company-backends) 'company-irony))))

(use-package irony-eldoc
  :after irony
  :ensure t
  :hook irony-mode
  )

(use-package cc-mode
  :defer t
  :config
  (setq c-default-style "k&r"
        c-basic-offset 2)
  )

(use-package c++-mode
  :after smartparens
  :bind
  ([remap kill-sexp] . sp-kill-hybrid-sexp)
  :hook (c++-mode . jl/c++-mode-hook)
  )


(use-package general
  :ensure t
)

;; Best of both worlds
(defun kill-region-or-backward-word ()
  "Kill the region if active, otherwise kill the word before point."
  (interactive)
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (if (and (boundp 'subword-mode) subword-mode)
        (subword-backward-kill 1)
      (backward-kill-word 1))))


(general-define-key
 "C-x C-m" 'counsel-M-x
 "C-w" #'kill-region-or-backward-word
;;"C-w" 'backward-kill-word
 "C-x C-k" 'kill-region
 "C-x O" '(other-window-prev :which-key "previous window")
 ;; use hippie-expand instead of dabbrev
 "M-/" 'hippie-expand
 "s-/" 'hippie-expand
 ;; align code
 "C-x \\" 'align-regexp
 ;; mark-end-of-sentence is normally unassigned
 "M-h" 'mark-end-of-sentence
 ;; rebind to zap-up-to-char instead of zap-to-char
 "M-z" 'zap-up-to-char)

(general-define-key
 :keymaps 'prog-mode-map
 "s-f" 'mark-defun
 )

;;; open current file in explorer/finder
(when *is-win*
      (general-define-key
       "M-O" #'jl/open-folder-in-explorer
       ))

(use-package reveal-in-osx-finder
  :ensure t
  :if *is-mac*
  :bind ("M-o" . reveal-in-osx-finder)
)

(defun jl/c++-mode-hook ()
  "FIX prevent bug in smartparens."
  (progn
    (setq sp-escape-quotes-after-insert nil)
    (make-local-variable 'sp-escape-quotes-after-insert))
    )


(use-package clang-format
  :ensure t
  :commands clang-format clang-format-buffer
  :bind (:map c++-mode-map
              ("C-c f" . clang-format-region)
              )
  )

(general-define-key
 :keymaps 'c-mode-base-map
 "C-c C-o" '(ff-find-other-file :which-key "toggle header/impl file")
 )

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer)
  :config (setq ibuffer-saved-filter-groups
                '(("Default"
                   ("Dired" (mode . dired-mode))
                   ("Org" (or (mode . org-mode)
                              (filename . "OrgMode")))
                   ("Subversion" (name . "^\\*svn"))
                   ("Magit" (or (name . "^\\*Magit")
                                (name . "^magit")))
                   ("Help" (or (name . "^\\*Help\\*")
                               (name . "^\\*Apropos\\*")
                               (name . "^\\*info\\*")))
                   ("Emacs" (or
                             (name . "^\\*dashboard\\*$"  )
                             (name . "^\\*scratch\\*$"    )
                             (name . "^\\*Messages\\*$"   )
                             (name . "^\\*Backtrace\\*$"  )
                             (name . "^\\*Compile-Log\\*$")
                             (name . "^\\*Flycheck"       )
                             ))
                   ))

              ibuffer-show-empty-filter-groups nil
              ibuffer-default-sorting-mode 'filename/process
              )
  :hook ((ibuffer-mode . (lambda () (ibuffer-switch-to-saved-filter-groups "Default"))))
  )

(use-package ibuffer-vc
  :ensure t
  )

;; show the cursor when moving after big movements in the window
(use-package beacon
  :ensure t
  :diminish beacon-mode
  :hook (after-init . beacon-mode)
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
  :diminish ""
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

(use-package request
  :ensure t
  :defer t
  :custom (request-curl (if *is-win*  "c:/ProgramData/chocolatey/bin/curl.exe" "curl"))
  )

(use-package eldoc
  :diminish eldoc-mode)

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :commands (yas-minor-mode)
  :hook (prog-mode . yas-minor-mode)
  :config (yas-reload-all)
  )


(use-package arm-lookup
  :load-path "lisp/arm-lookup"
  :after arm-mode
  :custom
  (arm-lookup-browse-pdf-function 'arm-lookup-browse-pdf-sumatrapdf)
  :bind (:map arm-mode-map ("C-M-." . arm-lookup))
  )


(use-package open-in-msvs
  :if *is-win*
  :load-path "lisp/open-in-msvs"
  :commands (open-in-msvs)
  :bind ("M-o" . open-in-msvs)
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
  :custom (org-export-backends '(ascii html md))
  (org-directory "d:/work/notes")
  :bind (("C-c c" . org-capture))
  :config
  (setq org-id-track-globally t)
  (setq org-capture-templates
        '(("t" "Todo [inbox]" entry
           (file+headline "d:/work/notes/todo.org" "Tasks")
           "* TODO %i%? %a")
          ))
  )

(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))

(use-package ox-mediawiki
  :ensure t
  :after (org mediawiki)
  )

(use-package ffap
  :custom (ffap-machine-p-known 'reject)
  )

(use-package mediawiki
  :ensure t
  :commands (mediawiki-mode)
  :init
  ;; workaround, unable to run mediawiki-open otherwise
  (setq url-user-agent "EMACS" ;
        )
  :hook (mediawiki-mode . visual-line-mode)
  )

(use-package alert
  :if window-system
  :ensure t
  :commands (alert)
  :custom (alert-default-style 'mode-line)
  )

(use-package slack
  :if window-system
  :ensure t
  :commands (slack-start)
  :bind ("<f12>" . slack-select-unread-rooms)
  :custom (slack-prefer-current-team t)
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
  :bind (("C-x g" . magit-status)
         ("C-c g l" . magit-list-repositories)
         )
  )


;; Transient commands: replaces the old magit-popup
(use-package transient :defer t
  :config (transient-bind-q-to-quit))

;; git-messenger: popup commit message at current line
;; https://github.com/syohex/emacs-git-messenger
(use-package git-messenger
  :ensure t
  :bind
  (("C-c g m" . git-messenger:popup-message)
   :map git-messenger-map
   ([(return)] . git-messenger:popup-close))
  :config
  ;; Enable magit-show-commit instead of pop-to-buffer
  (setq git-messenger:use-magit-popup t)
  (setq git-messenger:show-detail t))

(use-package git-timemachine
  :commands (git-timemachine)
  :ensure t)

(use-package magit-svn
  :ensure t
  :diminish magit-svn-mode
  :commands (magit-svn-mode)
  )


(defun clang-format-defun ()
  "Run clang-format on the current defun."
  (interactive)
  (save-excursion
    (mark-defun)
    (clang-format (region-beginning) (region-end))))



(use-package esup
  :disabled
  :ensure t
  :commands esup
  )

(use-package ivy-hydra
  :ensure t
  :after (ivy hydra)
  )

(when (eq window-system 'w32)
  (setq tramp-default-method "plink")
  )

(winner-mode 1)

(defvar ediff-last-windows nil
  "Last ediff window configuration.")

(defun store-pre-ediff-winconfig ()
  (setq ediff-last-windows (current-window-configuration)))

(defun restore-pre-ediff-winconfig ()
  (set-window-configuration ediff-last-windows))

(use-package ediff
  :custom
  (ediff-diff-options "-w")
  (ediff-ignore-similar-regions t)
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  :hook
  (ediff-before-setup . store-pre-ediff-winconfig)
  (ediff-quit . restore-pre-ediff-winconfig)
  )

(use-package google-this
  :ensure t
  :diminish ""
  :commands (google-this)
  :config (google-this-mode 1)
  )

(use-package dumb-jump
  :ensure t
  :custom
  (dumb-jump-selector 'ivy)
  :config (add-to-list 'dumb-jump-language-file-exts '(:language "c++" :ext "tg" :agtype "cc" :rgtype "c"))
  :bind (("M-g j" . dumb-jump-go)
         ("M-g i" . dumb-jump-go-prompt)
         ("M-g q" . dumb-jump-quick-look))
  )


(use-package bm
  :disabled
  :ensure t
  :custom (bm-restore-repository-on-load t)
  (bm-highlight-style 'bm-highlight-only-fringe)
  :init
  ;; restore on load (even before you require bm)
  :hook ((after-init . bm-repository-load)
         (kill-buffer . bm-buffer-save)
         (after-save . bm-buffer-save)
         (vc-before-checkin . bm-buffer-save)
         (find-file . bm-buffer-restore)
         (after-revert . bm-buffer-restore)
         (kill-emacs . (lambda ()
                         (bm-buffer-save-all)
                         (bm-repository-save)
                         ))
         )
  :bind (("<f2>" . bm-next)
         ("S-<f2>" . bm-previous)
         ("C-<f2>" . bm-toggle))
  )


;;; in bat mode, treat _ as a word constitutent
(add-hook 'bat-mode-hook #'(lambda () (modify-syntax-entry ?_ "w")))

(windmove-default-keybindings 'control)
;; numbered window shortcuts
(use-package winum
  :ensure t
  :defer t
  :config
  (winum-mode))

(use-package treemacs
  :ensure t
  :defer t
  :custom
  (treemacs-python-executable "c:/Python38/python.exe")
  (treemacs-follow-mode nil)
  :commands (treemacs-mode)
  :custom (treemacs-no-png-images t)
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  )

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

(use-package posframe
  :after xref-posframe
  :ensure t)

(use-package xref-posframe
  :after xref-asm
  :load-path "lisp/xref-posframe")

(use-package xref-asm
  :load-path "lisp/xref-asm"
  :after arm-mode
  :config
  (xref-asm-activate))

(use-package cheatsheet
  :ensure t
  :commands (cheatsheet-show)
  )

(use-package nxml-mode
  :mode ("\\.xml\\'")
  :config (setq show-smartparens-mode -1))

(use-package point-history
  :disabled t
  :straight (point-history :type git :host github :repo "blue0513/point-history")
  :hook after-init
  :bind (("C-c C-/" . point-history-show))
  :init (setq point-history-ignore-buffer "^ \\*Minibuf\\|^ \\*point-history-show*"))


(cheatsheet-add
 :group 'General
 :key "C-u C-SPC"
 :description "Move to previous mark")

(cheatsheet-add
 :group 'Ivy-occur
 :key "C-o"
 :description "Open file at location from an ivy-occur buffer")

(cheatsheet-add
 :group 'Swiper
 :key "M-j"
 :description "Insert word-at-point into the minibuffer. Extend by pressing multiple times")

(cheatsheet-add
 :group 'Swiper
 :key "M-n"
 :description "Insert symbol-at-point into the minibuffer")

(cheatsheet-add
 :group 'Swiper
 :key "M-q"
 :description "Query replace")


(cheatsheet-add
 :group 'Swiper
 :key "M-o i"
 :description "Insert current ivy/swiper/counsel match into the current buffer"
 )

(cheatsheet-add
 :group 'General
 :key "C-u 3 M-x mc/insert-numbers"
 :description "Insert 3 at the first cursor, 4 at the second curser, etc."
 )

(cheatsheet-add
 :group 'Ruby
 :key "C-c {"
 :description "Ruby toggle block type"
 )

(cheatsheet-add
 :group 'VC
 :key "a"
 :description "Previous revision to line"
 )

(cheatsheet-add
 :group 'VC
 :key "l"
 :description "Show commit info")

(cheatsheet-add
 :group 'Movement
 :key "C-x v ]"
 :description "diff-hl-next-chunk: Move to next modified hunk")

(cheatsheet-add
 :group 'Movement
 :key "C-M-n"
 :description "inside brackets, move to after closing bracket")

(cheatsheet-add
 :group 'Movement
 :key "C-M-u"
 :description "inside brackets, move to opening bracket (up in structure)")


(provide 'init)
;;; init.el ends here
