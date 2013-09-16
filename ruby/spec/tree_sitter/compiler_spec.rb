require "spec_helper"

module TreeSitter
  describe Compiler do
    let(:grammar) do
      Grammar.build do
        rule(:ids)     { (ids + id) | id }
        rule(:id)      { word | number }
        token(:word)   { %r(\w+) }
        token(:number) { %r(\d+) }
      end
    end

    let(:compiler) { Compiler.new(grammar) }

    describe "getting the C source code" do
      it "works" do
        expect(compiler.c_code).to include(%(#include "tree_sitter/runtime.h"))
      end
    end
  end
end
