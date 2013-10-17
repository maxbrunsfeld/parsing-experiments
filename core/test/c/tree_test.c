#include "_helper.h"
#include "document.h"

struct TSNode {
  TSNodeType type;
  int child_node_count;
  TSNode *child_nodes[10];
};

TEST(TSTree) {
  TSTree *tree;

  BEFORE_EACH {
    tree = ts_tree_new();
    TSNode *nodes[] = {
      ts_tree_add_node(tree, 11),
      ts_tree_add_node(tree, 12),
      ts_tree_add_node(tree, 13),
      ts_tree_add_node(tree, 14)
    };

    ts_node_add_child(nodes[1], nodes[0]);
    ts_node_add_child(nodes[3], nodes[1]);
    ts_node_add_child(nodes[3], nodes[2]);
  };

  DESCRIBE("equality") {
    IT("returns true for two nodes with the same type and children") {
      TSNode *node = ts_tree_node(tree, 3);
      TSNode *copy = ts_tree_add_node(tree, 14);
      ts_node_add_child(copy, ts_tree_node(tree, 1));
      ts_node_add_child(copy, ts_tree_node(tree, 2));
      assert(ts_node_eq(node, copy));
    }

    IT("returns false for two nodes with different types but the same children") {
      TSNode *node = ts_tree_node(tree, 3);
      TSNode *copy = ts_tree_add_node(tree, 15);
      ts_node_add_child(copy, ts_tree_node(tree, 1));
      ts_node_add_child(copy, ts_tree_node(tree, 2));
      assert(!ts_node_eq(node, copy));
    }
  };

  DESCRIBE("pretty-printing") {
    IT("represents the node as an s-expression based on its node-type") {
      TSNode *node = ts_tree_node(tree, 3);
      assert(!strcmp(ts_node_to_string(node), "(14 (12 (11)) (13))"));
    };
  };
}

END_TEST
