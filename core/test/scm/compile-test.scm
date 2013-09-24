(test-group "compiling a set of tokens to a state machine"
  (let* ((tokens '((plus "+")
                   (times "*")
                   (dog "dog")
                   (cat "cat")))
         (machine (tokens->state-machine tokens)))

    (it "is an LR state"
      (lr-state? machine))

    (test-group "finding the initial items"
      (let ((items (lr-state-items machine)))

        (it "gets an item for each of the tokens"
          (equal?
            items
            '()))
        ))
    ))
