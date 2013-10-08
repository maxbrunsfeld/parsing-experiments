#include "compiler.h"
#include "grammar.h"
#include <stdlib.h>
#include "lua_bridge.h"

struct TSCompiler {
  TSGrammar *grammar;
};

TSCompiler * ts_compiler_new(TSGrammar *grammar)
{
  TSCompiler *result = malloc(sizeof(TSCompiler));
  result->grammar = grammar;
  return result;
}

void ts_compiler_free(TSCompiler *compiler)
{
  free(compiler);
}

char * ts_compiler_c_code(TSCompiler *compiler)
{
  lua_State *L = ts_lua_vm();
  lua_getglobal(L, "grammar_to_c_code");
  ts_lua_push_grammar(L, compiler->grammar);
  lua_call(L, 1, 1);
  return lua_tostring(L, -1);
}
