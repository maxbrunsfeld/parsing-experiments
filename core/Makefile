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
LIB_NAME    = tree_sitter
DIR         = $(shell pwd)
HEADERS     = $(wildcard include/*.h)
SOURCES     = $(wildcard src/*.c)
TESTS       = $(wildcard test/*.c)
OBJECTS     = $(foreach file, $(SOURCES), $(basename $(file)).o)
LIB_FILE    = lib$(LIB_NAME)$(SO)
TEST_BIN    = test/run.out

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
	$(RM) $(MODDIR)/$(LIB_NAME);   $(SYMLINK) $(DIR)/share $(MODDIR)/$(LIB_NAME)
	$(RM) $(SOLIBDIR)/$(LIB_FILE); $(SYMLINK) $(DIR)/$(LIB_FILE) $(SOLIBDIR)/$(LIB_FILE)

test: $(TEST_BIN)
	./$<

$(TEST_BIN): $(LIB_FILE) $(TESTS)
	c++ -std=c++11 -stdlib=libc++ -I./include -Itest -Iexternals/bantam-bdd -L. -l$(LIB_NAME) test/_runner.cc -o $@

valgrind: $(TEST_BIN)
	valgrind --track-origins=yes $(TEST_BIN)

clean:
	$(RM) $(OBJECTS) $(LIB_FILE)
