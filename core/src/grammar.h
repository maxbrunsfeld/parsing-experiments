#include "rule.h"

// types
typedef struct IPGrammar {
  IPRule *rules;
  int rule_count;
} IPGrammar;

// constructors
IPGrammar * ip_grammar_new();
void ip_grammar_free();

