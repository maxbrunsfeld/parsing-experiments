#ifndef __RB_TREE_SITTER_H__
#define __RB_TREE_SITTER_H__

#include "ruby.h"
#include "tree-sitter.h"

extern VALUE cDocument;
extern VALUE cGrammar;
extern VALUE cNode;

void Init_tree_sitter();
void Init_document();
void Init_grammar();

#endif
