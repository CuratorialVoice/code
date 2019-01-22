#!/usr/bin/perl
use strict;
use warnings;
use utf8;

#perl removeTaschen.pl TSV_FILE
#takes .tsv file with  id\ttitles\tnames\tdescs\tdate, where "" around values have already been stripped

#it outputs a file xxx_noTaschen.tsv with all lines from the input file, except those where the descs field matches /Taschen Kalender/

my $input = $ARGV[0]; 
my $output = $input; $output =~ s/\.tsv/_noTaschen.tsv/;

open(INPUT, "<:encoding(UTF-8)", $input) or die "Can't open input file [$!]\n"; 
open(OUTPUT, ">:encoding(UTF-8)", $output) or die "Can't open output file [$!]\n";
while (<INPUT>){
	chomp; my $line = $_;
	if ($line =~ /^(.*?)\t(.*?)\t(.*?)\t(.*?)\t(.*?)$/){
		my $descsField = $4;
		if ($descsField =~ /Taschen Kalender/) {next;} 
			else {print OUTPUT $line."\n";}
	}
	else {print "Failed to parse line!!!";}
}
close INPUT; close OUTPUT;