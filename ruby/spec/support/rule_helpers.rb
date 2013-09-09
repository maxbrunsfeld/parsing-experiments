module TreeSitter
  module RuleHelpers
    def token(*args);     Rules::Token.new(*args); end
    def choice(*args);    Rules::Choice.new(*args); end
    def seq(*args);       Rules::Seq.new(*args); end
    def rule_ref(*args);  Rules::RuleRef.new(*args); end
    def token_ref(*args); Rules::TokenRef.new(*args); end
    def rule_end;         Rules::End; end
  end
end
