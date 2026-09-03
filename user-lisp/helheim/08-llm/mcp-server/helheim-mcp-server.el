;;; helheim-mcp-server.el         -*- lexical-binding: t; no-byte-compile: t -*-
;;; Commentary:
;;
;; Adapted from upstream helheim-emacs/helheim for offline/site-lisp use.
;;
;; Exposes this Emacs instance as an MCP server (via the vendored
;; emacs-mcp-server package) that ACP/MCP-aware tools -- including the
;; GitHub Copilot CLI, which supports MCP servers -- can call into. See
;; site-lisp/mcp-server/README.md for how to point an agent at it.
;;
;;; Code:

(setup mcp-server
  (:install mcp-server :host github :repo "rhblind/emacs-mcp-server"
    :files ("*.el" "tools/*.el" "mcp-wrapper.py" "mcp-wrapper.sh"))
  (:setopt mcp-server-security-prompt-for-permissions t)
  ;; Unix domain sockets aren't supported by native Windows Emacs
  ;; (`make-network-process' signals "Unknown address family"); use TCP
  ;; there instead. Defaults to the loopback address on a random free port.
  ;; NOTE: `:setopt' only works as a direct `setup' body form, not nested
  ;; inside `when', so a plain `setq' is used here instead.
  (when (eq system-type 'windows-nt)
    (setq mcp-server-default-transport "tcp"))
  (with-eval-after-load 'org
    (:setopt mcp-server-emacs-tools-org-allowed-roots (list org-directory)
             mcp-server-emacs-tools-org-auto-save t))
  (:defer
    (mcp-server-start)))

;;;; Do not ask about killing mcp-server process on exit Emacs

(advice-add 'mcp-server-transport-unix--start :after
            '+mcp-server-transport-unix--do-not-query-on-exit)

(advice-add 'mcp-server-transport-tcp--start :after
            '+mcp-server-transport-tcp--do-not-query-on-exit)

(defun +mcp-server-transport-unix--do-not-query-on-exit (&rest _)
  (-some-> mcp-server-transport-unix--server-process
    (set-process-query-on-exit-flag nil)))

(defun +mcp-server-transport-tcp--do-not-query-on-exit (&rest _)
  (-some-> mcp-server-transport-tcp--server-process
    (set-process-query-on-exit-flag nil)))

;;; .
(provide 'helheim-mcp-server)
;;; helheim-mcp-server.el ends here
