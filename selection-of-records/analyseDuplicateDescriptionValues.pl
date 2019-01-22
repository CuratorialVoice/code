#!/usr/bin/perl
use strict;
use warnings;
use utf8;

#perl analyseDuplicateDescriptionValues.pl TSV_FILE
#takes .tsv file with  id\ttitles\tnames\tdescs\tdate, where multiple field values are separated by █
#counts: (i) record has one description value; (ii) record has multiple descripion values - all equal; (iii) record has different description values
#then, based on first description value for each record:
##prints duplicated description values, with the relevant ids, sorted by the number of duplicate instances 
##and again, but skipping description values that match the pattern /for description see other impression/i 

my $input = $ARGV[0];

#read input file into hashes linked by id
my (%idTitles, %idNames, %idDescs, %idDate);
open(INPUT, "<:encoding(UTF-8)", $input) or die "Can't open input file [$!]\n"; 
while (<INPUT>){
	chomp; my $line = $_;
	if ($line =~ /^\"(.*?)\"\t\"(.*?)\"\t\"(.*?)\"\t\"(.*?)\"\t\"(.*?)\"\t\"(.*?)\"$/){ #we break into fields first for regex efficiency?!
		my $idField = $1; my $titlesField = $2; my $namesField = $3; my $descsField = $4;my $pubDate = $5; my $acqDate = $6;
		if ($idField =~ /^http\:\/\/collection\.britishmuseum\.org\/id\/object\/...(.*)\/prn/) 
			{$idTitles{$1} = $titlesField; $idNames{$1} = $namesField; $idDescs{$1} = $descsField;} 
			else {print "Failed to get ID";}
	}
	else {print "Failed to parse line!!!";}
}
close INPUT; print "\nloaded input file\n";

open(OUTPUT, ">:encoding(UTF-8)", $input."_analysisOfDuplicateDescriptions.txt") or die "Can't create output file [$!]\n"; 
select OUTPUT; $| = 1;

#analyse multiple description values within single records
print "test whether all description values (separated by █) are equal\n";
print "--------------------------------------------------------------\n";
my ($oneVal, $multValEqual, $multValDiff) = (0,0,0);
foreach my $idd (sort {$a <=> $b} (keys %idDescs)){
	my @values = split ('█', $idDescs{$idd});
	if (@values == 1) {$oneVal+=1; next;}
	my %v = map {$_, 1} @values; if (keys %v == 1) {$multValEqual+=1;next;}
	#if here then multiple values that are different	
	$multValDiff+=1;
	print "$idd -- ***different descriptions***\n";
	foreach my $vv (@values) {print $vv."\n";}
	print "\n\n";		
}
print "\nTOTALS, i.e. records/lines with: one value = $oneVal    multiple values, all equal = $multValEqual    different values = $multValDiff\n";


#because the results from the step above showed no cases of different descriptions, analysis continues by cutting each description string at the first █
foreach my $idd (keys %idDescs){$idDescs{$idd} =~ s/█.*//;}

#check for duplicate descriptions, and store ids with instances of duplicated strings - *brute force*
my %dupeStrings; my %countDupeStrings;
foreach my $id1 (keys %idDescs){
	foreach my $id2 (keys %idDescs){
		if ($id1 >= $id2){next;}#because equality comparison is transitive, and we don't want to compare a description with itself
		if ($idDescs{$id1} eq $idDescs{$id2}) {
			$dupeStrings{$idDescs{$id1}} .= $id1.",".$id2.",";#a comma separated string holding the ids that have the dupe string as description - with repetitions!!!
		}
	}
}
#remove repetitions from each string in %dupeStrings and make count of instances of each duplicated description
foreach my $ds (keys %dupeStrings){
	my @a = split ",", $dupeStrings{$ds}; my %h = map {$_, 1} @a; 
	$countDupeStrings{$ds} = keys %h; $dupeStrings{$ds} = join ("," ,keys %h);
}


#count total of description strings that are duplicates: counting separately those that match /for description/i and those that don't
my $dupeCount = 0; my $dupeCount2 = 0;
foreach my $ds (keys %countDupeStrings) {
	if ($ds =~/for description/i) {$dupeCount += $countDupeStrings{$ds};}
		else {$dupeCount2 += $countDupeStrings{$ds}};
}

print "\n\n\nNumber of duplicated description strings matching /for description/i  =  $dupeCount\n";
print "-------------------------------------------------------\n\n";
foreach my $ds (sort {$countDupeStrings{$b} <=> $countDupeStrings{$a}} keys %countDupeStrings) {
	if ($ds =~/for description/i) {print "$countDupeStrings{$ds} --- $ds\n$dupeStrings{$ds}\n\n";}
} 

print "\n\n\nNumber of duplicated description strings NOT matching /for description/i  =  $dupeCount2\n";
print "-------------------------------------------------------\n\n";
foreach my $ds (sort {$countDupeStrings{$b} <=> $countDupeStrings{$a}} keys %countDupeStrings) {
	if ($ds =~/for description/i){next;}
	print "$countDupeStrings{$ds} --- $ds\n$dupeStrings{$ds}\n\n";
} 



#check for cases of descriptions matching /for description/i that are not duplicates
print "\n\nCases of dedescriptions matching /for description/i that are not duplicates\n";
print "-------------------------------------------------------\n\n";
my %descCount; my $c;
foreach my $id (keys %idDescs){$descCount{$idDescs{$id}}+=1;}
foreach my $desc (keys %descCount){
	if (($descCount{$desc}==1) && ($desc =~ /for description/i))
	{print "$desc\n"; $c+=1;}
}
print "\n\nThat's $c more descriptions matching /for description/i";

close OUTPUT;