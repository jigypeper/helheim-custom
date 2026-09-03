;;; helheim-agent-shell.el        -*- lexical-binding: t; no-byte-compile: t -*-
;;; Commentary:
;;
;; Adapted from upstream helheim-emacs/helheim for offline/site-lisp use.
;;
;; `agent-shell' ships a ready-made GitHub Copilot backend
;; (`agent-shell-github.el') that spawns `copilot --acp' -- the GitHub
;; Copilot CLI's public, documented ACP server. For this to work:
;;
;; - Install the GitHub Copilot CLI (`copilot') and make sure it's on PATH.
;; - Run `copilot' once outside Emacs to authenticate.
;;
;; Other ACP-compatible agent CLIs (Claude Agent, Codex, Gemini CLI, etc.) are
;; also supported out of the box if installed -- see
;; site-lisp/agent-shell/README.org for the full list and per-agent setup.
;;
;;; Code:

(setup agent-shell
  (:install t)
  (:global-bind
    "C-c a RET" 'agent-shell   ;; pick a configured agent (Copilot included)
    "C-c a n"   '("new agent-shell" . agent-shell-new-shell)
    "C-c a w"   '("new worktree agent-shell" . agent-shell-new-worktree-shell))
  (:after-load
    (:global-bind
      "C-c a s" 'agent-shell-send-dwim)
    (:with-keymap agent-shell-mode-map
      (:bind :state 'normal
        ", ," 'agent-shell-prompt-compose
        "z '" 'agent-shell-prompt-compose)
      (:bind
        "C-c RET" 'dired-jump))))

;;;; Display buffer logic

;; Open the initial `agent-shell' buffer in another window. All subsequent
;; buffers are opened in the same window.
(setq agent-shell-display-action nil)
(add-to-list 'display-buffer-alist
             '((or (major-mode . agent-shell-mode)
                   (major-mode . agent-shell-viewport-view-mode)
                   (major-mode . agent-shell-viewport-edit-mode))
               (display-buffer-reuse-mode-window
                display-buffer-pop-up-window)
               (mode . (agent-shell-mode
                        agent-shell-viewport-view-mode
                        agent-shell-viewport-edit-mode))))

;;; .
(provide 'helheim-agent-shell)
;;; helheim-agent-shell.el ends here
