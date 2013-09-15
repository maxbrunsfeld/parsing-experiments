#include "compiler.h"

struct TSToken {
  const char *pattern;
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
  int rule_count;
  int token_count;
  TSRule **rules;
  TSToken **tokens;
  const char **symbol_names;
};
