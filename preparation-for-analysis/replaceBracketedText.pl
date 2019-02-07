#!/usr/bin/perl
use strict;
use warnings;
use utf8;

#takes descriptionText_XXXXXX.txt from getDescText.pl
#outputs: file of descriptions with bracketed text replaced with *BRACKETED*; log files of text in () and text in []  

my $input = $ARGV[0];

open(INPUT, "<:encoding(UTF-8)", $input) or die "Can't open input file [$!]\n"; 

$input =~ s/^descriptionText_//;
open(RB, ">:encoding(UTF-8)", "roundBracketText_".$input) or die "Can't open output file [$!]\n";
open(SB, ">:encoding(UTF-8)", "squareBracketText_".$input) or die "Can't open output file [$!]\n";
open(BR, ">:encoding(UTF-8)", "bracketsReplaced_".$input) or die "Can't open output file [$!]\n"; 

while (<INPUT>) {
	chomp; my $line = $_;
	
	#print to log, then cut all text in ()
	my @matches = ( $line =~ /(\(.*?\))/g ); 
	foreach my $m (@matches) {print RB $m."\n";}
	$line =~ s/\(.*?\)/ *BRACKETED* /g;
	
	#print to log, then cut all text in []
	@matches = ( $line =~ /(\[.*?\])/g ); 
	foreach my $m (@matches) {print SB $m."\n";}
	$line =~ s/\[.*?\]/ *BRACKETED* /g;
	
	#remove multiple whitespace, and preceding/trailing spaces
	$line =~ s/\s{2,}/ /g; $line =~ s/^ //; $line =~ s/ $//;
	
	print BR $line."\n";
}
close INPUT;
close RB; close SB; close BR;
