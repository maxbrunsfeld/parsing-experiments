module TreeSitter
  module Rules
    module Node
      def initialize(*args)
        super
        freeze
      end

      def |(other)
        Choice.new(self, other)
      end

      def +(other)
        Seq.new(self, other)
      end

      def inspect
        member_values = members.map { |member| "#{member}=#{send(member)}" }
        "#<#{self.class.name} #{member_values.join(' ')}>"
      end

      def to_s
        inspect
      end
    end

    Token = Struct.new(:pattern)

    Seq = Struct.new(:left, :right) do
      include Node
    end

    Choice = Struct.new(:left, :right) do
      include Node
    end

    Ref = Struct.new(:name) do
      include Node
    end

    TokenRef = Class.new(Ref)
    RuleRef  = Class.new(Ref)
  end
end
