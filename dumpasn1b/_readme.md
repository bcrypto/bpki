<!--
\brief dumpasn1b: A local version of dumpasn1
\created 2018.01.15
\version 2018.01.19
\thanks dumpasn1 is writen by (c) Peter Gutmann <pgut001@cs.auckland.ac.nz>
-->

[dumpasn1](http://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c) - 
это популярная программа дампа контейнеров АСН.1. К сожалению, dumpasn1 не 
справляется с отображением русских и белорусских символов в строках типа 
UTF8String. 

Мы решили проблему, немного подправив dumpasn1. Новую редакцию программы
мы назвали dumpasn1b.

Еще одна проблема dumpasn1 -- определенные синтаксические 
конструкции АСН.1 могут быть восприняты неверно:
```
	fputs( "Error: This file appears to be a base64-encoded text "
	   "file, not binary data.\n", stderr );
```
Например, мы столкнулись с неверной интерпретацией запроса OCSP, который 
начинается с 6 (!) вложенных друг в друга `SEQUENCE`. Проблема частично 
устранена заменой строки `"i >= 4"` на строку `"i >= 8"`.

\warning В dumpasn1b дамп выводится не на консоль, а в файл, имя которого 
является дополнительным параметром командной строки.
