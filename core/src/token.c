#include "tree_sitter.h"
#include "private.h"

struct TSToken {
  char *pattern;
};

TSToken * ts_token_new(char *pattern)
{
  TSToken *result = malloc(sizeof(TSToken));
  result->pattern = pattern;
  return result;
}
