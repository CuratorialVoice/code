# Preparing BMSat for analysis

This document describes the process to prepare text data for corpus linguistic analysis, as of 27 Jan 2019. See [Selection of BMSat Records](https://github.com/CuratorialVoice/code/blob/master/selection-of-records/readme.md) for background analysis.

## Objective

- To preprocess the text data for subsequent corpus linguistic analysis, specifically:
- Remove extraneous text, characters and whitespace.
- Replace bracketed text with `*BRACKETED*` (because brackets contain a mix of things, not all of which reflect George’s curatorial voice).
- Replace transcribed text, i.e. text appearing in quotation marks, labels, or titles, with `*TRANSCRIBED*` (because this is text that appears in prints and is not George’s curatorial voice).

## Notes

- Output is a text file with the description from one record on each line.
- We don’t retain metadata (e.g. ID, Title, Names, Publication Date, Acquisiton Date) for the corpus linguistic analysis.
- We insert `*BRACKETED*` and `*TRANSCRIBED*` so we can look at patterning around bracketed and transcribed text.
- Strictly, `*TRANSCRIBED*` also includes print titles and other text that appears in quotation marks but is not transcribed from the print itself.
  - e.g. in `85948	Six stages of mending a face, paper (1876,1014.10)█Six stages of mending a face, paper (1876,1014.10)	Thomas Rowlandson█S W Fores	A companion print to BMSat 8175. The head and shoulders of Lady Archer at different stages of her toilet. In the first (right), wearing a night-cap, with unsightly pendent breasts, she looks up to the left, tears falling from an empty eye-socket, her gaping mouth showing toothless jaws. In the next she fits in an eye, in the third she places a wig on her head, in the fourth (below on the right) she fits in a set of false teeth; in the next she applies rouge to her cheeks with a hare's foot, holding a mirror. In the last (left) she appears a pretty young woman, holding a mask in her hand. In the last two stages her arms, which were skinny and muscular, have become smooth and rounded and her breasts have been covered with the gauze drapery then fashionable. For Lady Archer (b. 1741) see BMSat 5879, &c, and index. \r\r\nCf. 'Epigram on Lady A------'.\r\r\n\r\r\n'Antient Phyllis has young graces, \r\r\n'Tis a strange thing, but a true one;\r\r\nShall I tell you how ?\r\r\nShe herself makes her own faces, \r\r\nAnd each morning wears a new one; \r\r\nWhere's the wonder now?\r\r\n'Asylum for Fugitive Pieces',' 2nd ed., iii. 1795, p. 106. \r\r\n\r\r\nFalse teeth were then regarded as illegitimate aids to beauty: \r\r\n\r\r\n'Can i'vry teeth at sixty-one, \r\r\nTho bought of March, be deem'd thy own, \r\r\nDisplay'd in lucid rows ?'\r\r\n\r\r\n'Excursions to Parnassus ...', 1787, p. 53. \r\r\nGrego, 'Rowlandson', i. 308. 29 May 1792\r\r\nHand-coloured etching	1792█1792	1876`
- The replaced text is kept in separate files for inspection and analysis in its own right.

## Process
The input is `selectedRecords.tsv` (output of the [Selection of BMSat Records](https://github.com/CuratorialVoice/code/blob/master/selection-of-records/readme.md) process), where one field is the description text extracted from the [ResearchSpace SPARQL endpoint](https://public.researchspace.org/sparql) using the query [2018-10-01_BMsparl.txt](https://github.com/CuratorialVoice/code/blob/master/BMsparql/2018-10-01_BMsparl.txt).

1. Select description text field

Run `perl getDescText.pl selectedRecords.tsv`. This selects the description text field from each record in the .tsv file, and then:

- Replaces all instances of `\r`, `\n` and `\t` with `‘ ‘`, i.e. a single space. These escapted characters seem to be remnants of text layout (new lines and tabs). We see no value in keeping them for the corpus linguistic analysis.
- Removes the \ from all instances of \". This is the only other frequently escaped character and does not correspond to text in George’s original published descriptions.
- Removes all text after the final full-stop. This is intended to remove trailing date and technique information. We do this because we observe that, in the majority of descriptions, after the final full-stop there is “standard” information about the date of the print and its technique/material. If kept this might skew some of the corpus linguistic analysis.
- Remove instances of ‘c.’ that are left by the previous step at the end of the description text. These arise when the date is preceded by ‘c.’.
- Remove multiple whitespace.

Outputs are:

- `descriptionText_selectedRecords.txt`.  This contains the 9400 processed descriptions, one per line, to be passed to the next step.
- `cutAfterFinalFullStop_selectedRecords.txt`.  This contains all instances of text that was cut after the final full-stop in descriptions, i.e. what we expect to be date and technique/material information. A skim of this file mostly confirms this, although there are some examples of descriptive text which are lost to the corpus linguistic analysis. There are 9039 lines in this file from 9400 descriptions. We think 336 descriptions have a full-stop at the very end of the line, e.g. after the date and technique information, so nothing will be cut from them (this was counted with `/\.\t[^\t]*\t[^\t]*$/` in `selectedRecords.tsv`). We speculate that the remaining 25 descriptions do not contain any full-stop. We are happy with this result as - following from the rationale used with [Selection of BMSat Records](https://github.com/CuratorialVoice/code/blob/master/selection-of-records/readme.md) - we would rather remove some of George’s descriptions (false negatives) than include non-George ones (false positives).

2. Replace bracketed text

Run ‘perl replaceBracketedText.pl descriptionText_selectedRecords.txt’. This aims to replace all bracketed text (text occurring in `()` and `[]`) with the string `*BRACKETED*`. This also removes the brackets themselves. Note, this does not deal with nested brackets.

Outputs are:

- `bracketsReplaced_selectedRecords.txt`. This contains the descriptions with bracketed text replaced with `*BRACKETED*`.
- `roundBracketText_selectedRecords.txt`. This contains 22990 instances of (...).
- `squareBracketText_selectedRecords.txt`. This contains 9078 instances of [...].

3. Replace transcribed text

Run ‘perl replaceTranscribedText.pl bracketsReplaced_selectedRecords.txt’. This aims to identify all strings within quote marks. The purpose is to be able to remove text which is not George’s voice: e.g. text transcribed from prints (speech bubbles, signs, etc.) and titles. However it may be that she also uses scare quotes in places e.g. to ‘bribe her’, she ‘steers her own course’, and other uses of quote marks: e.g. `216752	Remigration, paper (1865,1111.426)█Remigration, paper (1865,1111.426)	George Cruikshank█William Hone	See No. 13790. The Queen steers a small boat, rowed by a sailor, through huge waves towards the cliffs of Dover. A whale with the head of George IV swims towards her spouting great columns of water (as in No. 11877) at the boat, while four smaller creatures swim menacingly towards it, with the heads of Sidmouth (left), Liverpool, with a spiked profile like a narwhal, Castlereagh, and Eldon. Despite attempts to 'bribe' her (see No. 13730, &c.), she 'steers her own course'.\r\r\nAugust 1820\r\r\nWood-engraved illustration to a letterpress pamphlet	1820█1820	1865`

We are happy with this result as we would rather remove some of George’s descriptions (false negatives) than include non-George ones (false positives). The most common uses of word initial and final apostrophes are recognised, e.g. ‘em, tho’, musicians’, which were identified iteratively with `charsAroundQuotes.pl`. This does not deal with nested quote marks. See code comments for more details of method.

Outputs are:

- `quoteMarks_bracketsReplaced_selectedRecords.txt`. This contains the descriptions with quote marks replaced with `OPEN>>` and `<<CLOSE`. This file is for inspecting how quote marks are identified and how they are distributed. There are 472 instances of `"` remaining in this file: it seems these come from instances of `'"` (i.e. single quote followed by double quote).
- `transcribedReplaced_bracketsReplaced_selectedRecords.txt`. This contains descriptions with text between quote marks replaced with `*TRANSCRIBED*`. This includes 1222 instances of stray `<<CLOSE`’s.
- `textBetweenQuoteMarks_bracketsReplaced_selectedRecords.txt`. This contains 42,079 instances of text appearing between a pair of quote marks that have been replaced with `*TRANSCRIBED*` in the descriptions. This includes some descriptive text.
- `textAfterOpenNoClose_bracketsReplaced_selectedRecords.txt`. This contains text appearing after an opening quote mark for which there was no close, so taken until end of line. This includes some descriptive text.

4. Remove duplicates

The file `transcribedReplaced_bracketsReplaced_selectedRecords.txt`was opened in [UltraEdit](https://www.ultraedit.com/). This was sorted with the “remove duplicates” option selected. This reduced the 9400 descriptions to 9330 descriptions that were saved as `CurV-corpus-27Jan2019.txt`.This is the file that will be the starting point for corpus linguistic analysis.
