(import (srfi 9))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Types

(define-record-type fsm
  (make-fsm states transitions)
  fsm?
  (states fsm-states fsm-set-states!)
  (transitions fsm-transitions fsm-set-transitions!))

(define-record-type fsm-state
  (make-fsm-state id value)
  fsm-state?
  (id fsm-state-id)
  (value fsm-state-value))
