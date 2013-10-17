#include "_helper.h"
#include <tree_sitter/runtime.h>

// Example output of parser generator:
//------------------------------------
const char *input_names[3] = {
  "number",
  "times",
  "plus"
};

enum node_types {
  NodeTypeNumber,
  NodeTypeTimes,
  NodeTypePlus,
};

void parse_math_expression(TSTree *tree, const char *input)
{
  int state = 0;
  Parser *p = parser_new(tree, input);

  new_state:
  switch (parser_state(p)) {
    case 0:
      {
        if (isdigit(parser_lookahead(p))) {
          parser_consume(p);
          parser_push_state(p, 1);
          goto new_state;
        }

        parser_error(p);
        break;
      }

    /* Got number */
    case 1:
      {
        parser_reduce(p, 5, NodeTypeNumber);
        goto new_state;
      }
  }
}

//------------------------------------

TEST(ParserRuntime) {
  TSTree *tree;

  BEFORE_EACH {
    tree = ts_tree_new();
  };

  DESCRIBE("for valid inputs") {
    const char *input = "5";

    IT("builds up a tree") {
      parse_math_expression(tree, input);
      const TSNode *children1[] = {
        ts_node_new(1, 0, NULL),
        ts_node_new(2, 0, NULL)
      };
      const TSNode *children2[] = {
        ts_node_new(3, 0, NULL),
        ts_node_new(4, 0, NULL)
      };
      const TSNode *parents[] = {
        ts_node_new(5, 0, children1),
        ts_node_new(6, 0, children2)
      };
      TSNode *root = ts_node_new(7, 3, parents);
    }
  }
}

END_TEST

