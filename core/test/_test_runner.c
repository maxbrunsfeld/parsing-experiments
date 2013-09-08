#include "rule_test.c"
#include "array_test.c"
#include "grammar_test.c"

int main()
{
  printf("\n--- Running tests ---\n\n");

  RUN_TESTS(IPArray);
  RUN_TESTS(IPRule);
  RUN_TESTS(IPGrammar);

  printf("\n\n--- Tests passed ---\n\n");
}
