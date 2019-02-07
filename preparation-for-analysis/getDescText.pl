#!/usr/bin/perl
use strict;
use warnings;
use utf8;

#takes .tsv  id\titles\names\description\pubDate\acqDate
#outputs the description text after 'cleaning', one description per line

my $input = $ARGV[0];

open(INPUT, "<:encoding(UTF-8)", $input) or die "Can't open input file [$!]\n"; 

$input =~ s/\.tsv//;
open(CAFFS, ">:encoding(UTF-8)", "cutAfterFinalFullStop_".$input.".txt") or die "Can't open output file [$!]\n";
open(CLEANED_TEXT, ">:encoding(UTF-8)", "descriptionText_".$input.".txt") or die "Can't open output file [$!]\n"; 

while (<INPUT>){
	chomp; my $line = $_;
	if ($line =~ /^(.*?)\t(.*?)\t(.*?)\t(.*?)\t(.*?)$/){
		my $descsField = $4;
		
		$descsField =~ s/\\[rnt]/ /g;#replace escaped characters with space
		$descsField =~ s/\\\"/\"/g;#remove \ before " (it doesn't occur before ')
		
		#print to log then cut all text after the final full-stop (we assume it is date and technique info)
		if ($descsField =~ /\.([\"\'\”\`\)\]])([^\.]+)$/)#case of closing quote or bracket after full-stop which we want to keep
			{print CAFFS $2."\n"; $descsField =~ s/\.([\"\'\”\`\)\]])([^\.]+)$/$1./;}
		else 
			{if ($descsField =~ /\.([^\.]+)$/) {print CAFFS $1."\n"; $descsField =~ s/\.([^\.]+)$/\./;} }
		
		#remove trailing c.
		$descsField =~ s/\bc\.(\s)*$//;
		
		#remove multiple whitespace, and preceding and trailing whitespace
		$descsField =~ s/\s{2,}/ /g; $descsField =~ s/^ //; $descsField =~ s/ $//;
		
		print CLEANED_TEXT $descsField."\n";
		
	}
	else {print "Failed to parse line!!!";}
}
close INPUT;
close CAFFS; close CLEANED_TEXT;