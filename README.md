
Easy Markup är ett enkelt uppmärkningsspråk för text.

Easy Markup is a lightweight markup language.

```
This is an optional HTML title.

.p
This is a paragraph.

.p
This is a paragraph. It ends
here.

.p
This is a    paragraph. It
ends
here.

.l
This is a list item.

This is a list item.

This is a list item.


.p
This is a paragraph. #This word
is italic.

.p
This is a paragraph. @This word
is bold.

.p
This is a paragraph. #{These words}
are italic.

.p
This is a paragraph. @{These words}
are bold.

```

The em2htm program does not support Unicode.

```
Usage: em2htm < infile.txt > outfile.htm
       em2htm file.css < infile.txt > outfile.htm
       em2htm file.css print.css < infile.txt > outfile.htm
```
