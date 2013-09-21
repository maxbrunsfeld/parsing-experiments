(import (srfi 9))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Types

(define-record-type state-machine
  (make-state-machine states transitions)
  state-machine?
  (states
    state-machine-states state-machine-set-states!)
  (transitions
    state-machine-transitions state-machine-set-transitions!))
