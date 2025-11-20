(declaration
    declarator: (function_declarator)) @function.around

(function_definition
    body: (_
        "{"
        (_)* @function.inside
        "}" )
) @function.around

(comment) @comment.around

(struct_specifier
    body: (_
        "{"
        (_)* @class.inside
        "}")
) @class.around
