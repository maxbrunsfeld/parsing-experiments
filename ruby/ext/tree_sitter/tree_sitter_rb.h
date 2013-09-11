#ifndef RB_TREE_SITTER_H
#define RB_TREE_SITTER_H

#include "ruby.h"
#include "tree_sitter/compiler.h"

extern VALUE cDocument;
extern VALUE cNode;
extern VALUE cCompiler;

void Init_document();
void Init_compiler();

#endif
