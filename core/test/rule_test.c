#include "_helper.h"

TEST(TSRule) {
  IT("can construct rules correctly") {
    TSRule *choice = CHOICE(SYM(11), SYM(12));
    assert(ID(LEFT(choice)) == 11);
    assert(ID(RIGHT(choice)) == 12);

    TSRule *seq = SEQ(SYM(11), SYM(12));
    assert(ID(LEFT(seq)) == 11);
    assert(ID(RIGHT(seq)) == 12);

    ts_rule_free(choice);
    ts_rule_free(seq);
  }

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

  DESCRIBE("transitions") {
    TSRule *rule;
    TSArray *transitions;
    TSTransition *transition;

    AFTER_EACH {
      ts_rule_free(rule);
      ts_array_free(transitions);
    };

    IT("works for symbols") {
      rule = SYM(11);
      transitions = ts_rule_transitions(rule);
      assert(ts_array_length(transitions) == 1);

      transition = (TSTransition *)ts_array_get(transitions, 0);
      assert(transition->symbol_id == 11);
      assert(ts_rule_eq(transition->rule, ts_rule_new_end()));
    }

    IT("works for simple choices") {
      rule = CHOICE(SYM(11), SYM(12));
      transitions = ts_rule_transitions(rule);
      assert(ts_array_length(transitions) == 2);

      transition = (TSTransition *)ts_array_get(transitions, 0);
      assert(transition->symbol_id == 11);
      assert(ts_rule_eq(transition->rule, ts_rule_new_end()));

      transition = (TSTransition *)ts_array_get(transitions, 1);
      assert(transition->symbol_id == 12);
      assert(ts_rule_eq(transition->rule, ts_rule_new_end()));
    }

    IT("works for simple sequences") {
      rule = SEQ(SYM(11), SYM(12));
      transitions = ts_rule_transitions(rule);
      assert(ts_array_length(transitions) == 1);

      transition = (TSTransition *)ts_array_get(transitions, 0);
      assert(ts_rule_eq(transition->rule, SYM(12)));
    }
  }
}

END_TEST
