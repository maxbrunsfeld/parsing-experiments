#include "compiler.h"
#include "grammar.h"
#include <stdlib.h>

TSGrammar * ts_grammar_new(
  const char *name,
  int rule_count,
  const char **rule_names,
  const TSRule **rules,
  int token_count,
  const char **token_names,
  const TSToken **tokens)
{
  TSGrammar* grammar = malloc(sizeof(TSGrammar));
  grammar->name = name;

  grammar->rule_count = rule_count;
  grammar->rule_names = rule_names;
  grammar->rules = rules;

  grammar->token_count = token_count;
  grammar->token_names = token_names;
  grammar->tokens = tokens;

  return grammar;
}

void ts_grammar_free(TSGrammar *grammar)
{
  free(grammar);
}
