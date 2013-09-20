(import (srfi 9))
(import (srfi 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Types

(define-record-type grammar
  (make-grammar name rules tokens)
  grammar?
  (name   grammar-name)
  (rules  grammar-rules)
  (tokens grammar-tokens))

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

(define-record-type string-token
  (make-string-token str)
  string-token?
  (str string-token-value))

(define-record-type pattern-token
  (make-pattern-token str)
  pattern-token?
  (str pattern-token-value))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reading

(define (list->grammar l)
  (let
    ((name (get-alist-value 'NAME l))
     (rules (map-alist-values list->rule (get-alist-value 'RULES l)))
     (tokens (map-alist-values list->token (get-alist-value 'TOKENS l))))
    (make-grammar name rules tokens)))

(define (list->rule l)
  (if (pair? l)
    (let*
      ((operator (car l))
       (operands (cdr l))
       (constructor
         (cond
           ((eq? operator 'SEQ) make-seq-rule)
           ((eq? operator 'CHOICE) make-choice-rule))))
      (apply constructor (map list->rule operands)))
    (make-sym-rule l)))

(define (list->token l)
  (if (pair? l)
    (make-pattern-token (cadr l))
    (make-string-token l)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Printing

(define (grammar->list g)
  (list
    (list 'NAME (grammar-name g))
    (list 'RULES
          (map-alist-values rule->list (grammar-rules g)))
    (list 'TOKENS
          (map-alist-values token->list (grammar-tokens g)))))

(define (rule->list r)
  (cond
    ((choice-rule? r)
     (list 'CHOICE
           (rule->list (choice-rule-left r))
           (rule->list (choice-rule-right r))))
    ((seq-rule? r)
     (list 'SEQ
           (rule->list (seq-rule-left r))
           (rule->list (seq-rule-right r))))
    ((sym-rule? r)
     (sym-rule-id r))))

(define (token->list t)
  (cond
    ((string-token? t)
     (string-token-value t))
    ((pattern-token? t)
     (list 'PATTERN (pattern-token-value t)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helpers

(define (get-alist-value key alist)
  (cadr (assq key alist)))
(define (map-alist-values f alist)
  (map (lambda (entry) (list (car entry) (f (cadr entry)))) alist))

