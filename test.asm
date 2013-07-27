int i, value, return
li value, 0
addi value, value, 1	
move return, value
li $v0, 1
li $a0, return
syscall	
