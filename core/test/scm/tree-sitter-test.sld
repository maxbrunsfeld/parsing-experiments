(define-library (tree-sitter-test)
  (import
    (chibi)
    (chibi test)
    (srfi 1)
    (tree-sitter))
  (include
    "test-helper.scm"
    "grammar-test.scm"
    "state-machine-test.scm"
    "code-gen-test.scm")
  (begin
    (test-exit)))