# Sputum
Spits MIPS. Run it like this:

    ./sputum.pl file

## Usage

### Variables

Variables can be declared with the `var` keyword. Every new variable occupies a new `$t{n}` register.

    var i, j, sum
    li i, 0
    li j, 2
    add sum, i, j

outputs

    li $t0, 0
    li $t1, 2
    add $t3, $t0, $t1

### Output

`pi` prints integers. Feel free to use it with numbers too.

    var i
    li i, 0
    pi i
    pi 8

outputs

    li $t0, 0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 1
    li $a0, 8
    syscall
