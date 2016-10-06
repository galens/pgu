#PURPOSE: This program is to demonstrate how to call printf

.section .data

#format string
firststring:
.ascii "Sup! %s is a %s who loves the number %d\n\0"
name:
.ascii "Terrence\0"
personstring:
.ascii "alien\0"
#This couuld also have been an .equ, but we decided to give it a real memory location just for kicks
numberloved:
.long 420

.section .text
.globl _start
_start:
#note that the parameters are passed in the reverse order that they are listed
pushl numberloved       #this is the %d
pushl $personstring     #this is the second %s
pushl $name             #this is the first %s
pushl $firststring      #this is the format string in the prototype

call printf
pushl $0
call exit

