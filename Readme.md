# Sputum
Spits MIPS. Run it like this:

```bash
$ ./sputum.pl file > output
```


## Usage

### Variables

Integers can be declared with the `int` keyword. Every new integer occupies a new `$t{n}` register.

```asm
.data
	int i, j, sum

.text
	li i, 0
	li j, 2
	add sum, i, j
```
outputs

```asm
.data

.text
	li $t0, 0
	li $t1, 2
	add $t3, $t0, $t1
```

### Output

`print` prints anything. Well, almost. Add your own newlines.

```asm
.data
	prompt: .asciiz "Hello, world!\n"
	int i
	
.text
main:
	li i, 0

	print prompt

	print i, 8
```
outputs

```asm
.data
	prompt: .asciiz "Hello, world!\n"

.text
main:
	li $t0, 0

	li $v0, 4
	la $a0, prompt
	syscall

	li $v0, 1
	move $a0, $t0
	syscall

	li $v0, 1
	li $a0, 8
	syscall
```
