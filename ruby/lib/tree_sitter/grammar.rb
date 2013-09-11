module TreeSitter
  class Grammar
    attr_reader :tokens, :rules

    def self.build(&grammar_block)
      GrammarBuilder.new.build_grammar(&grammar_block)
    end

    def initialize(tokens, rules)
      @tokens = tokens
      @rules = rules
    end

    def start_rule
      @rules.values.first
    end

    def internal_representation
      {
        :rules => rules.values,
        :tokens => tokens.values,
        :symbol_names => rules.keys + tokens.keys
      }
    end

    private

    class GrammarBuilder
      def initialize
        @rule_definitions = {}
        @token_definitions = {}
      end

      def rule(name, &block)
        @rule_definitions[name] = block
      end

      def token(name, &block)
        @token_definitions[name] = block
      end

      def build_grammar(&grammar_block)
        instance_exec(&grammar_block)

        token_builder = TokenBuilder.new
        rule_builder = RuleBuilder.new(@rule_definitions.keys, @token_definitions.keys)

        tokens = @token_definitions.each_with_object({}) do |(name, block), h|
          h[name] = token_builder.build_token(&block)
        end

        rules = @rule_definitions.each_with_object({}) do |(name, block), h|
          h[name] = rule_builder.build_rule(&block)
        end

        Grammar.new(tokens, rules)
      end
    end

    class RuleBuilder
      def initialize(rule_names, token_names)
        rule_names.each do |name|
          define_singleton_method(name) { Rules::RuleRef.new(name) }
        end

        token_names.each do |name|
          define_singleton_method(name) { Rules::TokenRef.new(name) }
        end
      end

      def build_rule(&block)
        instance_exec(&block)
      end
    end

    class TokenBuilder
      def build_token(&block)
        Rules::Token.new(block.call)
      end
    end
  end
end
