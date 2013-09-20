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
  sexp_gc_var4(rules, tokens, make_grammar, args);
  sexp_gc_preserve4(ctx, rules, tokens, make_grammar, args);

  make_grammar = ts_scheme_sym(ctx, "make-grammar");

  rules = SEXP_NULL;
  for (int i = grammar->rule_count - 1; i >= 0; i--)
    rules = sexp_cons(ctx, ts_scheme_rule(ctx, grammar->rules[i]), rules);

  tokens = SEXP_NULL;
  for (int i = grammar->token_count - 1; i >= 0; i--)
    tokens = sexp_cons(ctx, ts_scheme_token(ctx, grammar->tokens[i]), tokens);

  args = sexp_cons(ctx, SEXP_TRUE, sexp_list2(ctx, rules, tokens));

  sexp ret = sexp_apply(ctx, make_grammar, args);
  sexp_gc_release4(ctx);
  return ret;
}

sexp ts_scheme_context()
{
  sexp ctx = sexp_make_eval_context(NULL, NULL, NULL, 0, 0);
  sexp_load_standard_env(ctx, NULL, SEXP_SEVEN);
  sexp_load_standard_ports(ctx, NULL, stdin, stdout, stderr, 1);
  sexp_add_module_directory(ctx, sexp_c_string(ctx, TS_SCHEME_SRC_DIR, -1), SEXP_TRUE);
  sexp_eval_string(ctx, "(import (tree-sitter))", -1, sexp_context_env(ctx));
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
