#ifndef __TREE_SITTER_H__
#define __TREE_SITTER_H__

#include <stdlib.h>

/* --- Types --- */
typedef struct TSArray TSArray;
typedef struct TSDocument TSDocument;
typedef struct TSGrammar TSGrammar;
typedef struct TSNode TSNode;
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
  element_type *element_name = ts_array_get(array, 0); \
  int __max_ ## index_name = ts_array_length(array); \
  for ( \
    int index_name = 0; \
    element_name; \
    (element_name = (++index_name < __max_ ## index_name) ? ts_array_get(array, index_name) : NULL))

/* --- Node --- */
TSNode * ts_node_new();
void ts_node_free(TSNode *node);
char * ts_node_name(TSNode *node);
void ts_node_set_name(TSNode *node, char *name);

/* --- Document --- */
TSDocument * ts_document_new();
void ts_document_free(TSDocument *doc);

TSNode * ts_document_tree(TSDocument *doc);
char * ts_document_text(TSDocument *doc);
void ts_document_set_text(TSDocument *doc, char *text);
void ts_document_parse(TSDocument *doc);

/* --- Rule --- */
typedef struct TSTransition {
  TSSymbolId symbol_id;
  TSRule *rule;
} TSTransition;

TSRule * ts_rule_new_sym(TSSymbolId id);
TSRule * ts_rule_new_choice(TSRule *left, TSRule *right);
TSRule * ts_rule_new_seq(TSRule *left, TSRule *right);
TSRule * ts_rule_new_end();
void ts_rule_free();

TSSymbolId ts_rule_id(TSRule *rule);
TSRule * ts_rule_left(TSRule *rule);
TSRule * ts_rule_right(TSRule *rule);
TSArray * ts_rule_transitions(TSRule *rule);
int ts_rule_eq(TSRule *rule1, TSRule *rule2);

/* --- Token --- */
TSToken * ts_token_new(char *pattern);

/* --- Grammar --- */
TSGrammar * ts_grammar_new(
  int rule_count,
  int token_count,
  TSRule **rules,
  TSToken **tokens,
  char **symbol_names);
void ts_grammar_free();
void ts_grammar_compile();

#endif
