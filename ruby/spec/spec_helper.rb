ROOT_PATH = File.expand_path("../..", __FILE__)
$LOAD_PATH << "#{ROOT_PATH}/lib"

require "tree_sitter"
require "pp"

Dir.glob("#{ROOT_PATH}/spec/support/**/*.rb") { |f| require f }

module TreeSitter
  RSpec::configure do |config|
    config.include RuleHelpers
  end
end

