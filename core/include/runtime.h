#include <tree_sitter/document.h>
#include <ctype.h>

typedef int TSParseState;

typedef struct {
  TSParseState *state_stack;
  int state_stack_size;
  TSTree *tree;
  TSNode **node_stack;
  int node_stack_size;
  int position;
  const char *input;
} TSParser;

static TSParseState ts_parser_state(TSParser *p)
{
  int size = p->state_stack_size;
  return size > 0 ?  p->state_stack[size] : -1;
}

static char ts_parser_lookahead(TSParser *p)
{
  return p->input[p->position];
}

static void ts_parser_consume(TSParser *p)
{
  p->position++;
}

static void ts_parser_push_state(TSParser *p, TSParseState s)
{
  p->state_stack[p->state_stack_size++] = s;
}

static void ts_parser_replace_state(TSParser *p, TSParseState s)
{
  p->state_stack[p->state_stack_size] = s;
}

static void ts_parser_error(TSParser *p)
{
  printf("==> OMG error \n");
}

static void ts_parser_reduce(TSParser *p, int symbol_count, TSNodeType node_type)
{
  TSTree *tree = p->tree;
  TSNode *node = ts_tree_add_node(tree, node_type);
  ts_tree_set_root(tree, node);
}

static TSParser * ts_parser_new(TSTree *tree, const char *input)
{
  TSParser *p = (TSParser *)malloc(sizeof(TSParser));
  p->state_stack = (TSParseState *)calloc(20, sizeof(TSParseState));
  p->node_stack = (TSNode **)calloc(20, sizeof(TSNode *));
  p->state_stack_size = 0;
  p->node_stack_size = 0;
  p->tree = tree;
  p->position = 0;
  p->input = input;
  ts_parser_push_state(p, 0);
  return p;
}

