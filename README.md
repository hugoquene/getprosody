# getprosody
get prosodic measurements from Praat, and export those

## REQ
This script requires Praat (www.praat.org).
The script was developed in Praat version 6.4 (dated 15 Nov 2023). 

## AIM
This script performs various prosodic measurement on
a single selected Sound object, and exports the resulting values
to a text file (a single text file for each input audio file).  
It does that repeatedly for each file having a name matching the 
search pattern (hard coded in the script below) in the search 
directory (also hard coded in the script). 
The list of files matching the pattern is written as a Strings object 
to the working (output) directory.  

## CONTEXT
Longitudinal corpus of University College English Accents (LUCEA)

## CONTACT 
Hugo Quené, h.quene@uu.nl, www.hugoquene.nl

## LICENSE
GNU GPL 3.0 (https://www.gnu.org/licenses/gpl-3.0.en.html)

## VERSION

0.4	2023.12.06      added quantile values (0.20,0.25,0.50,0.75,0.80),
			  			changed order of exported values (median among quantiles),
              added number of voiced frames,
              using ideas from https://github.com/uzaymacar/simple-speech-features
              
0.3	2023.12.04		added `if(nvoiced>0) ... endif` chunk; 
 						multiple search paths/patterns in comments; 
 						removed LUCEA details

0.2	2023.11.30		for all Sounds in folder that match the given pattern

0.1	2023.11.30		first release, for single selected Sound

# CODEBOOK OF PROSODY DATA

The data (columns) are separated by tabs on a single row of output text. 
The suffix `$` indicates a character string. The colon and integer numbe indicates the number of decimal digits (Praat uses a default of 17 digits for real numbers). 

soundname$	name of Sound object

durtotal:3	duration of Sound object (s)

durtalk:3	duration of talking time (s)

talkchunks	number of talking chunks 

durnontalk:3	duration of nontalking time (s)

nontalkchunks	number of nontalking chunks

nvoiced		number of voiced frames in Pitch object (each frame 0.015 s)

f0meanHz:2	mean of f0 (Hz)

f0meanST:2	mean of f0 (semitones relative to 100 Hz)

f0minST:2	minimum of f0 (semitones re 100 Hz)

f0maxST:2	maximum of f0 (semitones re 100 Hz)

f0sdST:2	standard deviation of f0 (semitones re 100 Hz)

f0qn1ST:2	P20 (first quintile) of f0 (semitones re 100 Hz)

f0q1ST:2	P25 (first quartile) of f0 (semitones re 100 Hz)

f0q2ST:2	P50 (median, second quartile) of f0 (semitones re 100 Hz)

f0q3ST:2	P75 (third quartile) of f0 (semitones re 100 Hz)

f0qn4ST:2	P80 (fourth quintile) of f0 (semitones re 100 Hz)

intmean:2	mean of intensity (dB)

intmin:2	minimum of intensity (dB)

intmax:2	maximum intensity (dB)

intsd:2		standard deviation of intensity (dB)

intqn1:2	P20 (first quintile) of intensity (dB)

intq1:2		P25 (first quartile) of intensity (dB)

intq2:2		P50 (median, second quartile) of intensity (dB)

intq3:2		P75 (third quartile) of intensity (dB)

intqn4:2	P80 (fourth quintile) of intensity (dB)

ltas1:1		energy (dB) in Ltas band 1 (0-1600 Hz)

ltas2:1		energy (dB) in Ltas band 2 (1600-3200 Hz)

ltas3:1		energy (dB) in Ltas band 3 (3200-4800 Hz)

ltasslope:1	average energy in Ltas bands 2+3 minus energy in band 1

ltassd:1	standard deviation of energy (dB) across bands

nrsylls		number of syllables (vowel nuclei)

temp1:2		tempo (syl/s)

temp2:3		average syllable duration (s/syl)
