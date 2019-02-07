#!/usr/bin/perl
use strict;
use warnings;
use utf8;

#this takes bracketsReplaced_XXXXX.txt and outputs:
	#1. a file of descriptions with quote marks changed to OPEN>> and <<CLOSE
	#2. a file of descriptions with text between quote marks replaced with *TRANSCRIBED*; text from stray open quotes to end of line is also replaced
	#3. log files of all quoted text: (i) found between open and close quote marks; (ii) found from stray open quote mark to end of line

my $input = $ARGV[0];
open(INPUT, "<:encoding(UTF-8)", $input) or die "Can't open input file [$!]\n"; 

$input =~ s/^bracketsRemoved_//;
open(MARKED, ">:encoding(UTF-8)", "quoteMarks_".$input) or die "Can't open output file [$!]\n"; 
open(SUBBED, ">:encoding(UTF-8)", "transcribedReplaced_".$input) or die "Can't open output file [$!]\n";
open(QUOTED, ">:encoding(UTF-8)", "textBetweenQuoteMarks_".$input) or die "Can't open output file [$!]\n";
open(QUOTED_NO_CLOSE, ">:encoding(UTF-8)", "textAfterOpenNoClose_".$input) or die "Can't open output file [$!]\n";

while (<INPUT>){
	chomp; my $line = $_;

	#deal with the most common non-quote uses of ' . (of course there are many less common ones.)
	$line =~ s/\b(tho|musicians|cherubs|horses|Grocers|satyrs|ladies)[\'\`]/$1AAAPOSTROPHE/g;
	$line =~ s/[\'\`](em|till|tis)/AAAPOSTROPHE$1/g;
	
	#replace quote characters with OPEN>> and <<CLOSE, preserving whitespace and punctuation around the quote marks
	$line =~ s/([\s\:])[\"\'\“\`]/$1 OPEN>> /g; #any other possible characters preceding an opening quote mark?
	$line =~ s/^[\"\'\“\`]/OPEN>> /; #case of quote mark at start of line
	$line =~ s/[\"\'\”\`](\W|$)/ <<CLOSE $1 /g; #assume that ok to do as any non-word character because opening quotes already done
	
	#put apostrophes back and print marked text
	$line =~ s/AAAPOSTROPHE/\'/gi; print MARKED $line."\n";
	
	#print quoted text, i.e. between OPEN>> ... <<CLOSE, and replace with *TRANSCRIBED*
	my @matches = ( $line =~ /OPEN\>\>\s+(.*?)\s+\<\<CLOSE/g );
	foreach my $m (@matches) {print QUOTED $m."\n";}
	$line =~ s/OPEN\>\>(.*?)\<\<CLOSE/*TRANSCRIBED*/g; 
	
	#case of remaining 'stray' open quote marks, i.e. text from OPEN>> to end of line
	if ($line =~ /OPEN\>\>\s+(.*?)$/g) {print QUOTED_NO_CLOSE $1."\n";}
	$line =~ s/OPEN\>\>(.*?)$/*TRANSCRIBED*/;
	
	#remove multiple whitespace, and preceding/trailing spaces
	$line =~ s/\s{2,}/ /g; $line =~ s/^ //; $line =~ s/ $//;
	
	#print final output
	print SUBBED $line."\n";

}

close INPUT;
close MARKED; close QUOTED; close QUOTED_NO_CLOSE; close SUBBED; 

