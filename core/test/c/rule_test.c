#include "_helper.h"

TEST(TSRule) {
  IT("can test equality") {
    TSRule
      *rule1 = CHOICE(SEQ(SYM(11), SYM(12)), SEQ(SYM(13), SYM(14))),
      *rule2 = CHOICE(SEQ(SYM(11), SYM(12)), SEQ(SYM(13), SYM(14))),
      *rule3 = CHOICE(SEQ(SYM(11), SYM(12)), SEQ(SYM(13), SYM(15)));

    assert(ts_rule_eq(rule1, rule2));
    assert(!ts_rule_eq(rule1, rule3));

    ts_rule_free(rule1);
    ts_rule_free(rule2);
    ts_rule_free(rule3);
  }
}

END_TEST
