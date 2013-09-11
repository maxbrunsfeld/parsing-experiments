#include "compiler.h"
#include "private.h"

struct TSGrammar {
  int rule_count;
  int token_count;
  TSRule **rules;
  TSToken *tokens;
  char **symbol_names;
};

TSGrammar * ts_grammar_new(
  int rule_count,
  int token_count,
  TSRule **rules,
  TSToken **tokens,
  char **symbol_names)
{
  TSGrammar* grammar = malloc(sizeof(TSGrammar));
  return grammar;
}

void ts_grammar_free(TSGrammar *grammar)
{
  free(grammar);
}
