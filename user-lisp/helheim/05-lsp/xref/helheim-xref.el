;;; helheim-xref.el               -*- lexical-binding: t; no-byte-compile: t -*-

(setup xref
  ;; (:install t)
  (:built-in)
  ;; Load the lib early so the functions are defined before remaps are set.
  (load "helheim-xref-lib" nil t)
  (:setopt xref-search-program 'ripgrep ;; or 'ugrep
           xref-auto-jump-to-first-definition 'show
           xref-prompt-for-identifier nil
           xref-history-storage #'xref-window-local-history
           ;; Enable completion in the minibuffer instead of the definitions
           ;; buffer. Use `embark-export' to export minibuffer content to xref
           ;; buffer.
           xref-show-xrefs-function #'xref-show-definitions-completing-read
           xref-show-definitions-function #'xref-show-definitions-completing-read)
  (:global-bind
    ;; Make Xref try all backends until first one succeeds.
    [remap xref-find-references]  'helheim-xref-find-references
    [remap xref-find-definitions] 'helheim-xref-find-definitions
    [remap xref-find-definitions-other-window] 'helheim-xref-find-definitions-other-window
    [remap xref-find-definitions-other-frame]  'helheim-xref-find-definitions-other-frame)
  ;; Open xref buffer in another window
  (add-to-list 'display-buffer-alist
               '((major-mode . xref--xref-buffer-mode)
                 (display-buffer-use-some-window display-buffer-pop-up-window)
                 (inhibit-same-window . t)
                 (body-function . select-window))))

(setup dumb-jump
  (:install t)
  (:after xref)
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  (remove-hook 'xref-backend-functions #'etags--xref-backend))

(setup nerd-icons-xref
  (:install t)
  (:after xref)
  (nerd-icons-xref-mode))

;;; .
(provide 'helheim-xref)
;;; helheim-xref.el ends here
