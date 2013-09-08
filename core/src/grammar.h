#include "rule.h"
#include "token.h"
#include "array.h"

typedef struct IPGrammar {
  int rule_count;
  int token_count;
  IPRule **rules;
  IPToken *tokens;
  char **symbol_names;
} IPGrammar;

typedef struct IPParser {
} IPParser;

IPGrammar * ip_grammar_new(
  int rule_count,
  int token_count,
  IPRule **rules,
  IPToken **tokens,
  char **symbol_names);

void ip_grammar_free();
IPParser * ip_grammar_compile();
