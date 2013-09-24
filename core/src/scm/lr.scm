(import (srfi 9))

(define-record-type lr-state
  (make-lr-state items)
  lr-state?
  (items lr-state-items)
  (transitions lr-state-transitions))

(define-record-type lr-item
  (make-lr-item name remaining-rule)
  lr-item?
  (name lr-item-name)
  (remaining-rule lr-item-remaining-rule))

(define (rules->items rules)
  '())

(define (item-transitions item)
  (let ((name (lr-item-name item)))
    (map
      (lambda (entry)
        (list (car entry)
              (make-lr-item name (cadr entry))))
      (rule-transitions (lr-item-remaining-rule item)))))
