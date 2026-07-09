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

(if (daemonp)
    ;; Defer to idle timer so font setup runs after the frame is fully ready.
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (run-with-idle-timer 0.1 nil #'helheim--setup-fonts frame)))
  (helheim--setup-fonts))

;;; Helheim core

;; ;; In case you use VPN. Also Emacs populates `url-proxy-services' variable
;; ;; from: `https_proxy', `socks_proxy', `no_proxy' environment variables.
;; (setq url-proxy-services '(("socks" . "127.0.0.1:10808")
;;                            ("https" . "127.0.0.1:10809"))
;;       gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; Use site-lisp/ (offline) package manager — no elpaca/straight needed.
(setq helheim-package-manager 'site-lisp)
(require 'helheim-core)

;; Remove all *-ts-mode remaps when tree-sitter is unavailable.
;; Both Emacs built-ins and helheim-cpp.el set these unconditionally.
(add-hook 'after-init-hook
          (lambda ()
            (unless (and (fboundp 'treesit-available-p) (treesit-available-p))
              (setq major-mode-remap-alist
                    (cl-remove-if
                     (lambda (x)
                       (string-suffix-p "-ts-mode" (symbol-name (cdr x))))
                     major-mode-remap-alist)))))

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
(setopt org-directory (expand-file-name "~/obsidian-vault/"))

;; Which modules to load. Place cursor on variable and press "M" to see
;; all possible values.
(setq org-modules '(ol-bibtex ol-docview ol-info))

(require 'helheim-org)
(require 'helheim-org-node)
(require 'helheim-daily-notes)

;; Auto-sync org vault with git on startup/shutdown
(require 'org-vault-sync)

;;; Major modes

(require 'helheim-cpp)
(require 'helheim-emacs-lisp)
(require 'helheim-json)
(require 'helheim-markdown)
(require 'helheim-lua)
(require 'helheim-sh)


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

;; Built-in dictionary client (Emacs 28+)
(use-package dictionary
  ;; :bind ("C-c d" . dictionary-search)
  :config
  (setq dictionary-server "dict.org")
  (setq dictionary-default-popup-strategy "lev")
  (setq dictionary-create-buttons nil)
  (setq dictionary-use-single-buffer t))

;; Auto-expand common typo corrections
(use-package abbrev
  :hook (text-mode-hook . abbrev-mode))

;;; Programming configuration

;; Auto-pair brackets, quotes, etc.
(electric-pair-mode 1)

;; Ensure eglot starts for C/C++ regardless of whether tree-sitter remaps the mode.
(add-hook 'c-mode-common-hook #'eglot-ensure)
(add-hook 'c-ts-mode-hook #'eglot-ensure)
(add-hook 'c++-ts-mode-hook #'eglot-ensure)
;; Start harper-ls for text/prose files.
(add-hook 'text-mode-hook #'eglot-ensure)

;; Restore SPC-d → dired-jump (C-c d is now the diagnostics prefix in new helheim).
(keymap-set mode-specific-map "d" 'dired-jump)

;; LSP server overrides (helheim-eglot provides the base eglot config)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(c-mode . ("clangd" "--header-insertion=never")))
  (add-to-list 'eglot-server-programs
               '(c-ts-mode . ("clangd" "--header-insertion=never")))
  (add-to-list 'eglot-server-programs
               '(text-mode . ("/home/ahmed/.local/bin/harper-ls" "--stdio"))))

;;; GDB debugging attach process

(defun gdb-attach-filtered ()

  (interactive)

  (let* ((pattern (read-string "Process name: "))

         (cmd (format

               "ps -u $USER -o pid=,comm=,etime= | grep -i %s"

               (shell-quote-argument pattern)))

         (matches

          (split-string

           (shell-command-to-string cmd)

           "\n" t))

         (choice

          (completing-read

           "Attach to process: "

           matches nil t)))

    (gud-basic-call

     (format "attach %s"

             (car (split-string choice))))))
;;; init.el ends here
