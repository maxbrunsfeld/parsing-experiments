.PHONY: clean test valgrind

LIB_NAME=tree_sitter
LIB_FILE=lib$(LIB_NAME).so
HEADER=src/$(LIB_NAME).h
SOURCE_FILES=$(wildcard src/*.c)
OBJECT_FILES=$(foreach file,$(SOURCE_FILES),$(basename $(file)).o)
TEST_FILES=test/_test_runner.c
TEST_BIN=test/run.out

CC=gcc
CFLAGS=-Wall -std=c99 -g -m64
CPPFLAGS=-Isrc
LDFLAGS=-L/usr/local/lib -lchibi-scheme -L.

TEST_CFLAGS=-fnested-functions
TEST_CPPFLAGS=-Itest -Iexternals/bantam-bdd
TEST_LDFLAGS=-l$(LIB_NAME)

test: $(TEST_BIN)
	$<

$(TEST_BIN): $(LIB_FILE) $(TEST_FILES)
	$(CC) $(CFLAGS) $(LDFLAGS) $(CPPFLAGS) \
	$(TEST_CFLAGS) $(TEST_LDFLAGS) $(TEST_CPPFLAGS) \
	$(TEST_FILES) -o $@

$(LIB_FILE): $(OBJECT_FILES) $(HEADER)
	$(CC) $(CPPFLAGS) $(LDFLAGS) $^ -shared -o $@

%.o: src/%.c
	$(CC) -c $(CFLAGS) $< -o $@

clean:
	$(RM) $(OBJECT_FILES) $(LIB_FILE)

valgrind: $(TEST_BIN)
	valgrind --track-origins=yes $^
