#ifndef __TREE_SITTER_RUNTIME_H__
#define __TREE_SITTER_RUNTIME_H__

/* --- Types --- */
typedef struct TSDocument TSDocument;
typedef struct TSNode TSNode;

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

#endif
