#include "tree_sitter_rb.h"

VALUE cDocument;
VALUE cNode;

static VALUE wrap_node(TSNode *node)
{
  VALUE name = ID2SYM(rb_intern(ts_node_name(node)));
  return rb_funcall(cNode, rb_intern("new"), 1, name, NULL);
}

static VALUE wrap_document(TSDocument *document)
{
  return Data_Wrap_Struct(cDocument, 0, ts_document_free, document);
}

static TSDocument * unwrap_document(VALUE self)
{
  TSDocument *document;
  Data_Get_Struct(self, TSDocument, document);
  return document;
}

static VALUE document_new(VALUE class, VALUE grammar)
{
  return wrap_document(ts_document_new());
}

static VALUE document_text(VALUE self)
{
  return rb_str_new2(ts_document_text(unwrap_document(self)));
}

static VALUE document_tree(VALUE self)
{
  TSDocument *document = unwrap_document(self);
  ts_document_parse(document);
  return wrap_node(ts_document_tree(document));
}

static VALUE document_set_text(VALUE self, VALUE text)
{
  ts_document_set_text(unwrap_document(self), StringValueCStr(text));
  return Qnil;
}

void Init_document(VALUE module)
{
  cDocument = rb_const_get(module, rb_intern("Document"));
  cNode = rb_const_get(module, rb_intern("Node"));
  rb_define_singleton_method(cDocument, "new", document_new, 1);
  rb_define_method(cDocument, "text", document_text, 0);
  rb_define_method(cDocument, "text=", document_set_text, 1);
  rb_define_method(cDocument, "tree", document_tree, 0);
}
