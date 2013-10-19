#include "document.h"
#include "tree.h"
#include <stdlib.h>

void ts_node_initialize(TSNode *node, TSNodeType type)
{
  node->type = type;
  node->child_node_count = 0;
  for (int i = 0; i < CHILD_COUNT; i++)
    node->child_nodes[i] = 0;
}

TSNode * ts_node_new(TSNodeType type, int child_node_count, const TSNode **child_nodes)
{
  TSNode *n = malloc(sizeof(TSNode));
  ts_node_initialize(n, type);
  for (int i = 0; i < child_node_count; i++) {
    ts_node_add_child(n, child_nodes[i]);
  }
  return n;
}

int ts_node_eq(TSNode *left, TSNode *right)
{
  if (left == right)
    return 1;
  if (left->type != right->type)
    return 0;
  if (left->child_node_count != right->child_node_count)
    return 0;
  for (int i = 0; i < left->child_node_count; i++)
    if (!ts_node_eq(left->child_nodes[i], right->child_nodes[i]))
      return 0;
  return 1;
}

static __ts_node_to_string(char *output, char *position, TSNode *node, const char **rule_names)
{
  if (!node) return;
  const char *rule_name = rule_names[node->type];
  sprintf(output + *position, "(%s", rule_name);
  (*position) += (strlen(rule_name) + 1);
  for (int i = 0; i < node->child_node_count; i++) {
    sprintf(output + *position, " ");
    (*position)++;
    __ts_node_to_string(output, position, node->child_nodes[i], rule_names);
  }
  sprintf(output + *position, ")");
  *position += 1;
}

char * ts_node_to_string(TSNode *node, const char **rule_names)
{
  char *output = calloc(500, sizeof(char));
  int position = 0;
  __ts_node_to_string(output, &position, node, rule_names);
  return output;
}

void ts_node_add_child(TSNode *n, const TSNode *child)
{
  n->child_nodes[n->child_node_count] = child;
  n->child_node_count++;
}

/* --- Tree --- */
TSTree * ts_tree_new(const char **rule_names)
{
  TSTree *t = malloc(sizeof(TSTree));
  t->node_count = 0;
  t->node_capacity = 100;
  t->nodes = calloc(t->node_capacity, sizeof(TSNode));
  t->root = NULL;
  t->rule_names = rule_names;
  return t;
}

char * ts_tree_to_string(TSTree *t)
{
  return ts_node_to_string(t->root, t->rule_names);
}

void ts_tree_free(TSTree *t)
{
  free(t->nodes);
  free(t);
}

void expand_tree(TSTree *t)
{
  t->node_capacity *= 2;
  realloc(t->nodes, t->node_capacity);
}

TSNode * ts_tree_add_node(TSTree *t, TSNodeType type)
{
  if (t->node_count >= t->node_capacity)
    expand_tree(t);
  TSNode *node = (t->nodes + t->node_count);
  t->node_count++;
  ts_node_initialize(node, type);
  return node;
}

TSNode * ts_tree_root(TSTree *t)
{
  return t->root;
}

void ts_tree_set_root(TSTree *t, TSNode *node)
{
  t->root = node;
}

TSNode * ts_tree_node(TSTree *t, int i)
{
  return (t->nodes + i);
}
