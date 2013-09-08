#ifndef __RULE_H__
#define __RULE_H__

#include "array.h"

// types
typedef int IPSymbolId;

typedef enum {
  IPRuleTypeEnd,
  IPRuleTypeSym,
  IPRuleTypeChoice,
  IPRuleTypeSeq
} IPRuleType;

typedef struct IPRule {
  IPRuleType type;
  union {
    IPSymbolId symbol_id;
    struct {
      struct IPRule *left;
      struct IPRule *right;
    } binary;
  } impl;
} IPRule;

typedef struct IPTransition {
  IPSymbolId symbol_id;
  IPRule *rule;
} IPTransition;

// constructors
IPRule * ip_rule_new_sym(IPSymbolId id);
IPRule * ip_rule_new_choice(IPRule *left, IPRule *right);
IPRule * ip_rule_new_seq(IPRule *left, IPRule *right);
IPRule * ip_rule_new_end();
void ip_rule_free();

// accessors
IPSymbolId ip_rule_id(IPRule *rule);
IPRule * ip_rule_left(IPRule *rule);
IPRule * ip_rule_right(IPRule *rule);
IPArray * ip_rule_transitions(IPRule *rule);

// comparison
int ip_rule_eq(IPRule *rule1, IPRule *rule2);

#endif
