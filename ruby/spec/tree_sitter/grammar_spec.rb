require "spec_helper"

module TreeSitter
  describe Grammar do
    let(:grammar) do
      Grammar.build do
        rule(:ids)     { (ids + id) | id }
        rule(:id)      { word | number }
        token(:word)   { %r(\w+) }
        token(:number) { %r(\d+) }
      end
    end

    it "sets the tokens" do
      expect(grammar.tokens).to eq({
        :word => token(/\w+/),
        :number => token(/\d+/)
      })
    end

    it "sets the non-tokens" do
      expect(grammar.rules).to eq({
        :id => choice(
          token_ref(:word),
          token_ref(:number)),
        :ids => choice(
          seq(
            rule_ref(:ids),
            rule_ref(:id)),
          rule_ref(:id))
      })
    end

    it "sets the start rule" do
      expect(grammar.start_rule).to eq(grammar.rules[:ids])
    end
  end
end
