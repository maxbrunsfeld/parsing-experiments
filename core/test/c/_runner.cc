#include "rule_test.c"
#include "compiler_test.c"
#include "tree_test.c"
#include "runtime_test.c"

int main()
{
  printf("\n--- Running tests ---\n\n");

  RUN_TESTS(TSRule);
  RUN_TESTS(TSCompiler);
  RUN_TESTS(TSTree);
  RUN_TESTS(ParserRuntime);

  printf("\n--- Tests passed ---\n\n");
}
