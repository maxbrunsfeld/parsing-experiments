#include "array.h"
#include "check.h"

#define EXPAND_RATE 300

IPArray *ip_array_new(int capacity)
{
  IPArray *array = malloc(sizeof(*array));
  check_mem(array);
  check(capacity >= 0, "Capacity must be >= 0");
  array->elements = calloc(capacity, sizeof(array->elements));
  check_mem(array->elements);
  array->capacity = capacity;
  array->max = -1;
  return array;
error:
  if (array) free(array);
  return NULL;
}

IPArray *ip_array_copy(IPArray *original)
{
  IPArray *result = ip_array_new(original->capacity);
  result->max = original->max;
  memcpy(result->elements, original->elements, ((original->max + 1) * sizeof(void *)));
  return result;
}

void ip_array_free(IPArray *array)
{
  if (array) {
    if (array->elements) free(array->elements);
    free(array);
  }
}

int ip_array_length(IPArray *array)
{
  return array->max + 1;
}

void *ip_array_get(IPArray *array, int i)
{
  check(i < array->capacity, "Array - can't read index %d, capacity: %d", i, array->capacity);
  return array->elements[i];
error:
  return NULL;
}

int ip_array_set(IPArray *array, int i, void *el)
{
  check(i < array->capacity, "Cannot set value beyond capacity");
  if (i > array->max) array->max = i;
  array->elements[i] = el;
  return 0;
error:
  return 1;
}

void * ip_array_remove(IPArray *array, int i)
{
  void *el = array->elements[i];
  array->elements[i] = NULL;
  return el;
}

void ip_array_clear(IPArray *array)
{
  for (int i = 0; i < array->capacity; i++) {
    if (array->elements[i]) {
      free(array->elements[i]);
    }
  }
}

int ip_array_resize(IPArray *array, int capacity)
{
  check(capacity > 0, "Capacity must be > 0");
  array->capacity = capacity;
  void *contents = realloc(array->elements, array->capacity * sizeof(void *));
  check_mem(contents);
  array->elements = contents;
  return 0;
error:
  return -1;
}

int ip_array_expand(IPArray *array)
{
  int old_capacity = array->capacity;
  check(
    ip_array_resize(array, array->capacity + EXPAND_RATE) == 0,
    "Failed to expand array to new size: %d",
    array->capacity + EXPAND_RATE);
  memset(array->elements + old_capacity, 0, EXPAND_RATE + 1);
  return 0;
error:
  return -1;
}

int ip_array_contract(IPArray *array)
{
  int new_size = (array->max < EXPAND_RATE) ? EXPAND_RATE : array->max;
  return ip_array_resize(array, new_size + 1);
}

int ip_array_push(IPArray *array, void *el)
{
  array->max++;
  array->elements[array->max] = el;

  if (array->max >= array->capacity) {
    return ip_array_expand(array);
  } else {
    return 0;
  }
}

void * ip_array_pop(IPArray *array)
{
  check(array->max >= 1, "Cannot pop from empty array");
  void *el = ip_array_remove(array, array->max - 1);
  array->max--;

  if ((ip_array_length(array) > EXPAND_RATE) && (ip_array_length(array) % EXPAND_RATE))
    ip_array_contract(array);

  return el;
error:
  return NULL;
}

