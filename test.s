.data
	prompt:	.asciiz "Hello, world!\n"

.text
.globl main
main:			
	int i, value, return
	li value, 0
	add value, value, 1	
	move return, value

	print return, 8, prompt
