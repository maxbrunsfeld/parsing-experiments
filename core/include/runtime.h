#include <tree_sitter/document.h>
#include <ctype.h>

typedef int ParseState;

typedef struct Parser {
  ParseState *state_stack;
  int state_stack_size;
  TSTree *tree;
  TSNode **node_stack;
  int node_stack_size;
  int position;
  const char *input;
} Parser;

static Parser * parser_new(TSTree *tree, const char *input)
{
  Parser *p = (Parser *)malloc(sizeof(Parser));
  p->state_stack = (ParseState *)calloc(20, sizeof(ParseState));
  p->node_stack = (TSNode **)calloc(20, sizeof(TSNode *));
  p->state_stack_size = 0;
  p->node_stack_size = 0;
  p->tree = tree;
  p->position = 0;
  p->input = input;
  return p;
}

static inline ParseState parser_state(Parser *p)
{
  int size = p->state_stack_size;
  return size > 0 ?  p->state_stack[size] : -1;
}

static inline char parser_lookahead(Parser *p)
{
  return p->input[p->position];
}

static inline void parser_consume(Parser *p)
{
  p->position++;
}

static inline void parser_push_state(Parser *p, ParseState s)
{
  p->state_stack[p->state_stack_size++] = s;
}

static inline void parser_error(Parser *p)
{
  printf("==> OMG error \n");
}

static void parser_reduce(Parser *p, int symbol_count, TSNodeType node_type)
{
  TSNode *node = ts_tree_add_node(p->tree, node_type);
}
