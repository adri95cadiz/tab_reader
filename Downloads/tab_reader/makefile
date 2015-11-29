LEX = lex
CC = g++

tab_reader: lex.yy.o
	${CC} -o tab_reader lex.yy.o -ll
lex.yy.o:  lex.yy.c 
	${CC} -c -x c++ lex.yy.c
lex.yy.c: tab_reader.l
	${LEX} tab_reader.l
clean:
	rm *.o
	rm *.c

