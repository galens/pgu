#PURPOSE: Modified version of toupper program that reads from STDIN and writes to STDOUT

#Processing:    1) Open the input file
#		2) Open the output file
#		3) While we're not at the end of the input file
#		a) read part of file at the end of the input file
#		b) go through each byte of memory if the byte is a lower-case letter, convert it
#		c) write the memory buffer to output file

.section .data

#CONSTANTS#

#system call numbers
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

#options for open (look at /usr/include/asm/fcntl.h for various values
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

#standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

#system call interrput
.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0 #this is the return value of read which means we've hit the end of the file
.equ NUMBER_ARGUMENTS, 2

.section .bss
#Buffer - this is where the data is loaded into from the data file and written from into the output file
#	  this should never exceed 16,000 for various reasons
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

#STACK POSITIONS
.equ ST_SIZE_RESERVE, 4
.equ ST_IN, -4
.equ ST_ARGC, 0		#number of arguments
.equ ST_ARGV_0, 4	#name of program
.equ ST_ARGV_1, 8	#stdin?
# .equ ST_ARGV_2, 12	#output file name

.globl _start
_start:
###INITIALIZE PROGRAM###
#save the stack pointer
movl %esp, %ebp

#Allocate space for our file descriptors on the stack
subl $ST_SIZE_RESERVE, %esp

open_files:
open_fd_in:
###OPEN INPUT FILE###
#open syscall
movl $SYS_READ, %eax
#input STDIN file discriptor into %ebx
movl $STDIN, %ebx

#buffer 
movl $BUFFER_DATA, %ecx

#number of bytes to read
movl $BUFFER_SIZE, %edx

#call linux
int $LINUX_SYSCALL

###Begin Main Loop###
#read_loop_begin:

###convert the block to upper case###
pushl $BUFFER_DATA	#location of buffer
pushl %eax		#size of the buffer
call convert_to_upper
popl %eax		#get the size back
addl $4, %esp		#restore %esp

###write the block put to the output file###
#size of the buffer
movl %eax, %edx
movl $SYS_WRITE, %eax
#file to use
movl $STDOUT, %ebx
#location of the buffer
movl $BUFFER_DATA, %ecx
int $LINUX_SYSCALL

###continue the loop###
#jmp read_loop_begin

#end_loop:
###close the files###
#note - we dont need to do error checking on these,
# because error conditions dont signify anything special here
#movl $SYS_CLOSE, %eax
#movl ST_FD_OUT(%ebp), %ebx
#int $LINUX_SYSCALL

#movl $SYS_CLOSE, %eax
#movl ST_FD_IN(%ebp), %ebx
#int $LINUX_SYSCALL

###exit###
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL

#PURPOSE: This function actually does the conversion to upper case for a block
#
#INPUT: The first parameter is the location of the block of memory to convert
# The second parameter is the length of that buffer
#
#OUTPUT: This function overwrites the current buffer with the upper-casified version.
#
#VARIABLES:
# %eax - beginning of buffer
# %ebx - length of buffer
# %edi - current buffer offset
# %cl - current byte being examined
# (first part of %ecx)


###constants###
#the lower boundary of our search
.equ LOWERCASE_A, 'a'
#the upper boundary of our search
.equ LOWERCASE_Z, 'z'
#conversion between upper and lower case
.equ UPPER_CONVERSION, 'A' - 'a'

###stack stuff###
.equ ST_BUFFER_LEN, 8	#length of buffer
.equ ST_BUFFER, 12	#actual buffer
convert_to_upper:
pushl %ebp
movl %esp, %ebp

###set up variables###
movl ST_BUFFER(%ebp), %eax
movl ST_BUFFER_LEN(%ebp), %ebx
movl $0, %edi

#if a buffer with zero length was given to us just leave
cmpl $0, %ebx
je end_convert_loop

convert_loop:
#get the current byte
movb (%eax,%edi,1), %cl

#go to the next byte unless it is between 'a' and 'z'
cmpb $LOWERCASE_A, %cl
jl next_byte
cmpb $LOWERCASE_Z, %cl
jg next_byte

#otherwise convert the byte to uppercase
addb $UPPER_CONVERSION, %cl
#and store it back
movb %cl, (%eax, %edi, 1)
next_byte:
incl %edi		#next byte
cmpl %edi, %ebx		#continue unless we've reached the end
jne convert_loop

end_convert_loop:
#no return value, just leave
movl %ebp, %esp
popl %ebp
ret
