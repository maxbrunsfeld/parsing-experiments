require "mkmf"

root = File.expand_path("../../..", __FILE__)

dir_config("tree_sitter", "#{root}/../core/src", "#{root}/../core")
find_library("tree_sitter", "ts_grammar_new")
find_header("tree_sitter.h")
create_makefile("tree_sitter_rb")
