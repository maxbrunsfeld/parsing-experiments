#include "compiler.h"
#include "grammar.h"
#include "check.h"
#include <stdlib.h>

/* --- Grammar --- */
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

/* --- Rules --- */
TSRule * ts_rule_new_sym(TSSymbolId id)
{
  TSRule* rule = malloc(sizeof(*rule));
  rule->type = TSRuleTypeSym;
  rule->impl.symbol_id = id;
  return rule;
}

TSRule * ts_rule_new_choice(TSRule *left, TSRule *right)
{
  TSRule* rule = malloc(sizeof(TSRule));
  rule->type = TSRuleTypeChoice;
  rule->impl.binary.left = left;
  rule->impl.binary.right = right;
  return rule;
}

TSRule * ts_rule_new_seq(TSRule *left, TSRule *right)
{
  TSRule* rule = malloc(sizeof(TSRule));
  rule->type = TSRuleTypeSeq;
  rule->impl.binary.left = left;
  rule->impl.binary.right = right;
  return rule;
}

TSRule * ts_rule_new_string(const char *value)
{
  TSRule *result = malloc(sizeof(TSRule));
  result->type = TSRuleTypeString;
  result->impl.string = value;
  return result;
}

TSRule * ts_rule_new_pattern(const char *value)
{
  TSRule *result = malloc(sizeof(TSRule));
  result->type = TSRuleTypePattern;
  result->impl.string = value;
  return result;
}

TSRule * ts_rule_new_end()
{
  TSRule* rule = malloc(sizeof(TSRule));
  rule->type = TSRuleTypeEnd;
  return rule;
}

void ts_rule_free(TSRule *rule)
{
  free(rule);
}

int ts_rule_eq(TSRule *left, TSRule *right)
{
  if (left->type != right->type)
    return 0;
  switch (left->type) {
    case TSRuleTypeSym:
      return (left->impl.symbol_id == right->impl.symbol_id);
    case TSRuleTypeEnd:
      return 1;
    default:
      return (
        ts_rule_eq(
          left->impl.binary.left,
          right->impl.binary.left) &&
        ts_rule_eq(
          left->impl.binary.right,
          right->impl.binary.right));
  }
}
