(define-library (tree-sitter)
  (export

    ;; grammar
    make-grammar
    make-choice-rule
    make-seq-rule
    make-sym-rule
    make-string-token
    make-pattern-token
    grammar?
    grammar-name
    grammar-rules
    grammar-tokens
    grammar->c-code
    list->grammar
    grammar->list

    ;; code-gen
    c-include

    ;; state-machine
    make-state-machine)

  (import (chibi))
  (include
    "grammar.scm"
    "compile.scm"
    "state-machine.scm"
    "code-gen.scm"))
