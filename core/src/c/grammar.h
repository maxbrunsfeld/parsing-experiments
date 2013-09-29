#include "compiler.h"

struct TSToken {
  int is_pattern;
  const char *value;
};

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

struct TSGrammar {
  const char *name;
  int rule_count;
  const char **rule_names;
  const TSRule **rules;
  int token_count;
  const char **token_names;
  const TSToken **tokens;
};
