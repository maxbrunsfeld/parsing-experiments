#include <tree_sitter/document.h>
#include <ctype.h>

typedef int* StateStack;
typedef int* SymbolStack;

StateStack symbol_stack_new()
{
  return (int *)calloc(80, sizeof(int));
}

StateStack state_stack_new()
{
  return (int *)calloc(80, sizeof(int));
}

#define PARSE_ERROR() \
  printf("Error occurred!");

#define PARSE_STATES \
next_state: \
  switch(current_state)

#define ACCEPT() \
  goto accept;

#define SETUP(tree) \
  int position = 0; \
  int current_state = 0; \
  char lookahead_char = input[0]; \
  int lookahead_sym = -1; \
  StateStack *state_stack = state_stack_new(); \
  SymbolStack *symbol_stack = symbol_stack_new();

#define ADVANCE(new_state) \
  { \
    current_state = new_state; \
    position++; \
    lookahead_char = input[position]; \
  }

#define SHIFT(new_state) \
  { \
    symbol_stack_push(symbol_stack, lookahead_sym); \
    state_stack_push(state_stack, current_state); \
    current_state = new_state; \
    goto next_state; \
  }

#define REDUCE(new_symbol) \
  { \
    symbol_stack_reduce(symbol_stack, new_symbol); \
    current_state = state_stack_pop(); \
    goto next_state; \
  }
