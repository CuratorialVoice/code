#!/usr/bin/perl
use strict;
use warnings;

my $input = $ARGV[0];

#perl countDistinctIds.pl JSON_FILE > OUTPUT_FILE

#this reads the .json dump into a hash of $id{frequency} and returns the count of different ids, and a frequency list of ids (in which we expect the frequency of each to be 1)
#assumes input is well-formed, i.e. after a line containing "id" then the next line containing "value" will indeed be the id value for the current record
#assumes that id value is a uri with a string starting Pxx in between the final two back slashes, and takes all that follows Pxx in that string to be the id number

open(INPUT, "<:encoding(UTF-8)", $input) or die "Can't open input file [$!]\n"; 
my %ids; my $field="";

while (<INPUT>){
	chomp; my $line = $_;
	if ($line =~ /\"id\"/){$field="true";}
	if (($field eq "true") && ($line =~ /\"value\" \: \"http\:\/\/collection\.britishmuseum\.org\/id\/object\/P..(.*)\/prn\"/)){$ids{$1} += 1; $field = "";}
}
close INPUT;

my $count = keys %ids; print "There are $count different ids\n";

foreach my $i (keys %ids){
	#uncomment the following line to print only ids that are not unique
	#if ($ids{$i} == 1){next;}
	print "$ids{$i}\t$i\n";
	}