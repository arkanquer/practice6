%option noyywrap
%{
#include <stdio.h>

void print_url(const char *url, int length) {
    while (length > 0 &&
          (url[length - 1] == '.' || url[length - 1] == ',' ||
           url[length - 1] == ';' || url[length - 1] == '!' ||
           url[length - 1] == '?')) {
        length--;
    }
    if (length > 0) {
        printf("%.*s\n", length, url);
    }
}
%}

%x LINE_COMMENT BLOCK_COMMENT STRING CHAR_LITERAL
URL https?:\/\/[A-Za-z0-9][A-Za-z0-9._~:/?#@!$&=+%,-]*

%%

<INITIAL>"//" { BEGIN(LINE_COMMENT); }
<INITIAL>"/*" { BEGIN(BLOCK_COMMENT); }

<INITIAL>\" { BEGIN(STRING); }
<INITIAL>\' { BEGIN(CHAR_LITERAL); }

<LINE_COMMENT>\\\n { }
<LINE_COMMENT>{URL} { print_url(yytext, yyleng); }
<LINE_COMMENT>\n { BEGIN(INITIAL); }

<BLOCK_COMMENT>"*/" { BEGIN(INITIAL); }
<BLOCK_COMMENT>{URL} { print_url(yytext, yyleng); }

<STRING>\\(.|\n) { }
<STRING>\" { BEGIN(INITIAL); }
<STRING>\n { BEGIN(INITIAL); }

<CHAR_LITERAL>\\(.|\n) { }
<CHAR_LITERAL>\' { BEGIN(INITIAL); }
<CHAR_LITERAL>\n { BEGIN(INITIAL); }

<LINE_COMMENT>. { }
<BLOCK_COMMENT>\n { }
<BLOCK_COMMENT>. { }

<INITIAL>\n { }
<INITIAL>. { }

<STRING>. { }
<CHAR_LITERAL>. { }
%%

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Використовуйте %s <file.cpp>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");

    if (yyin == NULL) {
        perror("Не виходить відкрити файл");
        return 1;
    }

    yylex();

    fclose(yyin);
    return 0;
}