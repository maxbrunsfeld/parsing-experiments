#include "_helper.h"
#include <string.h>

TEST(TSCompiler)
{
  TSGrammar *grammar;
  TSCompiler *compiler;

  TSRule *rules[] = {
    CHOICE(SYM(0), SYM(1)),
    CHOICE(SEQ(SYM(2), SYM(3)), SEQ(SYM(4), SYM(5))),
    SYM(0),
    SYM(1)
  };

  TSToken *tokens[] = {
    TOKEN("\\d+"),
    TOKEN("\\w+"),
    TOKEN("+")
  };

  const char *symbol_names[] = {
    "rule0", "rule1", "rule2", "rule3",
    "token0", "token1", "token2"
  };

  BEFORE_EACH {
    grammar = ts_grammar_new(4, 3, rules, tokens, symbol_names);
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
