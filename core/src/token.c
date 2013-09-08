#include "token.h"
#include "stdlib.h"

IPToken * ip_token_new(char *pattern)
{
  IPToken *result = malloc(sizeof(IPToken));
  result->pattern = pattern;
  return result;
}
