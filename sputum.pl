#! /usr/bin/perl

require 5.014;
use strict;
use warnings;

# global hashes
my %int_register;
my $free_int_register = 0;

my %data;

my $text;
{
    # set delimiter to under so that whole file
    # is slurped
    local $/;

    $text = <>;
}

print Sputum($text) . "\n\n";

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

    $text = _LoadData($text);
    $text = _SubPrint($text);
    $text = _SubScan($text);
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
	else {
	    _LoadVars($_);
	}
    }
    $text =~ s/^[ \t]*(int|float).*?\n//mg;
    return $text;
}

sub _SubScan {
    my $text = shift;
    $text =~ s/^([ \t]*)(scan\s.*?)\n/_GetScans($2, $1);/gme;
    return $text;
}

sub _GetScans {
    my @vars = split /[\s,]+/, shift;
    shift @vars;
    my $indent = shift;
    my $scans;

    my ($v, $load);
    foreach ( @vars ) {
	if ( defined $int_register{$_} ) {
	    $scans = $scans . _Scan(5, $_, "move", $indent);
	}
	$scans = $scans . "\n"
    }
    chomp $scans;
    return $scans;
}

sub _Scan {
    my ($v, $var, $load, $indent) = @_;
    my $text = "${indent}li \$v0, $v\n" .
	"${indent}syscall\n" .
	"${indent}$load $var, \$v0";
}

sub _SubPrint {

    my $text = shift;
    $text =~ s/^([ \t]*)(print\s.*?)\n/_GetPrints($2, $1);/gme;
    return $text;
}

sub _GetPrints {

    my ($vars, $indent) = @_;
    my @vars = split /[\s,]+/, $vars;
    shift @vars;

    my ($v, $load, $prints);
    
    foreach ( @vars ) {
	if ( defined $data{$_} ) {
	    if ( $data{$_} =~ "ascii" ) {
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
	$prints = $prints . "\n";
    }
    chomp $prints;
    return $prints;
}

sub _Print {
    my ($v, $load, $var, $indent) = @_;
    my $prints = "${indent}li \$v0, $v\n" .
	"${indent}$load \$a0, $var\n" .
	"${indent}syscall\n";
}

sub _LoadVars {
    
    my $text = shift;

    # Var definitions are of the form: ^var [vars ...]
    # Each var gets its own $t{n} register.
    $text =~ s/^[ \t]*(\S+) (.*?)$/_VarsToRegisters($1, $2)/ge; 
}


sub _VarsToRegisters {

    my $data_type = shift;
    my @vars = split /[\s,]+/, shift;
    foreach (@vars) {
	if ($data_type eq 'int') {
	    $int_register{$_} = "\$t$free_int_register";
	    $free_int_register++;
	}
    }
}

sub _SubVars {
#
# Strip variable definitions from text, and store variables and
# corresponding registers in hash references.
#
    my $text = shift;
    
    while ( my($int, $reg) = each %int_register) {
	$text =~ s/\b$int\b/$reg/g
    }

    return $text;
}
