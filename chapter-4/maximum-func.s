#PURPOSE:  This program finds the maximum number of a
#          set of data items.
#VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The following memory locations are used:
#
# data_items - contains the item data.  A 0 is used
#              to terminate the data
#
.section .data
data_items:		#These are the data items
.long 3,67,34,222,223,75,54,34,245,44,33,22,11,66,0
.section .text
.globl _start
_start:
pushl $data_items	#push data_items onto the stack
call maximum		#run the maximum function
addl $4, %esp

movl %eax, %ebx		#set return variable into %ebx
movl  $1, %eax          #call the kernel’s exit function
int   $0x80

# function definition
.type maximum,@function
maximum:
pushl %ebp		# save base pointer
movl %esp, %ebp		# dont modify stack pointer, use base

movl $0, %edi		# move 0 into the index register
movl 8(%ebp), %edx	# load the address of the data items into %edx register

movl (%edx,%edi,4), %ecx # load the first item of data into %ecx
movl %ecx, %eax

start_loop:		# start loop
cmpl $0, %ecx		# check to see if we’ve hit the end
je loop_exit

incl %edi		# load next value
movl (%edx,%edi,4), %ecx # load the next item of data into %ecx
cmpl %eax, %ecx		# compare values
jle start_loop		# jump to loop beginning if the new
			# one isn’t bigger
movl %ecx, %eax		# move the value as the largest
jmp start_loop		# jump to loop beginning

loop_exit:
movl %ebp, %esp
popl %ebp
ret
