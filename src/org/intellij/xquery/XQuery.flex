package org.intellij.xquery;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import org.intellij.xquery.psi.XQueryBasicTypes;
import org.intellij.xquery.psi.XQueryTypes;
import com.intellij.psi.TokenType;
import java.util.Stack;

%%

%{

  public _XQueryLexer() {
    this((java.io.Reader)null);
  }


  private Stack<Integer> stack = new Stack<Integer>();

  private void pushState(int state) {
    stack.push(yystate());
    yybegin(state);
  }

  private void popState() {
    if (stack.empty()) {
        yybegin(YYINITIAL);

    } else {
        int state = stack.pop();
        yybegin(state);
    }
  }
%}


%class _XQueryLexer
%implements FlexLexer
%unicode
%function advance
%type IElementType
%eof{  return;
%eof}


IntegerLiteral={Digits}
DecimalLiteral=("." {Digits}) | ({Digits} "." [0-9]*)               	                    /* ws: explicit */
DoubleLiteral=(("." {Digits}) | ({Digits} ("." [0-9]*)?)) [eE] [+-]? {Digits}             	/* ws: explicit */
StringLiteral=("\"" ({PredefinedEntityRef} | {CharRef} | {EscapeQuot} | [^\"&])* "\"") | ("'" ({PredefinedEntityRef} | {CharRef} | {EscapeApos} | [^'&])* "'") 	/* ws: explicit */
URIQualifiedName={BracedURILiteral} {NCName}                                                /* ws: explicit */
BracedURILiteral="Q" "{" ({PredefinedEntityRef} | {CharRef} | [^&{}]    )* "}"                  /* ws: explicit */
PredefinedEntityRef="&" ("lt" | "gt" | "amp" | "quot" | "apos") ";"                         /* ws: explicit */
EscapeQuot="\"\""
EscapeApos="''"
Digits=[0-9]+
Comment="(:" ({CommentContents} | {Comment})* ":)"                                          /* ws: explicit */ /* gn: comments */
CommentContents=({Char}+ - ({Char}* ("(:" | ":)") {Char}*))
DirCommentContents=(({Char} - '-') | ('-' ({Char} - '-')))*                                 /* ws: explicit */
PITarget={Name} - (("X" | "x") ("M" | "m") ("L" | "l"))                                     /* xgc: xml-version */
CharRef="&#" [0-9]+ ";" | "&#x" [0-9a-fA-F]+ ";"                                            /* xgc: xml-version */
NCName={NameStartCharWithoutFirst} ({NameCharWithoutFirst})*                                                     /* xgc: xml-version */
NameStartChar=":" | {NameStartCharWithoutFirst}
NameStartCharWithoutFirst= [A-Z] | "_" | [a-z] | [\u00C0-\u00D6] | [\u00D8-\u00F6] | [\u00F8-\u02FF] | [\u0370-\u037D] | [\u037F-\u1FFF] | [\u200C-\u200D] | [\u2070-\u218F] | [\u2C00-\u2FEF] | [\u3001-\uD7FF] | [\uF900-\uFDCF] | [\uFDF0-\uFFFD] | [\uD800\uDC00-\uDB7F\uDFFF]
NameChar={NameStartChar} | "-" | "." | [0-9] | \u00B7 | [\u0300-\u036F] | [\u203F-\u2040]
NameCharWithoutFirst={NameStartCharWithoutFirst} | "-" | "." | [0-9] | \u00B7 | [\u0300-\u036F] | [\u203F-\u2040]
Name={NameStartChar} ({NameChar})*
S=(\u20 | \u9 | \uD | \uA)+                                                                 /* xgc: xml-version */
Char=\u9| \uA | \uD | [\u20-\uD7FF] | [\uE000-\uFFFD] | [\u10000-\u10FFFF]                  /* xgc: xml-version */

%state EXPR_COMMENT
%state START_TAG
%state END_TAG
%state ELEMENT_CONTENT
%state QUOT_STRING
%state APOS_STRING
%state URIQUALIFIED
%state QNAME
%state ALLOWING
%state DIR_COMMENT
%%


<YYINITIAL> {
{S}                                       {return TokenType.WHITE_SPACE;}
{DecimalLiteral}                          {return XQueryTypes.DECIMALLITERAL;}
{DoubleLiteral}                           {return XQueryTypes.DOUBLELITERAL;}
{IntegerLiteral}                          {return XQueryTypes.INTEGERLITERAL;}
{StringLiteral}                           {return XQueryTypes.STRINGLITERAL;}
"Q{"                                      {pushState(URIQUALIFIED); yypushback(2);}
"(:"                                      {pushState(EXPR_COMMENT);return XQueryBasicTypes.EXPR_COMMENT_START;}
"<<"                                      {return XQueryTypes.NODECOMP_LT;}
">>"                                      {return XQueryTypes.NODECOMP_GT;}
"<" / {S}? "$"                            {return XQueryTypes.LT_CHAR;}
"<" / {S}? {IntegerLiteral}               {return XQueryTypes.LT_CHAR;}
"<" / {S}? {DecimalLiteral}               {return XQueryTypes.LT_CHAR;}
"<" / {S}? {DoubleLiteral}                {return XQueryTypes.LT_CHAR;}
"<="                                      {return XQueryTypes.LE_CHARS;}
">="                                      {return XQueryTypes.GE_CHARS;}
"<"                                       {pushState(START_TAG); return XQueryTypes.LT_CHAR;}
">"                                       {return XQueryTypes.GT_CHAR;}
"@"                                       {pushState(QNAME);return XQueryTypes.AT_SIGN;}
"//"                                      {pushState(QNAME);return XQueryTypes.SLASH_SLASH;}
"/"                                       {pushState(QNAME);return XQueryTypes.SLASH;}
"+"                                       {return XQueryTypes.OP_PLUS;}
"-"                                       {return XQueryTypes.OP_MINUS;}
":="                                      {return XQueryTypes.OP_ASSIGN;}
"::"                                      {return XQueryTypes.COLON_COLON;}
":"                                       {return XQueryTypes.COLON;}
"?"                                       {return XQueryTypes.QUESTIONMARK;}
"$"                                       {pushState(QNAME);return XQueryTypes.DOLLAR_SIGN;}
".."                                      {return XQueryTypes.DOT_DOT;}
"."                                       {return XQueryTypes.DOT;}
"*"                                       {return XQueryTypes.STAR_SIGN;}
"(#"                                      {return XQueryTypes.PRAGMA_BEGIN;}
"#)"                                      {return XQueryTypes.PRAGMA_END;}
"("                                       {return XQueryTypes.L_PAR;}
")"                                       {return XQueryTypes.R_PAR;}
"["                                       {return XQueryTypes.L_BRACKET;}
"]"                                       {return XQueryTypes.R_BRACKET;}
"{"                                       {pushState(YYINITIAL); return XQueryTypes.L_C_BRACE;}
"}"                                       {popState(); return XQueryTypes.R_C_BRACE;}
","                                       {return XQueryTypes.COMA;}
"=="                                      {return XQueryTypes.EQUAL_EQUAL;}
"!="                                      {return XQueryTypes.NOT_EQUAL;}
"="                                       {return XQueryTypes.EQUAL;}
";"                                       {return XQueryTypes.SEMICOLON;}
"%"                                       {return XQueryTypes.PERCENT;}
"#"                                       {return XQueryTypes.HASH;}
"||"                                      {return XQueryTypes.PIPE_PIPE;}
"|"                                       {return XQueryTypes.PIPE;}
"eq"                                      {return XQueryTypes.EQ;}
"ne"                                      {return XQueryTypes.NE;}
"lt"                                      {return XQueryTypes.LT;}
"le"                                      {return XQueryTypes.LE;}
"gt"                                      {return XQueryTypes.GT;}
"ge"                                      {return XQueryTypes.GE;}
"declare"                                 {return XQueryTypes.K_DECLARE;}
"default"                                 {return XQueryTypes.K_DEFAULT;}
"base-uri"                                {return XQueryTypes.K_BASE_URI;}
"option"                                  {return XQueryTypes.K_OPTION;}
"variable"                                {pushState(QNAME); return XQueryTypes.K_VARIABLE;}
"function" / {S} "namespace" {S} {StringLiteral} {return XQueryTypes.K_FUNCTION;}
"function"                                {pushState(QNAME); return XQueryTypes.K_FUNCTION;}
"construction"                            {return XQueryTypes.K_CONSTRUCTION;}
"boundary-space"                          {return XQueryTypes.K_BOUNDARY_SPACE;}
"preserve"                                {return XQueryTypes.K_PRESERVE;}
"strip"                                   {return XQueryTypes.K_STRIP;}
"collation"                               {return XQueryTypes.K_COLLATION;}
"construction"                            {return XQueryTypes.K_CONSTRUCTION;}
"ordering"                                {return XQueryTypes.K_ORDERING;}
"ordered"                                 {return XQueryTypes.K_ORDERED;}
"unordered"                               {return XQueryTypes.K_UNORDERED;}
"empty" / {S} "greatest"                  {return XQueryTypes.K_EMPTY;}
"empty" / {S} "least"                     {return XQueryTypes.K_EMPTY;}
"allowing"                                {pushState(ALLOWING);return XQueryTypes.K_ALLOWING;}
"greatest"                                {return XQueryTypes.K_GREATEST;}
"least"                                   {return XQueryTypes.K_LEAST;}
"ascending"                               {return XQueryTypes.K_ASCENDING;}
"descending"                              {return XQueryTypes.K_DESCENDING;}
"copy-namespaces"                         {return XQueryTypes.K_COPY_NAMESPACES;}
"no-preserve"                             {return XQueryTypes.K_NO_PRESERVE;}
"inherit"                                 {return XQueryTypes.K_INHERIT;}
"no-inherit"                              {return XQueryTypes.K_NO_INHERIT;}
"decimal-format"                          {return XQueryTypes.K_DECIMAL_FORMAT;}
"decimal-separator"                       {return XQueryTypes.K_DECIMAL_SEPARATOR;}
"grouping-separator"                      {return XQueryTypes.K_GROUPING_SEPARATOR;}
"infinity"                                {return XQueryTypes.K_INFINITY;}
"minus-sign"                              {return XQueryTypes.K_MINUS_SIGN;}
"NaN"                                     {return XQueryTypes.K_NAN;}
"percent"                                 {return XQueryTypes.K_PERCENT;}
"per-mille"                               {return XQueryTypes.K_PER_MILLE;}
"zero-digit"                              {return XQueryTypes.K_ZERO_DIGIT;}
"digit"                                   {return XQueryTypes.K_DIGIT;}
"pattern-separator"                       {return XQueryTypes.K_PATTERN_SEPARATOR;}
"namespace"                               {return XQueryTypes.K_NAMESPACE;}
"context"                                 {return XQueryTypes.K_CONTEXT;}
"item"                                    {return XQueryTypes.K_ITEM;}
"element"                                 {return XQueryTypes.K_ELEMENT;}
"import"                                  {return XQueryTypes.K_IMPORT;}
"schema"                                  {return XQueryTypes.K_SCHEMA;}
"module"                                  {return XQueryTypes.K_MODULE;}
"at"                                      {return XQueryTypes.K_AT;}
"xquery"                                  {return XQueryTypes.K_XQUERY;}
"version"                                 {return XQueryTypes.K_VERSION;}
"encoding"                                {return XQueryTypes.K_ENCODING;}
"return"                                  {return XQueryTypes.K_RETURN;}
"at"                                      {return XQueryTypes.K_AT;}
"for"                                     {return XQueryTypes.K_FOR;}
"let"                                     {return XQueryTypes.K_LET;}
"some"                                    {return XQueryTypes.K_SOME;}
"every"                                   {return XQueryTypes.K_EVERY;}
"in"                                      {return XQueryTypes.K_IN;}
"if"                                      {return XQueryTypes.K_IF;}
"then"                                    {return XQueryTypes.K_THEN;}
"else"                                    {return XQueryTypes.K_ELSE;}
"typeswitch"                              {return XQueryTypes.K_TYPESWITCH;}
"switch"                                  {return XQueryTypes.K_SWITCH;}
"case"                                    {return XQueryTypes.K_CASE;}
"and"                                     {return XQueryTypes.K_AND;}
"or"                                      {return XQueryTypes.K_OR;}
"as"                                      {return XQueryTypes.K_AS;}
"to"                                      {return XQueryTypes.K_TO;}
"where"                                   {return XQueryTypes.K_WHERE;}
"group"                                   {return XQueryTypes.K_GROUP;}
"by"                                      {return XQueryTypes.K_BY;}
"node"                                    {return XQueryTypes.K_NODE;}
"order"                                   {return XQueryTypes.K_ORDER;}
"map:map"                                 {pushState(QNAME);yypushback(yylength());return TokenType.WHITE_SPACE;}
"map"                                     {return XQueryTypes.K_MAP;}
"instance"                                {return XQueryTypes.K_INSTANCE;}
"of"                                      {return XQueryTypes.K_OF;}
"satisfies"                               {return XQueryTypes.K_SATISFIES;}
{NCName}                                  {pushState(QNAME);yypushback(yylength());return TokenType.WHITE_SPACE;}
}

<EXPR_COMMENT> {
":)"                                      {popState(); return XQueryBasicTypes.EXPR_COMMENT_END;}
"(:"                                      {pushState(EXPR_COMMENT); return XQueryBasicTypes.EXPR_COMMENT_START;}
{Char}                                    {return XQueryBasicTypes.EXPR_COMMENT_CONTENT;}
}

<START_TAG> {
{S}                                       {return XQueryTypes.S;}
{NCName}                                  {return XQueryTypes.NCNAME;}
":"                                       {return XQueryTypes.COLON;}
"="                                       {return XQueryTypes.EQUAL;}
"\""                                      {pushState(QUOT_STRING); return XQueryTypes.QUOT;}
"'"                                       {pushState(APOS_STRING); return XQueryTypes.APOSTROPHE;}
">"                                       {popState();pushState(ELEMENT_CONTENT); return XQueryTypes.GT_CHAR;}
"/>"                                      {popState(); return XQueryTypes.CLOSE_TAG;}
}

<ELEMENT_CONTENT> {
{S}                                       {return TokenType.WHITE_SPACE;}
"<!--"                                    {pushState(DIR_COMMENT); return XQueryTypes.DIR_COMMENT_BEGIN;}
"{{" | "}}" | [^{}<]+                     {return XQueryTypes.ELEMENTCONTENTCHAR;}
"{"                                       {pushState(YYINITIAL); return XQueryTypes.L_C_BRACE; }
"</"                                      {popState(); pushState(END_TAG); return XQueryTypes.END_TAG;}
"<"                                       {pushState(START_TAG); return XQueryTypes.LT_CHAR; }
}

<DIR_COMMENT> {
"--"                                      {return TokenType.BAD_CHARACTER;}
"-->"                                     {popState(); return XQueryTypes.DIR_COMMENT_END;}
{Char}                                    {return XQueryTypes.DIRCOMMENTCHAR;}
}

<END_TAG> {
{S}                                       {return XQueryTypes.S;}
{NCName}                                  {return XQueryTypes.NCNAME;}
":"                                       {return XQueryTypes.COLON;}
">"                                       {popState(); return XQueryTypes.GT_CHAR;}
}

<QUOT_STRING> {
{PredefinedEntityRef}                     {return XQueryTypes.PREDEFINEDENTITYREF;}
{CharRef}                                 {return XQueryTypes.CHARREF;}
"{{"                                      {return XQueryTypes.DBL_L_C_BRACE;}
"}}"                                      {return XQueryTypes.DBL_R_C_BRACE;}
"{"                                       {pushState(YYINITIAL); return XQueryTypes.L_C_BRACE; }
"\""                                      {popState(); return XQueryTypes.QUOT;}
{Char}                                    {return XQueryTypes.CHAR;}
}

<APOS_STRING> {
{PredefinedEntityRef}                     {return XQueryTypes.PREDEFINEDENTITYREF;}
{CharRef}                                 {return XQueryTypes.CHARREF;}
"{{"                                      {return XQueryTypes.DBL_L_C_BRACE;}
"}}"                                      {return XQueryTypes.DBL_R_C_BRACE;}
"{"                                       {pushState(YYINITIAL); return XQueryTypes.L_C_BRACE; }
"'"                                       {popState(); return XQueryTypes.APOSTROPHE;}
{Char}                                    {return XQueryTypes.CHAR;}
}

<URIQUALIFIED> {
{S}                                       {return TokenType.WHITE_SPACE;}
{URIQualifiedName}                        {popState(); return XQueryTypes.URIQUALIFIEDNAME;}
}

<QNAME> {
{NCName} ":" {NameStartCharWithoutFirst}  {yypushback(2); return XQueryTypes.NCNAME;}
{NCName}                                  {popState(); return XQueryTypes.NCNAME;}
":"                                       {return XQueryTypes.COLON;}
.                                         {yypushback(yylength()); popState();}
}

<ALLOWING> {
{S}                                       {return TokenType.WHITE_SPACE;}
"empty"                                   {return XQueryTypes.K_EMPTY;}
.                                         {yypushback(yylength()); popState();}
}

.                                         {return TokenType.BAD_CHARACTER;}