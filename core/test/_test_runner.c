#include "rule_test.c"
#include "array_test.c"
#include "grammar_test.c"

int main()
{
  printf("\n--- Running tests ---\n\n");

  RUN_TESTS(TSArray);
  RUN_TESTS(TSRule);
  RUN_TESTS(TSGrammar);

  printf("\n\n--- Tests passed ---\n\n");
}
