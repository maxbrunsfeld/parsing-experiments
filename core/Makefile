CC=gcc
CFLAGS=-Wall -I. -Isrc -std=c99 -g -m64
TEST_CFLAGS=-fnested-functions -Itest -Iexternals/bantam-bdd
LIB_FILE=./libiparse.a
SOURCE_FILES=src/*.c
OBJECT_FILES=*.o
TEST_FILES=test/index.c
TEST_BIN=test/run.out

all: clean test

clean:
	rm -f $(OBJECT_FILES) $(LIB_FILE)

compile: $(SOURCE_FILES)
	$(CC) $(CFLAGS) -c $(SOURCE_FILES)

lib: compile
	ar rcs $(LIB_FILE) $(OBJECT_FILES)

compile_test: lib $(TEST_FILES)
	$(CC) $(CFLAGS) $(TEST_CFLAGS) $(LIB_FILE) $(TEST_FILES) -o $(TEST_BIN)

test: compile_test
	$(TEST_BIN)

valgrind: compile_test
	valgrind --track-origins=yes $(TEST_BIN)
