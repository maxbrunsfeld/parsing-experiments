#include "grammar.h"
#include "stdlib.h"

// Grammar
IPGrammar * ip_grammar_new()
{
  IPGrammar* grammar = malloc(sizeof(IPGrammar));
  return grammar;
}

void ip_grammar_free(IPGrammar *grammar)
{
  free(grammar);
}

// Rule
