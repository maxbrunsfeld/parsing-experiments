.PHONY: all clean install install_dev test valgrind

### install configuration ###
CC        = gcc
RM        ?= rm -f
INSTALL   ?= install
MKDIR     ?= $(INSTALL) -d
SYMLINK   ?= ln -s

PREFIX    ?= /usr/local
BINDIR    ?= $(PREFIX)/bin
LIBDIR    ?= $(PREFIX)/lib
SOLIBDIR  ?= $(PREFIX)/lib
INCDIR    ?= $(PREFIX)/include
MODDIR    ?= $(PREFIX)/share
BINMODDIR ?= $(PREFIX)/lib
MANDIR    ?= $(PREFIX)/share/man/man1

### platform configuration ###
include externals/chibi-scheme/Makefile.detect

### library configuration ###
DIR        = $(shell pwd)
LIB_NAME   = tree_sitter
TEST_FILES = test/_test_runner.c
TEST_BIN   = test/run.out
HEADERS    = $(wildcard include/*.h)
SOURCES    = $(wildcard src/*.c)
LIB_FILE   = lib$(LIB_NAME)$(SO)
OBJECTS    = $(foreach file, $(SOURCES), $(basename $(file)).o)

### build configuration ###
CFLAGS ?= -Wall -std=c99 -g -m64

### targets ###
all: $(LIB_FILE)

$(LIB_FILE): $(OBJECTS) $(HEADERS)
	$(CC) -lchibi-scheme $(OBJECTS) $(CLIBFLAGS) -o $@

src/%.o: src/%.c
	$(CC) $(CFLAGS) -Iinclude -c $< -o $@

install_dev: $(LIB_FILE)
	$(RM) $(INCDIR)/$(LIB_NAME);   $(SYMLINK) $(DIR)/include $(INCDIR)/$(LIB_NAME)
	$(RM) $(SOLIBDIR)/$(LIB_FILE); $(SYMLINK) $(DIR)/$(LIB_FILE) $(SOLIBDIR)/$(LIB_FILE)

test: $(TEST_BIN)
	./$<

$(TEST_BIN): $(LIB_FILE) $(TEST_FILES)
	$(CC) -fnested-functions -I./include -Itest -Iexternals/bantam-bdd -L. -l$(LIB_NAME) $(CFLAGS) $(TEST_FILES) -o $@

valgrind: $(TEST_BIN)
	valgrind --track-origins=yes $(TEST_BIN)

clean:
	$(RM) $(OBJECTS) $(LIB_FILE)
