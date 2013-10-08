#include <lua.h>

lua_State * ts_lua_vm();
void ts_lua_push_grammar(lua_State *L, TSGrammar *grammar);
