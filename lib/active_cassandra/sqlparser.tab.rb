#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.6
# from Racc grammer file "".
#

require 'racc/parser.rb'


require 'strscan'

module ActiveCassandra

class SQLParser < Racc::Parser

module_eval(<<'...end sqlparser.y/module_eval...', 'sqlparser.y', 225)

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

...end sqlparser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
     3,   115,   101,    96,    21,     7,   117,   118,   126,   134,
   135,    85,    85,   128,    83,    12,   136,   137,    63,    85,
    65,    66,    65,    66,     5,    55,    55,     6,    68,    50,
    68,   127,    52,    55,    73,    76,   127,    12,    12,   127,
   127,    26,    50,   139,    29,    12,    55,    19,    20,    41,
    15,    80,    69,    70,    71,    72,    74,    75,    12,    73,
    76,    83,    77,    78,    65,    66,   127,    12,    12,    35,
    81,    82,    68,   130,   131,    27,    80,    69,    70,    71,
    72,    74,    75,    12,    45,    65,    66,    65,    66,    65,
    66,    65,    66,    68,    89,    68,    89,    68,    35,    68,
    65,    66,    65,    66,    65,    66,    65,    66,    68,    92,
    68,    93,    68,    94,    68,    65,    66,    62,    26,    12,
    99,    25,    35,    68,    12,   102,    23,   104,   106,   104,
    12,   109,   110,    12,    35,    30,    12,    47,   119,    12,
   119,    12,    31,    40,    12,    13,    12,    12,    35,    12,
    10,    12,   111 ]

racc_action_check = [
     0,   103,    84,    79,     8,     0,   104,   104,   113,   121,
   121,    83,    85,   114,    84,    19,   123,   124,    44,    52,
   103,   103,    79,    79,     0,    83,    85,     0,   103,    52,
    79,   113,    35,    52,    87,    87,   114,    83,    85,   123,
   124,    44,    35,   129,    20,    52,    35,     7,     7,    29,
     7,    87,    87,    87,    87,    87,    87,    87,    35,    49,
    49,    51,    49,    49,   109,   109,   129,    29,     7,    32,
    50,    50,   109,   119,   119,    18,    49,    49,    49,    49,
    49,    49,    49,    55,    32,    78,    78,   111,   111,   110,
   110,   115,   115,    78,    59,   111,    60,   110,    61,   115,
   127,   127,    81,    81,    99,    99,    96,    96,   127,    62,
    81,    63,    99,    77,    96,    47,    47,    42,    17,    40,
    82,    14,    39,    47,    13,    86,    11,    88,    89,    90,
    92,    93,    94,    10,    37,    21,    45,    33,   105,   106,
   107,    31,    22,    28,    27,     6,    26,    25,    24,     5,
     3,    23,    95 ]

racc_action_pointer = [
    -2,   nil,   nil,   147,   nil,   119,   137,    38,     4,   nil,
   103,    99,   nil,    94,   113,   nil,   nil,    90,    67,   -15,
    40,   135,   138,   121,   135,   117,   116,   114,   135,    37,
   nil,   111,    56,   122,   nil,    28,   nil,   121,   nil,   109,
    89,   nil,   112,   nil,    13,   106,   nil,    92,   nil,    44,
    55,    44,    15,   nil,   nil,    53,   nil,   nil,   nil,    74,
    76,    85,    98,   105,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    97,    62,    -1,
   nil,    79,   116,     7,    -3,     8,   120,    19,   105,   107,
   107,   nil,   100,   127,   128,   135,    83,   nil,   nil,    81,
   nil,   nil,   nil,    -3,   -17,   113,   109,   115,   nil,    41,
    66,    64,   nil,     3,     8,    68,   nil,   nil,   nil,    50,
   nil,   -30,   nil,    11,    12,   nil,   nil,    77,   nil,    38,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil ]

racc_action_default = [
   -68,    -2,    -3,   -68,    -4,   -68,   -68,   -68,   -68,    -1,
   -68,   -68,   -49,   -68,   -68,   -13,   -50,   -14,   -68,   -68,
   -68,   -68,   -68,   -68,   -15,   -68,   -68,   -68,   -68,   -68,
   140,   -68,   -15,   -68,   -45,   -68,   -48,   -15,   -51,   -15,
   -68,   -11,   -68,   -12,   -68,   -68,   -44,   -68,   -16,   -68,
   -68,   -17,   -68,   -18,   -22,   -68,   -24,   -30,   -31,   -34,
   -34,   -15,    -9,   -68,   -46,   -53,   -52,   -47,   -54,   -59,
   -60,   -61,   -62,   -65,   -63,   -64,   -57,   -68,   -68,   -68,
   -58,   -68,   -68,   -68,   -68,   -68,   -68,   -68,   -38,   -68,
   -38,    -7,   -68,   -68,   -68,   -68,   -68,   -26,   -20,   -68,
   -23,   -25,   -19,   -68,   -68,   -41,   -68,   -41,   -10,   -68,
   -68,   -68,   -55,   -68,   -68,   -68,   -27,   -39,   -40,   -68,
    -8,   -36,    -6,   -68,   -68,   -32,   -28,   -68,   -21,   -68,
   -42,   -43,   -35,   -37,   -66,   -67,    -5,   -33,   -56,   -29 ]

racc_goto_table = [
    11,    79,    16,    17,   105,    22,   107,    34,    24,   120,
    67,   122,    88,    90,    28,    36,    53,     2,    33,     4,
    37,    38,    39,    46,    43,    14,    16,    44,    59,    64,
    60,    42,    48,    86,   113,    61,    51,   114,    18,   103,
    33,    95,    97,     1,    98,   100,     9,   123,   124,   132,
    87,   133,    91,   129,    32,     8,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   116,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   125,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   108,   nil,   nil,
   138,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   121 ]

racc_goto_check = [
     6,    22,     6,     7,    12,     6,    12,    28,     6,    13,
    19,    13,    11,    11,     6,    10,    18,     4,     6,     5,
     6,     6,     6,    10,     6,    14,     6,     7,    10,    28,
    10,    15,    16,    18,     8,     6,    17,     8,     9,    22,
     6,    19,    19,     3,    19,    20,     2,     8,     8,    25,
     6,    26,    10,     8,    27,     1,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,    19,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,    19,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,     6,   nil,   nil,
    19,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,     6 ]

racc_goto_pointer = [
   nil,    55,    46,    43,    17,    19,    -5,    -4,   -62,    31,
    -9,   -47,   -84,   -96,    18,     2,    -3,     1,   -19,   -37,
   -38,   nil,   -48,   nil,   nil,   -72,   -70,    31,   -16 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,    49,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    84,   nil,   112,
    54,    56,   nil,    57,    58,   nil,   nil,   nil,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 42, :_reduce_none,
  1, 42, :_reduce_none,
  1, 42, :_reduce_none,
  1, 42, :_reduce_none,
  10, 43, :_reduce_5,
  8, 44, :_reduce_6,
  6, 44, :_reduce_7,
  8, 44, :_reduce_8,
  4, 55, :_reduce_9,
  6, 55, :_reduce_10,
  1, 56, :_reduce_none,
  1, 56, :_reduce_none,
  1, 50, :_reduce_13,
  1, 50, :_reduce_none,
  0, 51, :_reduce_15,
  2, 51, :_reduce_16,
  2, 51, :_reduce_17,
  1, 57, :_reduce_none,
  3, 57, :_reduce_19,
  3, 59, :_reduce_20,
  5, 59, :_reduce_21,
  1, 58, :_reduce_22,
  3, 58, :_reduce_23,
  1, 61, :_reduce_none,
  3, 61, :_reduce_25,
  3, 62, :_reduce_26,
  4, 62, :_reduce_27,
  5, 62, :_reduce_28,
  6, 62, :_reduce_29,
  1, 62, :_reduce_none,
  1, 62, :_reduce_none,
  5, 64, :_reduce_32,
  6, 65, :_reduce_33,
  0, 52, :_reduce_34,
  4, 52, :_reduce_35,
  0, 66, :_reduce_36,
  1, 66, :_reduce_none,
  0, 53, :_reduce_38,
  2, 53, :_reduce_39,
  2, 53, :_reduce_40,
  0, 54, :_reduce_41,
  2, 54, :_reduce_42,
  2, 54, :_reduce_43,
  5, 45, :_reduce_44,
  1, 68, :_reduce_none,
  3, 68, :_reduce_46,
  3, 69, :_reduce_47,
  4, 46, :_reduce_48,
  1, 47, :_reduce_none,
  1, 48, :_reduce_50,
  3, 48, :_reduce_51,
  1, 60, :_reduce_none,
  1, 60, :_reduce_none,
  1, 60, :_reduce_none,
  1, 49, :_reduce_55,
  3, 49, :_reduce_56,
  1, 63, :_reduce_57,
  1, 63, :_reduce_58,
  1, 63, :_reduce_59,
  1, 63, :_reduce_60,
  1, 63, :_reduce_61,
  1, 63, :_reduce_62,
  1, 63, :_reduce_63,
  1, 63, :_reduce_64,
  1, 63, :_reduce_65,
  1, 67, :_reduce_66,
  1, 67, :_reduce_67 ]

racc_reduce_n = 68

racc_shift_n = 140

racc_token_table = {
  false => 0,
  :error => 1,
  :INSERT => 2,
  :INTO => 3,
  "(" => 4,
  ")" => 5,
  :VALUES => 6,
  :SELECT => 7,
  :FROM => 8,
  :DISTINCT => 9,
  :COUNT => 10,
  :AS => 11,
  "*" => 12,
  :WHERE => 13,
  :ID => 14,
  "=" => 15,
  :IN => 16,
  :AND => 17,
  :NOT => 18,
  :BETWEEN => 19,
  :ORDER => 20,
  :BY => 21,
  :LIMIT => 22,
  :NUMBER => 23,
  :STRING => 24,
  :OFFSET => 25,
  :UPDATE => 26,
  :SET => 27,
  "," => 28,
  :DELETE => 29,
  :IDENTIFIER => 30,
  :NULL => 31,
  :REGEXP => 32,
  "<>" => 33,
  "!=" => 34,
  ">=" => 35,
  "<=" => 36,
  ">" => 37,
  "<" => 38,
  :ASC => 39,
  :DESC => 40 }

racc_nt_base = 41

racc_use_result_var = false

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "INSERT",
  "INTO",
  "\"(\"",
  "\")\"",
  "VALUES",
  "SELECT",
  "FROM",
  "DISTINCT",
  "COUNT",
  "AS",
  "\"*\"",
  "WHERE",
  "ID",
  "\"=\"",
  "IN",
  "AND",
  "NOT",
  "BETWEEN",
  "ORDER",
  "BY",
  "LIMIT",
  "NUMBER",
  "STRING",
  "OFFSET",
  "UPDATE",
  "SET",
  "\",\"",
  "DELETE",
  "IDENTIFIER",
  "NULL",
  "REGEXP",
  "\"<>\"",
  "\"!=\"",
  "\">=\"",
  "\"<=\"",
  "\">\"",
  "\"<\"",
  "ASC",
  "DESC",
  "$start",
  "sql",
  "create_statement",
  "read_statemant",
  "update_statemant",
  "delete_statemant",
  "id",
  "id_list",
  "value_list",
  "select_list",
  "where_clause",
  "order_by_clause",
  "limit_clause",
  "offset_clause",
  "count_clause",
  "count_arg",
  "id_search_condition",
  "search_condition",
  "id_predicate",
  "value",
  "boolean_primary",
  "predicate",
  "op",
  "between_predicate",
  "not_in_predicate",
  "ordering_spec",
  "order_spec",
  "set_clause_list",
  "set_clause" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

# reduce 2 omitted

# reduce 3 omitted

# reduce 4 omitted

module_eval(<<'.,.,', 'sqlparser.y', 10)
  def _reduce_5(val, _values)
                                {:command => :insert, :table => val[2], :column_list => val[4], :value_list => val[8]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 15)
  def _reduce_6(val, _values)
                                {:command => :select, :table => val[3], :select_list => val[1], :condition => val[4], :order => val[5], :limit => val[6], :offset => val[7]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 19)
  def _reduce_7(val, _values)
                                {:command => :select, :table => val[4], :select_list => val[2], :distinct => val[2], :condition => val[5]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 23)
  def _reduce_8(val, _values)
                                {:command => :select, :table => val[3], :count => val[1], :condition => val[4], :order => val[5], :limit => val[6], :offset => val[7]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 28)
  def _reduce_9(val, _values)
                                "count_all"
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 32)
  def _reduce_10(val, _values)
                                val[5]
                          
  end
.,.,

# reduce 11 omitted

# reduce 12 omitted

module_eval(<<'.,.,', 'sqlparser.y', 40)
  def _reduce_13(val, _values)
                                []
                          
  end
.,.,

# reduce 14 omitted

module_eval(<<'.,.,', 'sqlparser.y', 46)
  def _reduce_15(val, _values)
                                []
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 50)
  def _reduce_16(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 54)
  def _reduce_17(val, _values)
                                val[1]
                          
  end
.,.,

# reduce 18 omitted

module_eval(<<'.,.,', 'sqlparser.y', 60)
  def _reduce_19(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 65)
  def _reduce_20(val, _values)
                                val[2]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 69)
  def _reduce_21(val, _values)
                                val[3]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 74)
  def _reduce_22(val, _values)
                                [val[0]].flatten
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 78)
  def _reduce_23(val, _values)
                                (val[0] << val[2]).flatten
                          
  end
.,.,

# reduce 24 omitted

module_eval(<<'.,.,', 'sqlparser.y', 84)
  def _reduce_25(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 89)
  def _reduce_26(val, _values)
                                {:name => val[0], :op => val[1], :expr => val[2]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 93)
  def _reduce_27(val, _values)
                                {:name => val[1], :op => val[2], :expr => val[3], :not => true}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 97)
  def _reduce_28(val, _values)
                                {:name => val[0], :op => val[1], :expr => val[3]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 101)
  def _reduce_29(val, _values)
                                {:name => val[1], :op => val[2], :expr => val[4], :not => true}
                          
  end
.,.,

# reduce 30 omitted

# reduce 31 omitted

module_eval(<<'.,.,', 'sqlparser.y', 108)
  def _reduce_32(val, _values)
                                {:name => val[0], :op => '$bt', :expr => [val[2], val[4]]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 113)
  def _reduce_33(val, _values)
                                {:name => val[0], :op => '$in', :expr => val[4], :not => true}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 118)
  def _reduce_34(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 122)
  def _reduce_35(val, _values)
                                {:name => val[2], :type => val[3]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 127)
  def _reduce_36(val, _values)
                                :asc
                          
  end
.,.,

# reduce 37 omitted

module_eval(<<'.,.,', 'sqlparser.y', 133)
  def _reduce_38(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 137)
  def _reduce_39(val, _values)
                                val[1].to_i
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 141)
  def _reduce_40(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 146)
  def _reduce_41(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 150)
  def _reduce_42(val, _values)
                                val[1].to_i
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 154)
  def _reduce_43(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 159)
  def _reduce_44(val, _values)
                                {:command => :update, :table => val[1], :set_clause_list => val[3], :condition => val[4]}
                          
  end
.,.,

# reduce 45 omitted

module_eval(<<'.,.,', 'sqlparser.y', 165)
  def _reduce_46(val, _values)
                                val[0].merge val[2]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 170)
  def _reduce_47(val, _values)
                              {val[0] => val[2]}
                        
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 175)
  def _reduce_48(val, _values)
                                {:command => :delete, :table => val[2], :condition => val[3]}
                          
  end
.,.,

# reduce 49 omitted

module_eval(<<'.,.,', 'sqlparser.y', 182)
  def _reduce_50(val, _values)
                                [val[0]]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 186)
  def _reduce_51(val, _values)
                                val[0] << val[2]
                          
  end
.,.,

# reduce 52 omitted

# reduce 53 omitted

# reduce 54 omitted

module_eval(<<'.,.,', 'sqlparser.y', 195)
  def _reduce_55(val, _values)
                                [val[0]]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 199)
  def _reduce_56(val, _values)
                                val[0] << val[2]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 202)
  def _reduce_57(val, _values)
     '$in'     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 203)
  def _reduce_58(val, _values)
     '$regexp' 
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 204)
  def _reduce_59(val, _values)
     :'!='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 205)
  def _reduce_60(val, _values)
     :'!='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 206)
  def _reduce_61(val, _values)
     :'>='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 207)
  def _reduce_62(val, _values)
     :'<='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 208)
  def _reduce_63(val, _values)
     :'>'      
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 209)
  def _reduce_64(val, _values)
     :'<'      
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 210)
  def _reduce_65(val, _values)
     :'=='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 212)
  def _reduce_66(val, _values)
     :asc  
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 213)
  def _reduce_67(val, _values)
     :desc 
  end
.,.,

def _reduce_none(val, _values)
  val[0]
end

end   # class SQLParser


end # module ActiveCassandra
