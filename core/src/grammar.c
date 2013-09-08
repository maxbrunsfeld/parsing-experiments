#include "grammar.h"
#include "stdlib.h"
#include "chibi/eval.h"

IPGrammar * ip_grammar_new(
  int rule_count,
  int token_count,
  IPRule **rules,
  IPToken **tokens,
  char **symbol_names)
{
  IPGrammar* grammar = malloc(sizeof(IPGrammar));
  return grammar;
}

void ip_grammar_free(IPGrammar *grammar)
{
  free(grammar);
}

IPParser * ip_grammar_compile(IPGrammar *grammar)
{
  sexp ctx = sexp_make_eval_context(NULL, NULL, NULL, 0, 0);
  sexp_load_standard_env(ctx, NULL, SEXP_SEVEN);
  sexp_load_standard_ports(ctx, NULL, stdin, stdout, stderr, 1);

  sexp file_path = sexp_c_string(ctx, "/Users/maxbrunsfeld/workspace/parsing/ink/core/scm/compile.scm", -1);
  sexp_load(ctx, file_path, NULL);

  sexp_destroy_context(ctx);
  return NULL;
}
