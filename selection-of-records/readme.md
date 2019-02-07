# Selection of BMSat Records

This document records the selection of relevant records from [2018-10-01_BMsparql.json](https://github.com/CuratorialVoice/data/blob/master/BMsparql/2018-10-01_BMsparql.json). The final output of the process - `selectedRecords.tsv` - is the dataset used in our research into Mary Dorothy George’s curatorial voice. Note that the document is not intended as a comphrehensive guide to the process of selecting relevant records and complements comments in the code described below.

[2018-10-01_BMsparql.json](https://github.com/CuratorialVoice/data/blob/master/BMsparql/2018-10-01_BMsparql.json) was extracted from the [ResearchSpace SPARQL endpoint](https://public.researchspace.org/sparql) using the query [2018-10-01_BMsparl.txt](https://github.com/CuratorialVoice/code/blob/master/BMsparql/2018-10-01_BMsparl.txt). See [2018-10-01_BMsparl.txt](https://github.com/CuratorialVoice/code/blob/master/BMsparql/2018-10-01_BMsparl.txt) for documentation of the extraction process.

Perl scripts were devloped and executed (via the ‘terminal’ - if you don’t know what this is, see the *[Software Carpentry](https://software-carpentry.org/)* lesson ‘[The Unix Shell](https://swcarpentry.github.io/shell-novice/)’) on a Linux machine with `perl 5, version 22, subversion 1 (v5.22.1) built for x86_64-linux-gnu-thread-multi`. They have been tested on macOS and should work for most standard installs. Files are saved as UTF-8 with Unix LF line terminators.

## Objective

To extract from `2018-10-01_BMsparql.json` only those records we believe to be based on descriptions written by Mary Dorothy George and published between 1935 and 1954 as Volumes 5 to 11 of the *[Catalogue of Political and Personal Satires Preserved in the Department of Prints and Drawings in the British Museum](https://en.wikipedia.org/wiki/Catalogue_of_Political_and_Personal_Satires_Preserved_in_the_Department_of_Prints_and_Drawings_in_the_British_Museum)*. This is because `2018-10-01_BMsparql.json` contains records for all satirical prints at the British Museum, some of which were not written by George, whether before or after the period in which she was working. Therefore if necessary, we would rather miss some of George’s descriptions (false negatives) than include non-George ones (false positives).

For each record, this process produces one line in a tab-separated file containing the fields: 

- ID (as number)
- Title
- Names
- Description
- Publication date of print
- Acquisition date of print

## About `2018-10-01_BMsparql.json`

`2018-10-01_BMsparql.json` was extracted from [https://public.researchspace.org/sparql](https://public.researchspace.org/sparql) using the [SPARQL](https://en.wikipedia.org/wiki/SPARQL) query `2018-10-01_BMsparl.txt`. This query looks for records associated with the 'Catalogue of Political and Personal Satires Preserved in the Department of Prints and Drawings in the British Museum', and returns results organised under 'id', 'titles', 'names', 'descs' and 'dates' headings. Where multiple data appears for a single record, these are seperated by `█`. Note that `█` is used as separator rather than `|`, because `|` appears in the 'descs' field.

## Process

1. Integrity checks

Count instances of each variable - 'id', 'titles', etc. - using Find/Count in a text editor ([UltraEdit](https://www.ultraedit.com/)). This confirms that the counts are equal for all variables: 23,933 (including single instances in head), so 23,932 records
Count ‘id’ values and flag any `>1`; run `perl countDistinctIds.pl 2018-10-01_BMsparql.json > 2018-10-01_BMsparql.json_distinctIDs.txt` which confirms 23,932 unique ID values. A search in this file for the string `[^\d\s\n]` confirms that the extracted ‘id’ numbers are comprised only of digits.

2. Conversion to tab separated format

This step converts our `.json` files into a tab-seperated `.tsv` file.

Run `perl json2tsv.pl 2018-10-01_BMsparql.json` which makes `2018-10-01_BMsparql.json.tsv`, in which each line contains 'id', 'titles', 'names', 'descs', 'date'.

`wc -l 2018-10-01_BMsparql.json.tsv` confirms 23932 records.

3. Selecting George’s descriptions by publication date and acquisition date

This step removes records from `2018-10-01_BMsparql.json.tsv` that are not based on George’s descriptions, with the intention of ensuring that the dataset contains no false positives. To arrive at a collection of records that ‘definitely’ based on descriptions written by George, we remove:

Records for prints published outside the period 1771-1832, the dates covered by volumes 5 to 11 of the *[Catalogue of Political and Personal Satires Preserved in the Department of Prints and Drawings in the British Museum](https://en.wikipedia.org/wiki/Catalogue_of_Political_and_Personal_Satires_Preserved_in_the_Department_of_Prints_and_Drawings_in_the_British_Museum)*. This includes records for which there is no publication date. Note that where there are multiple values in the ‘date’ field (seperated by `█`) we use the first/left-most value in the field.
Records for prints acquired by the British Museum after 1929. George worked on the *Catalogue* between 1930 and 1954. Whilst some prints that were in scope of the volumes of her *Catalogue* were acquired in this period, this step ensures the removal of false positives. Note that this information is extracted from the ‘titles’ field - e.g. `Le déserteur, paper (1868,0808.8230)` - where the first four digits after the left-bracket are the year of acquisition.

Run `perl filterByDates.pl g` which makes `dateFiltered_2018-10-01_BMsparql.json.tsv`, in which each record is placed under one of six headings, as follows, with number of records under each heading:

- No publication date: 27 
- No acquisition date: 1741
- Published too early (before 1771): 3367
- Published too late (after 1832): 332
- Acquired too late (after 1929): 5542
- Definitely George: 12,923

Manually copy the 12,923 rows under “Definitely George” into `definitelyGeorge.tsv`, where for each record we now have a line with six tab-separated fields: 'id', 'titles', 'names', 'description', 'publication date', 'acquisition date'.

*NB: The acquisition date field is extracted and added by filterByDates.pl.*

4. Removing duplicate descriptions

In some cases, the British Museum holds multiple impressions of the prints George described: each impression gets its own record with the same description. This step, therefore, looks for duplicate descriptions and removes them, because we only want our dataset to contain one example of each description.

To see some examples of this, run `perl analyseDuplicateDescriptionValues.pl definitelyGeorge.tsv` which makes `definitelyGeorge.tsv_analysisOfDuplicateDescriptions.txt`. This looks for duplicates in the ‘description’ field of `definitelyGeorge.tsv`, and filters for those duplicates that contain varients of the entry '(For description see other impression)': a description by [British Musuem Collections Online](https://www.britishmuseum.org/research/collection_online/search.aspx) in cases where there are multiple impressions/versions/reproductions of the same print in their collections. Results are as follows:

- Number of duplicated description strings matching `/for description/i`  =  991
- Number of duplicated description strings NOT matching `/for description/i`  =  207 (98 distinct descriptions: 1 occurring 6 times; 7 occurring 3 times; 90 occurring 2 times).
- Number of descriptions that match `/for description/i` but only occur once = 2371.

To remove duplicates, run `perl dedupeDescriptions.pl definitelyGeorge.tsv` which makes `definitelyGeorge_deduped.tsv`. `wc -l definitelyGeorge_deduped.tsv` confirms that - as expected - there are now 9452 records (`12,923 - 991 - 2371 - (207-98) = 9452`).

*NB: The ID field is changed from url to number by dedupeDescriptions.pl.*

5. Remove records where the descs field matches /Taschen Kalender/

In this step we remove records for illustrations to *Lichtenberg's Göttinger Taschen Kalender*. Records relating to these items meet the criteria in Step 3 because they were acquired before 1930 (1851 in most cases) and are dated after 1771 (‘1790-1795 (c)’ in [Collections Online](https://www.britishmuseum.org/research/collection_online/collection_object_details.aspx?objectId=1597036&partId=1&searchText=Taschen+Kalender&page=1). However, published descriptions of these prints appear in Volume 3 Part I of *[Catalogue of Political and Personal Satires Preserved in the Department of Prints and Drawings in the British Museum](https://en.wikipedia.org/wiki/Catalogue_of_Political_and_Personal_Satires_Preserved_in_the_Department_of_Prints_and_Drawings_in_the_British_Museum)*, written by Frederick George Stephens and published in 1877. This volume concerns satirical prints in the British Museum collection covering the period 1734-1750, but subsequent to the publication of this volume, the date of publication for these prints have been revised in the British Museum database. These then are false positives.

Run `perl removeTaschen.pl definitelyGeorge_deduped.tsv`
which makes `definitelyGeorge_deduped_noTaschen.tsv`. `wc -l definitelyGeorge_deduped_noTaschen.tsv`confirms that there are now 9400 records. Run `mv definitelyGeorge_deduped_noTaschen.tsv selectedRecords.tsv` to complete the process.  

## Final output: `selectedRecords.tsv`

The final output of this process - `selectedRecords.tsv` - is a tab-separated file that contains 9400 records. Each record (line) contains six fields:

- ID (the number from the url in the .json id field)
- Title
- Names
- Description
- Publication Date
- Acquisition Date

*NB. Fields other than Description can contain multiple values. We expect some records to have multiple different values in the Names field. We suspect that there are multiple identical values in other fields as per number of different values in the Names field. For now, we have only dealt with duplicate values in the Description field.*
