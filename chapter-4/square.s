#PURPOSE - Given a number, this program computes the square of it
#
.section .data
#This program has no global data
.section .text
.globl _start
.globl square		#this is unneeded unless we want to share
			#this function among other programs
_start:
pushl $4		#The square takes one argument - the
			#number we want a square of.  So, it gets pushed
call  square		#run the square function
addl  $4, %esp		#Scrubs the parameter that was pushed on the stack
movl  %eax, %ebx	#square returns the answer in %eax, but
			#we want it in %ebx to send it as our exit status
movl  $1, %eax		#call the kernel’s exit function
int   $0x80
#This is the actual function definition
.type square,@function
square:
pushl %ebp		#standard function stuff - we have to
			#restore %ebp to its prior state before
			#returning, so we have to push it
movl  %esp, %ebp	#This is because we don’t want to modify
			#the stack pointer, so we use %ebp.
movl  8(%ebp), %eax	#This moves the first argument to %eax
			#4(%ebp) holds the return address, and
			#8(%ebp) holds the first parameter
imull %eax, %eax	#multiply that by itselfe
movl  %ebp, %esp	#standard function return stuff - we
popl  %ebp		#have to restore %ebp and %esp to where
			#they were before the function started
ret			#return to the function (this pops the
