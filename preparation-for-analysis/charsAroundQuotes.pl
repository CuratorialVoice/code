#!/usr/bin/perl
use strict;
use warnings;
use utf8;

my %count;

open my $input, "<:encoding(UTF-8)", $ARGV[0];
open my $output, ">:encoding(UTF-8)", $ARGV[1];

while (<$input>) {
	chomp;
	my @matches = ( $_ =~ /( \'[a-z]..)/g ); 
	foreach my $m (@matches) {$count{$m}+=1;}
}

my @strings = sort {$count{$b} <=> $count{$a}} keys %count;
foreach my $string (@strings) {print $output "$string\t$count{$string}\n";}

close $input; close $output;
