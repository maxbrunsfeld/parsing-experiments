(define-library (tree-sitter)
  (export

    ;; grammar
    make-grammar
    make-choice-rule
    make-seq-rule
    make-sym-rule
    make-string-token
    make-pattern-token
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

    ;; code-gen
    c-include

    ;; state-machine
    make-fsm

    ;; helpers
    alist-merge)

  (import (chibi))
  (include
    "grammar.scm"
    "compile.scm"
    "state-machine.scm"
    "code-gen.scm"))
