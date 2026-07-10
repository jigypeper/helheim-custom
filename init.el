;;; init.el -*- lexical-binding: t; no-byte-compile: t; -*-
;;; Fonts
;;
;; Set up fonts before anything else so error messages during startup were
;; readable.
;;
;; Place cursor before character and press "ga" to see information about it.
;; Press "<F1> k ga" to find out which command is bound to "ga".


(require 'cl-macs)
(cl-defun helheim-set-fontset-font (font charsets &key (fontset t) add)
  "Force some code point diapasons to use particular FONT."
  (declare (indent 1))
  (dolist (charset charsets)
    (set-fontset-font fontset charset font nil add)))

;; General Punctuation Unicode Block
;; ---------------------------------
;;   When text is bold or italic, Emacs falls back to other fonts if the
;; main one doesn’t have the required glyphs for those styles. Force Emacs
;; to use the main font for punctuation.
;;
;;   These are all the glyphs, so you can quickly see which ones your font
;; supports:
;;  ‐ ‑ ‒ – — ― ‖ ‗
;; ‘ ’ ‚ ‛ “ ” „ ‟
;; † ‡ • ‣ ․ ‥ … ‧ ‰ ‱ ′ ″ ‴ ‵ ‶ ‷ ‸ ‹ ›
;; ※ ‼ ‽ ‾ ‿ ⁀ ⁁ ⁂ ⁃ ⁄ ⁅ ⁆ ⁇ ⁈ ⁉ ⁊ ⁋ ⁌ ⁍
;; ⁎ ⁏ ⁐ ⁑ ⁒ ⁓ ⁔ ⁕ ⁖ ⁗ ⁘ ⁙ ⁚ ⁛ ⁜ ⁝ ⁞
(defun helheim--setup-fonts (&optional _frame)
  "Configure fonts after a graphical frame exists."
  (when (display-graphic-p)
    (setq use-default-font-for-symbols t)
    (let ((font (font-spec :family "Cascadia Code" :size 13.0 :weight 'normal)))
      (set-face-font 'default font)
      (set-face-font 'fixed-pitch font))
    (helheim-set-fontset-font (face-font 'default) '((#x2010 . #x205e)))
    (helheim-set-fontset-font "Symbols Nerd Font Mono"
      '((#xe5fa . #xe6b7) ;; Seti-UI + Custom  
        (#xe700 . #xe8ef) ;; Devicons  
        (#xed00 . #xf2ff) ;; Font Awesome  
        (#xe200 . #xe2a9) ;; Font Awesome Extension  
        (#xe300 . #xe3e3) ;; Weather  
        (#xf400 . #xf533) #x2665 #x26A1 ;; Octicons   ♥ ⚡
        (#x23fb . #x23fe) #x2b58 ;; IEC Power Symbols ⏻ ⏾ ⭘
        (#xf300 . #xf381) ;; Font Logos   
        (#xe000 . #xe00a) ;; Pomicons  
        (#xea60 . #xec1e) ;; Codicons  
        (#x276c . #x2771) ;; Heavy Angle Brackets ❬ ❱
        (#xee00 . #xee0b) ;; Progress  
        (#xf0001 . #xf1af0))) ;; Material Design Icons 󰀁 󱫰
    ;; In the modeline, we’re not restricted by a rigid grid, and non-monospace
    ;; Powerline symbols look better.
    (helheim-set-fontset-font "Symbols Nerd Font"
      `(;; Powerline Symbols
        (#xe0a0 . #xe0a2) ;;  
        (#xe0b0 . #xe0b3) ;;  
        ;; Powerline Extra Symbols
        (#xe0b4 . #xe0c8) ;;  
        (#xe0cc . #xe0d7) ;;  
    #xe0a3 #xe0ca))))  ;; 

;; Plain Emacs (not daemon/client) — frame exists at startup, call directly.
(helheim--setup-fonts)

;;; Helheim core

;; ;; In case you use VPN. Also Emacs populates `url-proxy-services' variable
;; ;; from: `https_proxy', `socks_proxy', `no_proxy' environment variables.
;; (setq url-proxy-services '(("socks" . "127.0.0.1:10808")
;;                            ("https" . "127.0.0.1:10809"))
;;       gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; Use site-lisp/ (offline) package manager — no elpaca/straight needed.
(setq helheim-package-manager 'site-lisp)
(require 'helheim-core)

;; Always remove *-ts-mode remaps: airgapped machine won't have grammars.
(add-hook 'after-init-hook
          (lambda ()
            (setq major-mode-remap-alist
                  (cl-remove-if
                   (lambda (x)
                     (string-suffix-p "-ts-mode" (symbol-name (cdr x))))
                   major-mode-remap-alist))))

;;; Color theme

(require 'helheim-modus-themes)
(load-theme 'modus-operandi t)

;; I can recommend `leuven' theme for org-mode work. It has so many nice little
;; touches to spruce up org-mode elements that some users switch to it from
;; their usual dark doom or modus themes when working on org-mode projects.
;;   You may try it with ": load-theme" then type "leuven".
(require 'leuven-theme)

;;; Essentials

(require 'helheim-minibuffer) ; Vertico + marginalia (command palette)
(require 'helheim-completion) ; Corfu + orderless (code completion)
(require 'helheim-keybindings)
(require 'helheim-disable-isearch)

(require 'helheim-ibuffer)  ; Buffers menu
(require 'helheim-dired)    ; File-manager
(require 'helheim-embark)   ; Context-aware action menus
(require 'helheim-modeline) ; Status line (doom-modeline)
(require 'helheim-outline)  ; See "Outline Mode" in Emacs manual
(require 'helheim-tab-bar)  ; Each tab represents a set of windows, as in Vim

;;; Search

(require 'helheim-consult)  ; A set of search commands with preview
(require 'helheim-deadgrep) ; Interface to Ripgrep

;;; IDE

(require 'helheim-xref)     ; Go to definition framework
(require 'helheim-eglot)    ; eglot + flymake (both built-in)

;;; Version control

(require 'helheim-magit)    ; Magit
(require 'helheim-diff-hl)  ; Git gutter indicators
(require 'helheim-ediff)    ; Ediff

;;; Org mode

;; The `org-directory' variable must be set before `helheim-org' loaded!
;; Set this to wherever your notes live on this machine.
(setopt org-directory (expand-file-name "~/notes/"))

(setq org-modules '(ol-bibtex ol-docview ol-info))

(require 'helheim-org)
(require 'helheim-org-node)
(require 'helheim-daily-notes)

;; org-vault-sync omitted — no network on air-gapped system.

;;; Major modes

;; Use Emacs built-in modes directly rather than helheim language wrappers.
;; (Tree-sitter is also not required.)

(require 'helheim-markdown)

;; C / C++ — use classic cc-mode with eglot via clangd
(setq-default c-basic-offset 4)
(add-hook 'c-mode-common-hook #'eglot-ensure)

;; JSON — use the vendored json-mode
(require 'json-mode)

;; Shell scripts — built-in sh-mode, no extra setup needed

;; Lua — use the vendored lua-mode if clangd/lua-lsp is available,
;; otherwise just syntax highlighting.
(when (locate-library "lua-mode")
  (require 'lua-mode))

;; Emacs Lisp enhancements (paredit omitted — needs hel-paredit)
(setup highlight-defined
  (:install t)
  (:hook emacs-lisp-mode-hook))

;;; Writing and spell checking

(use-package ispell
  :config
  (setq ispell-program-name "aspell")
  (setq ispell-dictionary "en_GB")
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_GB")))

(use-package flyspell
  :hook ((text-mode-hook . flyspell-mode)
         (prog-mode-hook . flyspell-prog-mode))
  :config
  (setq flyspell-issue-message-flag nil)
  (setq flyspell-issue-welcome-flag nil))

;; Auto-expand common typo corrections
(use-package abbrev
  :hook (text-mode-hook . abbrev-mode))

;;; Programming configuration

;; Auto-pair brackets, quotes, etc.
(electric-pair-mode 1)

;; Tell Emacs where LSP binaries live on this machine.
;; Adjust this path to wherever clangd (and other servers) are installed.
(add-to-list 'exec-path "/usr/local/bin")   ; <- change to actual binary dir

;; LSP server overrides — use full path so eglot never prompts interactively.
(with-eval-after-load 'eglot
  (let ((clangd (or (executable-find "clangd") "clangd")))
    (add-to-list 'eglot-server-programs
                 `(c-mode . (,clangd "--header-insertion=never")))
    (add-to-list 'eglot-server-programs
                 `(c++-mode . (,clangd "--header-insertion=never")))))

;; Restore SPC-d → dired-jump.
(keymap-set mode-specific-map "d" 'dired-jump)

;;; init.el ends here
