%{


#define PARA1 0
#define HEAD1 1
#define HEAD2 2
#define HEAD3 3
#define HEAD4 4
#define HEAD5 5
#define HEAD6 6

#define NONE 0
#define EMPHASIS 1
#define STRONG 2
#define CODE 3

#define ULIST 0
#define NUMLIST 1

#define TABLE1 0

#define VERBATIM1 0

#define IMG1 0

#define DEFLIST1 0


%}


%x TITLE COMMAND PARA LIST TABLE VERBATIM XTRA IMG_A IMG_B DEFLIST_A DEFLIST_B


                             int html_ver; 

                             int para_block;
                             int inline;
                             int inline_type;

                             int list_block;

                             int table_block;
                             int table_header;

                             int verbatim_block;

                             int img_block;

                             int deflist_block;


                             void title_open(void);
                             void title_close(void);

                             void para_block_open(void);
                             void para_block_close(void);
                             void inline_open(void);
                             void inline_close(void);
                             void put_char(char);

                             void list_block_open(void);
                             void list_block_close(void);
                             void list_item_open(void);
                             void list_item_close(void);

                             void table_block_open(void);
                             void table_block_close(void);
                             void table_row_open(void);
                             void table_row_close(void);
                             void table_col_open(void);
                             void table_col_open_th(void);
                             void table_col_close(void);
                             void table_col_close_th(void);

                             void verbatim_block_open(void);
                             void verbatim_block_close(void);

                             void img_block_open(void);
                             void img_block_alt(void);
                             void img_block_close(void);

                             void deflist_block_open(void);
                             void deflist_block_close(void);
                             void deflist_term_open(void);
                             void deflist_term_close(void);
                             void deflist_def_open(void);
                             void deflist_def_close(void);




%%

<DEFLIST_A>\n*\n\x20*\n\x2e            deflist_term_close(); deflist_def_open(); deflist_def_close(); deflist_block_close(); BEGIN(COMMAND); 
<DEFLIST_A><<EOF>>                     deflist_term_close(); deflist_def_open(); deflist_def_close(); deflist_block_close(); BEGIN(COMMAND); 
<DEFLIST_A>\n+                         deflist_term_close(); deflist_def_open(); BEGIN(DEFLIST_B); 
<DEFLIST_A>\x20*\x3b\x20*              deflist_term_close(); deflist_def_open(); BEGIN(DEFLIST_B); 
<DEFLIST_A>.                           put_char(yytext[0]);

<DEFLIST_B>\x5c.                       put_char(yytext[1]);

<DEFLIST_B>\x7c[0-9a-f][0-9a-f][0-9a-f][0-9a-f]  printf("&#x%c%c%c%c;", yytext[1], yytext[2], yytext[3], yytext[4]);

<DEFLIST_B>\x23\x7b                    inline = EMPHASIS; inline_type = 1; inline_open();
<DEFLIST_B>\x40\x7b                    inline = STRONG; inline_type = 1; inline_open();
<DEFLIST_B>\x24\x7b                    inline = CODE; inline_type = 1; inline_open();
<DEFLIST_B>\x7d                        inline_close(); inline = NONE;

<DEFLIST_B>\x23                        inline = EMPHASIS; inline_type = 0; inline_open();
<DEFLIST_B>\x40                        inline = STRONG; inline_type = 0; inline_open();
<DEFLIST_B>\x24                        inline = CODE; inline_type = 0; inline_open();

<DEFLIST_B>\n*\n\x20*\n\x2e            inline_close(); deflist_def_close(); deflist_block_close(); BEGIN(COMMAND); 
<DEFLIST_B><<EOF>>                     inline_close(); deflist_def_close(); deflist_block_close(); BEGIN(COMMAND);
<DEFLIST_B>\n\x20*\n                   inline_close(); deflist_def_close(); deflist_term_open(); BEGIN(DEFLIST_A); 
<DEFLIST_B>(\x20|\n)+                  if (inline_type == 0){ inline_close(); inline = NONE; } put_char(' ');
<DEFLIST_B>[^\n\x20]                   put_char(yytext[0]);


<IMG_A>\n*\n\x20*\n\x2e                img_block_alt(); img_block_close(); BEGIN(COMMAND); 
<IMG_A><<EOF>>                         img_block_alt(); img_block_close(); BEGIN(COMMAND); 
<IMG_A>\n+                             img_block_alt(); BEGIN(IMG_B); 
<IMG_A>.                               printf("%c", yytext[0]);

<IMG_B>\n*\n\x20*\n\x2e                img_block_close(); BEGIN(COMMAND); 
<IMG_B><<EOF>>                         img_block_close(); BEGIN(COMMAND); 
<IMG_B>(\x20|\n)+                      put_char(' ');
<IMG_B>[^\n\x20]                       put_char(yytext[0]);


<XTRA>\n*\n\x20*\n\x2e                 BEGIN(COMMAND); 
<XTRA><<EOF>>                          BEGIN(COMMAND);  
<XTRA>\n                               printf("\n", yytext[0]);
<XTRA>.                                printf("%c", yytext[0]);


<VERBATIM>\n*\n\x20*\n\x2e             verbatim_block_close(); BEGIN(COMMAND); 
<VERBATIM><<EOF>>                      verbatim_block_close(); BEGIN(COMMAND);  
<VERBATIM>\n                           put_char(yytext[0]);
<VERBATIM>.                            put_char(yytext[0]);


<TABLE>\n*\n\x20*\n\x2e                if (table_header == 1){ table_col_close_th(); } else { table_col_close(); } table_row_close(); table_block_close(); BEGIN(COMMAND); 
<TABLE><<EOF>>                         if (table_header == 1){ table_col_close_th(); } else { table_col_close(); } table_row_close(); table_block_close(); BEGIN(COMMAND);  

<TABLE>\n                              if (table_header == 1){ table_col_close_th(); } else { table_col_close(); } table_row_close(); table_header = 0; table_row_open(); table_col_open();
<TABLE>\x20*\x3b\x20*                  if (table_header == 1){ table_col_close_th(); } else { table_col_close(); } if (table_header == 1){ table_col_open_th(); } else { table_col_open(); }
<TABLE>[^\n\x20]                       put_char(yytext[0]);
<TABLE>\x20                            put_char(yytext[0]);


<LIST>\x5c.                            put_char(yytext[1]);

<LIST>\x7c[0-9a-f][0-9a-f][0-9a-f][0-9a-f]  printf("&#x%c%c%c%c;", yytext[1], yytext[2], yytext[3], yytext[4]);

<LIST>\x23\x7b                         inline = EMPHASIS; inline_type = 1; inline_open();
<LIST>\x40\x7b                         inline = STRONG; inline_type = 1; inline_open();
<LIST>\x24\x7b                         inline = CODE; inline_type = 1; inline_open();
<LIST>\x7d                             inline_close(); inline = NONE;

<LIST>\x23                             inline = EMPHASIS; inline_type = 0; inline_open();
<LIST>\x40                             inline = STRONG; inline_type = 0; inline_open();
<LIST>\x24                             inline = CODE; inline_type = 0; inline_open();

<LIST>\n*\n\x20*\n\x2e                 inline_close(); list_item_close(); list_block_close(); BEGIN(COMMAND); 
<LIST><<EOF>>                          inline_close(); list_item_close(); list_block_close(); BEGIN(COMMAND); 
<LIST>\n\x20*\n                        inline_close(); list_item_close(); list_item_open(); 
<LIST>(\x20|\n)+                       if (inline_type == 0){ inline_close(); inline = NONE; } put_char(' ');
<LIST>[^\n\x20]                        put_char(yytext[0]);


<PARA>\x5c.                            put_char(yytext[1]);

<PARA>\x7c[0-9a-f][0-9a-f][0-9a-f][0-9a-f]  printf("&#x%c%c%c%c;", yytext[1], yytext[2], yytext[3], yytext[4]);

<PARA>\x23\x7b                         inline = EMPHASIS; inline_type = 1; inline_open();
<PARA>\x40\x7b                         inline = STRONG; inline_type = 1; inline_open();
<PARA>\x24\x7b                         inline = CODE; inline_type = 1; inline_open();
<PARA>\x7d                             inline_close(); inline = NONE;

<PARA>\x23                             inline = EMPHASIS; inline_type = 0; inline_open();
<PARA>\x40                             inline = STRONG; inline_type = 0; inline_open();
<PARA>\x24                             inline = CODE; inline_type = 0; inline_open();

<PARA>\n*\n\x20*\n\x2e                 inline_close(); para_block_close(); BEGIN(COMMAND); 
<PARA><<EOF>>                          inline_close(); para_block_close(); BEGIN(COMMAND); 
<PARA>(\x20|\n)+                       if (inline_type == 0){ inline_close(); inline = NONE; } put_char(' ');
<PARA>[^\n\x20]                        put_char(yytext[0]);


<COMMAND>ld\n                          deflist_block = DEFLIST1; inline = NONE; inline_type = 0; deflist_block_open(); deflist_term_open(); BEGIN(DEFLIST_A);
<COMMAND>i\n                           img_block = IMG1; img_block_open(); BEGIN(IMG_A);
<COMMAND>x\n                           BEGIN(XTRA);
<COMMAND>v\n                           verbatim_block = VERBATIM1; verbatim_block_open(); BEGIN(VERBATIM);
<COMMAND>th\n                          table_block = TABLE1; table_header = 1; table_block_open(); table_row_open(); table_col_open_th(); BEGIN(TABLE);
<COMMAND>t\n                           table_block = TABLE1; table_header = 0; table_block_open(); table_row_open(); table_col_open(); BEGIN(TABLE);
<COMMAND>ln\n                          list_block = NUMLIST; inline = NONE; inline_type = 0; list_block_open(); list_item_open(); BEGIN(LIST);
<COMMAND>l\n                           list_block = ULIST; inline = NONE; inline_type = 0; list_block_open(); list_item_open(); BEGIN(LIST);
<COMMAND>h6\n                          para_block = HEAD6; inline = NONE; inline_type = 0; para_block_open(); BEGIN(PARA);
<COMMAND>h5\n                          para_block = HEAD5; inline = NONE; inline_type = 0; para_block_open(); BEGIN(PARA);
<COMMAND>h4\n                          para_block = HEAD4; inline = NONE; inline_type = 0; para_block_open(); BEGIN(PARA);
<COMMAND>h3\n                          para_block = HEAD3; inline = NONE; inline_type = 0; para_block_open(); BEGIN(PARA);
<COMMAND>h2\n                          para_block = HEAD2; inline = NONE; inline_type = 0; para_block_open(); BEGIN(PARA);
<COMMAND>h1\n                          para_block = HEAD1; inline = NONE; inline_type = 0; para_block_open(); BEGIN(PARA);
<COMMAND>p\n                           para_block = PARA1; inline = NONE; inline_type = 0; para_block_open(); BEGIN(PARA);
<COMMAND>.*                            BEGIN(0);

<TITLE>\n\x20*\n\x2e                   title_close(); BEGIN(COMMAND);
<TITLE>(\x20|\n)+                      put_char(' ');
[^\n\x20]                              put_char(yytext[0]);

\x20*\n\x2e                            title_close(); BEGIN(COMMAND);
[^\n]                                  put_char(yytext[0]); BEGIN(TITLE);
\n
 

%%

  

void title_open()
{
 
    printf("<title>");

}



void title_close()
{

    printf("</title></head><body>");

}


void para_block_open()
{


    switch (para_block){
        case PARA1 :
            printf("<p>");
            break;
        case HEAD1 :
            printf("<h1>");
            break;
        case HEAD2 :
            printf("<h2>");
            break;
        case HEAD3 :
            printf("<h3>");
            break;
        case HEAD4 :
            printf("<h4>");
            break;
        case HEAD5 :
            printf("<h5>");
            break;
        case HEAD6 :
            printf("<h6>");
            break;

    }

}


void para_block_close()
{


    switch (para_block){
        case PARA1 :
            printf("</p>");
            break;
        case HEAD1 :
            printf("</h1>");
            break;
        case HEAD2 :
            printf("</h2>");
            break;
        case HEAD3 :
            printf("</h3>");
            break;
        case HEAD4 :
            printf("</h4>");
            break;
        case HEAD5 :
            printf("</h5>");
            break;
        case HEAD6 :
            printf("</h6>");
            break;

    }

}


void inline_open()
{


    switch (inline){
        case EMPHASIS :
            printf("<em>");
            break;
        case STRONG :
            printf("<strong>");
            break;
        case CODE :
            printf("<code>");
            break;

    }

}


void inline_close()
{


    switch (inline){
        case EMPHASIS :
            printf("</em>");
            break;
        case STRONG :
            printf("</strong>");
            break;
        case CODE :
            printf("</code>");
            break;

    }

}


void put_char(char ch)
{


    switch (ch){
        case '"' :
            printf("&quot;");
            break;
        case '&' :
            printf("&amp;");
            break;
        case 0x27 :
            printf("&apos;");
            break;
        case '<' :
            printf("&lt;");
            break;
        case '>' :
            printf("&gt;");
            break;
        default :
            printf("%c", ch);
            break;

    }

}


void list_block_open()
{


    switch (list_block){
        case ULIST :
            printf("<ul>");
            break;
        case NUMLIST :
            printf("<ol>");
            break;
    }

}


void list_block_close()
{


    switch (list_block){
        case ULIST :
            printf("</ul>");
            break;
        case NUMLIST :
            printf("</ol>");
            break;
    }

}


void list_item_open()
{


    switch (list_block){
        case ULIST :
            printf("<li>");
            break;
        case NUMLIST :
            printf("<li>");
            break;
    }

}


void list_item_close()
{


    switch (list_block){
        case ULIST :
            printf("</li>");
            break;
        case NUMLIST :
            printf("</li>");
            break;
    }

}


void table_block_open()
{


    switch (table_block){
        case TABLE1 :
            printf("<table>");
            break;
    }

}


void table_block_close()
{


    switch (table_block){
        case TABLE1 :
            printf("</table>");
            break;
    }

}


void table_row_open()
{


    switch (table_block){
        case TABLE1 :
            printf("<tr>");
            break;
    }

}


void table_row_close()
{


    switch (table_block){
        case TABLE1 :
            printf("</tr>");
            break;
    }

}



void table_col_open()
{


    switch (table_block){
        case TABLE1 :
            printf("<td>");
            break;
    }

}


void table_col_close()
{


    switch (table_block){
        case TABLE1 :
            printf("</td>");
            break;
    }

}



void table_col_open_th()
{


    switch (table_block){
        case TABLE1 :
            printf("<th>");
            break;
    }

}


void table_col_close_th()
{


    switch (table_block){
        case TABLE1 :
            printf("</th>");
            break;
    }

}


void verbatim_block_open()
{


    switch (verbatim_block){
        case VERBATIM1 :
            printf("<pre>");
            break;
    }

}


void verbatim_block_close()
{


    switch (verbatim_block){
        case VERBATIM1 :
            printf("</pre>");
            break;
    }

}


void img_block_open()
{


    switch (img_block){
        case IMG1 :
            printf("<img src=\"");
            break;
    }

}


void img_block_alt()
{


    switch (img_block){
        case IMG1 :
            printf("\" alt=\"");
            break;
    }

}


void img_block_close()
{


    switch (img_block){
        case IMG1 :
            printf("\">");
            break;
    }

}


void deflist_block_open()
{


    switch (deflist_block){
        case DEFLIST1 :
            printf("<dl>");
            break;
    }

}


void deflist_block_close()
{


    switch (deflist_block){
        case DEFLIST1 :
            printf("</dl>");
            break;
    }

}


void deflist_term_open()
{


    switch (deflist_block){
        case DEFLIST1 :
            printf("<dt>");
            break;
    }

}


void deflist_term_close()
{


    switch (deflist_block){
        case DEFLIST1 :
            printf("</dt>");
            break;
    }

}


void deflist_def_open()
{


    switch (deflist_block){
        case DEFLIST1 :
            printf("<dd>");
            break;
    }

}


void deflist_def_close()
{


    switch (deflist_block){
        case DEFLIST1 :
            printf("</dd>");
            break;
    }

}


int yywrap()
{
    return 1;
}


int main(int argc, char *argv[])
{

    html_ver = 5;   /* 4 = html4  5 = html5 */

    para_block = PARA1;
    inline = NONE;
    inline_type = 0;

    if ((argc > 3)){

        fprintf(stderr, "Usage: em2htm < infile.txt > outfile.htm\n\n");
        fprintf(stderr, "em2htm file.css < infile.txt > outfile.htm\n\n");
        fprintf(stderr, "em2htm file.css print.css < infile.txt > outfile.htm\n\n");

        exit(1);
    }


    if (html_ver == 4){

        printf("<!DOCTYPE HTML PUBLIC \x22-//W3C//DTD HTML 4.01 Transitional//EN\x22 ");
        printf("\x22http://www.w3.org/TR/html4/loose.dtd\x22>");
        printf("<html><head><meta http-equiv=\x22");
        printf("Content-Type\x22 content=\x22text/html;charset=ISO-8859-1\x22>");

    }

    else if (html_ver == 5){

        printf("<!DOCTYPE html>");
        printf("<html><head><meta http-equiv=\x22");
        printf("Content-Type\x22 content=\x22text/html;charset=ISO-8859-1\x22>");

    }


    if (argc > 1){

        printf("<link rel=\x22stylesheet\x22 type=\x22text/css\x22 href=\x22%s\x22>", argv[1]); 

    }

    if (argc > 2){

        printf("<link rel=\x22stylesheet\x22 type=\x22text/css\x22 href=\x22%s\x22 media=\x22print\x22>", argv[2]); 

    }


    title_open();

    yylex();

  
    printf("</body></html>");

    return 0;

}
