[
  (field_expression)
  (assignment_expression)
  (if_statement)
  (for_statement)
  (while_statement)
  (else_clause)
  (select_statement)
] @indent

(_ "{" "}" @end) @indent
(_ "(" ")" @end) @indent

(if_statement) @start.if
(for_statement) @start.for
(while_statement) @start.while
(switch_statement) @start.switch
(else_clause) @start.else
(select_statement) @start.select