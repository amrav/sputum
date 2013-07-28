.data
	prompt:	.asciiz "Hello, world!\n"
	int i, value, return
.text
.globl main
main:			
	li value, 0
	add value, value, 1	
	move return, value

	print return, 8, prompt

	scan return
