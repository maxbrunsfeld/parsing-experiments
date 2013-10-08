#include "compiler.h"
#include "install.h"
#include "grammar.h"
#include "lua_bridge.h"
#include "lauxlib.h"
#include "lualib.h"
#include <string.h>
#include <stdlib.h>

#define debug_lua(message, L, n) \
  printf( \
    message "\n  type: %s,\n  value: %s,\n  top: %d\n", \
    lua_typename(L, lua_type(L, n)), \
    lua_tostring(L, n), \
    lua_gettop(L));


static int add_lua_path(lua_State* L, const char* path)
{
  const char *current_path;
  char *result;

  lua_getglobal(L, "package");
  lua_getfield(L, -1, "path");
  current_path = lua_tostring(L, -1);
  lua_pop(L, 1);

  result = malloc((strlen(current_path) + strlen(path) + 1) * sizeof(char));
  strcpy(result, current_path);
  strcat(result, ";");
  strcat(result, path);
  lua_pushstring(L, result);
  lua_setfield(L, -2, "path");

  lua_pop(L, 1);
  free(result);

  return 0;
}

lua_State * ts_lua_vm()
{
  lua_State *L = luaL_newstate();
  luaL_openlibs(L);
  add_lua_path(L, TS_SRC_DIR "?.lua");
  luaL_dofile(L, TS_SRC_DIR "start.lua");
  return L;
}

static void ts_lua_push_rule(lua_State *L, TSRule *rule)
{
  lua_getglobal(L, "Rules");

  switch (rule->type) {
    case TSRuleTypeSym:
      {
        lua_getfield(L, -1, "Sym");
        lua_pushinteger(L, rule->impl.symbol_id);
        lua_call(L, 1, 1);
        break;
      }
    case TSRuleTypeString:
      {
        lua_getfield(L, -1, "String");
        lua_pushstring(L, rule->impl.string);
        lua_call(L, 1, 1);
        break;
      }
    case TSRuleTypePattern:
      {
        lua_getfield(L, -1, "Pattern");
        lua_pushstring(L, rule->impl.string);
        lua_call(L, 1, 1);
        break;
      }
    case TSRuleTypeSeq:
      {
        lua_getfield(L, -1, "Seq");
        ts_lua_push_rule(L, rule->impl.binary.left);
        ts_lua_push_rule(L, rule->impl.binary.right);
        lua_call(L, 2, 1);
        break;
      }
    case TSRuleTypeChoice:
      {
        lua_getfield(L, -1, "Choice");
        ts_lua_push_rule(L, rule->impl.binary.left);
        ts_lua_push_rule(L, rule->impl.binary.right);
        lua_call(L, 2, 1);
        break;
      }
    case TSRuleTypeEnd:
      {
        lua_getfield(L, -1, "End");
        break;
      }
  }

  lua_remove(L, -2);
}

static void ts_lua_push_token(lua_State *L, TSRule *token)
{
  lua_pushinteger(L, 1);
}

void ts_lua_push_grammar(lua_State *L, TSGrammar *grammar)
{
  lua_getglobal(L, "Grammar");

  lua_pushstring(L, grammar->name);

  lua_createtable(L, grammar->rule_count, 0);
  for (int i = 0; i < grammar->rule_count; i++) {
    lua_pushinteger(L, i + 1);

    lua_createtable(L, 2, 0);
    lua_pushinteger(L, 1);
    lua_pushstring(L, grammar->rule_names[i]);
    lua_settable(L, -3);
    lua_pushinteger(L, 2);
    ts_lua_push_rule(L, grammar->rules[i]);
    lua_settable(L, -3);

    lua_settable(L, -3);
  }

  lua_createtable(L, grammar->token_count, 0);
  for (int i = 0; i < grammar->token_count; i++) {
    lua_pushinteger(L, i + 1);

    lua_createtable(L, 2, 0);
    lua_pushinteger(L, 1);
    lua_pushstring(L, grammar->token_names[i]);
    lua_settable(L, -3);
    lua_pushinteger(L, 2);
    ts_lua_push_rule(L, grammar->tokens[i]);
    lua_settable(L, -3);

    lua_settable(L, -3);
  }

  lua_call(L, 3, 1);
}
