#ifndef __TREE_SITTER_COMPILER_H__
#define __TREE_SITTER_COMPILER_H__

#include "runtime.h"

#ifdef __cplusplus
extern "C" {
#endif

/* --- Rules --- */
typedef struct TSRule TSRule;
typedef int TSSymbolId;
typedef enum {
  TSRuleTypeEnd,
  TSRuleTypeSym,
  TSRuleTypeChoice,
  TSRuleTypeSeq,
  TSRuleTypeString,
  TSRuleTypePattern
} TSRuleType;

TSRule * ts_rule_new_sym(TSSymbolId id);
TSRule * ts_rule_new_choice(TSRule *left, TSRule *right);
TSRule * ts_rule_new_seq(TSRule *left, TSRule *right);
TSRule * ts_rule_new_string(const char *string);
TSRule * ts_rule_new_pattern(const char *string);
TSRule * ts_rule_new_end();
void ts_rule_free(TSRule *rule);
int ts_rule_eq(TSRule *rule1, TSRule *rule2);

/* --- Grammar --- */
typedef struct TSGrammar TSGrammar;

TSGrammar * ts_grammar_new(
  const char *name,
  const int rule_count,
  const char **rule_names,
  const TSRule **rules);
void ts_grammar_free(TSGrammar *grammar);
void ts_grammar_compile();

/* --- Compiler --- */
typedef struct TSCompiler TSCompiler;

TSCompiler * ts_compiler_new(TSGrammar *grammar);
char * ts_compiler_c_code(TSCompiler *compiler);
void ts_compiler_free(TSCompiler *compiler);

#ifdef __cplusplus
}
#endif

#endif
