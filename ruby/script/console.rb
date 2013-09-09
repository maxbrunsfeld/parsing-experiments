ROOT_PATH = File.expand_path("../..", __FILE__)
$LOAD_PATH << "#{ROOT_PATH}/lib"

require "irb/completion"
require "tree_sitter"
