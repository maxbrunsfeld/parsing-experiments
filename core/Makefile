.PHONY: all clean install install-dev test test-c test-scm valgrind

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
LIB_NAME    = tree_sitter
DIR         = $(shell pwd)
HEADERS     = $(wildcard include/*.h)
C_SOURCES   = $(wildcard src/c/*.c)
C_TESTS     = $(wildcard test/c/*.c)
OBJECTS     = $(foreach file, $(C_SOURCES), $(basename $(file)).o)
LIB_FILE    = lib$(LIB_NAME)$(SO)
TEST_BIN    = test/run.out

### build configuration ###
CFLAGS ?= -Wall -std=c99 -g -m64

### targets ###
all: $(LIB_FILE)

$(LIB_FILE): $(OBJECTS) $(HEADERS)
	$(CC) -llua -lm $(OBJECTS) $(CLIBFLAGS) -o $@

src/c/%.o: src/c/%.c
	$(CC) $(CFLAGS) -Iinclude -c $< -o $@

install-dev:
	$(RM) $(INCDIR)/$(LIB_NAME);   $(SYMLINK) $(DIR)/include $(INCDIR)/$(LIB_NAME)
	$(RM) $(MODDIR)/$(LIB_NAME);   $(SYMLINK) $(DIR)/src/lua $(MODDIR)/$(LIB_NAME)
	$(RM) $(SOLIBDIR)/$(LIB_FILE); $(SYMLINK) $(DIR)/$(LIB_FILE) $(SOLIBDIR)/$(LIB_FILE)

test: test-c test-lua

test-c: $(TEST_BIN)
	./$<

test-lua:
	busted -m './src/lua/?.lua;./test/lua/?.lua' test/lua

$(TEST_BIN): $(LIB_FILE) $(C_TESTS)
	c++ -std=c++11 -stdlib=libc++ -I./include -Itest/c -Iexternals/bantam-bdd -L. -l$(LIB_NAME) test/c/_runner.cc -o $@

valgrind: $(TEST_BIN)
	valgrind --track-origins=yes $(TEST_BIN)

repl:
	lua -i -e'package.path = "./src/lua/?.lua;" .. package.path; require("start");'

clean:
	$(RM) $(OBJECTS) $(LIB_FILE)
