# getprosody
get prosodic measurements from Praat, and export those

## REQ:
This script requires Praat (www.praat.org).
The script was developed in Praat version 6.4 (dated 15 Nov 2023). 

## AIM:
This script performs various prosodic measurement on
a single selected Sound object, and exports the resulting values
to a text file (a single text file for each input audio file).  
It does that repeatedly for each file having a name matching the 
search pattern (hard coded in the script below) in the search 
directory (also hard coded in the script). 
The list of files matching the pattern is written as a Strings object 
to the working (output) directory.  

## CONTEXT:
Longitudinal corpus of University College English Accents (LUCEA)

## CONTACT: 
Hugo Quené, h.quene@uu.nl, www.hugoquene.nl

## LICENSE: 
GNU GPL 3.0 (https://www.gnu.org/licenses/gpl-3.0.en.html)

## VERSION:

0.4	2023.12.06      added quantile values (0.20,0.25,0.50,0.75,0.80),
			  			changed order of exported values (median among quantiles),
              added number of voiced frames,
              using ideas from https://github.com/uzaymacar/simple-speech-features
              
0.3	2023.12.04		added `if(nvoiced>0) ... endif` chunk; 
 						multiple search paths/patterns in comments; 
 						removed LUCEA details

0.2	2023.11.30		for all Sounds in folder that match the given pattern

0.1	2023.11.30		first release, for single selected Sound

# EXPORTED PROSODY DATA (tab separated):
soundname$, 
'durtotal:3', 'durtalk:3', talkchunks, 'durnontalk:3', nontalkchunks,
'nvoiced', 'f0meanHz:2', 'f0meanST:2', 'f0minST:2', 'f0maxST:2', 'f0sdST:2', 
'f0qn1ST:2', 'f0q1ST:2', 'f0q2ST:2', 'f0q3ST:2', 'f0qn4ST:2', 
'intmean:2', 'intmin:2', 'intmax:2', 'intsd:2', 
'intqn1:2', 'intq1:2', 'intq2:2', 'intq3:2', 'intqn4:2', 
'ltas1:1', 'ltas2:1', 'ltas3:1', 'ltasslope:1', 'ltassd:1',
'nrsylls', 'temp1:2' [syl/s], 'temp2:3' [s/syl]
