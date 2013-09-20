#include "compiler.h"
#include "grammar.h"
#include <stdlib.h>
#include "scheme.h"

struct TSCompiler {
  TSGrammar *grammar;
};

TSCompiler * ts_compiler_new(TSGrammar *grammar)
{
  TSCompiler *result = malloc(sizeof(TSCompiler));
  result->grammar = grammar;
  return result;
}

void ts_compiler_free(TSCompiler *compiler)
{
  free(compiler);
}

char * ts_compiler_c_code(TSCompiler *compiler)
{
  sexp ctx = ts_scheme_context();
  sexp grammar = ts_scheme_grammar(ctx, compiler->grammar);
  sexp result = ts_scheme_call(ctx, "grammar->c-code", grammar);
  char *result_string = ts_scheme_string(result);
  sexp_destroy_context(ctx);
  return result_string;
}
