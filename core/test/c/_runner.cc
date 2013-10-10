#include "rule_test.c"
#include "compiler_test.c"

int main()
{
  printf("\n--- Running tests ---\n\n");

  RUN_TESTS(TSRule);
  RUN_TESTS(TSCompiler);

  printf("\n--- Tests passed ---\n\n");
}
