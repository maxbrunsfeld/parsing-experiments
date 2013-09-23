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

(define-record-type char-token
  (make-char-token char)
  char-token?
  (char char-token-value))

(define-record-type char-class-token
  (make-char-class-token char-class)
  char-class-tokens?
  (char-class char-class-token-value))

(define rule-end 'grammar-rule-end)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reading

(define (list->grammar l)
  (let
    ((name (alist-get-value 'NAME l))
     (rules (alist-map-values list->rule (alist-get-value 'RULES l)))
     (tokens (alist-map-values list->token (alist-get-value 'TOKENS l))))
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
;; Transitions

(define (rule-transitions rule)
  (cond
    ((sym-rule? rule)
     (list (list rule rule-end)))
    ((seq-rule? rule)
     (list (list (seq-rule-left rule) (seq-rule-right rule))))
    ((choice-rule? rule)
     (alist-merge
       (rule-transitions (choice-rule-left rule))
       (rule-transitions (choice-rule-right rule))
       make-choice-rule))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Printing

(define (grammar->list g)
  (list
    (list 'NAME (grammar-name g))
    (list 'RULES
          (alist-map-values rule->list (grammar-rules g)))
    (list 'TOKENS
          (alist-map-values token->list (grammar-tokens g)))))

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

(define (display* name x)
  (display name)
  (display x) (newline))

(define (alist-merge l1 l2 merge-proc)
  (let ((result (alist-copy l1)))
    (for-each
      (lambda (entry)
        (let* ((key (car entry))
               (prev-entry (assoc key result)))
          (if prev-entry
            (set-cdr! prev-entry (list (merge-proc (cadr prev-entry) (cadr entry))))
            (append! result (list entry)))))
      l2)
    result))

(define (alist-get-value key alist)
  (cadr (assq key alist)))

(define (alist-map-values f alist)
  (map (lambda (entry) (list (car entry) (f (cadr entry)))) alist))
