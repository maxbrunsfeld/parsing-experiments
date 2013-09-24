(define-library (tree-sitter)
  (export

    ;; grammar
    make-grammar
    make-choice-rule
    make-seq-rule
    make-sym-rule
    make-string-token
    make-pattern-token
    make-char-token
    make-char-class-token
    rule-end
    grammar?
    grammar-name
    grammar-rules
    grammar-tokens
    grammar->c-code
    list->grammar
    list->rule
    grammar->list
    rule->list
    rule-transitions

    ;; compiler
    tokens->state-machine

    ;; code-gen
    c-include

    ;; state-machine
    make-lr-state
    make-lr-item
    lr-state?
    make-lr-state
    lr-state?
    lr-state-items

    ;; helpers
    alist-merge)

  (import (chibi))
  (include
    "grammar.scm"
    "compile.scm"
    "lr.scm"
    "code-gen.scm"
    ))
