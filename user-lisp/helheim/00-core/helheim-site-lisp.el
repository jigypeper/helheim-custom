;;; helheim-site-lisp.el          -*- lexical-binding: t; no-byte-compile: t -*-
;;; Commentary:
;;
;; Offline / air-gapped mode for helheim-custom.
;;
;; All packages are loaded from site-lisp/ via `load-path' set up in
;; early-init.el. No package manager is needed; `:install' keywords in
;; `setup' forms become no-ops, and `elpaca-wait' is silenced.
;;
;;; Code:

;; These are the five packages that elpaca/straight install eagerly
;; before helheim-setup.el runs. In site-lisp mode they are already on
;; load-path, so just require them directly.
(require 'dash)
(require 'f)
(require 's)
(require 'setup)
(require 'blackout)

;; `elpaca-wait' is called in helheim-core.el; make it a no-op.
(defalias 'elpaca-wait #'ignore)

;;; .
(provide 'helheim-site-lisp)
;;; helheim-site-lisp.el ends here
