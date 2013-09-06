#include "array.h"
#include "_test_helper.h"

TEST(IPArray)
{
  IPArray *array;
  char values[] = { 'a', 'b', 'c', 'd', 'e', 'f', 'g' };

  BEFORE_EACH {
    array = ip_array_new(4);
  }

  AFTER_EACH {
    ip_array_free(array);
  }

  IT("can get and set values") {
    for (int i = 0; i < 4; i++) {
      int result = ip_array_set(array, i, values + i);
      assert(result == 0);
      assert(ip_array_get(array, i) == values + i);
    }

    assert(ip_array_length(array) == 4);

    int result = ip_array_set(array, 4, values);
    assert(result != 0);
  }

  IT("can be copied") {
    for (int i = 0; i < 4; i++)
      ip_array_set(array, i, values + i);

    IPArray *copy = ip_array_copy(array);

    assert(ip_array_length(copy) == 4);
    ip_array_each(array, char, value, i) {
      assert(ip_array_get(copy, i) == value);
    }
  }
}

END_TEST

