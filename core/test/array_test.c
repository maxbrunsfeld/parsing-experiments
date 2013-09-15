#include "_helper.h"

TEST(TSArray)
{
  TSArray *array;
  char values[] = { 'a', 'b', 'c', 'd', 'e', 'f', 'g' };

  BEFORE_EACH {
    array = ts_array_new(4);
  };

  AFTER_EACH {
    ts_array_free(array);
  };

  IT("can get and set values") {
    for (int i = 0; i < 4; i++) {
      int result = ts_array_set(array, i, values + i);
      assert(result == 0);
      assert(ts_array_get(array, i) == values + i);
    }

    assert(ts_array_length(array) == 4);

    int result = ts_array_set(array, 4, values);
    assert(result != 0);
  };

  IT("can be copied") {
    for (int i = 0; i < 4; i++)
      ts_array_set(array, i, values + i);

    TSArray *copy = ts_array_copy(array);

    assert(ts_array_length(copy) == 4);
    ts_array_each(array, char, value, i) {
      assert(ts_array_get(copy, i) == value);
    }
  };
}

END_TEST
