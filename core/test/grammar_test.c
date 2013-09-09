#include "_test_helper.h"

TEST(TSGrammar)
{
  TSGrammar *grammar;

  BEFORE_EACH {
    char *symbol_names[] = {
      "rule0", "rule1", "rule2", "rule3",
      "token0", "token1", "token2"
    };

    TSRule *rules[] = {
      CHOICE(SYM(0), SYM(1)),
      CHOICE(SEQ(SYM(2), SYM(3)), SEQ(SYM(4), SYM(5))),
    };

    TSToken *tokens[] = {
      TOKEN("\\d+"),
      TOKEN("\\w+"),
      TOKEN("+")
    };

    grammar = ts_grammar_new(4, 3, rules, tokens, symbol_names);
  }

  AFTER_EACH {
    ts_grammar_free(grammar);
  }

  DESCRIBE("compilation to a state machine") {
    IT("works") {
      ts_grammar_compile(grammar);
    }
  }
}

END_TEST
