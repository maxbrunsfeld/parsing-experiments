#include "document.h"
#include <stdlib.h>

#define CHILD_COUNT 10

struct TSNode {
  TSNodeType type;
  int child_node_count;
  TSNode *child_nodes[CHILD_COUNT];
};

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

char * ts_node_to_string(TSNode *node)
{
  char *output = calloc(500, sizeof(char));
  __ts_node_to_string(output, node);
  return output;
}

int __ts_node_to_string(char *output, TSNode *node)
{
  sprintf(output, "(%2d", node->type);
  int position = 3;
  for (int i = 0; i < node->child_node_count; i++) {
    sprintf(output + position, " ");
    position++;
    position += __ts_node_to_string(output + position, node->child_nodes[i]);
  }
  sprintf(output + position, ")");
  position += 1;
  return position;
}

void ts_node_add_child(TSNode *n, const TSNode *child)
{
  n->child_nodes[n->child_node_count] = child;
  n->child_node_count++;
}

/* --- Tree --- */
struct TSTree {
  TSNode *nodes;
  int node_count;
  int node_capacity;
  TSNode *root;
};

TSTree * ts_tree_new()
{
  TSTree *t = malloc(sizeof(TSTree));
  t->node_count = 0;
  t->node_capacity = 100;
  t->nodes = calloc(t->node_capacity, sizeof(TSNode));
  return t;
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

TSNode * ts_tree_node(TSTree *t, int i)
{
  return (t->nodes + i);
}

