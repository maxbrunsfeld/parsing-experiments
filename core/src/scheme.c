#include "grammar.h"
#include "scheme.h"
#include <string.h>
#include "install.h"

static inline sexp ts_scheme_sym(sexp ctx, const char *name)
{
  return sexp_env_ref(sexp_context_env(ctx), sexp_intern(ctx, name, -1), NULL);
}

static sexp ts_scheme_rule(sexp ctx, TSRule *rule)
{
  switch (rule->type) {
    case TSRuleTypeSym:
      {
        /* sexp make_sym_rule = ts_scheme_sym(ctx, "make-sym-rule"); */
        /* ts_rule_id(rule); */
        break;
      }
    case TSRuleTypeSeq:
      {
        /* sexp make_seq = ts_scheme_sym(ctx, "make-seq-rule"); */
        break;
      }
    case TSRuleTypeChoice:
      {
        /* sexp make_choice = ts_scheme_sym(ctx, "make-choice-rule"); */
        break;
      }
    case TSRuleTypeEnd:
      {
        return SEXP_FALSE;
        break;
      }
  }

  return SEXP_TRUE;
}

static sexp ts_scheme_token(sexp ctx, TSToken *token)
{
  /* sexp make_token = ts_scheme_sym(ctx, "make-grammar-token"); */
  return SEXP_NULL;
}

sexp ts_scheme_grammar(sexp ctx, TSGrammar *grammar)
{
  sexp_gc_var2(rules, tokens);
  sexp_gc_preserve2(ctx, rules, tokens);
  sexp make_grammar = ts_scheme_sym(ctx, "make-grammar");

  rules = SEXP_NULL;
  for (int i = grammar->rule_count - 1; i >= 0; i--)
    rules = sexp_cons(ctx, ts_scheme_rule(ctx, grammar->rules[i]), rules);

  tokens = SEXP_NULL;
  for (int i = grammar->token_count - 1; i >= 0; i--)
    tokens = sexp_cons(ctx, ts_scheme_token(ctx, grammar->tokens[i]), tokens);

  sexp ret = sexp_apply(ctx, make_grammar, sexp_list2(ctx, rules, tokens));
  sexp_gc_release2(ctx);
  return ret;
}

sexp ts_scheme_context(const char *file_name)
{
  sexp ctx = sexp_make_eval_context(NULL, NULL, NULL, 0, 0);
  sexp_load_standard_env(ctx, NULL, SEXP_SEVEN);
  sexp_load_standard_ports(ctx, NULL, stdin, stdout, stderr, 1);

  char file_path[strlen(TS_SCHEME_SRC_DIR) + strlen(file_name) + 1];
  strcpy(file_path, TS_SCHEME_SRC_DIR);
  strcat(file_path, file_name);
  sexp_load(ctx, sexp_c_string(ctx, file_path, -1), NULL);

  return ctx;
}

sexp ts_scheme_call(sexp ctx, const char *fn_name, sexp arg)
{
  sexp fn = ts_scheme_sym(ctx, fn_name);
  sexp args = sexp_list1(ctx, arg);
  return sexp_apply(ctx, fn, args);
}

char * ts_scheme_string(sexp string)
{
  return sexp_string_data(string);
}
