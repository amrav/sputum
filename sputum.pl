#! /usr/bin/perl

require 5.014;
use strict;
use warnings;

# global hashes
my %int_register;
my $free_int_register = 0;

my $text;
{
    # set delimiter to under so that whole file
    # is slurped
    local $/;

    $text = <>;
}

print Sputum($text) . "\n";

sub Sputum {
    
    my $text = shift;
    
    # Standardize line endings:
    $text =~ s{\r\n}{\n}g; # DOS to Unix
    $text =~ s{\r}{\n}g;   # Mac to Unix

    # Convert all tabs to spaces
    # not sure if this is necessary
    # $text = _Detab($text);

    # Strip any lines consisting only of spaces and tabs.
    $text =~ s/^[ \t]+$//mg;

    $text = _SubPrint($text);
    $text = _SubVars($text);

    return $text;
}


sub _SubPrint {

    my $text = shift;

    $text =~ s{
                     ^[ \t]*pi
                     \s+(\S+)
                     \s*\n
                    }
         	    {
                     "li \$v0, 1\n".
                     "li \$a0, $1\n".
                     "syscall\n"
                    }gmxe;
    return $text;
}
    
sub _SubVars {
#
# Strip variable definitions from text, and store variables and
# corresponding registers in hash references.
#

    my $text = shift;

    # Var definitions are of the form: ^var [vars ...]
    # Each var gets its own $t{n} register.
    while ($text =~ s{
                         (^[ \t]*var       # line should begin with int
                          (?:[\s,]+\S+)+?   # match spaces or commas followed by words
                          \s*\n                # match end of line
                         )                 # save each 'int [vars...]' line in $1
                     }
        	     {}mx) {
#	print '$1 is: ', $1;
	_IntsToRegisters($1);
    }

    while ( (my $var, my $reg) = each %int_register) {
	$text =~ s/\b$var\b/$reg/g
    }
    $text;
}

sub _IntsToRegisters {

    my $text = shift;
    my @vars = split /[\s,]+/, $text;
    shift @vars;
    foreach (@vars) {
	$int_register{$_} = "\$t$free_int_register";
	$free_int_register++;
    }
}
	

	    
	

	
    
