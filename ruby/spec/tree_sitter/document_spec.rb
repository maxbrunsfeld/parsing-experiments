require "spec_helper"

module TreeSitter
  describe Document do
    describe "with a trivial grammar" do
      let(:grammar) do
        Grammar.build do
          start(:words) { word + word }
          token(:word) { "Hi" }
        end
      end

      let(:document) { Document.new(grammar) }
    end
  end
end
