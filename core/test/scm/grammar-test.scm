(test-group "reading a grammar"
  (let*
    ((serial-grammar
       '((NAME "my-language")
         (RULES
           ((sums (SEQ sums (SEQ plus products)))
            (products (SEQ products (SEQ times value)))
            (value (CHOICE number variable))))
         (TOKENS
           ((plus "+")
            (times "*")
            (number (PATTERN "\d+"))
            (variable (PATTERN "\a\w+"))))))

     (subject (list->grammar serial-grammar)))

    (it "returns a grammar"
      (grammar? subject))

    (it "gets the grammar's name"
      (equal? (grammar-name subject) "my-language"))

    (test-group "the rules"
      (let ((rules (grammar-rules subject)))

        (it "creates one for each entry in the list"
          (equal?
            (map car rules)
            '(sums products value)))

        (it "handles choices"
          (equal?
            (cadr (assq 'value rules))
            (make-choice-rule
              (make-sym-rule 'number)
              (make-sym-rule 'variable))))

        (it "handles sequences"
          (equal?
            (cadr (assq 'products rules))
            (make-seq-rule
              (make-sym-rule 'products)
              (make-seq-rule
                (make-sym-rule 'times)
                (make-sym-rule 'value)))))))

    (test-group "the tokens"
      (let ((tokens (grammar-tokens subject)))

        (it "creates one for every item in the list"
          (equal?
            (map car tokens)
            '(plus times number variable)))

        (it "handles string tokens"
          (equal?
            (cadr (assq 'plus tokens))
            (make-string-token "+")))

        (it "handles pattern tokens"
          (equal?
            (cadr (assq 'number tokens))
            (make-pattern-token "\d+")))))

    (test-group "re-serializing the grammar"
      (it "is the same as the original input"
        (equal?
          (grammar->list subject)
          serial-grammar)))))
