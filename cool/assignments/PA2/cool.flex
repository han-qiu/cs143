/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int commentDepth = 0;
char convert(char c)
{
  switch(c)
  {
    case('f'):
      return '\f';
    case('n'):
      return '\n';
    case('t'):
      return '\t';
    case('b'):
      return '\b';
    default:
      return c;
  }
}
%}
%x COMMENT COMMENT_DASH STRING STRERROR
/*
 * Define names for regular expressions here.
 */

NULL            \0

CLASS           ?i:class
ELSE            ?i:else
FI              ?i:fi
IF              ?i:if
IN              ?i:in
INHERITS        ?i:inherits
ISVOID          ?i:isvoid
LET             ?i:let
LOOP            ?i:loop
POOL            ?i:pool
THEN            ?i:then
WHILE           ?i:while
CASE            ?i:case
ESAC            ?i:esac
NEW             ?i:new
OF              ?i:of
NOT             ?i:not
TRUE            i(?i:rue)
FALSE           f(?i:alse)


BOOL            {TRUE}|{FALSE}
CHAR            [A-Za-z]
DIGIT           [0-9]
INTEGER         {DIGIT}+
NEWLINE         [\n]
UPPERCASE       [A-Z]
LOWERCASE       [a-z]
WHITESPACE      [ \t\f\n\r\v]
OBJECTID        {LOWERCASE}({CHAR}|{DIGIT}|_)*
TYPEID          {UPPERCASE}({CHAR}|{DIGIT}|_)*
SELF            "self"
SELF_TYPE       "SELF_TYPE"

SINGLE_CHAR_OP  [+\-*/(){}~<=.,;:@]    
DARROW          =>
LE              <=
ASSIGN          <-
%%
<INITIAL>--             BEGIN(COMMENT_DASH);
<COMMENT_DASH>[\n]      {
                          ++curr_lineno;
                          BEGIN(INITIAL);
                        }
<COMMENT_DASH><<EOF>>   {
                          yyterminate();
                        }
<COMMENT_DASH>.         {}
 /*
  *  Nested comments
  */
<INITIAL>"(*"           {
                          BEGIN(COMMENT);
                          commentDepth = 1;
                        }
<COMMENT>"(*"           {
                          ++commentDepth;
                        }
<COMMENT>"*)"           {
                          --commentDepth;
                          if(commentDepth==0)
                            BEGIN(INITIAL);
                        }
<COMMENT>{NEWLINE}      ++curr_lineno;
<COMMENT>[^*(]|\*[^)]|\([^*]    {}
<COMMENT><<EOF>>        {
                          cool_yylval.error_msg = "EOF in comment";
                          BEGIN(INITIAL);
                          return ERROR;
                        }
<INITIAL>"*)"           {
                          cool_yylval.error_msg = "Unmatched *)";
                          return ERROR;
                        }





 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
<INITIAL>\"             {
                          string_buf_ptr = string_buf;
                          BEGIN(STRING);
                        }
<STRING>{NULL}          {
                          cool_yylval.error_msg = "String contains null character."; 
                          BEGIN(STRERROR);
                          return(ERROR);
                        }
<STRING>\"              {
                          BEGIN(INITIAL);
                          if(string_buf_ptr - string_buf >= MAX_STR_CONST)
                          {
                            BEGIN(STRERROR);
                            cool_yylval.error_msg = "String constant too long";
                            return ERROR;
                          }
                          *string_buf_ptr = 0;
                          cool_yylval.symbol = stringtable.add_string(string_buf);
                          return STR_CONST;
                        }
<STRING>\\(.|\n)        {
                          if(yytext[1]=='\n')
                            ++curr_lineno;
                          if(string_buf_ptr - string_buf >= MAX_STR_CONST)
                          {
                            BEGIN(STRERROR);
                            cool_yylval.error_msg = "String constant too long";
                            return ERROR;
                          }
                          *(string_buf_ptr++) = convert(yytext[1]);
                        }
<STRING>.               {
                          if(string_buf_ptr - string_buf >= MAX_STR_CONST)
                          {
                            BEGIN(STRERROR);
                            cool_yylval.error_msg = "String constant too long";
                            return ERROR;
                          }
                          *(string_buf_ptr++) = yytext[0];
                        }
<STRING>\n              {
                          ++curr_lineno;
                          BEGIN(INITIAL);
                          cool_yylval.error_msg = "Unterminated string constant";
                          return ERROR;
                        }
<STRING><<EOF>>         {
                          BEGIN(INITIAL);
                          cool_yylval.error_msg = "EOF in string constant";
                          return ERROR;
                        }
<STRERROR>{
  \n                      ++curr_lineno;  BEGIN(INITIAL);
  \"                      BEGIN(INITIAL);
  .                       {}
}


 /*
  *  The multiple-character operators, then single-character operators
  */
<INITIAL>{SINGLE_CHAR_OP}     return(yytext[0]);

<INITIAL>{ASSIGN}       return(ASSIGN);
<INITIAL>{DARROW}       return(DARROW);
<INITIAL>{LE}           return(LE);

<INITIAL>{CLASS}        return(CLASS);
<INITIAL>{ELSE}         return(ELSE);
<INITIAL>{FI}           return(FI);
<INITIAL>{IF}           return(IF);
<INITIAL>{IN}           return(IN);
<INITIAL>{INHERITS}     return(INHERITS);
<INITIAL>{LET}          return(LET);
<INITIAL>{LOOP}         return(LOOP);
<INITIAL>{POOL}         return(POOL);
<INITIAL>{THEN}         return(THEN);
<INITIAL>{WHILE}        return(WHILE);
<INITIAL>{CASE}         return(CASE);
<INITIAL>{ESAC}         return(ESAC);
<INITIAL>{OF}           return(OF);
<INITIAL>{NEW}          return(NEW);
<INITIAL>{NOT}          return(NOT);
<INITIAL>{ISVOID}       return(ISVOID);

<INITIAL>{TRUE}         {
                          cool_yylval.boolean = true;
                          return(BOOL_CONST);
                        }
<INITIAL>{FALSE}        {
                          cool_yylval.boolean = false;
                          return(BOOL_CONST);
                        }

<INITIAL>{TYPEID}       {
                          cool_yylval.symbol = idtable.add_string(yytext);
                          return(TYPEID);
                        }
<INITIAL>{OBJECTID}     {
                          cool_yylval.symbol = idtable.add_string(yytext);
                          return(OBJECTID);
                        }
<INITIAL>{INTEGER}      {
                          cool_yylval.symbol = inttable.add_string(yytext);
                          return(INT_CONST);
                        }
<INITIAL>{NEWLINE}      ++curr_lineno;
<INITIAL>{WHITESPACE}         {}
<INITIAL>.              {
                          cool_yylval.error_msg = yytext;
                          return(ERROR);
                        }
%%