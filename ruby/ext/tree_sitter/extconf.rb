require "mkmf"
dir_config("tree_sitter")
find_library("tree-sitter", "ts_grammar_new")
find_header("tree-sitter.h")
create_makefile("tree_sitter/tree_sitter")
