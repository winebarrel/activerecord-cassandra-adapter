#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.6
# from Racc grammer file "".
#

require 'racc/parser.rb'


require 'strscan'

module ActiveCassandra

class SQLParser < Racc::Parser

module_eval(<<'...end sqlparser.y/module_eval...', 'sqlparser.y', 217)

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
    96,    41,   115,    35,   101,    21,    85,     3,    12,    85,
    81,    82,     7,   132,   133,    62,    83,    45,    12,    65,
    55,    65,    85,    55,   126,    52,    67,    68,    67,    68,
     5,    12,    50,     6,    12,    50,    55,    73,    76,    55,
    77,    78,    12,    12,    73,    76,   125,    12,   127,   134,
    12,   135,    63,   137,    80,    69,    70,    71,    72,    74,
    75,    80,    69,    70,    71,    72,    74,    75,    83,    27,
   125,   125,    12,   125,    26,   125,    19,    20,    65,    15,
    65,    89,    65,    89,    65,    67,    68,    67,    68,    67,
    68,    67,    68,    65,    35,    65,    12,    65,    92,    65,
    67,    68,    67,    68,    67,    68,    67,    68,    65,    93,
    65,    94,    35,    26,    35,    67,    68,    67,    68,    99,
    25,    30,    12,   102,    23,   104,   106,   104,    12,   109,
   110,    12,    47,    12,    29,   117,   118,    12,   118,    31,
    40,    12,    12,    13,    12,   129,    35,    12,    10,    12,
   111 ]

racc_action_check = [
    79,    29,   103,    32,    84,     8,    83,     0,    45,    85,
    50,    50,     0,   120,   120,    42,    84,    32,    29,    79,
    83,   103,    52,    85,   113,    35,    79,    79,   103,   103,
     0,    83,    52,     0,    85,    35,    52,    49,    49,    35,
    49,    49,    19,    40,    87,    87,   113,    52,   114,   122,
    35,   123,    44,   128,    49,    49,    49,    49,    49,    49,
    49,    87,    87,    87,    87,    87,    87,    87,    51,    18,
   114,   122,    55,   123,    44,   128,     7,     7,    99,     7,
   111,    59,   110,    60,   109,    99,    99,   111,   111,   110,
   110,   109,   109,   115,    61,    47,     7,    78,    62,   125,
   115,   115,    47,    47,    78,    78,   125,   125,    81,    63,
    96,    77,    39,    17,    37,    81,    81,    96,    96,    82,
    14,    21,    13,    86,    11,    88,    89,    90,    92,    93,
    94,    10,    33,    31,    20,   104,   105,   106,   107,    22,
    28,    27,    26,     6,    25,   118,    24,     5,     3,    23,
    95 ]

racc_action_pointer = [
     5,   nil,   nil,   145,   nil,   118,   135,    67,     5,   nil,
   102,    98,   nil,    93,   112,   nil,   nil,    86,    61,    13,
   130,   121,   135,   120,   133,   115,   113,   112,   132,   -11,
   nil,   104,   -10,   117,   nil,    21,   nil,   101,   nil,    99,
    14,   nil,    10,   nil,    47,   -21,   nil,    72,   nil,    22,
    -5,    51,    18,   nil,   nil,    43,   nil,   nil,   nil,    61,
    63,    81,    87,   103,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    95,    74,    -4,
   nil,    85,   115,     2,    -1,     5,   118,    29,   103,   105,
   105,   nil,    99,   125,   126,   133,    87,   nil,   nil,    55,
   nil,   nil,   nil,    -2,   112,   112,   108,   114,   nil,    61,
    59,    57,   nil,    19,    43,    70,   nil,   nil,   122,   nil,
   -26,   nil,    44,    46,   nil,    76,   nil,   nil,    48,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil ]

racc_action_default = [
   -66,    -2,    -3,   -66,    -4,   -66,   -66,   -66,   -66,    -1,
   -66,   -66,   -47,   -66,   -66,   -13,   -48,   -14,   -66,   -66,
   -66,   -66,   -66,   -66,   -15,   -66,   -66,   -66,   -66,   -66,
   138,   -66,   -15,   -66,   -43,   -66,   -46,   -15,   -49,   -15,
   -66,   -11,   -66,   -12,   -66,   -66,   -42,   -66,   -16,   -66,
   -66,   -17,   -66,   -18,   -22,   -66,   -24,   -30,   -31,   -34,
   -34,   -15,    -9,   -66,   -44,   -50,   -45,   -51,   -52,   -57,
   -58,   -59,   -60,   -63,   -61,   -62,   -55,   -66,   -66,   -66,
   -56,   -66,   -66,   -66,   -66,   -66,   -66,   -66,   -38,   -66,
   -38,    -7,   -66,   -66,   -66,   -66,   -66,   -26,   -20,   -66,
   -23,   -25,   -19,   -66,   -66,   -40,   -66,   -40,   -10,   -66,
   -66,   -66,   -53,   -66,   -66,   -66,   -27,   -39,   -66,    -8,
   -36,    -6,   -66,   -66,   -32,   -66,   -28,   -21,   -66,   -41,
   -35,   -37,   -64,   -65,    -5,   -33,   -54,   -29 ]

racc_goto_table = [
    11,    17,    16,     2,    79,    22,     4,    66,    24,    34,
    53,   105,    14,   107,    28,    36,    42,   119,    33,   121,
    37,    38,    39,    46,    43,    44,    16,    86,    59,    48,
    60,    64,    88,    90,   113,    61,    51,   114,    95,    97,
    33,    98,   103,    18,     1,   100,     9,   122,   123,   130,
    87,   131,    91,   128,    32,     8,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   116,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   124,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   136,   nil,   108,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   120 ]

racc_goto_check = [
     6,     7,     6,     4,    22,     6,     5,    19,     6,    28,
    18,    12,    14,    12,     6,    10,    15,    13,     6,    13,
     6,     6,     6,    10,     6,     7,     6,    18,    10,    16,
    10,    28,    11,    11,     8,     6,    17,     8,    19,    19,
     6,    19,    22,     9,     3,    20,     2,     8,     8,    25,
     6,    26,    10,     8,    27,     1,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,    19,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    19,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,    19,   nil,     6,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,     6 ]

racc_goto_pointer = [
   nil,    55,    46,    44,     3,     6,    -5,    -6,   -62,    36,
    -9,   -27,   -77,   -88,     5,   -13,    -6,     1,   -25,   -40,
   -38,   nil,   -45,   nil,   nil,   -71,   -69,    31,   -14 ]

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
  0, 54, :_reduce_40,
  2, 54, :_reduce_41,
  5, 45, :_reduce_42,
  1, 68, :_reduce_none,
  3, 68, :_reduce_44,
  3, 69, :_reduce_45,
  4, 46, :_reduce_46,
  1, 47, :_reduce_none,
  1, 48, :_reduce_48,
  3, 48, :_reduce_49,
  1, 60, :_reduce_none,
  1, 60, :_reduce_none,
  1, 60, :_reduce_none,
  1, 49, :_reduce_53,
  3, 49, :_reduce_54,
  1, 63, :_reduce_55,
  1, 63, :_reduce_56,
  1, 63, :_reduce_57,
  1, 63, :_reduce_58,
  1, 63, :_reduce_59,
  1, 63, :_reduce_60,
  1, 63, :_reduce_61,
  1, 63, :_reduce_62,
  1, 63, :_reduce_63,
  1, 67, :_reduce_64,
  1, 67, :_reduce_65 ]

racc_reduce_n = 66

racc_shift_n = 138

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
  :STRING => 23,
  :OFFSET => 24,
  :UPDATE => 25,
  :SET => 26,
  "," => 27,
  :DELETE => 28,
  :IDENTIFIER => 29,
  :NUMBER => 30,
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
  "STRING",
  "OFFSET",
  "UPDATE",
  "SET",
  "\",\"",
  "DELETE",
  "IDENTIFIER",
  "NUMBER",
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
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 142)
  def _reduce_40(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 146)
  def _reduce_41(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 151)
  def _reduce_42(val, _values)
                                {:command => :update, :table => val[1], :set_clause_list => val[3], :condition => val[4]}
                          
  end
.,.,

# reduce 43 omitted

module_eval(<<'.,.,', 'sqlparser.y', 157)
  def _reduce_44(val, _values)
                                val[0].merge val[2]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 162)
  def _reduce_45(val, _values)
                              {val[0] => val[2]}
                        
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 167)
  def _reduce_46(val, _values)
                                {:command => :delete, :table => val[2], :condition => val[3]}
                          
  end
.,.,

# reduce 47 omitted

module_eval(<<'.,.,', 'sqlparser.y', 174)
  def _reduce_48(val, _values)
                                [val[0]]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 178)
  def _reduce_49(val, _values)
                                val[0] << val[2]
                          
  end
.,.,

# reduce 50 omitted

# reduce 51 omitted

# reduce 52 omitted

module_eval(<<'.,.,', 'sqlparser.y', 187)
  def _reduce_53(val, _values)
                                [val[0]]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 191)
  def _reduce_54(val, _values)
                                val[0] << val[2]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 194)
  def _reduce_55(val, _values)
     '$in'     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 195)
  def _reduce_56(val, _values)
     '$regexp' 
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 196)
  def _reduce_57(val, _values)
     :'!='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 197)
  def _reduce_58(val, _values)
     :'!='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 198)
  def _reduce_59(val, _values)
     :'>='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 199)
  def _reduce_60(val, _values)
     :'<='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 200)
  def _reduce_61(val, _values)
     :'>'      
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 201)
  def _reduce_62(val, _values)
     :'<'      
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 202)
  def _reduce_63(val, _values)
     :'=='     
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 204)
  def _reduce_64(val, _values)
     :asc  
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 205)
  def _reduce_65(val, _values)
     :desc 
  end
.,.,

def _reduce_none(val, _values)
  val[0]
end

end   # class SQLParser


end # module ActiveCassandra
