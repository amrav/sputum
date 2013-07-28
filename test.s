.data
	prompt:	.asciiz "Hello, world!\n"

.text
.globl main
main:			
	var i, value, return
	li value, 0
	addi value, value, 1	
	move return, value

	print return, 8, prompt
