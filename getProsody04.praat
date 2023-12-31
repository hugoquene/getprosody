####################################################################
# getProsody.praat
####################################################################
#
# REQ:
# This script requires Praat (www.praat.org).
# The script was developed in Praat version 6.4 (dated 15 Nov 2023). 
# 
# AIM:
# This script performs various prosodic measurement on
# a single selected Sound object, and exports the resulting values
# to a text file (a single text file for each input audio file).  
# It does that repeatedly for each file having a name matching the 
# search pattern (hard coded in the script below) in the search 
# directory (also hard coded in the script). 
# The list of files matching the pattern is written as a Strings object 
# to the working (output) directory.  
# 
# CONTEXT:
# Longitudinal corpus of University College English Accents (LUCEA)
#
# CONTACT: 
# Hugo Quené, h.quene@uu.nl, www.hugoquene.nl
# 
# LICENSE: 
# GNU GPL 3.0 (https://www.gnu.org/licenses/gpl-3.0.en.html)
# 
# VERSION:
# 0.4	2023.12.06      added quantile values (0.20,0.25,0.50,0.75,0.80),
#						changed order of exported values (median among quantiles), 
#                       added number of voiced frames,
# 						using ideas from https://github.com/uzaymacar/simple-speech-features
# 0.3	2023.12.04		added `if(nvoiced>0) ... endif` chunk; 
# 						multiple search paths/patterns in comments; 
# 						removed LUCEA details
# 0.2	2023.11.30		for all Sounds in folder that match the given pattern
# 0.1	2023.11.30		first release, for single selected Sound
# 
####################################################################
#
# EXPORTED PROSODY DATA (tab separated):
# soundname$, 
# 'durtotal:3', 'durtalk:3', talkchunks, 'durnontalk:3', nontalkchunks,
# 'nvoiced', 'f0meanHz:2', 'f0meanST:2', 'f0minST:2', 'f0maxST:2', 'f0sdST:2', 
# 'f0qn1ST:2', 'f0q1ST:2', 'f0q2ST:2', 'f0q3ST:2', 'f0qn4ST:2', 
# 'intmean:2', 'intmin:2', 'intmax:2', 'intsd:2', 
# 'intqn1:2', 'intq1:2', 'intq2:2', 'intq3:2', 'intqn4:2', 
# 'ltas1:1', 'ltas2:1', 'ltas3:1', 'ltasslope:1', 'ltassd:1',
# 'nrsylls', 'temp1:2' [syl/s], 'temp2:3' [s/syl]
#
# The output files (one for each input sound file) can be aggregated in a 
# Terminal shell into a single datafile:
# shell> cat *prosodydata.txt > allprosodydata.txt 
# This concatenated file can then be read into R:
# R> data <- read.table(file="allprosodydata.txt", header=FALSE)
# R> dimnames(data)[[2]] <- c(
# 	"soundname", 
# 	"durtotal", "durtalk", "talkchunks", "durnontalk", "nontalkchunks",
#	"nvoiced", "f0meanHz", "f0meanST", "f0minST", "f0maxST", "f0sdST",
#   "f0qn1ST", "f0q1ST", "f0q2ST", "f0q3ST", "f0qn4ST", 
#	"intmean", "intmin", "intmax", "intsd",
#   "intqn1", "intq1", "intq2", "intq3", "intqn4", 
#	"ltas1", "ltas2", "ltas3", "ltasslope", "ltassd",
#	"nrsylls", "tempo", "asd" )
# 
####################################################################
# 
# Note that the search path (mypath$) and the search pattern (mypattern$)
# for the input audio files are hard-coded in the script below. 
# These two string arguments for this script could be obtained
# interactively (see Praat help on Scripting), but for my purposes 
# hard-coded paths are fine. 
# Similarly, various analysis parameters are hard-coded in the script. 
# 
####################################################################

# clear Praat Info window
clearinfo

# define search path and search pattern 
# see Praat help, Scripting, §6.4, sub Folder listings

## for majority of files
# mypath$ = "/Users/hugo/surfdrive/onderzoek/LUCEA/informal"
## for some additional files
mypath$ = "/Users/hugo/surfdrive/onderzoek/LUCEA/MaxWitt/trimmed_recordings/R5_nonD-nonE/informal"
# MORE GENERAL PATTERN... matching many files
# mypattern$ = "s-1-informal.wav"
## MORE NARROW PATTERN FOR TESTING AND DEBUGGING... matching few files
# mypattern$ = "s041f*-informal.wav"
mypattern$ = "s*-1_informal.wav" ; replace by "s*-1-informal.wav" for more audio files

####################################################################
# obtain list of matching input audio files

# infiles$# = fileNames$# (mypath$ + "/" + mypattern$)
# infiles$ = Create Strings as file list... (mypath$ + "/" + mypattern$)
Create Strings as file list... infilelist 'mypath$'/'mypattern$'
numberOfFiles = Get number of strings
listid = selected("Strings") ; for later reference
# writeInfo: "starting to process ",numberOfFiles," sound files..."
appendInfoLine: "starting to process ", 'numberOfFiles', " sound files" 

####################################################################
# start working on each of the matching input audio files in the list

for ifile to 'numberOfFiles'
# begin `for` loop over matching input sound files
   select 'listid'
   fileName$ = Get string... 'ifile'
#   Read from file: mypath$ + "/" + infiles$# [ifile]
   Read from file... 'mypath$'/'fileName$'

# without indentation of subsequent script lines, proceed with this input sound file

# at this point, a single sound must be selected, check
if ( numberOfSelected("Sound") != 1 )
	exitScript: Select a single Sound object.
endif
# proceed

# use object ID, not object name, see Praat help
soundname$ = selected$("Sound")
soundid = selected("Sound")

# report to Info window
appendInfoLine: ""
appendInfoLine: "[",ifile,"] ", "processing ",soundname$," ... "
# output filename
fn$ = soundname$+"-prosodydata.txt"

writeFile: fn$, soundname$, tab$

#### Duration etc
durtotal = Get total duration
# appendInfoLine: tab$, durtotal
To TextGrid (speech activity): 0, 0.3, 0.1, 70, 4800, -10, -35, 0.1, 0.1, "nonspeech", "speech"
tg1id = selected("TextGrid")
durtalk = Get total duration of intervals where: 1, "is equal to", "speech" ; total speech time
talkchunks = Count intervals where: 1, "is equal to", "speech"
durnontalk = Get total duration of intervals where: 1, "is equal to", "nonspeech" ; total nonspeech time
nontalkchunks = Count intervals where: 1, "is equal to", "nonspeech"
appendFile: fn$, 'durtotal:4', tab$, 'durtalk:4', tab$, talkchunks, tab$, 'durnontalk:4', tab$, nontalkchunks, tab$
# from these data, we can compute speaking rate and articulation rate, 
# as well as (approx) pause time, nr of pauses, and frequency of pauses

#### Pitch
selectObject: 'soundid'
To Pitch (filtered ac): 0, 50, 400, 15, "yes", 0.03, 0.09, 0.5, 0.055, 0.35, 0.14
# Praat uses a time step of 0.75/pitch floor, here 0.75/50 = 0.015 sec
pitch1id = selected("Pitch") ; for later reference
f0meanHz = Get mean: 0, 0, "Hertz"
f0meanST = Get mean: 0, 0, "semitones re 100 Hz"
f0minST = Get minimum: 0, 0, "semitones re 100 Hz", "parabolic"
f0maxST = Get maximum: 0, 0, "semitones re 100 Hz", "parabolic"
f0sdST = Get standard deviation: 0, 0, "semitones"
f0qn1ST = Get quantile: 0, 0, 0.20, "semitones re 100 Hz"
f0q1ST = Get quantile: 0, 0, 0.25, "semitones re 100 Hz"
f0q2ST = Get quantile: 0, 0, 0.50, "semitones re 100 Hz" ;median
f0q3ST = Get quantile: 0, 0, 0.75, "semitones re 100 Hz"
f0qn4ST = Get quantile: 0, 0, 0.80, "semitones re 100 Hz"

nvoiced = Count voiced frames
if ( nvoiced>0 ) 
  appendFile: fn$, 'nvoiced', tab$, 'f0meanHz:1', tab$, 'f0meanST:2', tab$, 'f0minST:2', tab$, 'f0maxST:2', tab$, 'f0sdST:2', tab$
  appendFile: fn$, 'f0qn1ST:2', tab$, 'f0q1ST:2', tab$, 'f0q2ST:2', tab$, 'f0q3ST:2', tab$, 'f0qn4ST:2', tab$
else
  appendFile: fn$, 'nvoiced', tab$, "NA", tab$, "NA", tab$, "NA", tab$, "NA", tab$, "NA", tab$
  appendFile: fn$, "NA", tab$, "NA", tab$, "NA", tab$, "NA", tab$, "NA", tab$
  appendInfoLine: "[",ifile,"] ", soundname$, " -- no voiced frames in Pitch; NAs exported ! "
endif

#### Intensity
selectObject: 'soundid'
To Intensity: 75, 0, "yes"
int1id = selected("Intensity") ; for later reference
intmean = Get mean: 0, 0, "dB"
intmin = Get minimum: 0, 0, "cubic"
intmax = Get maximum: 0, 0, "cubic"
intsd = Get standard deviation: 0, 0
intqn1 = Get quantile: 0, 0, 0.20
intq1 = Get quantile: 0, 0, 0.25
intq2 = Get quantile: 0, 0, 0.5 ; median 
intq3 = Get quantile: 0, 0, 0.75 
intqn4 = Get quantile: 0, 0, 0.80
appendFile: fn$, 'intmean:2', tab$, 'intmin:2', tab$, 'intmax:2', tab$, 'intsd:2', tab$
appendFile: fn$, 'intqn1:2', tab$, 'intq1:2', tab$, 'intq2:2', tab$, 'intq3:2', tab$, 'intqn4:2', tab$

#### Ltas, for spectral slope, related to speaking effort
selectObject: 'soundid'
To Ltas: 1600 ; Hz width of each bin of Ltas
ltasid = selected("Ltas") ; for later reference
ltas1 = Get value in bin: 1 ; centered at  800 Hz
ltas2 = Get value in bin: 2 ; centered at 2400 Hz
ltas3 = Get value in bin: 3 ; centered at 4000 Hz
# Report spectral trend: 50, 4800, "logarithmic", "robust"
ltasslope = ((ltas2+ltas3)/2) - ltas1 ; neg slope of mean(bin2,bin3)-bin1 
ltassd = Get standard deviation: 0, 4800, "dB"
# ltasq1 = Get quantile: 0, 0, 0.25 
# ltasq3 = Get quantile: 0, 0, 0.75 
appendFile: fn$, 'ltas1:2', tab$, 'ltas2:2', tab$, 'ltas3:2', tab$, 'ltasslope:2', tab$, 'ltassd:2', tab$
# appendFile: fn$, 'ltasq1:2', tab$, 'ltasq3:2', tab$

#### Tempo
# The following part (intended lines) is adapted from 
# the script `tempo.praat` in the same folder. 
# The core analyses are identical to those in the script
# `tempobyinterval.praat` at https://github.com/hugoquene/tempo
# The script requires two arguments:
#   iglevel: ignorance level, ignore peaks that are less than this amount, in dB, above median intensity
iglevel = 0
#   mindip: minimum dip, in dB, between two peaks in intensity contour
mindip = 2

selectObject: 'soundid'
# added one-pole filter, C=1000 Hz, 
# to emphasize lower frequencies, i.e. vowel energy
Filter (one formant): 1000, 250
soundLPid = selected("Sound") ; for later reference

   originaldur = Get total duration
   # allow non-zero starting time
   bt = Get starting time

   # Use intensity to get threshold
   To Intensity... 50 0 yes
   int2id = selected("Intensity")
   start = Get time from frame number... 1
   nframes = Get number of frames
   end = Get time from frame number... 'nframes'

   # estimate noise floor
   minint = Get minimum... 0 0 Parabolic
   # estimate noise max
   maxint = Get maximum... 0 0 Parabolic
   #get median of Intensity: limits influence of high peaks
   medint = Get quantile... 0 0 0.5

   # estimate Intensity threshold
   threshold = medint + iglevel
   if threshold < minint
       threshold = minint
   endif

   Down to Matrix
   matid = selected("Matrix")
   # Convert intensity to sound, hack suggested by PB
   To Sound (slice)... 1
   sndintid = selected("Sound")

   # HQ: use total duration, not end time, to find out duration of intdur
   #     in order to allow nonzero starting times!!
   intdur = Get total duration
   intmax = Get maximum... 0 0 Parabolic

   # estimate peak positions (all peaks)
   # presumably this should yield extremes in intensity contour
   To PointProcess (extrema)... Left yes no Sinc70
   ppid = selected("PointProcess")

   numpeaks = Get number of points

   # fill array with time points
   for i from 1 to numpeaks
       t'i' = Get time from index... 'i'
   endfor

   # fill array with intensity values matching those in the PointProcess
   select 'sndintid'
   peakcount = 0
   for i from 1 to numpeaks
       value = Get value at time... t'i' Cubic
       if value > threshold
             peakcount += 1
             int'peakcount' = value
             timepeaks'peakcount' = t'i'
       endif
   endfor

   # fill array with valid peaks: only intensity values if preceding
   # dip in intensity is greater than mindip
   # select Intensity 'obj$'
   select 'int2id'
   validpeakcount = 0
   precedingtime = timepeaks1
   precedingint = int1
   for p to peakcount-1
      following = p + 1
      followingtime = timepeaks'following'
      dip = Get minimum... 'precedingtime' 'followingtime' None
      diffint = abs(precedingint - dip)
      if diffint > mindip
         validpeakcount += 1
         validtime'validpeakcount' = timepeaks'p'
         precedingtime = timepeaks'following'
         precedingint = Get value at time... timepeaks'following' Cubic
      endif
   endfor

   # Look for only voiced parts
   # select Sound 'obj$'
   select 'soundid' 
   To Pitch (ac)... 0.02 30 4 no 0.03 0.25 0.01 0.35 0.25 450
   # keep track of id of Pitch
   pitch2id = selected("Pitch")

   voicedcount = 0
   for i from 1 to validpeakcount
      querytime = validtime'i'
      value = Get value at time... 'querytime' Hertz Linear
      if value <> undefined
         voicedcount = voicedcount + 1
         voicedpeak'voicedcount' = validtime'i'
      endif
   endfor
  
   # calculate time correction due to shift in time for Sound object versus
   # intensity object
   timecorrection = originaldur/intdur

   # Make a new TextGrid, with a single (point) tier, containing syllable nuclei. 
   select 'soundid'
   To TextGrid... "syllables" syllables
   tg2id = selected("TextGrid")
   for i from 1 to voicedcount
   # Insert timepoint; the label is sequential number (i) of the nucleus.
       position = voicedpeak'i' * timecorrection
       Insert point... 1 position 'i'
   endfor
   nrsylls = Get number of points... 1

   select 'int2id'
   plus 'soundLPid' ; LP filtered sound
   plus 'matid'
   plus 'sndintid'
   plus 'ppid'
   plus 'pitch2id'
   # are you sure?
   Remove

   select 'tg2id'
   # save tg2 with syllable nuclei in separate text file
   Write to text file... 'soundname$'.syllables.TextGrid
   Remove
 
   temp1 = 'nrsylls'/'originaldur'
   temp2 = 'originaldur'/'nrsylls'

# add newline$
appendFile: fn$, 'nrsylls', tab$, 'temp1:2', tab$, 'temp2:3', newline$

# end of tempo part in script

# report in Info window
appendInfo: "prosody data written to ", fn$, " ... "

# cleanup
select 'tg1id'
plus 'pitch1id'
plus 'int1id'
plus 'ltasid'
# are you sure?
Remove
# The input sound file is not removed but retained in Praat object list.
# That may lead to memory problems, but it avoids unintentional removal of sound data. 
select 'soundid' ; for easier workflow
# are you sure? NO, keep the current input sound object
# Remove
appendInfoLine: "done"

endfor
# end `for` loop over matching input sound files

####################################################################

# report to Info window
appendInfoLine: newline$, 'numberOfFiles', " sound files processed" 

# save the list of files processed, and keep the Strings object
select 'listid'
infilelistname$ = "infile" + date_iso$ () + ".Strings.txt"
Save as short text file... 'infilelistname$'

# finish