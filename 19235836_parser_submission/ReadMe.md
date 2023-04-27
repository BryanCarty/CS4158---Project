**Name:** Bryan Carty\
**Student Id**: 19235836\
\
\
**Instructions to Run:**\
./program input.txt
\
\
**Instructions to Compile:**\
flex ./lexer.l\
bison -d ./parser.y\
gcc -c lex.yy.c parser.tab.c\
gcc -o program lex.yy.o parser.tab.o
