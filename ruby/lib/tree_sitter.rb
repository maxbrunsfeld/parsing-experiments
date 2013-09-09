root = File.expand_path("../tree_sitter", __FILE__)
Dir.glob("#{root}/**/*.rb") { |f| require f }
require "#{root}/tree_sitter.so"

module TreeSitter
  VERSION = "0.0.1"
end
