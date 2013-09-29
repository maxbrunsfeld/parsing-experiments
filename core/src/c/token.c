#include "compiler.h"
#include "grammar.h"
#include <stdlib.h>

TSToken * ts_token_new_string(const char *value)
{
  TSToken *result = malloc(sizeof(TSToken));
  result->is_pattern = 1;
  result->value = value;
  return result;
}

TSToken * ts_token_new_pattern(const char *value)
{
  TSToken *result = malloc(sizeof(TSToken));
  result->is_pattern = 0;
  result->value = value;
  return result;
}
