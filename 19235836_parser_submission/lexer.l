

%{
#include <stdio.h>
#include "parser.tab.h"
#include <string.h>
%}

%option yylineno
%option noyywrap

%%


[Ss][Tt][Aa][Rr][Tt] {          
   yylval.sval = strdup(yytext); return START; 
}

[Ee][Nn][Dd] {          
   yylval.sval = strdup(yytext); return END; 
}
[Mm][Aa][Ii][Nn] {          
   yylval.sval = strdup(yytext); return MAIN; 
}

[Mm][Oo][Vv][Ee] {          
   yylval.sval = strdup(yytext); return MOVE; 
}

[Aa][Dd][Dd] { 
   yylval.sval = strdup(yytext); return ADD; 
 }

[Tt][Oo] {          
   yylval.sval = strdup(yytext); return TO; 
}

[Ii][Nn][Pp][Uu][Tt] {          
   yylval.sval = strdup(yytext); return INPUT; 
}

[Pp][Rr][Ii][Nn][Tt] {          
   yylval.sval = strdup(yytext); return PRINT; 
}

[Ss]+ {          
   yylval.sval = strdup(yytext); return CAPACITY_DECLARATION; 
}

((_[a-zA-Z][a-zA-Z0-9-]*)|([a-rt-zA-RT-Z][a-zA-Z0-9-]*)|([sS][a-rt-zA-RT-Z0-9-]*[sS]+[a-zA-Z0-9-]*)) {          
   yylval.sval = strdup(yytext); return IDENTIFIER; 
}

[.] {          
   yylval.sval = strdup(yytext); return DOT; 
}

[;] {          
   yylval.sval = strdup(yytext); return SEMI_COLON; 
}

[0-9]+ { yylval.ival = atoi(yytext); return INTEGER; }

[[:space:]] {}
 
\"[^"]*\" {          
   yylval.sval = strdup(yytext); return QUOTED_TEXT; 
}

. { return yytext[0]; }

%%
/**
int main(int argc, char** argv) {
  if (argc != 2) {
    printf("Input file required");
    return 1;
  }

  FILE* input_file = fopen(argv[1], "r");
  if (!input_file) {
    printf("Failed to open file %s\n", argv[1]);
    return 1;
  }

  yyin = input_file;
  yylex();
  fclose(input_file);

  return 0;
}**/
