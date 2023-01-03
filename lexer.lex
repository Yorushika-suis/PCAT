%{
#include<string>
#include<iostream>
#include "yacc.h"
#define T_EOF -1
//define other arguments
#define string_max_length 255

#define unterminated_comment -2
#define bad_character -3
#define invalid_string -4
#define unterminated_string -5

//integer overflow and overlong string is dealed by main.cpp
//so we don't need to encode these errors here to return in lexer.lex
//but we want all error message to be output in the same way

#define string_too_long -6
#define integer_overflow -7
#define id_too_long -8

int mylineno = 1;
int mycolumnno = 1;
int error_flag = -1;
using namespace std;


bool intergerOverflow(char* p){
    string s(p);
    int i, size = s.size(), ret = 0;
    if (size == 0)
        return false;
    else if (size > 10)
        return true;
    else if (size == 10) {
        //check
        string intmax = "2147483647";
        bool overflow = false;
        for (i = 0; i < size; i++) {
            if (intmax[i] > s[i]) {
                return false;
            }
            else if (intmax[i] < s[i]) {
                return true;
            }
        }
    }
    return false;
}

bool stringTooLong(char* p){
    //subtract ""
    if(strlen(p) - 2 > string_max_length)
        return true;
    else return false;
}

int invalidString(char* p){
    //return number of tabs
    int i = 0;
    int ret = 0;
    while(p[i] != '\0'){
        if(p[i] == '\t')
            ret++;
        i++;
    }
    return ret;
}

bool identifierTooLong(char* p){
    if(strlen(p) > string_max_length)
        return true;
    else return false;
}



%}
%option     nounput
%option     noyywrap

DIGIT       [0-9]
INTEGER     {DIGIT}+
REAL        {DIGIT}+"."{DIGIT}*
LETTER      [A-Za-z]
STRING      \"[^"\n]*\"
ID          {LETTER}[a-zA-Z0-9]*
BAD_CHARACTER [^[:space:][:graph:]]+
UNTERMINATED_STRING \"[^"\t\n]*[\t\n\r]


%%
<<EOF>>     return T_EOF;

"AND"           {mycolumnno += yyleng; return AND;}
"ARRAY"         {mycolumnno += yyleng; return ARRAY;}
"BEGIN"         {mycolumnno += yyleng; return MYBEGIN;}
"BY"            {mycolumnno += yyleng; return BY;}
"DIV"           {mycolumnno += yyleng; return DIV;}
"DO"            {mycolumnno += yyleng; return DO;}
"ELSE"          {mycolumnno += yyleng; return ELSE;}
"ELSIF"         {mycolumnno += yyleng; return ELSIF;}
"END"           {mycolumnno += yyleng; return END;}
"EXIT"          {mycolumnno += yyleng; return EXIT;}
"FOR"           {mycolumnno += yyleng; return FOR;}
"IF"            {mycolumnno += yyleng; return IF;}
"IS"            {mycolumnno += yyleng; return IS;}
"LOOP"          {mycolumnno += yyleng; return LOOP;}
"MOD"           {mycolumnno += yyleng; return MOD;}
"NOT"           {mycolumnno += yyleng; return NOT;}
"OF"            {mycolumnno += yyleng; return OF;}
"OR"            {mycolumnno += yyleng; return OR;}
"PROCEDURE"             {mycolumnno += yyleng; return PROCEDURE;}
"PROGRAM"               {mycolumnno += yyleng; return PROGRAM;}
"READ"          {mycolumnno += yyleng; return READ;}
"RECORD"                {mycolumnno += yyleng; return RECORD;}
"RETURN"                {mycolumnno += yyleng; return RETURN;}
"THEN"          {mycolumnno += yyleng; return THEN;}
"TO"            {mycolumnno += yyleng; return TO;}
"TYPE"          {mycolumnno += yyleng; return TYPE;}
"VAR"           {mycolumnno += yyleng; return VAR;}
"WHILE"         {mycolumnno += yyleng; return WHILE;}
"WRITE"         {mycolumnno += yyleng; return WRITE;}

":"             {mycolumnno += yyleng; return COLON;}
";"             {mycolumnno += yyleng; return SEMICOLUMN;}
","             {mycolumnno += yyleng; return COMMA;}
"."             {mycolumnno += yyleng; return DOT;}
"("             {mycolumnno += yyleng; return LEFTPARENTHESES;}
")"             {mycolumnno += yyleng; return RIGHTPARENTHESES;}
"["             {mycolumnno += yyleng; return LEFTBRACKET;}
"]"             {mycolumnno += yyleng; return RIGHTBRACKET;}
"{"             {mycolumnno += yyleng; return LEFTBRACE;}
"}"             {mycolumnno += yyleng; return RIGHTBRACE;}
"[<"            {mycolumnno += yyleng; return LEFTUNKNOWN;}
">]"            {mycolumnno += yyleng; return RIGHTUNKNOWN;}

":="            {mycolumnno += yyleng; return ASSIGNMENT;}
"+"             {mycolumnno += yyleng; return ADD;}
"-"             {mycolumnno += yyleng; return SUB;}
"*"             {mycolumnno += yyleng; return MUL;}
"/"             {mycolumnno += yyleng; return DIVD;}
"<"             {mycolumnno += yyleng; return LESS;}
"<="            {mycolumnno += yyleng; return LE;}
">"             {mycolumnno += yyleng; return GREATER;}
">="            {mycolumnno += yyleng; return GE;}
"="             {mycolumnno += yyleng; return EQUAL;}
"<>"            {mycolumnno += yyleng; return NOTEQUAL;}

"(*"        {
            char c;
            bool error = false;
            printf("---You can ignore this row. Comment: (*");
            while(true)
                {
                while ( (c = yyinput()) != '*' &&
                        c != EOF && c != '\0'){
                        if ( c == '\n' ){
		            mycolumnno = 1;
		            mylineno++;
                        }
                        else mycolumnno++;
                        printf("%c", c);
                    /*printf("I'm EATING TEXT:%c\n", c);*/
                    }    /* eat up text of comment */

                if ( c == '*' )
                    {
                        mycolumnno++;
                        printf("%c", c);
                    while ( (c = yyinput()) == '*' )
                        mycolumnno++;
                        printf("%c", c);
                        /*printf("I'm EATING *\n");*/
                    if ( c == ')' ){
                        mycolumnno++;
                        printf("---\n");
                        /*printf("I'm END\n");*/
                        break;    /* found the end */
                        }
                    }

                if ( c == EOF || c == '\0')
                    {
                        /*printf("I'm EOF\n");*/
                        error = true;
                        break;
                    }
                if ( c == '\n' ){
                    mycolumnno = 1;
                    mylineno++;
                    printf("%c", c);
                }
                }
            if(error){
                cout << "\nAn unterminated comment! Check source file.\n" << endl;
                error_flag = unterminated_comment;
                return Unterminated_comment;
            }
            else{
            mycolumnno += yyleng;
            // end here
            }
            }

{INTEGER}       {mycolumnno += yyleng; 
                if(intergerOverflow(yytext)){
                    cout << "\nInteger overflow! Check source file.\n" << endl;
                    error_flag = integer_overflow;
                    return Integer_overflow;
                }
                yylval.str = strdup(yytext); return INTEGER;}    /* NUMBERS */

{REAL}          {mycolumnno += yyleng; yylval.str = strdup(yytext); return REAL;}

{ID}            {mycolumnno += yyleng;
                if(identifierTooLong(yytext)){
                    cout << "\nAn overlong identifier! Check source file.\n" << endl;
                    error_flag = id_too_long;
                    return Id_too_long;
                }
                yylval.str = strdup(yytext); return ID;}

{UNTERMINATED_STRING} {mycolumnno += yyleng; error_flag = unterminated_string; cout << "\nAn unterminated string! Check source file.\n" << endl; 
                return Unterminated_string;}

{STRING}        {mycolumnno += yyleng; 
                if(invalidString(yytext)){
                    cout << "\nAn invalid string! Check source file.\n" << endl;
                    error_flag = invalid_string;
                    return Invalid_string;
                }
                if(stringTooLong(yytext)){
                    error_flag = string_too_long;
                    cout << "\nToo long string! Check source file.\n" << endl;
                    return String_too_long;
                }
                yylval.str = strdup(yytext); return STRING;}



{BAD_CHARACTER} {mycolumnno += yyleng; error_flag = bad_character; cout << "\nA bad character! Check source file.\n" << endl; return Bad_character;}

" "         mycolumnno++;    /* deal with blanks */
"\t"        mycolumnno += 4;
"\n"        {mylineno++; mycolumnno = 1;}// return NEWLINE;}
%%