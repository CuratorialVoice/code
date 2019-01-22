#!/usr/bin/perl
use strict;
use warnings;
use utf8;

#perl dedupeDescriptions.pl TSV_FILE
#takes .tsv file with  id\ttitles\tnames\tdescs\tpubdate\tacqdate, where values are in "" and multiple field values are separated by █

#it outputs a TSV_FILE_deduped.tsv file in the same format (except without "" around values, and id is now just number not uri) having de-duped according to:
	#multiple values within the Descs field ==> cut the string on the first separator.
	#descriptions that match the pattern ‘/for description/i’ ==> Delete all entire records with such descriptions,that is regardless of whether they repeat exactly across records or not
	#descriptions that are repeated across records in the dump but do not match ‘/for description/i’ ==> Keep the earliest record (i.e. lowest id number) and delete the others.

my $input = $ARGV[0];
#read input file into hashes linked by id
my (%idTitles, %idNames, %idDescs, %idPubDate, %idAcqDate);
open(INPUT, "<:encoding(UTF-8)", $input) or die "Can't open input file [$!]\n"; 
while (<INPUT>){
	chomp; my $line = $_;
	if ($line =~ /^\"(.*?)\"\t\"(.*?)\"\t\"(.*?)\"\t\"(.*?)\"\t\"(.*?)\"\t\"(.*?)\"$/){ #we break into fields first for regex efficiency?!
		my $idField = $1; my $titlesField = $2; my $namesField = $3; my $descsField = $4;my $pubDateField = $5; my $acqDateField = $6;
		#the following changes id from url to number only
		if ($idField =~ /^http\:\/\/collection\.britishmuseum\.org\/id\/object\/...(.*)\/prn/) 
			{$idTitles{$1} = $titlesField; $idNames{$1} = $namesField; $idDescs{$1} = $descsField; $idPubDate{$1} = $pubDateField; $idAcqDate{$1} = $acqDateField;} 
			else {print "Failed to get ID";}
	}
	else {print "Failed to parse line!!!";}
}
close INPUT; print "\nloaded input file\n";

#for all records cut description at first separator
foreach my $id (keys %idDescs){$idDescs{$id} =~ s/█.*//;}

#for all records if /for description/i then remove record   ????also a close copy, a later state, a later issue, a copy of ????
foreach my $id (keys %idDescs){if ($idDescs{$id} =~ /for description/i){delete $idDescs{$id};}}

#remove all records where description equals another record's description and the id number is bigger
my @idsToRemove;
foreach my $id1 (keys %idDescs){
	foreach my $id2 (keys %idDescs){
		if ($id1 >= $id2){next;}#because equality comparison is transitive, and we don't want to compare a description with itself, and we know we can delete $id2 in case of duplication
		if ($idDescs{$id1} eq $idDescs{$id2}) {push @idsToRemove, $id2;}#can't delete hash entry here because later in loop may try to look it up!?
	}
}
my %idsToRemoveHash = map {$_, 1} @idsToRemove;
foreach my $id (keys %idsToRemoveHash){delete $idDescs{$id};}

#for all remaining records, print whole records sorted by id, now with "" removed!!
$input =~ s/\.tsv//;
open(OUTPUT, ">:encoding(UTF-8)", $input."_deduped.tsv") or die "Can't create output file [$!]\n"; 
select OUTPUT; $| = 1;
foreach my $id (keys %idDescs){print $id."\t".$idTitles{$id}."\t".$idNames{$id}."\t".$idDescs{$id}."\t".$idPubDate{$id}."\t".$idAcqDate{$id}."\n";}
close OUTPUT;