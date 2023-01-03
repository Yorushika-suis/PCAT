GCC = @g++
LEX = @flex
YACC = @bison

main: main.cpp yacc.o
			$(GCC) main.cpp yacc.o -o demo

yacc.o: yacc.c
			$(GCC) -c yacc.c

yacc.c: PACT.y lex.c
			$(YACC) -o yacc.c -d PCAT.y

lex.c: lexer.lex
			$(LEX) -o lex.c lexer.lex

clean:
				@-rm -f *.o *~ lex.c yacc.c yacc.h demo
.PHONY: clean
