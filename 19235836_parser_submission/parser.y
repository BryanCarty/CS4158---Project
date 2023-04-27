

%token START END MAIN MOVE ADD TO INPUT PRINT DOT SEMI_COLON QUOTED_TEXT 
%token <sval> CAPACITY_DECLARATION
%token <sval> IDENTIFIER
%token <ival> INTEGER

%union {
    int ival;
    char *sval;
}


%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

extern FILE* yyin;
extern int yylineno;

int yylex();
void yyerror(const char *msg);

#define MAX_SYMBOLS 100000

struct symbol {
    char name[50];
    int value;
    int size;
};

struct symbol symbol_table[MAX_SYMBOLS];
int num_symbols = 0;

void add_symbol(char* name, char* size);
int find_symbol(char* name);

%}

%locations

%%
program : declation_and_main_sections
        ;

declation_and_main_sections : START DOT declaration_section MAIN DOT main_section END DOT
                            ;
                    
declaration_section : declaration_statement
                    | declaration_section declaration_statement 
                    ;

declaration_statement : CAPACITY_DECLARATION IDENTIFIER DOT { add_symbol($2, $1); }
                      ;

main_section : main_statement
             | main_section main_statement
             ;

main_statement : move_assignment_statement
               | add_assignment_statement
               | input_assignment_statement
               | output_statement
               ;

move_assignment_statement : MOVE IDENTIFIER TO IDENTIFIER DOT { 
                                                                    int index_one = find_symbol($2);
                                                                    if (index_one == -1) {
                                                                        char str[100];
                                                                        sprintf(str, "Undeclared variable: %s", $2);
                                                                        yyerror(str);
                                                                    }

                                                                    int index_two = find_symbol($4);
                                                                    if (index_two == -1) {
                                                                        char str[100];
                                                                        sprintf(str, "Undeclared variable: %s", $4);
                                                                        yyerror(str);
                                                                    }

                                                                    if (symbol_table[index_one].size > symbol_table[index_two].size){
                                                                        char str[100];
                                                                        sprintf(str, "%s is larger than the capacity of %s", $2, $4);
                                                                        yyerror(str);
                                                                    }
                                                                    symbol_table[index_two].value = (int)$2;                                                                     
                                                                }
                          | MOVE INTEGER TO IDENTIFIER DOT { 
                                                                int index = find_symbol($4);
                                                                if (index == -1) {
                                                                    char str[100];
                                                                    sprintf(str, "Undeclared variable: %s", $4);
                                                                    yyerror(str);
                                                                }
                                                                int val = $2;
                                                                int num_digits = 0;
                                                                while (val != 0) {
                                                                    val /= 10;
                                                                    num_digits++;
                                                                }

                                                                if (num_digits > symbol_table[index].size){
                                                                    char str[100];
                                                                    sprintf(str, "%d is larger than the capacity of %s", (int)$2, $4);
                                                                    yyerror(str);
                                                                }
                                                                symbol_table[index].value = $2; 
                                                            }
                          ;

add_assignment_statement : ADD INTEGER TO IDENTIFIER DOT { 
                                                                    int index = find_symbol($4);
                                                                    if (index == -1) {
                                                                        char str[100];
                                                                        sprintf(str, "Undeclared variable: %s", $4);
                                                                        yyerror(str);
                                                                    }
                                                                    int val = symbol_table[index].value;
                                                                    int new_val = $2 + val;
                                                                    int num_digits = 0;
                                                                    while (new_val != 0){
                                                                        new_val/=10;
                                                                        num_digits++;
                                                                    }
                                                                    if (num_digits > symbol_table[index].size){
                                                                        char str[100];
                                                                        sprintf(str, "The summation is larger than the capacity of: %s", $4);
                                                                        yyerror(str);
                                                                    }
                                                                    symbol_table[index].value = $2 + val;
                                                                }
                         | ADD IDENTIFIER TO IDENTIFIER DOT { 
                                                                    int index_one = find_symbol($2);
                                                                    if (index_one == -1) {
                                                                        char str[100];
                                                                        sprintf(str, "Undeclared variable: %s", $2);
                                                                        yyerror(str);
                                                                    }

                                                                    int index_two = find_symbol($4);
                                                                    if (index_two == -1) {
                                                                        char str[100];
                                                                        sprintf(str, "Undeclared variable: %s", $4);
                                                                        yyerror(str);
                                                                    }

                                                                    int val2 = symbol_table[index_two].value;
                                                                    int val1 = symbol_table[index_one].value;
                                                                    int newVal = val1 + val2;
                                                                    int num_digits = 0;
                                                                    while(newVal != 0){
                                                                        newVal/=10;
                                                                        num_digits++;
                                                                    }
                                                                    if (num_digits > symbol_table[index_two].size){
                                                                        char str[100];
                                                                        sprintf(str, "the summation is larger than the capacity of: %s", $4);
                                                                        yyerror(str);
                                                                    }
                                                                    symbol_table[index_two].value = val1 + val2;
                                                                }
                         ;
input_assignment_statement : INPUT IDENTIFIER DOT {
                                                        int index_one = find_symbol($2);
                                                        if (index_one == -1) {
                                                            char str[100];
                                                            sprintf(str, "Undeclared variable: %s", $2);
                                                            yyerror(str);
                                                        }
                                                  }
                           | INPUT identifier_list IDENTIFIER DOT {
                                                                        int index_one = find_symbol($3);
                                                                        if (index_one == -1) {
                                                                            char str[100];
                                                                            sprintf(str, "Undeclared variable: %s", $3);
                                                                            yyerror(str);
                                                                        }
                                                                   }
                           ;

identifier_list : IDENTIFIER SEMI_COLON {
                                            int index_one = find_symbol($1);
                                            if (index_one == -1) {
                                                char str[100];
                                                sprintf(str, "Undeclared variable: %s", $1);
                                                yyerror(str);
                                            }
                                        }
                | identifier_list IDENTIFIER SEMI_COLON {
                                                            int index_one = find_symbol($2);
                                                            if (index_one == -1) {
                                                                char str[100];
                                                                sprintf(str, "Undeclared variable: %s", $2);
                                                                yyerror(str);
                                                            }
                                                        }
                ;

output_statement : PRINT print_element DOT
                 | PRINT print_list
                 ;

print_list : print_element SEMI_COLON
           | print_list print_element SEMI_COLON
           | print_list print_element DOT
           ;

print_element : QUOTED_TEXT
              | IDENTIFIER {
                                int index_one = find_symbol($1);
                                if (index_one == -1) {
                                    char str[100];
                                    sprintf(str, "Undeclared variable: %s", $1);
                                    yyerror(str);
                                }
                            }
              ;
%%

void yyerror(const char *msg) {
    printf("Invalid Program!\n");
    fprintf(stderr, "Line %d: %s\n", yylineno, msg);
    exit(1);
}

int find_symbol(char* name) {
    int i;
    for (i = 0; i < num_symbols; i++) {
        if (strcmp(name, symbol_table[i].name) == 0) {
            return i;
        }
    }
    return -1;
}

void add_symbol(char* name, char* size) {
    int index = find_symbol(name);
    if (index == -1) {
        strcpy(symbol_table[num_symbols].name, name);
        symbol_table[num_symbols].value = 0;
        symbol_table[num_symbols].size =strlen(size);
        num_symbols++;
    }
}
/**
int main(void) {
    yyparse();
    if (!was_error){
        printf("The program is well formed!\n");
    }else{
        printf("The program is NOT well formed!\n");
    }

}**/


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
  int parseResult = yyparse();
  if (parseResult == 0){
    printf("Program is well formed!\n");
  }else if (parseResult == 2){
    printf("Program ran out of memory!\n");
  }
  
  fclose(input_file);
  return 0;
}