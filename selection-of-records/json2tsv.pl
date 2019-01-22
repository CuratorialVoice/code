#!/usr/bin/perl
use strict;
use warnings;

#perl json2tsv.pl JSON_FILE
#it creates an output file called JSON_FILE.tsv where each record appears on one line with values separated by single tabs
#NB. the "" around values are kept

#assumes that there are N * number_of_records instances of /\"value\" \:/ , where N = the number of "vars" in the .json file. So we can simply print the string following /\"value\" \:/ plus \t, or \n every Nth time.
#set the number of vars in the next line
my $numberVars = 5;

my $input = $ARGV[0];
open(INPUT, "<:encoding(UTF-8)", $input) or die "Can't open input file [$!]\n"; 
open(OUTPUT, ">:encoding(UTF-8)", $input.".tsv") or die "Can't open output file [$!]\n";
my $count = 1;

while (<INPUT>){
	chomp; my $line = $_; my $value="";
	if ($line =~ /\"value\" \: (.*?)$/){$value=$1;} else {next;}
	if ($count%$numberVars != 0){print OUTPUT $value."\t";} else {print OUTPUT $value."\n";}
	$count +=1;
}
close INPUT; close OUTPUT;
print $count-1; #as a check this number printed in the terminal window, it should equal (number_of_records * number_of_vars)