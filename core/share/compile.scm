(import (chibi))
(import (srfi 9))

(display "loaded compile.scm!")
(newline)

(define-record-type choice-rule
  (make-choice-rule left right)
  choice-rule?
  (left choice-rule-left)
  (right choice-rule-right))

(define-record-type seq-rule
  (make-seq-rule left right)
  seq-rule?
  (left seq-rule-left)
  (right seq-rule-right))

(define-record-type sym-rule
  (make-sym-rule id)
  sym-rule?
  (id sym-rule-id))

(define-record-type grammar
  (make-grammar rules tokens)
  grammar?
  (rules  grammar-rules)
  (tokens grammar-tokens))

(define (grammar->c-code g)
  (display g)
  "some c code")

(newline)
(display "it works")
(newline)
