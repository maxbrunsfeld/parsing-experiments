#include <tree_sitter/document.h>
#include <ctype.h>

typedef struct {
  TSTree *tree;
  int *state_stack;
  int state_stack_size;
  TSNode **node_stack;
  int node_stack_size;
  int position;
  const char *input;
} TSParser;

static int ts_parser_state(TSParser *p)
{
  int size = p->state_stack_size;
  return size > 0 ?  p->state_stack[size] : -1;
}

static char ts_parser_lookahead_char(TSParser *p)
{
  return p->input[p->position];
}

static void ts_parser_shift(TSParser *p, int state)
{
  p->position++;
  p->state_stack[p->state_stack_size] = state;
}

static void ts_parser_push_state(TSParser *p, int state)
{
  p->state_stack[p->state_stack_size++] = state;
}

static void ts_parser_error(TSParser *p)
{
  printf("==> OMG error \n");
}

static void ts_parser_reduce(TSParser *p, int symbol_count, int node_type)
{
  TSTree *tree = p->tree;
  TSNode *node = ts_tree_add_node(tree, node_type);
  ts_tree_set_root(tree, node);
}

static TSParser * ts_parser_new(TSTree *tree, const char *input)
{
  TSParser *p = (TSParser *)malloc(sizeof(TSParser));
  p->state_stack = (int *)calloc(80, sizeof(int));
  p->node_stack = (TSNode **)calloc(80, sizeof(TSNode *));
  p->state_stack_size = 0;
  p->node_stack_size = 0;
  p->tree = tree;
  p->position = 0;
  p->input = input;
  ts_parser_push_state(p, 1);
  return p;
}

