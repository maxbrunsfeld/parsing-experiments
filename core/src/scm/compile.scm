(import (chibi))

(define (grammar->c-code g)
  (state-machine->c-code
    (grammar->state-machine g)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compilation

(define (grammar->state-machine g)
  (make-lr-state '()))

(define (tokens->state-machine tokens)
  (make-lr-state '()))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; code generation

(define (state-machine->c-code machine) "some c code")

