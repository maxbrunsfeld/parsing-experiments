#ifndef __TREE_SITTER_COMPILER_H__
#define __TREE_SITTER_COMPILER_H__

#include "runtime.h"

#ifdef __cplusplus
extern "C" {
#endif

/* --- Types --- */
typedef struct TSCompiler TSCompiler;
typedef struct TSArray TSArray;
typedef struct TSGrammar TSGrammar;
typedef struct TSRule TSRule;
typedef struct TSToken TSToken;
typedef int TSSymbolId;
typedef enum {
  TSRuleTypeEnd,
  TSRuleTypeSym,
  TSRuleTypeChoice,
  TSRuleTypeSeq
} TSRuleType;

/* --- Array --- */
TSArray *ts_array_new(int capacity);
TSArray *ts_array_copy(TSArray *array);
void ts_array_free(TSArray *array);

void * ts_array_get(TSArray *array, int i);
void * ts_array_remove(TSArray *array, int i);
void * ts_array_pop(TSArray *array);
int ts_array_set(TSArray *array, int i, void *el);
int ts_array_push(TSArray *array, void *el);
int ts_array_length(TSArray *array);
void ts_array_clear(TSArray *array);

#define ts_array_each(array, element_type, element_name, index_name) \
  element_type *element_name = (element_type *)ts_array_get(array, 0); \
  int __max_ ## index_name = ts_array_length(array); \
  for ( \
    int index_name = 0; \
    element_name; \
    (element_name = (++index_name < __max_ ## index_name) ? (element_type *)ts_array_get(array, index_name) : NULL))

/* --- Rule --- */
typedef struct TSTransition {
  TSSymbolId symbol_id;
  TSRule *rule;
} TSTransition;

TSRule * ts_rule_new_sym(TSSymbolId id);
TSRule * ts_rule_new_choice(TSRule *left, TSRule *right);
TSRule * ts_rule_new_seq(TSRule *left, TSRule *right);
TSRule * ts_rule_new_end();
void ts_rule_free(TSRule *rule);

TSSymbolId ts_rule_id(TSRule *rule);
TSRule * ts_rule_left(TSRule *rule);
TSRule * ts_rule_right(TSRule *rule);
TSArray * ts_rule_transitions(TSRule *rule);
int ts_rule_eq(TSRule *rule1, TSRule *rule2);

/* --- Token --- */
TSToken * ts_token_new_pattern(const char *pattern);
TSToken * ts_token_new_string(const char *pattern);

/* --- Grammar --- */
TSGrammar * ts_grammar_new(
  const char *name,
  const int rule_count,
  const char **rule_names,
  const TSRule **rules,
  const int token_count,
  const char **token_names,
  const TSToken **tokens);
void ts_grammar_free(TSGrammar *grammar);
void ts_grammar_compile();

/* --- Compiler --- */
TSCompiler * ts_compiler_new(TSGrammar *grammar);
char * ts_compiler_c_code(TSCompiler *compiler);
void ts_compiler_free(TSCompiler *compiler);

#ifdef __cplusplus
}
#endif

#endif
