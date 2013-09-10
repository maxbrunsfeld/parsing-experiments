#include "tree_sitter.h"
#include "private.h"
#include <chibi/eval.h>

void ts_grammar_compile(TSGrammar *grammar)
{
  sexp ctx = sexp_make_eval_context(NULL, NULL, NULL, 0, 0);
  sexp_load_standard_env(ctx, NULL, SEXP_SEVEN);
  sexp_load_standard_ports(ctx, NULL, stdin, stdout, stderr, 1);

  sexp file_path = sexp_c_string(ctx, "/Users/maxbrunsfeld/workspace/parsing/tree-sitter/core/scm/compile.scm", -1);
  sexp_load(ctx, file_path, NULL);

  sexp_destroy_context(ctx);
}
