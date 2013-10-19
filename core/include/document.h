#ifndef __TREE_SITTER_DOCUMENT_H__
#define __TREE_SITTER_DOCUMENT_H__

#ifdef __cplusplus
extern "C" {
#endif

#define BREAK raise(SIGINT)

/* --- Node --- */
typedef int TSNodeType;
typedef struct TSNode TSNode;
TSNode * ts_node_new(TSNodeType type, int child_node_count, const TSNode **child_nodes);
TSNode ** ts_node_children(TSNode *n, int *count);
void ts_node_add_child(TSNode *n, const TSNode *child);
int ts_node_eq(TSNode *left, TSNode *right);
char * ts_node_to_string(TSNode *node, const char **rule_names);

/* --- Tree --- */
typedef struct TSTree TSTree;
TSTree * ts_tree_new(const char **rule_names);
TSNode * ts_tree_add_node(TSTree *tree, TSNodeType type);
TSNode * ts_tree_node(TSTree *tree, int i);
TSNode * ts_tree_root(TSTree *t);
void ts_tree_set_root(TSTree *t, TSNode *node);
char * ts_tree_to_string(TSTree *tree);
void ts_tree_free(TSTree *);

/* --- Document --- */
typedef struct TSDocument TSDocument;
TSDocument * ts_document_new();
void ts_document_free(TSDocument *doc);
TSNode * ts_document_tree(TSDocument *doc);
char * ts_document_text(TSDocument *doc);
void ts_document_set_text(TSDocument *doc, char *text);

#ifdef __cplusplus
}
#endif

#endif
