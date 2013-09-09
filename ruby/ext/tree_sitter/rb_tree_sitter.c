#include "rb_tree_sitter.h"

VALUE mTreeSitter;

void Init_tree_sitter()
{
  mTreeSitter = rb_const_get(rb_cObject, rb_intern("TreeSitter"));
  Init_document(mTreeSitter);
  Init_grammar(mTreeSitter);
}
