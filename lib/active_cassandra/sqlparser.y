class SQLParser
options no_result_var
rule
  sql                   : create_statement
                        | read_statemant
                        | update_statemant
                        | delete_statemant

  create_statement      : INSERT INTO id '(' id_list ')' VALUES '(' value_list ')'
                          {
                            {:command => :insert, :table => val[2], :column_list => val[4], :value_list => val[8]}
                          }

  read_statemant        : SELECT select_list FROM id where_clause order_by_clause limit_clause offset_clause
                          {
                            {:command => :select, :table => val[3], :select_list => val[1], :condition => val[4], :order => val[5], :limit => val[6], :offset => val[7]}
                          }
                        | SELECT DISTINCT id FROM id where_clause
                          {
                            {:command => :select, :table => val[4], :select_list => val[2], :distinct => val[2], :condition => val[5]}
                          }
                        | SELECT count_clause FROM id where_clause order_by_clause limit_clause offset_clause
                          {
                            {:command => :select, :table => val[3], :count => val[1], :condition => val[4], :order => val[5], :limit => val[6], :offset => val[7]}
                          }

  count_clause          : COUNT '(' count_arg ')'
                          {
                            "count_all"
                          }
                        | COUNT '(' count_arg ')' AS id
                          {
                            val[5]
                          }

  count_arg             : '*'
                        | id

  select_list           : '*'
                          {
                            []
                          }
                        | id_list

  where_clause          :
                          {
                            []
                          }
                        | WHERE id_search_condition
                          {
                            val[1]
                          }
                        | WHERE search_condition
                          {
                            val[1]
                          }

  id_search_condition   : id_predicate
                        | '(' id_predicate ')'
                          {
                            val[1]
                          }

  id_predicate          : ID '=' value
                          {
                            val[2]
                          }
                        |  ID IN '(' value_list ')'
                          {
                            val[3]
                          }

  search_condition      : boolean_primary
                          {
                            [val[0]].flatten
                          }
                        | search_condition AND boolean_primary
                          {
                            (val[0] << val[2]).flatten
                          }

  boolean_primary       : predicate
                        | '(' search_condition ')'
                          {
                            val[1]
                          }

  predicate             : id op value
                          {
                            {:name => val[0], :op => val[1], :expr => val[2]}
                          }
                        | NOT id op value
                          {
                            {:name => val[1], :op => val[2], :expr => val[3], :not => true}
                          }
                        | id op '(' value_list ')'
                          {
                            {:name => val[0], :op => val[1], :expr => val[3]}
                          }
                        | NOT id op '(' value_list ')'
                          {
                            {:name => val[1], :op => val[2], :expr => val[4], :not => true}
                          }
                        | between_predicate
                        | not_in_predicate

  between_predicate     : id BETWEEN value AND value
                          {
                            {:name => val[0], :op => '$bt', :expr => [val[2], val[4]]}
                          }

  not_in_predicate     : id NOT IN '(' value_list ')'
                          {
                            {:name => val[0], :op => '$in', :expr => val[4], :not => true}
                          }

  order_by_clause       :
                          {
                            nil
                          }
                        | ORDER BY id ordering_spec
                          {
                            {:name => val[2], :type => val[3]}
                          }

  ordering_spec         :
                          {
                            :asc
                          }
                        | order_spec

  limit_clause          :
                          {
                            nil
                          }
                        | LIMIT STRING
                          {
                            val[1]
                          }

  offset_clause          :
                          {
                            nil
                          }
                        | OFFSET STRING
                          {
                            val[1]
                          }

  update_statemant      : UPDATE id SET set_clause_list where_clause
                          {
                            {:command => :update, :table => val[1], :set_clause_list => val[3], :condition => val[4]}
                          }

  set_clause_list       : set_clause
                        | set_clause_list ',' set_clause
                          {
                            val[0].merge val[2]
                          }

  set_clause            : id '=' value
                        {
                          {val[0] => val[2]}
                        }

  delete_statemant      : DELETE FROM id where_clause
                          {
                            {:command => :delete, :table => val[2], :condition => val[3]}
                          }

  id                    : IDENTIFIER

  id_list               : id
                          {
                            [val[0]]
                          }
                        | id_list ',' id
                          {
                            val[0] << val[2]
                          }

  value                 : STRING
                        | NUMBER
                        | NULL

  value_list            : value
                          {
                            [val[0]]
                          }
                        | value_list ',' value
                          {
                            val[0] << val[2]
                          }

  op                    : IN     { '$in'     }
                        | REGEXP { '$regexp' }
                        | '<>'   { :'!='     }
                        | '!='   { :'!='     }
                        | '>='   { :'>='     }
                        | '<='   { :'<='     }
                        | '>'    { :'>'      }
                        | '<'    { :'<'      }
                        | '='    { :'=='     }

  order_spec            : ASC  { :asc  }
                        | DESC { :desc }

end

---- header

require 'strscan'

module ActiveCassandra

---- inner

KEYWORDS = %w(
  AND
  AS
  ASC
  BETWEEN
  BY
  COUNT
  DELETE
  DESC
  DISTINCT
  FROM
  IN
  INSERT
  INTO
  LIMIT
  NOT
  OFFSET
  ORDER
  REGEXP
  SELECT
  SET
  UPDATE
  VALUES
  WHERE
)

KEYWORD_REGEXP = Regexp.compile("(?:#{KEYWORDS.join '|'})\\b", Regexp::IGNORECASE)

def initialize(obj)
  src = obj.is_a?(IO) ? obj.read : obj.to_s
  @ss = StringScanner.new(src)
end

def scan
  piece = nil

  until @ss.eos?
    if (tok = @ss.scan /\s+/)
      # nothing to do
    elsif (tok = @ss.scan /(?:<>|!=|>=|<=|>|<|=)/)
      yield tok, tok
    elsif (tok = @ss.scan KEYWORD_REGEXP)
      yield tok.upcase.to_sym, tok
    elsif (tok = @ss.scan /NULL\b/i)
      yield :NULL, nil
    elsif (tok = @ss.scan /'(?:[^']|'')*'/) #'
      yield :STRING, tok.slice(1...-1).gsub(/''/, "'")
    elsif (tok = @ss.scan /-?(?:0|[1-9]\d*)(?:\.\d+)/)
      yield :NUMBER, tok.to_f
    elsif (tok = @ss.scan /-?(?:0|[1-9]\d*)/)
      yield :NUMBER, tok.to_i
    elsif (tok = @ss.scan /[,\(\)\*]/)
      yield tok, tok
    elsif (tok = @ss.scan /(?:[a-z_]\w+\.|[a-z]\.)*ID\b/i)
      yield :ID, tok
    elsif (tok = @ss.scan /(?:[a-z_]\w+\.|[a-z]\.)*(?:[a-z_]\w+|[a-z])/i)
      yield :IDENTIFIER, tok
    else
      raise Racc::ParseError, ('parse error on value "%s"' % @ss.rest.inspect)
    end
  end

  yield false, '$'
end
private :scan

def parse
  yyparse self, :scan
end

---- footer

end # module ActiveCassandra
