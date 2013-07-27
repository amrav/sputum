# Sputum
Spits MIPS. Run it like this:

    ./sputum.pl file

## Usage:

### Variables

Integers can be declared with the `int` keyword. Every new integer occupies a new `$t{n}` register.

    int i, j, sum
    li i, 0
    li j, 2
    add sum, i, j

outputs

    li $t0, 0
    li $t1, 2
    add $t3, $t0, $t1
