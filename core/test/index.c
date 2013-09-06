#include "rule_test.c"
#include "array_test.c"

int main()
{
  printf("\nRunning tests...");

  RUN_TESTS(IPArray);
  RUN_TESTS(IPRule);

  printf("Tests passed!\n");
}
