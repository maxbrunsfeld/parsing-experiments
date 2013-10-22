#define CHILD_COUNT 10

struct TSNode {
  int type;
  int child_node_count;
  TSNode *child_nodes[CHILD_COUNT];
};

struct TSTree {
  TSNode *nodes;
  int node_count;
  int node_capacity;
  TSNode *root;
  const char **rule_names;
};
