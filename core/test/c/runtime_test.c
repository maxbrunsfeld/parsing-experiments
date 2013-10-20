#include "_helper.h"
#include "document.h"
#include "parsers/math.c"

TEST(ParserRuntime) {
  TSTree *tree;

  AFTER_EACH {
    ts_tree_free(tree);
  };

  DESCRIBE("arithmetic expressions") {
    IT("parses single numbers") {
      tree = ts_parse_math("55");
      assert(!strcmp(ts_tree_to_string(tree), "(number)"));
    };

    IT("parses sums") {
      tree = ts_parse_math("3+5");
      printf("==> %s \n", ts_tree_to_string(tree));
      assert(!strcmp(ts_tree_to_string(tree), "(sum (number) (number))"));
    };

    IT("parses products") {
      tree = ts_parse_math("3*5");
      printf("==> %s \n", ts_tree_to_string(tree));
      assert(!strcmp(ts_tree_to_string(tree), "(product (number) (number))"));
    };
  };
}

END_TEST

