#! /usr/bin/perl

require 5.014;
use strict;
use warnings;

# global hashes
my %var_register;
my $free_var_register = 0;

my %data;

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

    _LoadData($text);
    $text = _SubPrint($text);
    $text = _SubVars($text);

    return $text;
}

sub _LoadData {
    my $text = shift;
    $text =~ /\.data\s*?(.*?\n)\s*\.text/s;
    my @data = split /\s*\n/, $1;
    foreach ( @data ) {
	if ( $_ =~ /[ \t]*(\S+?):[ \t]+\.(\S+)/ ) {
	    $data{$1} = $2;
	}
    }
}

sub _SubPrint {

    my $text = shift;
    $text =~ s/^([ \t]*)(print\s.*?)\n/_GetPrints($2, $1);/gme;
    return $text;
}

sub _GetPrints {
    my @vars = split /[\s,]+/, shift ;
    shift @vars;
    my $indent = shift;
    my $prints;

    my $v; my $load;
    foreach ( @vars ) {
	if ( defined $data{$_} ) {
	    if ( $data{$_} eq "asciiz" ) {
		$prints = $prints . _Print(4, "la", $_, $indent);
	    }
	}
	elsif ( $_ =~ /(\d+)/ ) {
	    $prints = $prints . _Print(1, "li", $1, $indent);
	}
	elsif ( $_ =~ /(\S+)/ ) {
	    $prints = $prints . _Print(1, "move", $1, $indent);
	}
	elsif ( $_ =~ /"(\S+)"/ ) {
	    $prints = $prints . _Print(4, "la", $1, $indent);
	}
    }
    return $prints;
}

sub _Print {
    my $v = shift;
    my $load = shift;
    my $var = shift;
    my $indent = shift;
    my $return = "${indent}li \$v0, $v\n" .
	"${indent}$load \$a0, $var\n" .
	"${indent}syscall\n\n";
    $return;
}

sub _SubVars {
#
# Strip variable definitions from text, and store variables and
# corresponding registers in hash references.
#

    my $text = shift;

    # Var definitions are of the form: ^var [vars ...]
    # Each var gets its own $t{n} register.
    $text =~ s/^[ \t]*var (.*?\n)/_IntsToRegisters($1)/mge; 

    while ( (my $var, my $reg) = each %var_register) {
	$text =~ s/\b$var\b/$reg/g
    }

    return $text;
}

sub _IntsToRegisters {

    my @vars = split /[\s,]+/, shift;
    foreach (@vars) {
	$var_register{$_} = "\$t$free_var_register";
	$free_var_register++;
    }
}
