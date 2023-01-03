%{
#include <iostream>
#include<string>
#include "lex.c"
#define BLANK 2
using namespace std;

// extern "C" int mylineno;
// extern "C" int mycolumnno;

void yyerror(const char* msg) {
//   switch(error_flag)
//             {
//                 deal with errors
//             case bad_character:
//                 cerr << "\nA bad character! Check source file.\n" << endl;
//             case unterminated_string:
//                 cerr << "\nAn unterminated string! Check source file.\n" << endl;
//             case unterminated_comment:
//                 cerr << "\nAn unterminated comment! Check source file.\n" << endl;
//             case integer_overflow: 
//                 cerr << "\nInteger overflow! Check source file.\n" << endl;
//             case id_too_long:
//                 cerr << "\nAn overlong identifier! Check source file.\n" << endl;
//             case invalid_string:
//                 cerr << "\nAn invalid string! Check source file.\n" << endl;
//             case string_too_long: 
//                 cerr << "\nToo long string! Check source file.\n" << endl;
//             default:
//                 cerr << "\nSyntax Error!" << endl;
//             }
}

void printblank(int _level){ 
    for(int i = 0; i < _level * BLANK; i++){
        printf(" ");
    }
    printf("·");
}

int level = 0;
%}

%union {
    char* str;
}

/* reserved words */
%token <str> ARRAY MYBEGIN BY DO ELSE ELSIF END EXIT FOR IF IS LOOP
%token <str> NOT OF DOT PROCEDURE PROGRAM READ RECORD RETURN THEN TO TYPE
%token <str> VAR WHILE WRITE ID

/* errors */
%token <str> Integer_overflow Id_too_long Invalid_string String_too_long 
%token <str> Unterminated_string Bad_character Unterminated_comment Comment

/* delimiters */
%token <str> SEMICOLUMN COLON COMMA ASSIGNMENT
%token <str> LEFTBRACKET RIGHTBRACKET LEFTBRACE RIGHTBRACE
%token <str> LEFTUNKNOWN RIGHTUNKNOWN STRING //NEWLINE

%token <str> INTEGER
%token <str> REAL

/* Nonterminal Symbols */
%start program

%type <str>  component type var_decl another_id id_type
%type <str>  procedure_decl formal_params fp_section another_procedure_decl
%type <str>  another_param another_l_value another_var_decl
%type <str>  else elsif byexpression write_params another_type_decl
%type <str>  another_write_expr write_expr expression
%type <str>  l_value actual_params another_expression
%type <str>  comp_values another_comp array_values
%type <str>  array_value another_array 
%type <str>  number type_decl empty_expression
%type <str>  declarations another_component declaration statements
%type errors

/* operator */
/* '/' is DIVD, because DIV is a reserved keyword. */
%left <str> GREATER LESS EQUAL GE LE NOTEQUAL
%left <str> OR
%left <str> AND
%left <str> ADD SUB
%left <str> MUL DIVD DIV MOD
%left <str> LEFTPARENTHESES RIGHTPARENTHESES
%left <str> unary

%%
program : {printf("·program (%d, %d)\n", mylineno, mycolumnno);} PROGRAM IS body
        SEMICOLUMN {printf("·End of the program\n");}
        ;
        //| Comment program 
        /* | Unterminated_comment NEWLINE {cerr << "\nAn unterminated comment! Check source file.\n" << endl; yyerrok;}
        | Integer_overflow NEWLINE {cerr << "\nInteger overflow! Check source file.\n" << endl; yyerrok;}
        | Id_too_long NEWLINE{cerr << "\nAn overlong identifier! Check source file.\n" << endl; yyerrok;}
        | Invalid_string {cerr << "\nAn invalid string! Check source file.\n" << endl;}
        | String_too_long NEWLINE{cerr << "\nA overlong string! Check source file.\n" << endl; yyerrok;}
        | Unterminated_string NEWLINE{cerr << "\nAn unterminated string! Check source file.\n" << endl; yyerrok;}
        | Bad_character NEWLINE{cerr << "\nA bad character! Check source file.\n" << endl; yyerrok;} */
        | errors {
            // printf("ERROR\n");
            // cerr << error_flag << endl;
            // switch(error_flag)
            // {
            //     //deal with errors
            // case bad_character:
            //     cerr << "\nA bad character! Check source file.\n" << endl;
            // case unterminated_string:
            //     cerr << "\nAn unterminated string! Check source file.\n" << endl;
            // case unterminated_comment:
            //     cerr << "\nAn unterminated comment! Check source file.\n" << endl;
            // case integer_overflow: 
            //     cerr << "\nInteger overflow! Check source file.\n" << endl;
            // case id_too_long:
            //     cerr << "\nAn overlong identifier! Check source file.\n" << endl;
            // case invalid_string:
            //     cerr << "\nAn invalid string! Check source file.\n" << endl;
            // case string_too_long: 
            //     cerr << "\nToo long string! Check source file.\n" << endl;
            // default:
            //     cerr << "Syntax error" << endl;
            // }
            char c; 
            yyclearin;
            while ((c = yyinput()) != EOF && c != '\n' && c != '\0'); 
            if(c == '\n'){mylineno++; mycolumnno = 1;}
            yyerrok;
        }
errors : {cout << endl;}
    | error errors

body : {level++; 
        printblank(level); printf("body (%d, %d)\n", mylineno + 1, mycolumnno); 
        level++;
        printblank(level);
        printf("Beginning of declarations\n"); 
        } declarations {
            printblank(level);
            cout << "End of declarations" << endl;
            }
        MYBEGIN 
        // statements and declarations are on the same level
        {printblank(level);
        printf("Beginning of statements\n"); 
        }
        statements {
            printblank(level);
            cout << "End of statements" << endl;
            }
        END
        {level--;
        printblank(level); printf("End of body\n");
        level--;}
    ;

statements: { $$ = (char*)calloc(1, 8); *($$) ='\0';}  // empty
    | { printblank(level);
        printf("statement (%d, %d)\n", mylineno, mycolumnno);
        } statement statements //{level--;} // string res($1); res = res + string($2);  strcpy($$, res.c_str());}
    /* | { printblank(level);     // declaration
        printf("Error in declaration (%d, %d)\n", mylineno, mycolumnno); 
    } error statements { char c;
    while ((c = getchar()) != EOF && c != '\n'); yyerrok;} */

declarations: { $$ = (char*)calloc(1, 8); *($$) ='\0';}  // empty
    | { printblank(level);     // declaration
        printf("declaration (%d, %d)\n", mylineno, mycolumnno); 
        } declaration declarations //{string res($1); res = res + string($2);  strcpy($$, res.c_str());}
    /* | { printblank(level);     // declaration
        printf("Error in declaration (%d, %d)\n", mylineno, mycolumnno); 
    } error declarations { char c;
    while ((c = getchar()) != EOF && c != '\n');} */

// declaration are the same level of 
declaration: { level++;
        printblank(level);
        printf("var_decl (%d, %d)\n", mylineno, mycolumnno); 
        } VAR var_decl another_var_decl {level++; printblank(level); cout << $3 << "   " << $4 << "\n"; level -= 2; free($3); free($4);}
    | { level++;
        printblank(level);
        printf("type_decl (%d, %d)\n", mylineno, mycolumnno);
        } TYPE type_decl another_type_decl {level++; printblank(level); cout << $3 << "   " << $4 << "\n"; level -= 2; free($3); free($4);}
    | { level++;
        printblank(level);
        printf("procedure_decl (%d, %d)\n", mylineno, mycolumnno);
        } PROCEDURE procedure_decl another_procedure_decl //{printblank(level); cout << $3 << "   " << $4 << "\n"; level -= 2; free($3); free($4);}
    //| error { printf("\nError in declaration at (%d, %d). Keywords missing or met an unexpected token.\n\n", mylineno, mycolumnno); char c; yyclearin;
    //while ((c = yyinput()) != EOF && c != '\n' && c != '\0'); if(c == '\n'){mylineno++; mycolumnno = 1;} yyerrok; level--;}
    ;

type_decl : ID IS type SEMICOLUMN {string res = "typedef " + string($3) + " " + string($1); $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                    free($3);}
            | error {printf("\nError in type_decl at line %d\n\n", mylineno); printf("Error after '%s'\n\n", yylval.str);
                        char c; yyclearin; while ((c = yyinput()) != EOF && c != '\n' && c != '\0');
                        if(c == '\n'){mylineno++; mycolumnno = 1;} yyerrok;}
    ;
another_type_decl: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | type_decl another_type_decl {string res = string($1) + "   " + string($2); $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                    free($1); free($2);}
component : ID COLON type SEMICOLUMN {string res = string($3) + " : " + string($1); $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                    free($3); free($1);}
    ;
another_component : {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | component another_component {string res = string($1) + string($2); $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                    free($1); free($2);}
    ;

type : ID {$$ = (char*)calloc(strlen($1) + 1, 8); strcpy($$, $1);}
    | ARRAY OF type {string res = string($3) + "[]"; $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str()); free($3);}
    | RECORD component another_component END {string res = "struct/class { " + string($2) + string($3) + "}"; 
                                            $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str()); free($2); free($3);}
    ;

var_decl : ID another_id id_type ASSIGNMENT expression SEMICOLUMN {string res($3); res = res + " " + string($1) + string($2) + " = " + string($5); 
    $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, $1); strcpy($$, res.c_str());
    free($3); free($2); free($5);}
    | error {printf("\nError in var_decl at line %d\n\n", mylineno); printf("Error after '%s'\n\n", yylval.str);
                        char c; yyclearin; while ((c = yyinput()) != EOF && c != '\n' && c != '\0');
                        if(c == '\n'){mylineno++; mycolumnno = 1;} yyerrok;}
    ;
another_var_decl: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | var_decl another_var_decl {string res = string($1) + "   " + string($2); $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                    free($1); free($2);}

another_id : {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | COMMA ID another_id {string res = "," + string($2) + string($3); 
    $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
    free($3);}
id_type: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | COLON type {$$ = (char*)calloc(strlen($2) + 1, 8); strcpy($$, $2); free($2);}
    ;

procedure_decl : ID {level++; printblank(level); cout << "Procedure " << $1 << " is defined" << endl; level++;
                    } formal_params id_type {
                        printblank(level); cout << "Params: " << $3 << endl; // add id_type here
                    } IS body SEMICOLUMN {free($3); free($4); free($6); level-=3; }
                | error {printf("\nError in procedure_decl at line %d\n\n", mylineno); printf("Error after '%s'\n\n", yylval.str);
                        char c; yyclearin; while ((c = yyinput()) != EOF && c != '\n' && c != '\0');
                        if(c == '\n'){mylineno++; mycolumnno = 1;} yyerrok;}
    ;
another_procedure_decl: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | procedure_decl {level++;} another_procedure_decl //{string res = string($1) + "   " + string($3); $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());}
                                            //free($1); free($2);}

formal_params : LEFTPARENTHESES fp_section another_param RIGHTPARENTHESES {string res = string($2) + "   " + string($3) + "   "; $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                    free($3); free($2);}
    | LEFTPARENTHESES RIGHTPARENTHESES {string res = "Empty params"; $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());}
    ;
fp_section : ID another_id COLON type {string res = string($4) + "  " + string($1) + " " + string($2) + " "; 
                                        $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                    free($1); free($2); free($4);}
    ;
another_param : {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | SEMICOLUMN fp_section another_param {string res = string($2) + "   " + string($3) + "   "; $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                    free($3); free($2);}
    ;

statement : l_value ASSIGNMENT expression SEMICOLUMN { level++; printblank(level);
        cout << "Assign " << $1 << " with value " << $3 << endl; level--;
        free($1); free($3);
        }
    | ID actual_params SEMICOLUMN { level++; printblank(level);
        cout << "Function " << $1 << " with params " << $2 << " is called" << endl; level--;
        free($2);
        }
    | READ LEFTPARENTHESES l_value another_l_value RIGHTPARENTHESES SEMICOLUMN {level++; printblank(level); 
        cout << "Read Params: " << $3 << $4 << endl; level--;
        free($3); free($4);
        }
    | WRITE write_params SEMICOLUMN {level++; printblank(level); 
        cout << "Write Params: " << $2 << endl; level--;
        free($2);
        }
    | IF {level++; printblank(level); 
        cout << "if-clause " << endl; level--;} expression THEN statements elsif else END SEMICOLUMN
    | WHILE expression DO statements END SEMICOLUMN{level++; printblank(level);
        cout << "while-clause " << endl; level--;
        //free($2); free($4);
        }
    | LOOP statements END SEMICOLUMN{level++; printblank(level);
        cout << "loop-cluase " << endl; level--;
        //free($2);
        }
    | FOR ID ASSIGNMENT expression TO expression byexpression DO statements END SEMICOLUMN{level++; printblank(level);
        cout << "for-loop " << endl; level--;
        //free($4); free($6); free($9); // by expression is deleted down there
        }
    | EXIT SEMICOLUMN{level++; printblank(level);
        cout << "exit" << endl; level--;
    }
    | RETURN empty_expression SEMICOLUMN{level++; printblank(level);
        cout << "return " << $2 << endl; level--;
        free($2);
    }
    //| WRITE write_params {printf("\nERROR! Missing ';' at line %d\n\n", mylineno); free($2);}
    | l_value ASSIGNMENT expression {printf("\nERROR! Missing ';' at line %d\n\n", mylineno);
        free($1); free($3);
        }
    | ID actual_params {printf("\nERROR! Missing ';' at line %d\n\n", mylineno);
        free($2);
        }
    | READ LEFTPARENTHESES l_value another_l_value RIGHTPARENTHESES {printf("\nERROR! Missing ';' at line %d\n\n", mylineno);
        free($3); free($4);
        }
    /* | IF {level++; printblank(level); 
        cout << "if-clause " << endl; level--;} expression THEN statements elsif else END {printf("\nERROR! Missing ';' at (%d, %d)\n\n", mylineno, mycolumnno); } */
    | WHILE expression DO statements END {printf("\nERROR! Missing ';' at line %d\n\n", mylineno);}
    | LOOP statements END {printf("\nERROR! Missing ';' at line %d\n\n", mylineno);
        //free($2);
        }
    | FOR ID ASSIGNMENT expression TO expression byexpression DO statements END {printf("\nERROR! Missing ';' at line %d\n\n", mylineno);
        //free($4); free($6); free($9); // by expression is deleted down there
        }
    | EXIT {level++; printblank(level);
        printf("\nERROR! Missing ';' at line %d\n\n", mylineno);
    }
    /* | RETURN empty_expression {level++; printblank(level);
        printf("\nERROR! Missing ';' at (%d, %d)\n\n", mylineno, mycolumnno);
        free($2);
    } */
    // deal with error in statment
    | error { printf("\nError in statement at (%d, %d). Keywords missing or met an unexpected token after '%s'.\n\n", mylineno, mycolumnno, yylval.str); //char c; yyclearin;
    yyerrok;}
    ;

another_l_value : {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | COMMA l_value another_l_value {string res = ","; res = res + string($2) + string($3); 
                                    $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                    free($2); free($3);}
    ;
elsif: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | ELSIF expression THEN statement  //{free($2); free($4);}// no output
    ;
else: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | ELSE statement //{free($2);}
    ;
byexpression: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | BY expression {free($2);}
    ;

write_params : LEFTPARENTHESES write_expr another_write_expr RIGHTPARENTHESES {string res = ""; res = string($2) + "   " + string($3) + "   "; 
                                                                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                                                                free($2); free($3);}
    | LEFTPARENTHESES RIGHTPARENTHESES {string res = "Empty params"; $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());}
    ;
another_write_expr: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | COMMA write_expr another_write_expr {string res = ""; res = string($2) + "   " + string($3) + "   "; 
                                            $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                            free($2); free($3);}
    ;

write_expr : STRING {$$ = (char*)calloc(strlen($1) + 1, 8); strcpy($$, $1);}
    | expression {$$ = (char*)calloc(strlen($1) + 1, 8); strcpy($$, $1); free($1);}
    ;

expression : number {$$ = (char*)calloc(strlen($1) + 1, 8); strcpy($$, $1); free($1);}
    | l_value {$$ = (char*)calloc(strlen($1) + 1, 8); strcpy($$, $1); free($1);}
    | LEFTPARENTHESES expression RIGHTPARENTHESES {string res = "("; res = res + string($2) + ")"; 
                                                    $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str()); 
                                                    free($2);}
    | ADD expression %prec unary {$$ = (char*)calloc(strlen($2) + 1, 8); strcpy($$, $2); free($2);}
    | SUB expression %prec unary {string res = "-"; res = res + string($2); 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($2);}
    | NOT expression %prec unary {string res = "~"; res = res + string($2); 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($2);}
    | ID actual_params {string res($1); res = res + string($2); 
                        $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                        free($2);} // use function
    | ID comp_values {string res($1); res = res + string($2); 
                        $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                        free($2);}
    | ID array_values {string res($1); res = res + string($2); 
                        $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                        free($2);}
    | expression MUL expression {string exp1($1); string exp2($3); string res = exp1 + "*" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str()); 
                                free($1); free($3);}
    | expression ADD expression {string exp1($1); string exp2($3); string res = exp1 + "+" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str()); 
                                free($1); free($3);}
    | expression SUB expression {string exp1($1); string exp2($3); string res = exp1 + "-" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str()); 
                                free($1); free($3);}
    | expression DIVD expression {string exp1($1); string exp2($3); string res = exp1 + "/" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression DIV expression {string exp1($1); string exp2($3); string res = exp1 + "/" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression MOD expression {string exp1($1); string exp2($3); string res = exp1 + "%" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression OR expression {string exp1($1); string exp2($3); string res = exp1 + "|" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression AND expression {string exp1($1); string exp2($3); string res = exp1 + "&" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression GREATER expression {string exp1($1); string exp2($3); string res = exp1 + ">" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression LESS expression {string exp1($1); string exp2($3); string res = exp1 + "<" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression EQUAL expression {string exp1($1); string exp2($3); string res = exp1 + "==" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression GE expression {string exp1($1); string exp2($3); string res = exp1 + ">=" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression LE expression {string exp1($1); string exp2($3); string res = exp1 + "<=" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    | expression NOTEQUAL expression {string exp1($1); string exp2($3); string res = exp1 + "!=" + exp2; 
                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                free($1); free($3);}
    /* | error {printf("\nError in expression at (%d, %d). Keywords missing or met an unexpected token.\n\n", mylineno, mycolumnno); char c; yyclearin;
    while ((c = yyinput()) != EOF && c != '\n' && c != '\0'); if(c == '\n'){mylineno++; mycolumnno = 1; yyerrok;} if(c != EOF && c != '\0') yyerrok;} */
    ;

empty_expression : {$$ = (char*)calloc(1, 8); *($$) ='\0'; }
    | expression {string res($1);
                    $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str()); 
                    free($1);}
    ;

l_value : ID {$$ = (char*)calloc(strlen($1) + 1, 8); strcpy($$, $1);}
    | l_value LEFTBRACKET expression RIGHTBRACKET {string res($1); res = res + "[" + string($3) + "]"; 
                                                    $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                                    free($1); free($3);}
    | l_value DOT ID {string res = string($1) + "." + string($3); 
                        $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                        free($1);}
    ;

actual_params : LEFTPARENTHESES expression another_expression RIGHTPARENTHESES {string res = "("; res = res + string($2) + string($3) + ")"; 
                                                                                $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                                                                free($2); free($3);}
    | LEFTPARENTHESES RIGHTPARENTHESES {string res = "Empty"; 
                                        $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());} // no delete
another_expression: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | COMMA expression another_expression {string res = ", "; res = res + string($2) + string($3); 
                                            $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str()); 
                                            free($2); free($3);}
    ;

comp_values : LEFTBRACE ID ASSIGNMENT expression another_comp RIGHTBRACE {string res = "{"; res = res + string($2) + " = " + string($4) + string($5) + "}"; 
                                                                            $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                                                            free($4); free($5);}
another_comp: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | SEMICOLUMN ID ASSIGNMENT expression another_comp {string res = "; "; res = res + string($2) + " = " + string($4) + string($5); 
                                                        $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                                        free($4); free($5);}
    ;


array_values : LEFTUNKNOWN array_value another_array RIGHTUNKNOWN {string res = "{"; res = res + string($2) + string($3) + "}"; 
                                                                    $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                                                    free($2); free($3);}
    ;
another_array: {$$ = (char*)calloc(1, 8); *($$) ='\0';}
    | COMMA array_value another_array {string res = ", "; res = res + string($2) + string($3); 
                                        $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                        free($2); free($3);}
    ;

array_value : expression OF expression {string res = " OF "; res = string($1) + res + string($3); 
                                        $$ = (char*)calloc(res.size() + 1, 8); strcpy($$, res.c_str());
                                        free($1); free($3);}
    | expression {$$ = (char*)calloc(strlen($1) + 1, 8); strcpy($$, $1); free($1);}
    ;

number : INTEGER {$$ = (char*)calloc(strlen($1) + 1, 8); strcpy($$, $1);} // don't free
    | REAL {$$ = (char*)calloc(strlen($1) + 1, 8); strcpy($$, $1);}
    ;


%%
