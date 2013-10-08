#include "compiler.h"
#include "grammar.h"
#include <stdlib.h>

TSGrammar * ts_grammar_new(
  const char *name,
  int rule_count,
  const char **rule_names,
  const TSRule **rules)
{
  TSGrammar* grammar = malloc(sizeof(TSGrammar));
  grammar->name = name;

  grammar->rule_count = rule_count;
  grammar->rule_names = rule_names;
  grammar->rules = rules;

  return grammar;
}

void ts_grammar_free(TSGrammar *grammar)
{
  free(grammar);
}
