#include "tree_sitter_rb.h"

VALUE cCompiler;

static VALUE wrap_rule(TSRule *rule)
{
  return Qnil;
}

static TSGrammar * unwrap_grammar(VALUE grammar)
{
  VALUE grammar_hash = rb_funcall(grammar, rb_intern("internal_representation"), 0);
  VALUE tokens_array = rb_hash_aref(grammar_hash, ID2SYM(rb_intern("tokens")));
  VALUE rules_array = rb_hash_aref(grammar_hash, ID2SYM(rb_intern("rules")));
  VALUE names_array = rb_hash_aref(grammar_hash, ID2SYM(rb_intern("symbol_names")));

  int rule_count = RARRAY_LEN(rules_array);
  int token_count = RARRAY_LEN(tokens_array);
  TSRule **rules = calloc(rule_count, sizeof(TSRule *));
  TSToken **tokens = calloc(token_count, sizeof(TSToken *));
  for (int i = 0; i < rule_count; i++) {
    /* rules[i] = unwrap_rule(); */
  }

  return NULL;
}

static VALUE compiler_c_code(VALUE self)
{
  return rb_str_new("", 0);
}

void Init_compiler(VALUE module)
{
  cCompiler = rb_const_get(module, rb_intern("Compiler"));
  rb_define_method(cCompiler, "c_code", compiler_c_code, 0);
}
