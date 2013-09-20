#include <chibi/eval.h>
#include "compiler.h"

sexp ts_scheme_context();
sexp ts_scheme_grammar(sexp ctx, TSGrammar *grammar);
sexp ts_scheme_call(sexp ctx, const char *fn_name, sexp arg);
char * ts_scheme_string(sexp string);
