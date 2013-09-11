#include "tree_sitter_rb.h"

VALUE mTreeSitter;

void Init_tree_sitter_rb()
{
  mTreeSitter = rb_const_get(rb_cObject, rb_intern("TreeSitter"));
  Init_document(mTreeSitter);
  Init_compiler(mTreeSitter);
}
