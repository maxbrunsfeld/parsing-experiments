#include "rule.h"
#include "helper.h"

TEST(IPRule) {
  IT("can construct rules correctly") {
    IPRule *choice = CHOICE(SYM(11), SYM(12));
    assert(ID(LEFT(choice)) == 11);
    assert(ID(RIGHT(choice)) == 12);

    IPRule *seq = SEQ(SYM(11), SYM(12));
    assert(ID(LEFT(seq)) == 11);
    assert(ID(RIGHT(seq)) == 12);

    ip_rule_free(choice);
    ip_rule_free(seq);
  }

  IT("can test equality") {
    IPRule
      *rule1 = CHOICE(SEQ(SYM(11), SYM(12)), SEQ(SYM(13), SYM(14))),
      *rule2 = CHOICE(SEQ(SYM(11), SYM(12)), SEQ(SYM(13), SYM(14))),
      *rule3 = CHOICE(SEQ(SYM(11), SYM(12)), SEQ(SYM(13), SYM(15)));

    assert(ip_rule_eq(rule1, rule2));
    assert(!ip_rule_eq(rule1, rule3));

    ip_rule_free(rule1);
    ip_rule_free(rule2);
    ip_rule_free(rule3);
  }

  DESCRIBE("transitions") {
    IPRule *rule;
    IPArray *transitions;
    IPTransition *transition;

    AFTER_EACH {
      ip_rule_free(rule);
      ip_array_free(transitions);
    }

    IT("works for symbols") {
      rule = SYM(11);
      transitions = ip_rule_transitions(rule);
      assert(ip_array_length(transitions) == 1);

      transition = ip_array_get(transitions, 0);
      assert(transition->symbol_id == 11);
      assert(ip_rule_eq(transition->rule, ip_rule_new_end()));
    }

    IT("works for simple choices") {
      rule = CHOICE(SYM(11), SYM(12));
      transitions = ip_rule_transitions(rule);
      assert(ip_array_length(transitions) == 2);

      transition = ip_array_get(transitions, 0);
      assert(transition->symbol_id == 11);
      assert(ip_rule_eq(transition->rule, ip_rule_new_end()));

      transition = ip_array_get(transitions, 1);
      assert(transition->symbol_id == 12);
      assert(ip_rule_eq(transition->rule, ip_rule_new_end()));
    }

    IT("works for simple sequences") {
      rule = SEQ(SYM(11), SYM(12));
      transitions = ip_rule_transitions(rule);
      assert(ip_array_length(transitions) == 1);

      transition = ip_array_get(transitions, 0);
      assert(ip_rule_eq(transition->rule, SYM(12)));
    }
  }
}

END_TEST
