#include <tree_sitter/document.h>
#include <ctype.h>
#include <stdlib.h>

/* --- TSStateStack --- */

typedef struct {
  int count;
  int capacity;
  int *contents;
} TSStateStack;

static TSStateStack ts_state_stack_new()
{
  int capacity = 80;
  TSStateStack stack = { 0, capacity, (int *)calloc(capacity, sizeof(int)) };
  return stack;
}

static void ts_state_stack_push(TSStateStack stack, int state)
{
  stack.contents[stack.count++] = state;
}

static int ts_state_stack_pop(TSStateStack stack, int n)
{
  stack.count -= n;
  return stack.contents[stack.count];
}

/* --- TSNodeStack --- */

typedef struct {
  int count;
  int capacity;
  TSNode **contents;
} TSNodeStack;

static TSNodeStack ts_node_stack_new()
{
  int capacity = 80;
  TSNodeStack stack = { 0, capacity, (TSNode **)calloc(capacity, sizeof(TSNode *)) };
  return stack;
}

static void ts_node_stack_push(TSNodeStack stack, TSNode *node)
{
  stack.contents[stack.count++] = node;
}

static TSNode ** ts_node_stack_pop(TSNodeStack stack, int n)
{
  stack.count -= n;
  return stack.contents + stack.count;
}

/* --- TSParser --- */

typedef struct {
  TSTree *tree;
  const char *input;
  int position;
  int current_state;
  char lookahead_char;
  int lookahead_sym;
  TSNode *lookahead_node;
  TSStateStack state_stack;
  TSNodeStack node_stack;
} TSParser;

static TSParser ts_parser_new(const char *input, const char **rule_names)
{
  TSParser result = {
    .tree = ts_tree_new(rule_names),
    .input = input,
    .position = 0,
    .current_state = 1,
    .lookahead_char = input[0],
    .lookahead_node = NULL,
    .lookahead_sym = -1,
    .state_stack = ts_state_stack_new(),
    .node_stack = ts_node_stack_new()
  };
  return result;
}

static inline void ts_parser_shift(TSParser *p, int new_state)
{
  if (p->lookahead_node) {
    ts_node_stack_push(p->node_stack, p->lookahead_node);
    p->lookahead_node = NULL;
    p->lookahead_sym = -1;
  }
  ts_state_stack_push(p->state_stack, p->current_state);
  p->current_state = new_state;
}

static inline void ts_parser_advance(TSParser *p, int new_state)
{
  p->position++;
  p->lookahead_char = p->input[p->position];
  p->current_state = new_state;
}

static inline void ts_parser_reduce(TSParser *p, int symbol)
{
  TSNode *node = ts_tree_add_node(p->tree, symbol);
  ts_tree_set_root(p->tree, node);

  // TODO - compute this correctly
  int child_count = 0;

  TSNode **children = ts_node_stack_pop(p->node_stack, child_count);
  for (int i = 0; i < child_count; i++)
    ts_node_add_child(node, children[i]);
  p->current_state = ts_state_stack_pop(p->state_stack, child_count);
}

/* --- Runtime --- */

#define SETUP_PARSER() \
  TSParser p = ts_parser_new(input, rule_names); \

#define PARSE_STATES \
next_state: \
  switch(p.current_state)

#define END_PARSER() \
accept: \
  return p.tree; \
parse_error: \
  return NULL;

#define ACCEPT() \
  { goto accept; }

#define ADVANCE(to_state) \
  { ts_parser_advance(&p, to_state); \
    goto next_state; }

#define SHIFT(new_state) \
  { ts_parser_shift(&p, new_state); \
    goto next_state; }

#define REDUCE(symbol) \
  { ts_parser_reduce(&p, symbol); \
    goto next_state; }

#define PARSE_ERROR() \
  { printf("Error occurred!"); \
    goto parse_error; }
