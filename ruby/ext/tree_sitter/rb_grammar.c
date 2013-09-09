#include "rb_tree_sitter.h"

VALUE cGrammar;

void Init_grammar(VALUE module)
{
  cGrammar = rb_define_class_under(module, "Grammar", rb_cObject);
}
