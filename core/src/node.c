#include "runtime.h"
#include <stdlib.h>

struct TSNode {
  char *name;
  int childNodeCount;
  struct TSNode *childNodes;
};

TSNode * ts_node_new()
{
  TSNode *node = malloc(sizeof(TSNode));
  node->name = 0;
  node->childNodeCount = 0;
  node->childNodes = 0;
  return node;
}

void ts_node_free(TSNode *node)
{
  for (int i = 0; i < node->childNodeCount; i++) {
    ts_node_free(node->childNodes + i);
  }
  free(node);
}

char * ts_node_name(TSNode *node)
{
  return node->name;
}

void ts_node_set_name(TSNode *node, char *name)
{
  node->name = name;
}
