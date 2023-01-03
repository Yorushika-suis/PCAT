#ifndef _LEXER_H_
#define _LEXER_H_


#define T_EOF -1

//define types with corelating number
#define RESERVED 0
#define DILIMITER 1
#define OPERATOR 2
#define INTEGER 3
#define REAL 4
#define IDENTIFIER 5
#define STRING 6
#define COMMENT 7

//define other arguments
#define string_max_length 255

#define comment_error -2
#define bad_character -3
#define invalid_string -4
#define unterminated_string -5

//integer overflow and overlong string is dealed by main.cpp
//so we don't need to encode these errors here to return in lexer.lex
//but we want all error message to be output in the same way

#define overlong_string -6
#define integer_overflow -7
#define overlong_indentifier -8
#define OFFSET 8 //equal to smallest error code

#endif
