(import (chibi))

(define (grammar->c-code g)
  (state-machine->c-code
    (grammar->state-machine g)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compilation

(define (grammar->state-machine g)
  (make-state-machine 1 2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; code generation

(define (state-machine->c-code machine) "some c code")
