#ifndef __TREE_SITTER_RUNTIME_H__
#define __TREE_SITTER_RUNTIME_H__

#ifdef __cplusplus
extern "C" {
#endif

/* --- Node --- */
typedef struct TSNode TSNode;

TSNode * ts_node_new();
void ts_node_free(TSNode *node);
char * ts_node_name(TSNode *node);
void ts_node_set_name(TSNode *node, char *name);

/* --- Document --- */
typedef struct TSDocument TSDocument;

TSDocument * ts_document_new();
void ts_document_free(TSDocument *doc);
TSNode * ts_document_tree(TSDocument *doc);
char * ts_document_text(TSDocument *doc);
void ts_document_set_text(TSDocument *doc, char *text);
void ts_document_parse(TSDocument *doc);

#ifdef __cplusplus
}
#endif

#endif
