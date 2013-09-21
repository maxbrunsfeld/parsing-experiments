(test-group "generating c code"
  (it "works"
    (equal?
      (c-include "something.h")
      "#include \"something.h\""
      ))
  )
