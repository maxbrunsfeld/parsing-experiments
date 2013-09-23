TODO
====

* Create lexical analyzer from tokens

  * Compile tokens to FSA
    * Determine how to represent FSA.
    * Convert string tokens to sequences of characters
      - When grammar is serialized, tokens should still
        be shown as strings. This means we represent
        the tokens as strings, but convert them to an
        easier-to-work-with form before compilation.
    * Convert pattern tokens to rule trees
      * '|' -> choice
      * '+' -> repeat
    * Compute possible transitions for each rule type
    * Group token states into overall states

  * Compile FSA to C code

  * Make runtime library for lexical analyzer
    * syntax tree and node data structures
      - malloc'd in a batch, not once per node
