#include "rule.h"
#include "stdlib.h"
#include "check.h"

// constructors
IPRule * ip_rule_new_sym(IPSymbolId id)
{
  IPRule* rule = malloc(sizeof(*rule));
  rule->type = IPRuleTypeSym;
  rule->impl.symbol_id = id;
  return rule;
}

IPRule * ip_rule_new_choice(IPRule *left, IPRule *right)
{
  IPRule* rule = malloc(sizeof(IPRule));
  rule->type = IPRuleTypeChoice;
  rule->impl.binary.left = left;
  rule->impl.binary.right = right;
  return rule;
}

IPRule * ip_rule_new_seq(IPRule *left, IPRule *right)
{
  IPRule* rule = malloc(sizeof(IPRule));
  rule->type = IPRuleTypeSeq;
  rule->impl.binary.left = left;
  rule->impl.binary.right = right;
  return rule;
}

IPRule * ip_rule_new_end()
{
  IPRule* rule = malloc(sizeof(IPRule));
  rule->type = IPRuleTypeEnd;
  return rule;
}

void ip_rule_free(IPRule *rule)
{
  free(rule);
}

// accessors
IPSymbolId ip_rule_id(IPRule *rule)
{
  switch (rule->type) {
    case IPRuleTypeSym:
      return rule->impl.symbol_id;
    default:
      return 0;
  }
}

IPRule * ip_rule_left(IPRule *rule)
{
  switch (rule->type) {
    case IPRuleTypeChoice:
    case IPRuleTypeSeq:
      return rule->impl.binary.left;
    default:
      return 0;
  }
}

IPRule * ip_rule_right(IPRule *rule)
{
  switch (rule->type) {
    case IPRuleTypeChoice:
    case IPRuleTypeSeq:
      return rule->impl.binary.right;
    default:
      return 0;
  }
}

IPTransition * ip_transition_new(IPSymbolId symbol_id, IPRule *rule)
{
  IPTransition *transition = malloc(sizeof(*transition));
  check_mem(transition);
  transition->symbol_id = symbol_id;
  transition->rule = rule;
  return transition;
error:
  return NULL;
}

IPArray * ip_rule_transitions(IPRule *rule)
{
  IPArray *result = NULL;

  switch (rule->type) {
    case IPRuleTypeSym:
      {
        result = ip_array_new(20);
        check_mem(result);
        IPTransition *transition = ip_transition_new(ip_rule_id(rule), ip_rule_new_end());
        ip_array_push(result, transition);
        break;
      }
    case IPRuleTypeChoice:
      {
        // Start with the left transitions.
        IPArray *left_transitions = ip_rule_transitions(ip_rule_left(rule));
        IPArray *right_transitions = ip_rule_transitions(ip_rule_right(rule));
        result = ip_array_copy(left_transitions);

        // For each right transition,
        ip_array_each(right_transitions, IPTransition, transition, i) {
          IPSymbolId symbol_id = transition->symbol_id;
          IPRule *rule = transition->rule;

          // try to find the left transition for the same symbol.
          int left_index = -1;
          IPRule *left_rule = NULL;
          ip_array_each(left_transitions, IPTransition, left_transition, j) {
            if (left_transition->symbol_id == symbol_id) {
              left_index = j;
              left_rule = left_transition->rule;
              break;
            }
          }

          // If there is one, replace it with a choice between the left
          // and right transitions' rules. Otherwise, add a new transition.
          if (left_rule) {
            IPRule *choice = ip_rule_new_choice(left_rule, rule);
            IPTransition *t = ip_transition_new(symbol_id, choice);
            ip_array_set(result, left_index, t);
          } else {
            IPTransition *t = ip_transition_new(symbol_id, rule);
            ip_array_push(result, t);
          }
        }

        break;
      }
    case IPRuleTypeSeq:
      {
        // Start with the left transitions.
        IPArray *left_transitions = ip_rule_transitions(ip_rule_left(rule));
        IPRule *right_rule = ip_rule_right(rule);
        result = ip_array_copy(left_transitions);

        // For each one, replace the rule with a sequence containing itself
        // and the right side of the sequence.
        ip_array_each(left_transitions, IPTransition, transition, i) {
          IPRule *rule = transition->rule;
          IPRule *new_rule = (rule->type == IPRuleTypeEnd) ?
            right_rule:
            ip_rule_new_seq(rule, right_rule);
          transition->rule = new_rule;
        }
        break;
      }
    case IPRuleTypeEnd:
      {
        result = ip_array_new(0);
        break;
      }
  }

  return result;
error:
  return NULL;
}

// comparison
int ip_rule_eq(IPRule *left, IPRule *right)
{
  if (left->type != right->type) return 0;
  switch (left->type) {
    case IPRuleTypeSym:
      return (ip_rule_id(left) == ip_rule_id(right));
    case IPRuleTypeEnd:
      return 1;
    default:
      return (
        ip_rule_eq(ip_rule_left(left), ip_rule_left(right)) &&
        ip_rule_eq(ip_rule_right(left), ip_rule_right(right)));
  }
}
