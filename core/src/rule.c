#include "tree-sitter.h"
#include "private.h"

struct TSRule {
  TSRuleType type;
  union {
    TSSymbolId symbol_id;
    struct {
      struct TSRule *left;
      struct TSRule *right;
    } binary;
  } impl;
};

// constructors
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

// accessors
TSSymbolId ts_rule_id(TSRule *rule)
{
  switch (rule->type) {
    case TSRuleTypeSym:
      return rule->impl.symbol_id;
    default:
      return 0;
  }
}

TSRule * ts_rule_left(TSRule *rule)
{
  switch (rule->type) {
    case TSRuleTypeChoice:
    case TSRuleTypeSeq:
      return rule->impl.binary.left;
    default:
      return 0;
  }
}

TSRule * ts_rule_right(TSRule *rule)
{
  switch (rule->type) {
    case TSRuleTypeChoice:
    case TSRuleTypeSeq:
      return rule->impl.binary.right;
    default:
      return 0;
  }
}

TSTransition * ts_transition_new(TSSymbolId symbol_id, TSRule *rule)
{
  TSTransition *transition = malloc(sizeof(*transition));
  check_mem(transition);
  transition->symbol_id = symbol_id;
  transition->rule = rule;
  return transition;
error:
  return NULL;
}

TSArray * ts_rule_transitions(TSRule *rule)
{
  TSArray *result = NULL;

  switch (rule->type) {
    case TSRuleTypeSym:
      {
        result = ts_array_new(20);
        check_mem(result);
        TSTransition *transition = ts_transition_new(ts_rule_id(rule), ts_rule_new_end());
        ts_array_push(result, transition);
        break;
      }
    case TSRuleTypeChoice:
      {
        // Start with the left transitions.
        TSArray *left_transitions = ts_rule_transitions(ts_rule_left(rule));
        TSArray *right_transitions = ts_rule_transitions(ts_rule_right(rule));
        result = ts_array_copy(left_transitions);

        // For each right transition,
        ts_array_each(right_transitions, TSTransition, transition, i) {
          TSSymbolId symbol_id = transition->symbol_id;
          TSRule *rule = transition->rule;

          // try to find the left transition for the same symbol.
          int left_index = -1;
          TSRule *left_rule = NULL;
          ts_array_each(left_transitions, TSTransition, left_transition, j) {
            if (left_transition->symbol_id == symbol_id) {
              left_index = j;
              left_rule = left_transition->rule;
              break;
            }
          }

          // If there is one, replace it with a choice between the left
          // and right transitions' rules. Otherwise, add a new transition.
          if (left_rule) {
            TSRule *choice = ts_rule_new_choice(left_rule, rule);
            TSTransition *t = ts_transition_new(symbol_id, choice);
            ts_array_set(result, left_index, t);
          } else {
            TSTransition *t = ts_transition_new(symbol_id, rule);
            ts_array_push(result, t);
          }
        }

        break;
      }
    case TSRuleTypeSeq:
      {
        // Start with the left transitions.
        TSArray *left_transitions = ts_rule_transitions(ts_rule_left(rule));
        TSRule *right_rule = ts_rule_right(rule);
        result = ts_array_copy(left_transitions);

        // For each one, replace the rule with a sequence containing itself
        // and the right side of the sequence.
        ts_array_each(left_transitions, TSTransition, transition, i) {
          TSRule *rule = transition->rule;
          TSRule *new_rule = (rule->type == TSRuleTypeEnd) ?
            right_rule:
            ts_rule_new_seq(rule, right_rule);
          transition->rule = new_rule;
        }
        break;
      }
    case TSRuleTypeEnd:
      {
        result = ts_array_new(0);
        break;
      }
  }

  return result;
error:
  return NULL;
}

// comparison
int ts_rule_eq(TSRule *left, TSRule *right)
{
  if (left->type != right->type) return 0;
  switch (left->type) {
    case TSRuleTypeSym:
      return (ts_rule_id(left) == ts_rule_id(right));
    case TSRuleTypeEnd:
      return 1;
    default:
      return (
        ts_rule_eq(ts_rule_left(left), ts_rule_left(right)) &&
        ts_rule_eq(ts_rule_right(left), ts_rule_right(right)));
  }
}
