;;; org-vault-sync.el --- Auto-sync org vault with git -*- lexical-binding: t; -*-

;;; Commentary:
;; Automatically pull from git when Emacs starts
;; and commit/push changes when Emacs exits.

;;; Code:

(defvar org-vault-sync-directory (expand-file-name "~/obsidian-vault/")
  "Directory of the org vault to sync.")

(defun org-vault-sync--has-changes-p ()
  "Check if there are uncommitted changes in the vault."
  (let ((default-directory org-vault-sync-directory))
    (not (string-empty-p
          (string-trim
           (shell-command-to-string "git status --porcelain"))))))

(defun org-vault-sync-pull ()
  "Pull latest changes from remote on Emacs startup."
  (interactive)
  (when (file-directory-p org-vault-sync-directory)
    (let ((default-directory org-vault-sync-directory))
      (message "Syncing org vault: pulling changes...")
      (let ((result (shell-command-to-string "git pull --rebase 2>&1")))
        (if (string-match-p "error\\|fatal" result)
            (message "Org vault pull failed: %s" result)
          (message "Org vault synced: %s" (string-trim result)))))))

(defun org-vault-sync-push ()
  "Commit and push changes to remote on Emacs exit."
  (when (and (file-directory-p org-vault-sync-directory)
             (org-vault-sync--has-changes-p))
    (let ((default-directory org-vault-sync-directory))
      (message "Syncing org vault: committing and pushing changes...")
      (shell-command "git add -A")
      (let ((timestamp (format-time-string "%Y-%m-%d %H:%M:%S")))
        (shell-command (format "git commit -m 'Auto-sync: %s'" timestamp)))
      (let ((result (shell-command-to-string "git push 2>&1")))
        (if (string-match-p "error\\|fatal" result)
            (message "Org vault push failed: %s" result)
          (message "Org vault synced: pushed changes"))))))

;; Pull on startup (standalone Emacs, or daemon init)
(add-hook 'emacs-startup-hook #'org-vault-sync-pull)

;; Pull when a new emacsclient frame connects (daemon mode)
(add-hook 'server-after-make-frame-hook #'org-vault-sync-pull)

;; Push on exit (standalone, or daemon shutdown)
(add-hook 'kill-emacs-hook #'org-vault-sync-push)

;; Push when a client frame is deleted (daemon mode)
(add-hook 'delete-frame-functions
          (lambda (_frame)
            (when (daemonp)
              (org-vault-sync-push))))

(provide 'org-vault-sync)
;;; org-vault-sync.el ends here
