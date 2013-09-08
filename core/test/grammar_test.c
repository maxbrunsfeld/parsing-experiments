#include "_test_helper.h"
#include "grammar.h"

TEST(IPGrammar)
{
  IPGrammar *grammar;

  BEFORE_EACH {
    char *symbol_names[] = {
      "rule0", "rule1", "rule2", "rule3",
      "token0", "token1", "token2"
    };

    IPRule *rules[] = {
      CHOICE(SYM(0), SYM(1)),
      CHOICE(SEQ(SYM(2), SYM(3)), SEQ(SYM(4), SYM(5))),
    };

    IPToken *tokens[] = {
      TOKEN("\\d+"),
      TOKEN("\\w+"),
      TOKEN("+")
    };

    grammar = ip_grammar_new(4, 3, rules, tokens, symbol_names);
  }

  AFTER_EACH {
    ip_grammar_free(grammar);
  }

  DESCRIBE("compilation to a state machine") {
    IT("works") {
      ip_grammar_compile(grammar);
    }
  }
}

END_TEST
