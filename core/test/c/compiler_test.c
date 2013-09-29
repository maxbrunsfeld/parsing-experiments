#include "_helper.h"
#include <string.h>

TEST(TSCompiler)
{
  TSGrammar *grammar;
  TSCompiler *compiler;

  const char *rule_names[] = {
    "rule0", "rule1", "rule2", "rule3",
  };

  const TSRule *rules[] = {
    CHOICE(SYM(0), SYM(1)),
    CHOICE(SEQ(SYM(2), SYM(3)), SEQ(SYM(4), SYM(5))),
    SYM(0),
    SYM(1)
  };

  const char *token_names[] = {
    "token0", "token1", "token2"
  };

  const TSToken *tokens[] = {
    PAT("\\d+"),
    PAT("\\w+"),
    STR("+")
  };

  BEFORE_EACH {
    grammar = ts_grammar_new(
      "my-grammar",
      4, rule_names, rules,
      3, token_names, tokens);

    compiler = ts_compiler_new(grammar);
  };

  AFTER_EACH {
    ts_compiler_free(compiler);
    ts_grammar_free(grammar);
  };

  DESCRIBE("compiling the grammar to c source code") {
    char *code;

    BEFORE_EACH {
      code = ts_compiler_c_code(compiler);
    };

    IT("works") {
      assert(strcmp(code, "some c code") == 0);
    };
  }
}

END_TEST
