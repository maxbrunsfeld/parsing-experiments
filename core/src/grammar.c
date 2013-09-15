#include "compiler.h"
#include "grammar.h"
#include <stdlib.h>

TSGrammar * ts_grammar_new(
  int rule_count,
  int token_count,
  TSRule **rules,
  TSToken **tokens,
  const char **symbol_names)
{
  TSGrammar* grammar = malloc(sizeof(TSGrammar));
  grammar->rule_count = rule_count;
  grammar->token_count = token_count;
  grammar->rules = rules;
  grammar->tokens = tokens;
  grammar->symbol_names = symbol_names;
  return grammar;
}

void ts_grammar_free(TSGrammar *grammar)
{
  free(grammar);
}
