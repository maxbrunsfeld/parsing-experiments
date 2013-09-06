#ifndef __array_h__
#define __array_h__

#include <stdlib.h>

typedef struct IPArray {
  int max;
  int capacity;
  void **elements;
} IPArray;

IPArray *ip_array_new(int capacity);
IPArray *ip_array_copy(IPArray *array);
void ip_array_free(IPArray *array);

void * ip_array_get(IPArray *array, int i);
int ip_array_set(IPArray *array, int i, void *el);
void * ip_array_remove(IPArray *array, int i);

int ip_array_length(IPArray *array);
int ip_array_push(IPArray *array, void *el);
void *ip_array_pop(IPArray *array);
void ip_array_clear(IPArray *array);

#define ip_array_each(array, element_type, element_name, index_name) \
  element_type *element_name = ip_array_get(array, 0); \
  int __max_ ## index_name = ip_array_length(array); \
  for ( \
    int index_name = 0; \
    index_name < __max_ ## index_name; \
    (++index_name < __max_ ## index_name) ? \
    (element_name = ip_array_get(array, index_name)) : \
    NULL)

#endif
