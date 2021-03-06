;;; modus-mode.el --- Major mode for the Modus language, working with Modusfiles -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Modus Continens
;;
;; Author: Chris Tomy <https://github.com/thevirtuoso1973>
;; Maintainer: Modus Continens
;; Created: December 02, 2021
;; Version: 0.1.0
;; Keywords: languages modus docker modusfile dockerfile
;; Homepage: https://github.com/modus-continens/modus-mode
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;; This was based off the csharp-tree-sitter mode.
;; TODO: licence
;;
;;
;;; Code:

(when t
  (require 'tree-sitter)
  (require 'tree-sitter-hl)
  (require 'tree-sitter-indent)
  (require 'tree-sitter-langs))

;; Vars and functions defined by the above packages:
(defvar tree-sitter-major-mode-language-alist) ;From `tree-sitter-langs'.
(declare-function tree-sitter-indent-mode "ext:tree-sitter-indent")
(declare-function tree-sitter-indent-line "ext:tree-sitter-indent")
(declare-function tree-sitter-hl-mode "ext:tree-sitter-hl")
(declare-function tsc-node-end-position "ext:tree-sitter")
(declare-function tsc-node-start-position "ext:tree-sitter")
(declare-function tree-sitter-node-at-point "ext:tree-sitter")

(defvar modus-mode-syntax-table)
(defvar modus-mode-map)

;; If this doesn't work, it'll throw an error later anyway.
;; Might make debugging annoying but will work offline.
;; TODO: improve
(ignore-errors
  (url-copy-file "https://raw.githubusercontent.com/modus-continens/modus-mode/main/tree-sitter-moduslang/Moduslang.so"
                 "/tmp/Moduslang.so"
                 t)
  (mkdir "~/.tree-sitter/bin" t)
  (copy-file "/tmp/Moduslang.so" "~/.tree-sitter/bin/moduslang.so" t))

;; (copy-directory "./tree-sitter-moduslang/Moduslang" 'tree-sitter-langs--queries-dir)

(defconst modus-mode-tree-sitter-patterns
  [
   (comment) @comment

                                        ; Predicate names

   (head (literal_identifier) @function)
   (literal_definition (literal_identifier) @function.call)
   (operator_definition (literal_identifier) @method.call)

                                        ; TODO: highlight , and ; and the others.

                                        ; Vars

   (head
    (term_list
     (term_definition
      (variable_identifier) @variable.parameter)))

   (variable_identifier) @variable

                                        ; Keywords
   [
    ":-"
    "."
    ] @keyword

                                        ; Strings

   (constant_term) @string
   (constant_escape_sequence) @escape

   (format_string_content) @string
   (f_string_escape_sequence) @escape
   ])

(defgroup modus-mode-indent nil "Indent lines using Tree-sitter as backend"
  :group 'tree-sitter)

(defcustom modus-indent-offset 4
  "Indent offset for modus-tree-sitter-mode."
  :type 'integer
  :group 'modus)

(defcustom tree-sitter-indent-modus-scopes
  '((indent-all . (body))
    (outdent . (head)))
  "`tree-sitter-indent' indentation rules."
  :type 'sexp)

(defvar modus-tree-sitter-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap used in modus-mode buffers.")

(defvar modus-tree-sitter-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?@ "_" table)
    table))

;;;###autoload
(define-derived-mode modus-mode prog-mode "Modusfile"
  "Major mode for editing Modusfiles.
Key bindings:
\\{modus-tree-sitter-mode-map}"
  :group 'modus
  :syntax-table modus-tree-sitter-mode-syntax-table

  (setq-local indent-line-function #'tree-sitter-indent-line)
  ;; (setq-local beginning-of-defun-function #'csharp-beginning-of-defun)
  ;; (setq-local end-of-defun-function #'csharp-end-of-defun)

  ;; https://github.com/ubolonton/emacs-tree-sitter/issues/84
  (unless font-lock-defaults
    (setq font-lock-defaults '(nil)))
  (setq-local tree-sitter-hl-default-patterns modus-mode-tree-sitter-patterns)
  ;; Comments
  ;; (setq-local comment-start "// ")
  ;; (setq-local comment-start-skip "\\(?://+\\|/\\*+\\)\\s *")
  ;; (setq-local comment-end "")

  (tree-sitter-hl-mode)
  (tree-sitter-indent-mode))

(add-to-list 'tree-sitter-major-mode-language-alist '(modus-mode . moduslang))

;;;###autoload
(add-to-list 'auto-mode-alist (cons "\\Modusfile$" 'modus-mode))

(provide 'modus-mode)

;;; modus-mode.el ends here
