# Sputum
Spits MIPS assembly. Run it like this:

```bash
$ ./sputum.pl file > output
```
### Features
1. Sputum is a dumb text preprocessor. It is almost certainly not a compiler, but I'm not sure yet.
2. Sputum is a superset of MIPS assembly. You can freely mix both.
3. Sputum tries to preserve your indentation, and doesn't touch comments. 

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
### I/O

`scan` scans anything. Well, almost. And you'll never guess what `print` does.

```asm
.data
	prompt: .asciiz "Hello, world!\n"
	int i
	
.text
main:
	scan i
	print prompt, i
```
outputs
```asm
.data
	prompt: .asciiz "Hello, world!\n"

.text
main:
	li $v0, 5
	syscall
	move $t0, $v0

	li $v0, 4
	la $a0, prompt
	syscall

	li $v0, 1
	move $a0, $t0
	syscall
```
