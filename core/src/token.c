#include "compiler.h"
#include "grammar.h"
#include <stdlib.h>

TSToken * ts_token_new(const char *pattern)
{
  TSToken *result = malloc(sizeof(TSToken));
  result->pattern = pattern;
  return result;
}
