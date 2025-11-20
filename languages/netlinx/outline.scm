(preproc_define
    (preproc_define_keyword) @context
    name: (_) @name) @item

(struct_specifier
    (struct_keyword) @context
    name: (_) @name) @item

(define_function
    (define_function_keyword) @context
    (function_definition
        return_type: (_)? @context
        name: (_) @name
        parameters: (parameter_list
            "(" @context
            ")" @context))
) @item

(comment) @annotation
