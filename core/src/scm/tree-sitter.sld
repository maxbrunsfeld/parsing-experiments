(define-library (tree-sitter)
  (export
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
    list->rule
    rule->list
    list->grammar
    grammar->list)
  (import (chibi))
  (include
    "grammar.scm"
    "compile.scm"))
