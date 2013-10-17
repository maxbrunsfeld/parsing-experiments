#include "document.h"
#include "check.h"
#include <stdlib.h>

struct TSDocument {
  char *text;
  TSTree *tree;
};

TSDocument * ts_document_new()
{
  TSDocument *document = malloc(sizeof(TSDocument));
  document->text = 0;
  document->tree = 0;
  return document;
}

void ts_document_free(TSDocument *doc)
{
  if (doc->tree) ts_tree_free(doc->tree);
  free(doc);
}

void ts_document_set_text(TSDocument *doc, char *text)
{
  doc->text = text;
}

TSNode * ts_document_tree(TSDocument *doc)
{
  return doc->tree;
}

char * ts_document_text(TSDocument *doc)
{
  return doc->text;
}
