#!/usr/bin/perl
use strict;
use warnings;

#perl filterByDates TSV_FILE
#input is a .tsv file with each line  id\ttitles\tnames\tdescs\tdate

#it makes an output file called dateFiltered_TSV_FILE which lists five sets of lines/records, each preceded by a header in which the number of lines in that set is given:
##No publication date, i.e. the Date field did not match the pattern /^\"(\d\d\d\d)/
##No acquisition date, i.e. when reversed the Titles field did match /^\"\).*?\,(\d\d\d\d)\(/
##Published too early, i.e. the extracted $pubDate is less than the set $earliestPubDate
##Published too late, i.e. the extracted $pubDate is greater than the set $latestPubDate
##Acquired too late, i.e. the extracted $acqDate is greater than the set $latestAcqDate
##Definitely George, i.e. all other lines/records

##For the latter four cases (above), the acquisition date is added as a sixth field, i.e. so that each row comprises id\ttitles\tnames\tdescs\tpubDate\tacqDate

# **Set years in the following three lines**
my $earliestPubDate = 1771;
my $latestPubDate = 1832;
my $latestAcqDate = 1929;

my $input = $ARGV[0];
open(INPUT, "<:encoding(UTF-8)", $input) or die "Can't open input file [$!]\n"; 

my (@noPub, @noAcq, @pubTooEarly, @pubTooLate, @acqTooLate, @definiteGeorge);

while (<INPUT>){
	chomp; my $line = $_;
	if ($line =~ /^(.*?)\t(.*?)\t(.*?)\t(.*?)\t(.*?)$/){
		my $titlesField = $2; my $dateField = $5;
		my ($pubDate, $acqDate, $acqDateField); 
		
		#the current line/record will be one of the following six cases (it will only be recorded as the first matching case reached)...

		#no publication date
		if ($dateField =~ /^\"(\d\d\d\d)/) {$pubDate=$1;} else {push (@noPub, $line); next;}

		#no acquisition date
		my $rev = reverse $titlesField; if ($rev =~/^\"\).*?\,(\d\d\d\d)\(/) {$acqDate = reverse $1; $acqDateField = "\"".$acqDate."\"";} else {push (@noAcq, $line); next;}
		
		#publication date < $earliestPubDate
		if ($pubDate < $earliestPubDate) {push (@pubTooEarly, $line."\t".$acqDateField); next;}
		
		#publication date > $latestPubDate
		if ($pubDate > $latestPubDate) {push (@pubTooLate, $line."\t".$acqDateField); next;}
		
		#acquisition date > $latestAcqDate 
		if ($acqDate > $latestAcqDate) {push (@acqTooLate, $line."\t".$acqDateField); next;}
		
		#else, keep as a definite George description
		push (@definiteGeorge, $line."\t".$acqDateField);
	}
	else {print "Failed to parse line!!!";}
}
close INPUT;

open(OUTPUT, ">:encoding(UTF-8)", "dateFiltered_".$input) or die "Can't open output file [$!]\n";
select OUTPUT; $| = 1;
print "No publication date: ".@noPub."\n--------------------\n"; foreach my $l (@noPub){print $l."\n";}
print "\n\nNo acquisition date: ".@noAcq."\n--------------------\n"; foreach my $l (@noAcq){print $l."\n";}
print "\n\nPublished too early (before $earliestPubDate): ".@pubTooEarly."\n--------------------\n"; foreach my $l (@pubTooEarly){print $l."\n";}
print "\n\nPublished too late (after $latestPubDate): ".@pubTooLate."\n--------------------\n"; foreach my $l (@pubTooLate){print $l."\n";}
print "\n\nAcquired too late (after $latestAcqDate): ".@acqTooLate."\n--------------------\n"; foreach my $l (@acqTooLate){print $l."\n";}
print "\n\nDefinitely George: ".@definiteGeorge."\n--------------------\n"; foreach my $l (@definiteGeorge){print $l."\n";}
close OUTPUT;

