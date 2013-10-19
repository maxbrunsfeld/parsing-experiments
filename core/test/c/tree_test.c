#include "_helper.h"
#include "document.h"
#include "tree.h"

TEST(TSTree) {
  TSTree *tree;
  const char *rule_names[4] = {
    "rule-1",
    "rule-2",
    "rule-3",
    "rule-4"
  };

  BEFORE_EACH {
    tree = ts_tree_new(rule_names);
    TSNode *nodes[] = {
      ts_tree_add_node(tree, 0),
      ts_tree_add_node(tree, 1),
      ts_tree_add_node(tree, 2),
      ts_tree_add_node(tree, 3)
    };

    ts_node_add_child(nodes[1], nodes[0]);
    ts_node_add_child(nodes[3], nodes[1]);
    ts_node_add_child(nodes[3], nodes[2]);
    ts_tree_set_root(tree, nodes[3]);
  };

  DESCRIBE("equality") {
    TSNode *node, *copy;

    BEFORE_EACH {
      node = ts_tree_node(tree, 3);
      copy = ts_tree_add_node(tree, node->type);
      ts_node_add_child(copy, node->child_nodes[0]);
      ts_node_add_child(copy, node->child_nodes[1]);
    };

    IT("is true for nodes with the same type and children") {
      assert(ts_node_eq(node, copy));
    };

    IT("is false for nodes with different types") {
      copy->type = 15;
      assert(!ts_node_eq(node, copy));
    };

    IT("is false for nodes with different childeren") {
      TSNode *new_child = ts_tree_add_node(tree, 6);
      ts_node_add_child(node, new_child);
      assert(!ts_node_eq(node, copy));
    };
  };

  DESCRIBE("pretty-printing") {
    IT("represents the tree as an s-expression") {
      assert(!strcmp(ts_tree_to_string(tree), "(rule-4 (rule-2 (rule-1)) (rule-3))"));
    };
  };
}

END_TEST
