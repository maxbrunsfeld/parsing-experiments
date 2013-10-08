#include "compiler.h"

struct TSRule {
  TSRuleType type;
  union {
    TSSymbolId symbol_id;
    struct {
      struct TSRule *left;
      struct TSRule *right;
    } binary;
    const char *string;
  } impl;
};

struct TSGrammar {
  const char *name;
  int rule_count;
  const char **rule_names;
  const TSRule **rules;
  int token_count;
  const char **token_names;
  const TSRule **tokens;
};
