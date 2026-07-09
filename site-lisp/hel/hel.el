;;; hel.el --- Helix Emulation Layer -*- lexical-binding: t -*-
;;
;; Copyright © 2025-2026 Yuriy Artemyev
;;
;; Author: Yuriy Artemyev <anuvyklack@gmail.com>
;; Maintainer: Yuriy Artemyev <anuvyklack@gmail.com>
;; Created: March 27, 2025
;; Version: 0.12.0
;; Homepage: https://github.com/anuvyklack/hel
;; Package-Requires: ((emacs "29.1") (dash "2.19.1") (avy "0.5.0") (pcre2el "1.12") (ultra-scroll "0.6"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Emulation of the Kakoune/Helix text editing model.
;;
;;; Code:

(require 'hel-vars)
(require 'hel-lib)
(require 'hel-macros)
(require 'hel-multiple-cursors-core)
(require 'hel-core)
(require 'hel-commands)
(require 'hel-search)
(require 'hel-scroll)
(require 'hel-integration)
(require 'hel-keybindings)

(provide 'hel)
;;; hel.el ends here
