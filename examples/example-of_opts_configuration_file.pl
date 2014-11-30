# "This is a template configuration file for OPT (version 0.7).
# Copyright 2008-2014 by Gian Luca Brunetti and Politecnico di Milano.  
# Gian Luca Brunetti, Politecnico di Milano,  DAStU Department, Milan, Italy.
# gianluca.brunetti@polimi.it.
# OPT is a program built to manage parametric explorations through the use of the ESP-r energy simulation platform.
# OPT COMES WITH ABSOLUTELY NO WARRANTY.
 

####################### HERE FOLLOW CONFIGURATION DATA #####################

$exeonfiles = 
"y"
; # say “y” if you want OPT's work be executed on files and directories. As an alternative, you may want to say “no” because you may want to output to a shell file that you can study and make executable afterwards.

$generatechance = "n";
# IF "n", THE SEARCH STRUCTURES ARE TAKEN FROM $chancefile and @casefile, 
# WHERE THEY HAVE TO DESCRIBED EXPLICITLY.
# IF "y", SEARCH STRUCTURES ARE GENERATED FROM @chanceseed, @caseseed AND @chancedata.

$dimchance =
3;
# THIS IS USED IF $generatechance IS "y". IT TELLS TO THE PROGRAM AMONG HOW MANY RANDOM TRIALS THE COMBINATION 
# THAT WILL END UO BEING USED HAS TO BE SELECTED.

#@caseseed =
#( 
#[ 
#[0, 4], [2, 4] , [4, 4],
#]
#,
#[
#[0, 2], [1, 2]
#]
#) ;  
# BETWEEN SQUARE BRACKETS ARE THE BLOCKS OF THE BLOCK COORDINATE SEARCH. THE FIRST ITEM IN 
# EACH SQUARE BRACKET IS THE POSITION OF THE FIRST ITEM IN THE ACTIVE BLOCK (INDEX FROM 0). 
# THE SECOND ITEM IS THE DIMENSION OF THE ACTIVE BLOCK, IN TERMS OF NUMBER OF PARAMETERS.



#@chanceseed = 
#(
#[
#[1, 2, 3, 4, 5], [1, 2, 3, 4, 5] , [1, 2, 3, 4, 5]
#]
#, 
#[
#[1, 2, 3], [1, 2, 3]
#]
#);
# THIS IS THE ORDER OR PARAMETERS AT EACH SEARCH SWEEP. THERE IS A POINT TO POINT CORRESPONDENCE WITH @chanceseed.
# EACH OF THIS SERIES IS REFERRED TO THE CORRESPONDING BLOCK IN THE SAME POSITION OF THE $casefile.
# THESE SERIES SPECIFY THE ORDER OF PARAMETERS TO BE DECOMPOSED. THE DECOMPOSITION IS THAT SPECIFIED 
# IN $caseseed. 

#@sweeps = ( [ [1, 2, 3, 4], [3, 4, 5, 1], [5, 1, 2, 3] ], [ [1, 2], [2, 3] ] );
#@sweeps = ( [ [1, 2, 3, 4], [3, 4, 5, 1], [5, 1, 2, 3] ] );
@sweeps = ( [ [1, 2], [2, 3] ] );
# THIS IS THE BLOCK SEARCH STRUCTURE DECLARED EXPLICITLY AS AN ALTERNATIVE TO USING @chanceseed AND @caseseed.
# IF BOTH @sweeps AND THOSE TWO VARIABLES ARE SPECIFIED, 
# @sweeps IS OVERRIDDEN ON THE BASIS OF WHAT IS SPECIFIED IN @chanceseed AND @caseseed.

@chancedata = 
([4, 2, 1]); 
# HERE: 1) BLOCK LENGTH OF BLOCKS TO ADD; 2) OVERLAP BETWEEN BLOCKS; 3) NUMBER OF SWEEPS TO ADD.

#@varinumbers = ( { 1 => '3', 2 => '3', 3 => '3', 4 => '3', 5 => '3' }, { 1 => '3', 2 => '3', 3 => '3' } );
#@varinumbers = ( { 1 => '3', 2 => '3', 3 => '3', 4 => '3', 5 => '3' } );
@varinumbers = ( { 1 => '3', 2 => '3', 3 => '3' } );
# IN THIS ARRAY OF HASHES (DICTIONARIES) THE NUMBER OF ITERATIONS FOR EACH VARIABLES ARE SPECIFIED.

#@miditers = ( );
@miditers = ( { 1 => '1', 3 => '3'} );
# IN THIS ARRAY OF HASHES (DICTIONARIES) THE BASE ITERATION FOR EACH VARIABLES ARE SPECIFIED. 
#IF IT IS NOT SPECIFIED, IT DEFAULTS TO THE MIDDLE ITERATION FOR THAT VARIABLE.

$file = 
"amoeba";  
# Write here the root model directory.

$filenew = "$file"."_"; # DON'T EDIT THIS

%dowhat = ( # This variables tells to the program what to do.
morph => "n", 
# create cases for simulation?

simulate => "n", 
# simulate AND retrieve? THIS MUST BE "y" TO PERFORM BLOCK SEARCH.

retrieve => "n",  
# retrieve data? THIS MUST BE "y" TO PERFORM BLOCK SEARCH.

eraseres => "n", 
# erase .res and .fl files as they are created or leave them as traces?

report => "n", 
# report? (UNTESTED SINCE EARLY VERSIONS.)

mergeresults => "n", 
# merge reports? THIS MUST BE "y" FOR BLOCK SEARCH.

substitutenames => "n", 
# substitute names (convert) in non-filtered reports? (UNTESTED SINCE EARLY VERSIONS.)

filterconverted => "n", 
# filter already converted reports? (UNTESTED SINCE EARLY VERSIONS.)

make3dtable => "n",
# make table to be plotted in 3D? (UNTESTED SINCE EARLY VERSIONS.)

takeoptima => "n"
); 

# 11) THIS MUST BE "y" TO PERFORM BLOCK SEARCH. It checks if it is possible to launch a block search, and if it is does it.

$preventsim = 
"n"
;# prevent simulation, just retrieve

$mypath = 
"/home/luca/Sim-OPT"
;# path of the directory in which you are going to work

$fileconfig=(
"cells.cfg"
); # name of the configuration file of the model, which will reside in the "./cfg/" directory in your model's directory.

$outfile = "$mypath/$file-$fileconfig-feedback.txt"
; # Write here the name of the files in which reports will be printed. This may be useful to debug the program.  But in order to do this, you'll have to mess up with the source code to specify what you want to be printed.

$outfilewrite = "$mypath/$file-$fileconfig-outfile.csv"
;

$toshell = 
"$mypath/$file-$fileconfig-toshell.txt"
; # name of the files into which the output to the shell will be printed. This may be useful to check the inner working of the program, or to postpone the operations with ESP-r.  In that case, the printed has to be made executable to be launched from the shell afterward. 

my $reportfile = 
"$mypath/$file-$fileconfig-report.txt"
;

$simnetwork = 
"y"; 
# is there a mass/flow network? This information regards the simulation settings.

@themereports = 
([ "loads", "tempsstats"], [ "loads", "tempsstats"]); 
# possibilities: "loads", "temps" , "comfort", "tempsstats" ######### General themes regarding the simulation.  This piece of information go to compose the result name files.

@simtitles = 
("mar1-apr30", "mar1-apr30" ); 
# write here the name of the time periods will be taken into account in the simulations.

@reporttitles = 
( ["march1-31", "march1-31"], ["april1-30", "april1-30"] ); 
# THESE ARE THE PERIODS TO BE REPORTED. THERE IS A POINT TO POINT CORRENSPONDENCE WITH @simtitles

@simdata = (["1 3", "30 4", "20", "1"],["1 3", "30 4", "20", "1"]); 
# Here put the data this way: "starting-month_1 starting-day_1", "ending-month_1 ending-day_1", "start-up-period-duration_1", "time/steps-hour_1", "starting-month_2"starting-day_2", "ending-month_2 ending-day_2", "start-up-period-duration_2", "time/steps-hour_2", ..., "starting-month_n starting-day_n", "ending-month_n ending-day_n", "start-up-period-duration_n", "time/steps-hour_n"
# THESE ARE THE PERIODS TO BE REPORTED. THERE IS A POINT TO POINT CORRENSPONDENCE WITH @simdata


@retrievedata = ( 
[["1 3 1", "31 3 24", "1"] , ["1 3 1", "31 3 24", "1"]], [["1 4 1", "30 4 24", "1"] , ["1 4 1", "30 4 24", "1"]]
); 
# start data to retrieve for temps; end data to retrieve for temps.
# THESE ARE THE PERIODS TO BE REPORTED. THERE IS A POINT TO POINT CORRENSPONDENCE WITH @reporttiles# THESE ARE THE PERIODS TO BE REPORTED. THERE IS A POINT TO POINT CORRENSPONDENCE WITH @simdata# THESE ARE THE PERIODS TO BE REPORTED. THERE IS A POINT TO POINT CORRENSPONDENCE WITH @simdata

@keepcolumns = ( [1, 6], [16, 18] ); 
# COLUMNS TO KEEP FROM THE FILE OF RESULTS. THEY ARE WRITTEN IN PAIRS. 
# THE FIRST ITEM OF EACH PAIR IS THE OBJECTIVE FUNCTION NAME AND THE SECOND IS THE OBJECTIVE FUNCTION.

@weights = ( 
0.5, 0.5
); 
# RATIO OF EACH OBJECTIVE FUNCTION, OVER THE TOTAL OF 1.

@weightsaim = (
1, -1
); 
# THERE IS A POINT TO POINT CORRENSPONDENCE WITH THE ABOVE ARRAY. A (-1) VALUE TELLS THE PROGRAM THAT THE OBJECTIVE FOR THAT OBJECTIVE FUNCTION IS MINIMIZATION. 
# A (+1) VALUE TELLS THE PROGRAM THAT THE OBJECTIVE IS MAXIMIZATION. 

@varthemes_report = (
"something", "something_else1","something_else2", "something_else3"
); ########## Definitions that are going to substitute the variable numbers in the tables. (THIS OPERATION MAY OFTEN BE UNUSED.)

@varthemes_variations = (
[-1, 1], [-1, 1],[-36, 36] , [-30, 30],[-30, 30],[-30, 30],[-30, 30], [-1, 1]
); ######### Minimum and maximum values regarding the variables, in the same order above. (THIS OPERATION MAY OFTEN BE UNUSED.)

@varthemes_steps = (
5, 5, 5, 5, 5
);  ######### Number of steps allowed for each variables. In the same order above. (NOTE: THIS OPERATION MAY OFTEN  BE UNUSED.)


@rankdata = (
"n", "n", "n", "y"
); # THIS DATA ARE POINT-TO- POINT RELATIVE TO THE ARRAY ABOVE AND TELL WHAT FIELD THE RANKING HAS TO BE BASED ON (NOTE: UNMANTAINED FROM VERSION 0.5 ON).

@rankcolumn = (
0, 0, 3, 0
); # THIS DATA ARE POINT-TO- POINT RELATIVE TO THE ARRAY ABOVE AND TELLS WHAT FILE COLUMN THE RANKING HAS TO BE BASED ON: 3 for max air temps, 5 for min air temps, 7 for mean air temps, 8 for resultant max temps, 10 for resultant min temps, 12 for resultant mean temps - # (NOTE: UNMANTAINED FROM VERSION 0.5 ON).

@reporttempsdata = ([$simtitle[0], $simtitle[1]], ["UNUSED"], ["Time", "AmbientdbTmp(degC)", 
"zonedbT(degC)", "zoneMRT(degC)", "zoneResT(degC)"]);
 # This is for temperatures.  [$simtitle[0] refers to the first @simtitle, [$simtitle[1] refers to the second @simtitle.  If you have more or less $simtitle(s), you'll have to add or subtract them to this line.  In the last set of square parentheses ("[]") the names of the columns in the report files have to be specified.

@reportcomfortdata = ([$simtitle[0], $simtitle[1]], 
["UNUSED"], [
"Time",
"zonePMV(-)"
]); # This is for comfort.  Here in the last set of square parentheses ("[]") the names of the columns in the report files have to be specified.


@reportradiationenteringdata = ([$simtitle[0], $simtitle[1]], 
["UNUSED"], 
["testzone"]); 
# This is for radiation entering zone.  Here in the last set of square parentheses ("[]") the names of the columns in the report files have to be specified. ES, bizonal: ["zone1", "zone2", "All"]

@reporttempsstats = ([$simtitle[0], $simtitle[1]], 
"Ann", 
["1"]); 
# This is for temperatures statistics. Put the zones' number in this array. UPDATE: The only working field is the third. Put there the beginning word of the row you want to filter. Es: "All", or "Jan".

$reportloadsdata = [[$simtitle[0], $simtitle[1]], 
"Feb", 
["1"], 
"Feb"
]; # mix data y/n,  # "name of the files you want to deal with, if they are not all the existing ones", # list of the the names of the simdata to you want to mix together


################# HERE THE MORPHING VARIABLES FOLLOW ###################


# POINT TO POINT CORRENSPODENCE WITH THE PARAMETERS $stepsvar1, $stepsvar2 etc. 
# IT IS THE LIST OF THE MID ITERATION NUMBER FOR EACH PARAMETER. 
# I.E. IF THERE ARE 3 ITERATION PER PARAMETER, A VALUE "2" FOR EACH $midvalue (@midvalues) HAS TO BE SPECIFIED.
# THERE IS NO PROBLEM IS THIS LIST IS LONGER THAN THE MORPHING PHASES. IT MUST NOT BE SHORTER.

@applytype1 = ( ["translation", "zone.cfg", "zone.cfg", "a"]); #  @applytype(n) = (["type_of_change", "your_test_file", "file_name_to_which_the_former_will_be_copied_to", "zone_letter"]), 
$general_variables1 = [
"y", # $generate(n) eq "n" # (if the models deriving from this runs will not be generating new models) or y (if they will be generating new models).
"n" #if $sequencer eq "y", or "last" (of a sequence) iteration between non-continuous cases wanted.  The first gets appended to the middle(s) and to he last. Otherwise, "n".
];
$translate1 = [ ["y", #yes_or_no_translate # @applytype111 = (["translation", "zone.geo", "zone.geo", "a"]);
"n", # $yes_or_no_translate_obstructions
["9", "0", "0"], # give the coordinates for one extreme of the swing.  The other one will be simmetrical along the line.
"c", # update radiation calculation with the "ish" module?  "a" for yes and "c" for no, continue.
"" # configuration file for conditions
] ];

@applytype2 = ( ["translation", "zone.cfg", "zone.cfg", "a"]); #  @applytype(n) = (["type_of_change", "your_test_file", "file_name_to_which_the_former_will_be_copied_to", "zone_letter"]), 
$general_variables2 = [
"y", # $generate(n) eq "n" # (if the models deriving from this runs will not be generating new models) or y (if they will be generating new models).
"n" #if $sequencer eq "y", or "last" (of a sequence) iteration between non-continuous cases wanted.  The first gets appended to the middle(s) and to he last. Otherwise, "n".
];
$translate2 = [ ["y", #yes_or_no_translate # @applytype111 = (["translation", "zone.geo", "zone.geo", "a"]);
"n", # $yes_or_no_translate_obstructions
["0", "6", "0"], # give the coordinates for one extreme of the swing.  The other one will be simmetrical along the line.
"a", # update radiation calculation with the "ish" module?  "a" for yes and "c" for no, continue.
"" # configuration file for conditions
] ];

@applytype3 = ( ["translation", "zone.cfg", "zone.cfg", "a"]); #  @applytype(n) = (["type_of_change", "your_test_file", "file_name_to_which_the_former_will_be_copied_to", "zone_letter"]), 
$general_variables3 = [
"y", # $generate(n) eq "n" # (if the models deriving from this runs will not be generating new models) or y (if they will be generating new models).
"n" #if $sequencer eq "y", or "last" (of a sequence) iteration between non-continuous cases wanted.  The first gets appended to the middle(s) and to he last. Otherwise, "n".
];
$translate3 = [ ["y", #yes_or_no_translate # @applytype111 = (["translation", "zone.geo", "zone.geo", "a"]);
"n", # $yes_or_no_translate_obstructions
["0", "0", "2"], # give the coordinates for one extreme of the swing.  The other one will be simmetrical along the line.
"c", # update radiation calculation with the "ish" module?  "a" for yes and "c" for no, continue.
"" # configuration file for conditions
] ];

@applytype4 = ( ["rotation", "zone.cfg", "zone.cfg", "a"]); #  @applytype(n) = (["type_of_change", "your_test_file", "file_name_to_which_the_former_will_be_copied_to", "zone_letter"]), 
$general_variables4 = [
"n", # $generate(n) eq "n" # (if the models deriving from this runs will not be generating new models) or y (if they will be generating new models).
"n" #if $sequencer eq "y", or "last" (of a sequence) iteration between non-continuous cases wanted.  The first gets appended to the middle(s) and to he last. Otherwise, "n".
];
$rotate4 = [ ["y",  # yes or no rotate # @applytype111 = (["rotation", "zone.geo", "zone.geo", "a"]);
"n", # $yes_or_no_rotate_obstruction: 	"y" o "n"						
"90", # swingrotate
"a", # update radiation calculation with the "ish" module?  "b" for yes and "c" for no, continue.
"a", #vertex around which to rotate
"undef" # configuration file for conditions. UNUSED FOR NOW.
] ];
$recalculateish4 = "n"; # "y" or "n". This way ish is launched just at the end of a whole morphing operation, and not at every suboperations componing it.

@applytype5 = ( ["surface_translation", "zone.cfg", "zone.cfg", "a"]); #  @applytype(n) = (["type_of_change", "your_test_file", "file_name_to_which_the_former_will_be_copied_to", "zone_letter"]), 
$recalculateish5 = "n"; # "y" or "n". This way ish is launched just at the end of a whole morphing operation, and not at every suboperations componing it.
$general_variables5 = [
"y", # $generate(n) eq "n" # (if the models deriving from this runs will not be generating new models) or y (if they will be generating new models).
"n" #if $sequencer eq "y", or "last" (of a sequence) iteration between non-continuous cases wanted.  The first gets appended to the middle(s) and to he last. Otherwise, "n".
]; 
$translate_surface5 = # THIS VERSION IS THE MOST ADVISABLE BUT IT HAS STILL TO BE DEVELOPED. THIS NEEDS STILL TO INCORPORATE A CONFIGURATION FILE ON THE EXAMPLE OF sub reshape_windows
[ ["y", # $yes_or_no_transl_surfs: shifts along the surface normal # @applytype111 = ( ["surface_translation", "zone.cfg", "zone.cfg", "a"]);
"a", # transform type: "a" for surface translation along normal, "b" for x y z surface translation
["b", "d"],  #@surfs_to_transl2
[ 1, 1 ] , # @ends_movs, in case of surface_translation_along_normal (example: [2, 2, 2, 2, 2, 2] ), or "x y z" translation if x y z translation of surface (example: ["2  2  2", "2  2  2"]). Relative to the fields above.
"c", # $yes_or_no radiation update : "b" for yes or "c" for no.
[  ], # x y z movs, in case of surface x y z translation
]
];
@apply_constraints5 = (
[
"y", # $yes_or_no_apply_constraints
["/zones/zone.geo"], # source file
["/zones/zone.geo"], # target file
["confile_ams2.pl"], # configuration file for constraints
[216], # base values
[], # swing values: still unused
[ "e", "f", "g", "h", "0\nb\nb" , "0\nb\nd", "0\nb0\nb\nf", "0\nb\n0\nb\nh", "0\nb\n0\nb\nj" ],
"y" # do you long menues for items in ESP-r here? "y" or "n".
]
); # TO DO: RIFARE CON: lettere vertici parete, lettere vertici finestra, piano di lavoro (xz, yz, xy), distanza desiderata della finestra dalla base (o da cosa a cosa, distanza desiderata della finestra dalla sommità (o da cosa a cosa), variabile da ottenere




################################################################################
################################################################################
# HERE FOLLOWS THE DESCRIPTION OF THE MORPHING OPERATIONS 
# REFERRED TO A NON-EXISTING MORPHING PHASE 1111, AS AN EXAMPLE. 

$stepsvar111 =
3
; #  Number of steps for this variable.  This should better be an odd number, since thiat way one number will be the central one, which is, the one already supplied in the starting model;

@applytype111 =  ( [   ##### @applytype = (["type_of_change", "your_test_file", "target_file", "zone_letter"]). 
# THIS REPRESENTS A FIRST CYCLE OF ACTIONS, THAT MAY BE THE ONLY ONE FOR THIS MORPHING CYCLE. Presently, the following morphing operations are available: "translation", "rotation", "rotationz", "surface_translation", "vertexes_shift", "surface_rotation", "warping", "construction_reassignment", "thickness_change", "obs_modification", "generic_change", "vary_controls", “vary_net”. And these operations can be accompanied by the following operations for the propagation of constraints to the models: apply_constraints (regarding geometry), constrain_geometry (more general: it will gradually substitute the former), constrain_controls, bring_obstructions_back (to pin down some obstructions while other are being moved), constrain_obstructions, constrain_net, recalculatenet (this both updates a net and applies constraints to it). The following update operations are also possible: recalculateish, daylightcalc (with Radiance, through e2r).
# "Target file" here means: "file name to which the test file has to be copied to"
"surface_translation", 
###  type_of_change
"zone.cfg", 
### your_test_file
"zone.cfg", 
###  target_file. If it is the same as above, no copying is done.
"a"
], # zone letter. (See the ESP-r model.)
["unused", "zone.cfg", "zone.cfg", "a"], 
# OPTIONAL. ERASE IF IT IS UNUSED. THIS MAY REPRESENT A SECOND CYCLE OF ACTIONS, ADDED TO THE PREVIOUS ONE THE THE SAME MORPHING PHASE. YOU HAVE TO FILL THE DATA BY YOUSELF FOLLOWING THE EXAMPLE OF THE FIELDS FOR THE FIRST CYCLE. IF YOU DON'T PLAN TO USE IT, "unused" HAS TO BE WRITTEN IN THE FIRST FIELD HERE. 
["unused", "zone.cfg", "zone.cfg", "a"], 
# OPTIONAL. ERASE IF IT IS UNUSED. THIS MAY REPRESENT A THIRD CYCLE OF ACTIONS, ADDED TO THE PREVIOUS ONE THE THE SAME MORPHING PHASE. YOU HAVE TO FILL THE DATA BY YOUSELF FOLLOWING THE EXAMPLE OF THE FIELDS FOR THE FIRST CYCLE. IF YOU DON'T PLAN TO USE IT, "unused" HAS TO BE WRITTEN IN THE FIRST FIELD HERE. 
["unused", "zone.cfg", "zone.cfg", "a"], 
# OPTIONAL. ERASE IF IT IS UNUSED. THIS MAY REPRESENT A FOURTH CYCLE OF ACTIONS, ADDED TO THE PREVIOUS ONE THE THE SAME MORPHING PHASE. YOU HAVE TO FILL THE DATA BY YOUSELF FOLLOWING THE EXAMPLE OF THE FIELDS FOR THE FIRST CYCLE. IF YOU DON'T PLAN TO USE IT, "unused" HAS TO BE WRITTEN IN THE FIRST FIELD HERE. 
["unused", "zone.cfg", "zone.cfg", "a"]
); # OPTIONAL. ERASE IF IT IS UNUSED. THIS MAY REPRESENT A FIFTH CYCLE OF ACTIONS, ADDED TO THE PREVIOUS ONE THE THE SAME MORPHING PHASE. YOU HAVE TO FILL THE DATA BY YOUSELF FOLLOWING THE EXAMPLE OF THE FIELDS FOR THE FIRST CYCLE. IF YOU DON'T PLAN TO USE IT, "unused" HAS TO BE WRITTEN IN THE FIRST FIELD HERE. MORE CYCLES CAN BE ADDED.

@copy_config111 = ([ "file_old" , # file to be substituted
"file_new" ] , # file that substitutes
# END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
);

$general_variables1 = [
"y", 
# generate other models by branching? "y" or "n". (Be careful of the exponential growth of the number of cases).
"n" 
# attach the morphing operation of the next morphing phase to the present one without generating new cases? If "yes", you'll see the symbol "" attached to file names in place of "_" for morphed models.
];

$translate1 =  [ [  #####  @applytype1 = (["translation", "file_name.geo", "target_file_name.geo",
"y", 
# translate zone?   "y” or “n”.
"n", 
# translate obstructions? "y" or "n".
["9", 
# coordinate “x” for one extreme of the swing.  The other one will be simmetrical along the line.
"0",  
# coordinate “y” for one extreme of the swing.  The other one will be simmetrical along the line.
"0"], 
# coordinate “z” for one extreme of the swing.  The other one will be simmetrical along the line.
"c", 
# update radiation calculation with the "ish" module?  "a" for yes and "c" for no (= continue).
] , # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
];

$translate_surface111 =  [ [   #### @applytype111 = ( ["surface_translation", "file_name", "target_file_name", "zone_letter"]); # (NOTE: THIS VERSION HAS TO BE IMPROVED. MOREOVER, IT STILL NEEDS  TO EMBODY A CONFIGURATION FILE ON THE EXAMPLE OF THE FUNCTION "reshape_windows")
"y", 
# translate surfaces?   # "y" or "n".  
"a", 
# transform type: "a" for surface translation along normal, "b" for x y z surface translation.
[
"b", "d"
],  # surfaces to be translated (letters)
[  1, 1  ] , 
# end movements, in case of surface translation along_normal (example: [2, 2, 2, 2, 2, 2] ), or "x y z" translation, in the case of x y z translation of surface (example: ["2  2  2", "2  2  2"]). Relative to the fields above.
"c", 
# update radiation? "b" for yes or "c" for no.
[unused], # x y z movs, in case of surface x y z translation. If unused, leave blank, or write unused.
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[ ], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
];

$shift_vertexes111 = [ [   #### @applytype111 = ( ["vertexes_shift", "file_name", "target_file_name", "zone_letter"]);
"y", 
# shift vertexes? "y" or "n".
"j", 
# movement type: "j": shift vertexes along a line. "h": align vertexes with a line.
[
"i" , "q" , "j", "r" , "m" , "0\ns", "n", "0\nt" , "0\nv", "c", "0\nu", "d", "0\nz", "f", "0\ny", "e"
], # pairs of vertexes defining axes
[
0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8
], # Complete shift movements - whole excursion here.
"c", 
# configuration file for conditions
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
];

$rotate_surface111 = ##### @applytype111 = ( ["surface_rotation", "file_name", "target_file_name", "zone_letter"]);
[ ["y", 
# rotate surface around a vertex? "y" or "n".  
[
"b", "d"
],  # surfaces to rotate
[
10, 12
], #  vertexes around which to rotate
[
30, 30
] , #  wing extremes of the rotation
[
"y", "y" 
], # apply to others? "y" or "n".
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
];

$warp111 = [ [   #### @applytype111 = ( ["warping", "file_name", "target_file_name", "zone_letter"]).
"y", 
# warp a zone? "y" or "n".  THE ZONE HAS TO HAVE A RECTANGULAR BASE AND BE ORIENTED NORTH-SOUTH.   THIS OPERATION ROTATES A SURFACE THEN MAKE A VERTEX SHIFT TO LEAVE THE BASE AREA UNCHANGED.
[
"b", "d"
],  #  surfaces to warp
[
2, 2
], # vertexes around which to rotate
[
36, -36
] , # swings of rotation
[ 
"y", "y" 
], # apply to other ones? "y" or "n".
"configfile.1.1.warp.pl", 
# configuration file for conditions. # TO COMPLETE
[
"a" , "d" , "e", "h" , "b" , "c", "f", "g" , "d" , "a" , "h", "e" , "c" , "b", "g", "f" 
], # pairs of vertexes defining axes
[
"g", "i"
], # windows to be realigned
"/zones/zone.geo", 
# zone geometry file
"y" 
# long menus occurring in ESP-r? "y" or "n".
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE..
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
];

$construction_reassignment111 =  ##### @applytype111 = (["construction_reassignment", "file_name", "target_file_name", "zone_letter"]);
[ ["y", 
# modify construction? "y" or "n".
[
"a", "b", "c", "d", "e", "f" , "k", "l", "m", "n", "o", "p", "q", "r" 
], #  surfaces to be reassigned
[
["b", "d", "g", "h"], ["b", "d", "g", "h"], ["b", "d", "g", "h"], ["b", "d", "g", "h"], 
["b", "d", "g", "h"], ["b", "d", "g", "h"] , ["b", "0\nu", "0\nv", "0\nw"] , ["b", "0\nu", "0\nv", "0\nw"], ["b", "0\nu", "0\nv", "0\nw"], ["b", "0\nu", "0\nv", "0\nw"], 
["b", "0\nu", "0\nv", "0\nw"], ["b", "0\nu", "0\nv", "0\nw"], ["b", "0\nu", "0\nv", "0\nw"], ["b", "0\nu", "0\nv", "0\nw"]  
], # constructions to be chosen (take care. letter combination, here!!). IN EACH GROUP WITHIN EACH PARENTHESIS THERE IS A SEQUENCE OF LETTER OF MATERIALS TO BE TRIED. THE NUMBER OF MATERIALS SHOULD BE EQUAL TO THE NUMBER OF ITERATIONS IN THIS MORHING PHASE (OR GREATER – BUT IN THIS CASE SOME LAST ITEMS WILL BE IGNORED). EACH GROUP WITHIN A PARENTHESIS [] REFERS TO A LETTER OF THE FIRST LIST. NOTICE THAT YOU HAVE TO USE THE "0\nw" TRICK IF THE MENU IS MORE THAN ONE PAGE LONG.
] , # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
];

$thickness_change111 = ##### @applytype111 = ( ["thickness_change", "file_name", "target_file_name", "zone_letter"]); 
[ ["n", 
# change thickness of a construction layer? "y" or "n".
[ a, b, c ], #  entries to be changed in the construction database. It has to be a local copy.
[
[i, j], [a, b], [k] 
], # groups of strata to change: strata to change for each entry. There is a correspondence with the above.
[ [ 
[10, 20] , [20, 50] ], [ [20, 60] , [10, 40] ], [ [20, 50 ] 
]],
] , # END OF DATA FOR FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL: DATA FOR SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL: THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL: FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL: FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
]; # @groups_of_pairs_of_min_max_values, containing @min_max_values: min and max values for each change above.  There is a two to one correnspondence of the values below with the above.

$obs_modify111 = ( [   # @applytype111 = (["obs_modification",trans "cell.geo", "cell.geo", "a"], ["obs_modification", "cell.geo", "cell.geo", "a"]);
[ [ 
"i","j", "k", "l" 
] , # obstructions to modify (letters)
"c",  # what to modify? "a" for origin, "b" for dimensions, "c" for z_rotation, "d" for y_rotation, "g" for construction, "h" for opacity, "t" for transform. That care, because the first item, that is "e" in the other transformation operations, in transforms is "a".				
[45 ], # enter value or values corresponding to the above. If origin coordinates of one extreme of the translation. If dimensions: x y z of dimensions. If rotation: swing of the rotation. If construction:construction name. If opacity: percentage of opacity.
[180], # if origin: base x y z origin. If dimensions: base x y z dimensions. If rotations: start rotation. If opacity: base opacity. if transform: "a" for rotation, "b" for transform.
]]);#TAKE CARE: THE DIFFERENT ZONE DATA ARE BETWEEN ([]) in obs_modify. THAT IS, TO TAKE INTO ACCOUNT TWO ZONES, YOU HAVE TO DO THIS: ([ [something], [something_else] ]).


$rotate111 = ##### @applytype111 = (["rotation", "file_name", "target_file_name", "zone_letter"]);
[ ["y",  
# rotate zone? "y" or "n".
"n", 
# rotate obstructions? 	"y" o "n"						
"90", 
# swing of rotation 
"c", 
# update radiation calculation with the "ish" module?  "b" for yes and "c" for no, continue.
"a", 
# vertex around which to rotate
], # END OF DATA FOR FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], 
# OPTIONAL: DATA FOR SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], 
# OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], 
# OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] 
# OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
];

$rotatez111 = #  @applytype(n) = (["type_of_change", "your_test_file", "file_name_to_which_the_former_will_be_copied_to", "zone_letter"]). # THIS ROUTINE KEEPS THE OBSTRUCTIONS STILL AND ROTATE THE ZONE(S) ON THE ALTITUDE ANGLE.  IT DOES NOT PASS THROUGH ESP-R.  IT JUST MANAGES THE .GEO CONFIGURATION FILE.
["y", 
# rotate zone around the "z" axis? "y" or "n".    
[
0.7, 0.7, 0.02
], # x, y (or x) and z of the point that is the center of the axis rotation
"x", 
# plane of rotation: x or y
90
, # rotation swing of plane xy
0, 
# rotation already had by the zone with respect to the x axis
0
, # rotation on plane yz - TO DO
# 0, # swing for the rotation on plane xy - TO DO
]; # PLEASE NOTE THAT THIS OPERATION HAS NOT YET BEEN WRITTEN TO BE USED IN SEQUENCE WITH OTHER OPERATIONS IN THE SAME MORPHING PHASE. SO USE IT IN THE FIRST SEQUENCE OF THIS PHASE, AND KEEP JUST ONE SEQUENCE IN THIS PHASE.

@generic_change1 = ##### # @applytype111 = (["generic_change", "file_name", "target_file_name", "zone_letter"]); THIS VARIABLE CONTROLS A FUNCTIONS THAT TARGETS CONFIGURATION SOURCE FILES AND MODIFIES THEM SELECTIVELY IN PARTS WHICH ARE SPECIFIED BY POSITION (ROW, COLUMN, TEXT LENGTH).
([ [ 
["-", 
4, 
# ([["-", number_of_row_to_modify, 
[ 
18, 7, 0.5, 5 
], 
# [1st-field-of_the_text_area_to_modify, 1st-field-length, 1st-f-variable's-swing, 1st-f-number_of_decimals],
[ 
0, 0, 0, 0 
],  
# [nth-field-of_the_text_area_to_modify, nth-field-length, nth-f-variable's-swing, nth-f-number_of_decimals],
[ 
0, 0, 0, 0 
]], 
# [last-field-of_the_text_area_to_modify, last-field-length, last-f-variable's-swing, last-f-number_of_decimals],
["-", 
5
, 
# ([["-", number_of_row_to_modify, 
[ 
0, 0, 0, 0 
], 
# [1st-field-of_the_text_area_to_modify, 1st-field-length, 1st-f-variable's-swing, 1st-f-number_of_decimals],
[ 
0, 0, 0, 0 
], 
# [nth-field-of_the_text_area_to_modify, nth-field-length, nth-f-variable's-swing, nth-f-number_of_decimals],
[ 
0, 0, 0, 0 
]], # [last-field-of_the_text_area_to_modify, last-field-length, last-f-variable's-swing, last-f-number_of_decimals],
["-", 
8
, # ([["-", number_of_row_to_modify, 
[ 
0, 0, 0, 0 
], 
# [1st-field-of_the_text_area_to_modify, 1st-field-length, 1st-f-variable's-swing, 1st-f-number_of_decimals],
[ 
0, 0, 0, 0 
], 
# [nth-field-of_the_text_area_to_modify, nth-field-length, nth-f-variable's-swing, nth-f-number_of_decimals],
[ 
0, 0, 0, 0 
]], 
# [last-field-of_the_text_area_to_modify, last-field-length, last-f-variable's-swing, last-f-number_of_decimals],
]], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
); 


@change_climate111 = 
([
"e", "g", "0\nb\nu" # CLIMATE LETTERS. THEIR NUMBER MUST BE EQUAL OR GREATER THAN $stepsavar. THE ITEMS IN EXCESS WILL BE IGNORED.
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. YOU CAN ADD NEW SEQUENCES.
);


@reshape_windows111 = (
[[ [
"/zones/zone.geo"
], # source file
[
"/zones/zone.geo"
], # target file
[
"configfile.1.1.window_reshapement.pl"
], # configuration file for constraints
[(
40/100
)], # windows percentage base value
[(
30/100
)], # windows percentage swing
[ 
"k", "l", "m", "n" 
], # vertex number of the windows to change
[
"y"
] # there are long menus for items in ESP-r here? "y" or "n".
]]); 


$keep_obstructions111 = ##### BRING SOME OBSTRUCTIONS BACK IN THE ORIGINAL POSITION AFTER ALL OF THEM HAVE BEEN MOVED.
[ [ "y", 
# keep some obstructions in position? "y" or "n".
[["0\ng", "0", "0", "30", "10", "0"], 
# HERE: obstruction letter, unused, unused, “x”, “y”, “z” for the movement. rotation_z and rotation_y (second and third fields) are indeed still unused. Notice that you have to adopt the  "0\ng" trick when a menu is more than one page long. You can add more obstructions following the example of the first.
["0\nh", "0", "0", "43", "20", "0"],
["0\ni", "0", "0", "15", "8", "0" ],
["0\nj", "0", "0", "5", "10", "0" ],
["0\nk", "0", "0", "2", "15", "0"],
["0\nl", "0", "0", "3", "30", "0"]
],
"n", 
# update radiation calculations? "y" for yes or "n" for no
"5 10"
 # x grid density for "x z" resolution, z grid density for "x z" resolution.
] , # END OF DATA FOR FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
]; # TO BE REWRITTEN

@vary_controls111 = ( [
"/ctl/cell.ctl", # source file
"/ctl/cell.ctl", # target file
"/opts/default_configfile_control_constraints.pl", # config file
[ #BEGINNING OF BUILDING CONTROLS
["e", # LETTER OF THE FIRST LOOP  # BEGINNING OF THE FIRST CONTROLLER OF THE FIRST LOOP FOR BUILDING CONTROLS
"a", # LETTER OF THE FIRST CONTROLLER OF THE FIRST LOOP
0, # SWINGS FOR ZONE START PERIOD HOUR 
1000, # SWINGS FOR MAXIMUM ZONE HEATING POWER 
0, # SWINGS FOR MINIMUM ZONE HEATING POWER 
500, # SWINGS FOR MAXIMUM ZONE COOLING POWER
0, # SWINGS FOR MINIMUM ZONE COOLING POWER
1, # SWINGS FOR ZONE HEATING SETPOINT 
1],  # SWINGS FOR ZONE COOLING SETPOINT - END OF THE FIRST CONTROLLER OF THE FIRST LOOP FOR BUILDING CONTROLS
["f", # LETTER OF THE FIRST LOOP  # BEGINNING OF THE FIRST CONTROLLER OF THE SECOND LOOP FOR BUILDING CONTROLS
"a", # LETTER OF THE FIRST CONTROLLER OF THE FIRST LOOP
0, # SWINGS FOR ZONE START PERIOD HOUR
1000, # SWINGS FOR MAXIMUM ZONE HEATING POWER 
0, # SWINGS FOR MINIMUM ZONE HEATING POWER 
500, # SWINGS FOR MAXIMUM ZONE COOLING POWER
0, # SWINGS FOR MINIMUM ZONE COOLING POWER
1, # SWINGS FOR ZONE HEATING SETPOINT 
1] , # SWINGS FOR ZONE COOLING SETPOINT - END OF THE FIRST CONTROLLER OF THE SECOND LOOP FOR BUILDING CONTROLS
["f", # LETTER OF THE FIRST LOOP  # BEGINNING OF THE SECOND CONTROLLER OF THE SECOND LOOP FOR BUILDING CONTROLS
"b", # LETTER OF THE FIRST CONTROLLER OF THE FIRST LOOP
0, # SWINGS FOR ZONE START PERIOD HOUR
1000, # SWINGS FOR MAXIMUM ZONE HEATING POWER 
0, # SWINGS FOR MINIMUM ZONE HEATING POWER 
500, # SWINGS FOR MAXIMUM ZONE COOLING POWER
0, # SWINGS FOR MINIMUM ZONE COOLING POWER
1, # SWINGS FOR ZONE HEATING SETPOINT 
1] # SWINGS FOR ZONE COOLING SETPOINT - END OF THE SECOND CONTROLLER OF THE SECOND LOOP FOR BUILDING CONTROLS
], # END OF BUILDING CONTROLS
[ # BEGINNING OF NET CONTROLS
[ "e", # FIRST LOOP  FOR NETS
"a", #  FIRST CONTROL FOR THE FIRST LOOP FOR NETS
0,  # BEGINNING HOUR SWING
1, #  SETPOINT SWING
0, # VARIATION RELATIVE TO ON-OFF (-1 OR 1)
0 ], # FRACTION
[ "e", "b", 0, 1, 0, 0 ], # FIRST LOOP AND SECON CONTROL FOR THE FIRST LOOP FOR NETS; THEN BEGINNING HOUR SWING, SETPOINT SWING, ON-OFF (-1 OR 1), FRACTION
[ "f", "a", 0, 1, 0, 0 ], # SECOND LOOP AND FIRST CONTROL FOR THE SECOND LOOP FOR NETS; THEN BEGINNING HOUR SWING, SETPOINT SWING, ON-OFF (-1 OR 1), FRACTION
] # END OF NET CONTROLS
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. YOU CAN ADD NEW SEQUENCES.
);

@apply_constraints111 = ##### APPLY PROPAGATION OF CONSTRAINTS TO THE MODEL AFTER A CERTAIN CHANGE; GENERAL. YOU HAVE TO WRITE A CONFIGURATION FILES TO DO IT. (SEE EXAMPLE MODELS.)
([ "y", 
# apply constraints?
["/zones/zone.geo"], 
# source file
["/zones/zone.geo"], 
# target file
["configfile.1.1.apply_constraints.pl"], 
# configuration file for constraints
[216], # base values
[ "/opts/default_configfile_control_constraints.pl" ], # swing values: still unused
[ 
"e", "f", "g", "h", "0\nb\nb" , "0\nb\nd", "0\nb0\nb\nf", "0\nb\n0\nb\nh", "0\nb\n0\nb\nj" 
], 
# letters of vertexes in the esp-r geometry file. Here the letters have to be specified corresponding to the vertexes whose position has to be changes through propagation of constraints.
"y" 
# do you have long menus for items in ESP-r here? "y" or "n".
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
); 

@constrain_geometry111 = (  # This is similar to "apply_constraints", but more general, because the propagation here criteria has to be specified in the configuration file. 
[[ [
"/zones/zone.geo"
], # source file
[
"/zones/zone.geo"
], # target file
[
"/opts/default_configfile_geometry_constraints.pl"], # configuration file for constraints. Here the criteria for propagation of constraints have to be specified.
[ 
"k", "l", "m", "n"
], # vertex letters to be changed.
["y"] # long vertex letters (long menus) in ESP-r here? "y" or "n"
]], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
); #
# THIS VARIABLE REGARDS GEOMETRY USER-IMPOSED CONSTRAINTS
# THIS CONSTRAINT CONFIGURATION FILE MAKES AVAILABLE TO THE USER THE FOLLOWING VARIABLES:
# @v[$number][$x], @v[$number][$y], @v[$number][$z]. 
# EXAMPLE: @v[4][$x] = 1. THIS MEANS: COORDINATE x OF VERTEX 4. OR: @v[4][$x] =  @v[4][$y].
# ALSO, IT FILE MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS 
# AND THE STEPS THE MODEL HAVE TO FOLLOW. SPECIFICALLY, THE FOLLOWING VARIABLES:
# $stepsvar, WHICH TELLS THE PROGRAM HOW MANY ITERATION STEPS IT HAS TO DO IN THE CURRENT MORPHING PHASE.
# $counterzone, WHICH TELLS THE PROGRAM WHAT OPERATION IS BEING EXECUTED IN THE CHAIN OF OPERATIONS 
# THAT MAY BE EXECUTES AT EACH MORPHING PHASE. EACH $counterzone WILL CONTAIN ONE OR MORE ITERATION STEPS.
# TYPICALLY, IT WILL BE USED FOR A ZONE, BUT NOTHING PREVENTS THAT SEVERAL OF THEM CHAINED ONE AFTER 
# THE OTHER ARE APPLIED TO THE SAME ZONE.
# $counterstep, WHICH TELLS THE PROGRAM WHAT THE CURRENT ITERATION STEP IS.
# If the alphabetical order is not accepted as an order to propagate constraints, a new order can be specificed
# WITH THE FOLLOWING VARIABLE: @vertexletters


@constrain_controls111 = ( # to apply contraints to and from controls.
["y", # apply constraints to controls? "y" or "n".
"/ctl/cell.ctl", # source file
"/ctl/cell.ctl", # target file
"/opts/default_configfile_control_constraints.pl", # config file 
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
);
# THIS VARIABLE REGARDS CONTROL USER-IMPOSED CONSTRAINTS
# THIS CONSTRAINT CONFIGURATION FILE FILE MAKES AVAILABLE TO THE USER THE FOLLOWING VARIABLES:
# 1) $loop_control[$countloop][$countloopcontrol][$loop_hour] 
# Where $countloop and  $countloopcontrol has to be set to a specified number in the OPT file for constraints.
# 2) $loop_control[$countloop][$countloopcontrol][$max_heating_power] # Same as above.
# 3) $loop_control[$countloop][$countloopcontrol][$min_heating_power] # Same as above.
# 4) $loop_control[$countloop][$countloopcontrol][$max_cooling_power] # Same as above.
# 5) $loop_control[$countloop][$countloopcontrol][$min_cooling_power] # Same as above.
# 6) $loop_control[$countloop][$countloopcontrol][heating_setpoint] # Same as above.
# 7) $loop_control[$countloop][$countloopcontrol][cooling_setpoint] # Same as above.
# 8) $flow_control[$countflow][$countflowcontrol][$flow_hour] 
# Where $countflow and  $countflowcontrol has to be set to a specified number in the OPT file for constraints.
# 9) $flow_control[$countflow][$countflowcontrol][$flow_setpoint] # Same as above.
# 10) $flow_control[$countflow][$countflowcontrol][$flow_onoff] # Same as above.
# 11) $flow_control[$countflow][$countflowcontrol][$flow_fraction] # Same as above.
# EXAMPLE : $flow_control[1][2][$flow_fraction] = 0.7
# OTHER EXAMPLE: $flow_control[1][2][$flow_fraction] = $flow_control[2][1][$flow_fraction]
# ALSO, THIS FILE MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS 
# AND THE STEPS THE MODEL HAVE TO FOLLOW. SPECIFICALLY, THE FOLLOWING VARIABLES:
# $stepsvar, WHICH TELLS THE PROGRAM HOW MANY ITERATION STEPS IT HAS TO DO IN THE CURRENT MORPHING PHASE.
# $counterzone, WHICH TELLS THE PROGRAM WHAT OPERATION IS BEING EXECUTED IN THE CHAIN OF OPERATIONS 
# THAT MAY BE EXECUTES AT EACH MORPHING PHASE. EACH $counterzone WILL CONTAIN ONE OR MORE ITERATION STEPS.
# TYPICALLY, IT WILL BE USED FOR A ZONE, BUT NOTHING PREVENTS THAT SEVERAL OF THEM CHAINED ONE AFTER 
# THE OTHER ARE APPLIED TO THE SAME ZONE.
# $counterstep, WHICH TELLS THE PROGRAM WHAT THE CURRENT ITERATION STEP IS.
# If the alphabetical order is not accepted as an order to propagate constraints, a new order can be specificed
# WITH THE FOLLOWING VARIABLES: @letters AND @period_letters

@constrain_obstructions111 = ( # To apply constraints to and from obstructions.
 ["y", # apply constraints to obstructions? "y" or "n".
 "a", # zone letter
 "/zones/zone.geo", # source file
"/zones/zone.geo", # target file
"/opts/default_configfile_obstruction_constraints.pl", # configuration file for constraints. Here the criteria for propagation of constraints have to be specified.
[  "e", "f", "g", "h" ], # obstruction letters to be changed.
"y" # act on construction too? "y" or "n". Note that constructions letters (as they appear in the construction database) and not construction names have to be given in the configuration files.
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. 
); #
# THIS PART REGARDS USER-IMPOSED CONSTRAINTS ABOUT ONSTRUCTIONS
# THIS CONSTRAINT CONFIGURATION FILE FILE MAKES AVAILABLE TO THE USER THE FOLLOWING VARIABLES:
# $obs[$obs_number][$x], $obs[$obs_number][$y], $obs[$obs_number][$y]
# $obs[$obs_number][$width], $obs[$obs_number][$depth], $obs[$obs_number][$height]
# $obs[$obs_number][$z_rotation], $obs[$obs_number][$y_rotation], 
# $obs[$obs_number][$tilt], $obs[$obs_number][$opacity], $obs[$obs_number][$material], 
# EXAMPLE: $obs[2][$x] = 2. THIS MEANS: COORDINATE x OF OBSTRUCTION HAS TO BE SET TO 2.
# OTHER EXAMPLE: $obs[2][$x] = $obs[2][$y]. THIS MEANS: 
# NOTE: THE MATERIAL TO BE SPECIFIED IS A MATERIAL LETTER, BETWEEN QUOTES. EXAMPLE: $obs[1][$material] = "a".
#  $tilt IS PRESENTLY UNUSED.
# ALSO, THIS FILE MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS 
# AND THE STEPS THE MODEL HAVE TO FOLLOW. SPECIFICALLY, THE FOLLOWING VARIABLES:
# $stepsvar, WHICH TELLS THE PROGRAM HOW MANY ITERATION STEPS IT HAS TO DO IN THE CURRENT MORPHING PHASE.
# $counterzone, WHICH TELLS THE PROGRAM WHAT OPERATION IS BEING EXECUTED IN THE CHAIN OF OPERATIONS 
# THAT MAY BE EXECUTES AT EACH MORPHING PHASE. EACH $counterzone WILL CONTAIN ONE OR MORE ITERATION STEPS.
# TYPICALLY, IT WILL BE USED FOR A ZONE, BUT NOTHING PREVENTS THAT SEVERAL OF THEM CHAINED ONE AFTER 
# THE OTHER ARE APPLIED TO THE SAME ZONE.
# $counterstep, WHICH TELLS THE PROGRAM WHAT THE CURRENT ITERATION STEP IS.
# If the alphabetical order is not accepted as an order to propagate constraints, a new order can be specificed
# WITH THE FOLLOWING VARIABLE:  @obs_letters 

@vary_net111 = ( [
"/nets/cell.afn", # source file
"/nets/cell.afn", # target file
"/opts/default_configfile_net_constraints.pl", # config file # LEAVE BLANK. SPECIFY PROPARATION OF CONSTRAINTS SEPARATELY.
[ #BEGINNING OF  NODES. JUST THE ONES THAT HAS TO BE CHANGED HAVE TO BE LISTED HERE
["a", # NODE LETTER  # BEGINNING OF THE FIRST NODE. THIS IS AN INTERNAL UNKNOWN NODE.
"a", # FLUID TYPE
"a", # BOUNDARY TYPE
"", # HEIGHT. LEAVE "" BLANK IF YOU ACCEPT THE CURRENT VALUE
"", # VOLUME. LEAVE "" BLANK IF YOU ACCEPT THE CURRENT VALUE
],  #  END OF THE FIRST NODE
["b", # NODE LETTER  # BEGINNING OF THE SECOND NODE. THIS IS A BOUNDARY, WIND-INDUCED NODE
"a", # FLUID TYPE
"e", # BOUNDARY TYPE. LETTER
"", # HEIGHT. LEAVE "" BLANK IF YOU ACCEPT THE CURRENT VALUE
"", # SURFACE AZIMUTH ANGLE. LEAVE "" BLANK IF YOU ACCEPT THE CURRENT VALUE
"g", # SURFACE IN ZONE, LETTER. IT CAN'T BE BLANK. THE LETTER MUST BE CHECKED IN ESP-R AND WRITTEN HERE.
[ "f" , "g" ] # PRESSURE COEFFICIENTS (LETTERS) TO APPLY. THEY MUST BE AT LEAST THE SAME NUMBER OF $stepsvar. THE EXCEEDING ITEMS WILL NOT BE USED.
] , # END OF THE SECOND NODE
["c", # NODE LETTER  # BEGINNING OF THE SECOND NODE. THIS IS A BOUNDARY, WIND-INDUCED NODE
"a", # FLUID TYPE
"e", # BOUNDARY TYPE
"", # HEIGHT. LEAVE "" BLANK IF YOU ACCEPT THE CURRENT VALUE
"", #  AZIMUTH ANGLE. LEAVE "" BLANK IF YOU ACCEPT THE CURRENT VALUE
"h", # SURFACE IN ZONE, LETTER. THE LETTER MUST BE CHECKED IN ESP-R AND WRITTEN HERE.
[ "f" , "g" ] # PRESSURE COEFFICIENTS (LETTERS) TO APPLY. THEY MUST BE AT LEAST THE SAME NUMBER OF $stepsvar. THE EXCEEDING ITEMS WILL NOT BE USED.
]  # END OF THE THIRD NODE
], # END OF NODES
[ # BEGINNING OF COMPONENTS. JUST THE ONES THAT HAS TO BE CHANGED HAVE TO BE LISTED HERE
["a", # COMPONENT LETTER  # BEGINNING OF THE FIRST COMPONENT. THIS IS A WINDOW EXAMPLE
"k", # COMPONENT TYPE. "k" IS FOR WINDOWS, "l" FOR CRACKS, AND "m" FOR DOORS.
.4 # SWING OF THE AREA. LEAVE "" BLANK IF YOU ACCEPT THE CURRENT VALUE] , 
], # END OF THE FIRST COMPONENT
["b", # COMPONENT LETTER  # BEGINNING OF THE SECOND COMPONENT. THIS IS THE EXAMPLE OF A CRACK
"l", # COMPONENT TYPE. "k" IS FOR WINDOWS, "l" FOR CRACKS, AND "m" FOR DOORS.
.1,  # SWING OF THE CRACK WIDTH IN MM. LEAVE "" BLANK IF YOU ACCEPT THE CURRENT VALUE
.2 # SWING OF THE CRACK LENGTH IN M. LEAVE "" BLANK IF YOU ACCEPT THE CURRENT VALUE
], # END OF THE SECOND COMPONENT
["c", # COMPONENT LETTER  # BEGINNING OF THE THIRD COMPONENT. THIS IS THE EXAMPLE OF A DOOR
"m", # COMPONENT TYPE. "k" IS FOR WINDOWS, "l" FOR CRACKS, AND "m" FOR DOORS.
.1,  # SWING OF THE DOOR WIDTH.
.1, # SWING OF THE DOOR HEIGHT
.1, # SWING OF THE HEIGHT OF THE ADJOINING NODE ABOVE BASE
0 # SWING OF THE DISCHARGE FACTOR
], # END OF THE THIRD COMPONENT
] # END OF NET COMPONENTS
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. YOU CAN ADD NEW SEQUENCES.
); # If the alphabetical order is not accepted as an order to propagate constraints, a new order can be specificed
# WITH THE FOLLOWING VARIABLES:
# @node_letters AND @component_letters 


@constrain_net111 = (
["y", # apply constraints to nets? "y" or "n".
"/nets/cell.afn", # source file
"/nets/cell.afn", # target file
"/opts/default_configfile_net_constraints.pl", # config file 
[ "none", "g", "i", "h", "j" ], # SURFACE LETTERS IN ZONE FOR EACH NETWORK NODE, IN THE SAME ORDER AS THEY APPEAR IN THE ".afn" FILE. THEY MUST BE AT LEAST THE SAME NUMBER OF $stepsvar. 
# ALSO THE INTERNAL NODE WILL NEED A VALUE TO BE SPECIFIED, THAT IT WON'T BE USED. IT DOESN'T MATTER WHAT IT IS. "none" IS FINE BECAUSE IT IS CLEAR. 
[ "none", "g", "k", "f", "g" ] # BASE PRESSURE COEFFICIENT LETTERS TO APPLY TO EACH NETWORK NODE, IN THE SAME ORDER AS THEY APPEAR IN THE ".afn" FILE. THEY MUST BE AT LEAST THE SAME NUMBER OF $stepsvar. 
# ALSO THE INTERNAL NODE WILL NEED A VALUE TO BE SPECIFIED, THAT IT WON'T BE USED. IT DOESN'T MATTER WHAT IT IS. "none" IS FINE BECAUSE IT IS CLEAR. # THE EXCEEDING ITEMS WILL NOT BE USED. 
# THE EXCEEDING ITEMS WILL NOT BE USED. ALSO, THESE VALUES WILL NOT BE USED IF DIFFERENT ONES WILL BE CALCULATED THROUGH PROPAGATION OF CONSTRAINTS, DEPENDING ON THE INSTRUCTIONS IN THE CONFIG FILE
], # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. YOU CAN ADD NEW SEQUENCES.
); 
# THIS FILE CAN CONTAIN USER-IMPOSED CONSTRAINTS FOR MASS-FLOW NETWORKS TO BE READ BY OPT.
# IT MAKES AVAILABLE VARIABLES REGARDING THE SETTING OF NODES IN A NETWORK.
# SPECIFICALLY, @nodes and @components.
# CURRENTLY: INTERNAL UNKNOWN AIR NODES AND BOUNDARY WIND-CONCERNED NODES.
# IT MAKES AVAILABLE VARIABLES REGARDING COMPONENTS
# CURRENTLY: WINDOWS, CRACKS, DOORS.
# ALSO, THIS FILE MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS.
# SPECIFICALLY, THE FOLLOWING VARIABLES WHICH REGARD BOTH INTERNAL AND BOUNDARY NODES.
# NOTE THAT "node_number" IS THE NUMBER OF THE NODE IN THE ".afn" ESP-r FILE. 
# $node[node_number][$node]. # EXAMPLE: $node[3][$node]. THIS IS THE LETTER OF THE THIRD NODE.
# $node[node_number][$type]
# $node[node_number][$height]. # EXAMPLE: $node[3][$height]. THIS IS THE HEIGHT OF THE 3RD NODE.
# THEN IT MAKES AVAILABLE THE FOLLOWING VARIABLES REGARDING NODES:
# $node[node_number][$volume] # REGARDING INTERNAL NODES
# $node[node_number][$azimut] # REGARDING BOUNDARY NODES
# THEN IT MAKE AVAILABLE THE FOLLOWING VARIABLES REGARDING COMPONENTS:
# $component[node_number][$area] # REGARDING SIMPLE OPENINGS
# $component[node_number][$width] # REGARDING CRACKS
# $component[node_number][$length] # REGARDING CRACKS
# $component[node_number][$door_width] # REGARDING DOORS
# $component[node_number][$door_height] # REGARDING DOORS
# $component[node_number][$door_nodeheight] # REGARDING DOORS
# $component[node_number][$door_discharge] # REGARDING DOORS (DISCHARGE FACTOR)
# ALSO, THIS FILE MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS 
# AND THE STEPS THE MODEL HAVE TO FOLLOW.
# THIS ALLOWS TO IMPOSE EQUALITY CONSTRAINTS TO THESE VARIABLES, 
# WHICH COULD ALSO BE COMBINED WITH THE FOLLOWING ONES: 
# $stepsvar, WHICH TELLS THE PROGRAM HOW MANY ITERATION STEPS IT HAS TO DO IN THE CURRENT MORPHING PHASE.
# $counterzone, WHICH TELLS THE PROGRAM WHAT OPERATION IS BEING EXECUTED IN THE CHAIN OF OPERATIONS 
# THAT MAY BE EXECUTES AT EACH MORPHING PHASE. EACH $counterzone WILL CONTAIN ONE OR MORE ITERATION STEPS.
# TYPICALLY, IT WILL BE USED FOR A ZONE, BUT NOTHING PREVENTS THAT SEVERAL OF THEM CHAINED ONE AFTER 
# THE OTHER ARE APPLIED TO THE SAME ZONE.
# $counterstep, WHICH TELLS THE PROGRAM WHAT THE CURRENT ITERATION STEP IS.
# If the alphabetical order is not accepted as an order to propagate constraints, a new order can be specificed
# WITH THE FOLLOWING VARIABLES: @vertexletters (FOR GEOMETRY EDITING), @obs_letters (FOR OBSTRUCTIONS), 
# @node_letters AND @component_letters (FOR NETS), @letters AND @period_letters (FOR CONTROLS)

@propagate_constraints111 = (
["y", # apply constraints to nets? "y" or "n".
[ "read_geo", # what to do
"/zones/zone.geo", # source file
"/zones/zone.geo", # target file
"/opts/default_configfile_constraints.pl", # config file 
[ "k", "l", "m", "n"], # vertex letters to be changed.
"y" # ARE THERE LONG MENUS? "y" or "n".
],
["read_net", # what to do
"/nets/cell.afn", # source file
"/nets/cell.afn", # target file
"/opts/default_configfile_constraints.pl", # config file 
[ "none", "g", "i", "h", "j" ], # SURFACE LETTERS IN ZONE FOR EACH NETWORK NODE, IN THE SAME ORDER AS THEY APPEAR IN THE ".afn" FILE. THEY MUST BE AT LEAST THE SAME NUMBER OF $stepsvar. 
# ALSO THE INTERNAL NODE WILL NEED A VALUE TO BE SPECIFIED, THAT IT WON'T BE USED. IT DOESN'T MATTER WHAT IT IS. "none" IS FINE BECAUSE IT IS CLEAR. 
[ "none", "g", "k", "f", "g" ] # BASE PRESSURE COEFFICIENT LETTERS TO APPLY TO EACH NETWORK NODE, IN THE SAME ORDER AS THEY APPEAR IN THE ".afn" FILE. THEY MUST BE AT LEAST THE SAME NUMBER OF $stepsvar. 
# ALSO THE INTERNAL NODE WILL NEED A VALUE TO BE SPECIFIED, THAT IT WON'T BE USED. IT DOESN'T MATTER WHAT IT IS. "none" IS FINE BECAUSE IT IS CLEAR. # THE EXCEEDING ITEMS WILL NOT BE USED. 
# THE EXCEEDING ITEMS WILL NOT BE USED. ALSO, THESE VALUES WILL NOT BE USED IF DIFFERENT ONES WILL BE CALCULATED THROUGH PROPAGATION OF CONSTRAINTS, DEPENDING ON THE INSTRUCTIONS IN THE CONFIG FILE
], 
[ "read_obs", # what to do
"/zones/zone.geo", # source file
"/zones/zone.geo", # target file
"/opts/default_configfile_constraints.pl", # config file 
[ "e", "f", "g", "h"], # obstruction letters to be changed.
"n" # act on materials too? "y" or "n". That materials letters (as they appear in the material database) and not materials names have to be given in the configuration files.
],
["read_ctl", # what to do
"/ctl/cell.ctl", # source file
"/ctl/cell.ctl", # target file
"/opts/default_configfile_constraints.pl", # config file 
],
["write_ctl", # what to do
"/ctl/cell.ctl", # source file
"/ctl/cell.ctl", # target file
"/opts/default_configfile_constraints.pl", # config file 
],
["write_net", # what to do
"/nets/cell.afn", # source file
"/nets/cell.afn", # target file
"/opts/default_configfile_constraints.pl", # config file 
[ "none", "g", "i", "h", "j" ], # SURFACE LETTERS IN ZONE FOR EACH NETWORK NODE, IN THE SAME ORDER AS THEY APPEAR IN THE ".afn" FILE. THEY MUST BE AT LEAST THE SAME NUMBER OF $stepsvar. 
# ALSO THE INTERNAL NODE WILL NEED A VALUE TO BE SPECIFIED, THAT IT WON'T BE USED. IT DOESN'T MATTER WHAT IT IS. "none" IS FINE BECAUSE IT IS CLEAR. 
[ "none", "g", "k", "f", "g" ] # BASE PRESSURE COEFFICIENT LETTERS TO APPLY TO EACH NETWORK NODE, IN THE SAME ORDER AS THEY APPEAR IN THE ".afn" FILE. THEY MUST BE AT LEAST THE SAME NUMBER OF $stepsvar. 
# ALSO THE INTERNAL NODE WILL NEED A VALUE TO BE SPECIFIED, THAT IT WON'T BE USED. IT DOESN'T MATTER WHAT IT IS. "none" IS FINE BECAUSE IT IS CLEAR. # THE EXCEEDING ITEMS WILL NOT BE USED. 
# THE EXCEEDING ITEMS WILL NOT BE USED. ALSO, THESE VALUES WILL NOT BE USED IF DIFFERENT ONES WILL BE CALCULATED THROUGH PROPAGATION OF CONSTRAINTS, DEPENDING ON THE INSTRUCTIONS IN THE CONFIG FILE
], 
[ "write_geo", # what to do
"/zones/zone.geo", # source file
"/zones/zone.geo", # target file
"/opts/default_configfile_constraints.pl", # config file 
[ "k", "l", "m", "n"], # vertex letters to be changed.
"y" # ARE THERE LONG MENUS? "y" or "n".
],
[ "write_obs", # what to do
"/zones/zone.geo", # source file
"/zones/zone.geo", # target file
"/opts/default_configfile_constraints.pl", # config file 
[ "e", "f", "g", "h"], # obstruction letters to be changed.
"n" # act on materials too? "y" or "n". That materials letters (as they appear in the material database) and not materials names have to be given in the configuration files.
]
],
# END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[none], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[none], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[none], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[none] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE. YOU CAN ADD NEW SEQUENCES.
); # THIS FILE CAN CONTAIN USER-IMPOSED CONSTRAINTS FOR MASS-FLOW NETWORKS TO BE READ BY OPT.
# IT MAKES AVAILABLE VARIABLES REGARDING THE SETTING OF NODES IN A NETWORK.
# THIS FILE ALLOWS TO MANIPULATE COMPOUND USER-IMPOSED CONSTRAINTS.
# IT MAKES AVAILABLE TO THE USER THE FOLLOWING VARIABLES FOR MANIPULATION.
# IT IS POSSIBILE TO OPERATE ON GEOMETRY, CONSTRUCTIION
# REGARDING GEOMETRY:
# @v[$number][$x], @v[$number][$y], @v[$number][$z]. EXAMPLE: @v[4][$x] = 1. OR: @v[4][$x] =  @v[4][$y].
# REGARDING OBSTRUCTIONS:
# $obs[$obs_number][$x], $obs[$obs_number][$y], $obs[$obs_number][$y]
# $obs[$obs_number][$width], $obs[$obs_number][$depth], $obs[$obs_number][$height]
# $obs[$obs_number][$z_rotation], $obs[$obs_number][$y_rotation], 
# $obs[$obs_number][$tilt], $obs[$obs_number][$opacity], $obs[$obs_number][$material], 
# EXAMPLE: $obs[2][$x] = 2. THIS MEANS: COORDINATE x OF OBSTRUCTION HAS TO BE SET TO 2.
# OTHER EXAMPLE: $obs[2][$x] = $obs[2][$y]. THIS MEANS: 
# NOTE THAT THE MATERIAL TO BE SPECIFIED IS A MATERIAL LETTER, BETWEEN QUOTES! EXAMPLE: $obs[1][$material] = "a".
#  $tilt IS PRESENTLY UNUSED.
# REGARDING MASS-FLOW NETWORKS:
# @nodes and @components.
# CURRENTLY: INTERNAL UNKNOWN AIR NODES AND BOUNDARY WIND-CONCERNED NODES.
# IT MAKES AVAILABLE VARIABLES REGARDING COMPONENTS
# CURRENTLY: WINDOWS, CRACKS, DOORS.
# ALSO, THIS FILE MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS.
# SPECIFICALLY, THE FOLLOWING VARIABLES WHICH REGARD BOTH INTERNAL AND BOUNDARY NODES.
# NOTE THAT "node_number" IS THE NUMBER OF THE NODE IN THE ".afn" ESP-r FILE. 
# $node[node_number][$node]. # EXAMPLE: $node[3][$node]. THIS IS THE LETTER OF THE THIRD NODE.
# $node[node_number][$type]
# $node[node_number][$height]. # EXAMPLE: $node[3][$height]. THIS IS THE HEIGHT OF THE 3RD NODE.
# THEN IT MAKES AVAILABLE THE FOLLOWING VARIABLES REGARDING NODES:
# $node[node_number][$volume] # REGARDING INTERNAL NODES
# $node[node_number][$azimut] # REGARDING BOUNDARY NODES
# THEN IT MAKE AVAILABLE THE FOLLOWING VARIABLES REGARDING COMPONENTS:
# $component[node_number][$area] # REGARDING SIMPLE OPENINGS
# $component[node_number][$width] # REGARDING CRACKS
# $component[node_number][$length] # REGARDING CRACKS
# $component[node_number][$door_width] # REGARDING DOORS
# $component[node_number][$door_height] # REGARDING DOORS
# $component[node_number][$door_nodeheight] # REGARDING DOORS
# $component[node_number][$door_discharge] # REGARDING DOORS (DISCHARGE FACTOR)
# REGARDING CONTROLS:
# 1) $loop_control[$countloop][$countloopcontrol][$loop_hour] 
# Where $countloop and  $countloopcontrol has to be set to a specified number in the OPT file for constraints.
# 2) $loop_control[$countloop][$countloopcontrol][$max_heating_power] # Same as above.
# 3) $loop_control[$countloop][$countloopcontrol][$min_heating_power] # Same as above.
# 4) $loop_control[$countloop][$countloopcontrol][$max_cooling_power] # Same as above.
# 5) $loop_control[$countloop][$countloopcontrol][$min_cooling_power] # Same as above.
# 6) $loop_control[$countloop][$countloopcontrol][heating_setpoint] # Same as above.
# 7) $loop_control[$countloop][$countloopcontrol][cooling_setpoint] # Same as above.
# 8) $flow_control[$countflow][$countflowcontrol][$flow_hour] 
# Where $countflow and  $countflowcontrol has to be set to a specified number in the OPT file for constraints.
# 9) $flow_control[$countflow][$countflowcontrol][$flow_setpoint] # Same as above.
# 10) $flow_control[$countflow][$countflowcontrol][$flow_onoff] # Same as above.
# 11) $flow_control[$countflow][$countflowcontrol][$flow_fraction] # Same as above.
# EXAMPLE : $flow_control[1][2][$flow_fraction] = 0.7
# OTHER EXAMPLE: $flow_control[1][2][$flow_fraction] = $flow_control[2][1][$flow_fraction]
# If the alphabetical order is not accepted as an order to propagate constraints, a new order can be specificed
# WITH THE FOLLOWING VARIABLES: @vertexletters (FOR GEOMETRY EDITING), @obs_letters (FOR OBSTRUCTIONS), 
# @node_letters AND @component_letters (FOR NETS), @letters AND @period_letters (FOR CONTROLS)
# FINALLY, ALL THE VARIABLES SPECIFIED IN THIS FILE CAN BE ACCESSED. FOR EXAMPLE: $recalculateish1, $translate2, ETC.
# THE VARIABLE AT THE CURRENT SEARCH STEP CAN BE NAMED WITHOUT THE NUMBER. EXAMPLE: $recalculateish, $translate, ETC.


$recalculateish111 = 
"n"; 
# recalculate the solar radiation? "y" or "n". This way the "ish" module is launched just at the end of a whole morphing operation, and not at every sub-operations composing it.

@recalculatenet1 = ( # here the net is re-set using new pressure coefficients.
"n", 
# recalculate the mass-flow network? y" or "n";
"cell.afn", 
# path to the file, starting from a model's root directory. Example: "./nets/cell.afn".
[[
"a"
], # zone letter; if a wind boundary node, put also: letters of the surfaces
[
"a", "g", "g"
], # letters of the surfaces. 
[
"a", "h", "g"
]]); # letters for the set of pressure coefficients. BE CAREFUL: after "r" pressure coefficient letters does not work anymore. This has to be fixed. "g" is semi-exposed long wall. 

@daylightcalc1 = (   ##### THIS VARIABLE GOVERNS A FUNCTION WHICH LAUNCHED DAYLIGHT FACTOR CALCULATION THROUGH RADIANCE. PLEASE NOTICE THAT EVEN THIS FUNCTION PRESENTLY WORKS ONLY FOR A SINGLE ZONE. ALSO NOTICE THAT THIS OPERATION HAS NOT YET BEEN WRITTEN TO BE USED IN SEQUENCE WITH OTHER OPERATIONS IN THE SAME MORPHING PHASE. SO USE IT IN THE FIRST SEQUENCE OF THIS PHASE, AND KEEP JUST ONE SEQUENCE IN THIS PHASE.
"n", 
# compute daylight factors? "y" or "n". 
"a", 
# zone letter
"f", 
# surface with respect to which daylight factors have to be calculated
"a", 
# "a" for Inside, "b" for Outside: what daylight factor have to be calculated with respect to
"f", # edge with respect to which the first row has to be calculated
"0.9", 
# distance from surface
"1 2", 
#  grid layout density
"5", 
# level of accuracy, for convergence in calculations
"cell_Day_fa.df" 
# name of daylight factor file
); #


$skip111 = " if ( ($$translate[$counterzone][2][0] > 2) or ($$translate[$counterzone][2][0] < 8 ) ) "; 
# THIS IS AN EXAMPLE OF CONDITION TO SKIP SOME TESTS. THIS IS A CONDITION WRITTEN IN PERL AND CAN BE AS COMPLEX AS YOU WANT.
# IT WILL BE EVALED BY THE PROGRAM TO SKIP AN INSTANCE IF CONDITION YOU HAVE SPECIFIED IS MET.


$constrain111 = "
if ( ($$translate[$counterzone][2][0] > 2) or ($$translate[$counterzone][2][0] < 8 ) ) { $something1 = $something2 ; } 
"; # perl instructions for propagation of constraints can be specified here.
# All the variables here specified in the comments to "@propagate_constraints" can be used,
# If the alphabetical order is not accepted as an order to propagate constraints, a new order can be specificed
# WITH THE FOLLOWING VARIABLES: @vertexletters (FOR GEOMETRY EDITING), "@obs_letters" (FOR OBSTRUCTIONS), 
# "@node_letters" AND "@component_letters" (FOR NETS), "@letters" AND "@period_letters" (FOR CONTROLS)
# To propagate dhe constraints, the "$constrain" variable must be used together with an operation
# activated by the existence of a file for propagation of constraints, even if that file is void.
# But even if such a file is no void, the condition specified in the variable "$constrain"
# will be able to access and modify all the variables in the present OPT condifuration file, as
# for example "$traslate2", or "$translate" (when referred to the current iteration).

############################## HERE FOLLOWS THE DESCRIPTION OF MORPHING PHASE NUMBER 112, AS AN EXAMPLE ##########################
$stepsvar112 =
3
; #  Number of steps for this variable.  This should better be an odd number, since this way one number will be the central one, which is, the one already supplied in the starting model;

@applytype2 =  ( [   ##### @applytype = (["type_of_change", "your_test_file", "target_file", "zone_letter"]). 
# THIS REPRESENTS A FIRST CYCLE OF ACTIONS, THAT MAY BE THE ONLY ONE FOR THIS MORPHING CYCLE. Presently, the following morphing operations are available: "translation", "rotation", "rotationz", "surface_translation", "vertexes_shift", "surface_rotation", "warping", "construction_reassignment", "thickness_change", "obs_modification", "control_management", "generic_change". # "Target file" here means: "file name to which the test file has to be copied to".
"surface_translation", 
###  type_of_change
"zone.cfg", 
### your_test_file
"zone.cfg", 
###  target_file. If it is the same as above, no copying is done.
"a"
], # zone letter. (See the ESP-r model.)
["unused", "zone.cfg", "zone.cfg", "a"], 
# OPTIONAL. ERASE IF IT IS UNUSED. THIS MAY REPRESENT A SECOND CYCLE OF ACTIONS, ADDED TO THE PREVIOUS ONE THE THE SAME MORPHING PHASE. YOU HAVE TO FILL THE DATA BY YOUSELF FOLLOWING THE EXAMPLE OF THE FIELDS FOR THE FIRST CYCLE. IF YOU DON'T PLAN TO USE IT, "unused" HAS TO BE WRITTEN IN THE FIRST FIELD HERE. 
["unused", "zone.cfg", "zone.cfg", "a"], 
# OPTIONAL. ERASE IF IT IS UNUSED. THIS MAY REPRESENT A THIRD CYCLE OF ACTIONS, ADDED TO THE PREVIOUS ONE THE THE SAME MORPHING PHASE. YOU HAVE TO FILL THE DATA BY YOUSELF FOLLOWING THE EXAMPLE OF THE FIELDS FOR THE FIRST CYCLE. IF YOU DON'T PLAN TO USE IT, "unused" HAS TO BE WRITTEN IN THE FIRST FIELD HERE. 
["unused", "zone.cfg", "zone.cfg", "a"], 
# OPTIONAL. ERASE IF IT IS UNUSED. THIS MAY REPRESENT A FOURTH CYCLE OF ACTIONS, ADDED TO THE PREVIOUS ONE THE THE SAME MORPHING PHASE. YOU HAVE TO FILL THE DATA BY YOUSELF FOLLOWING THE EXAMPLE OF THE FIELDS FOR THE FIRST CYCLE. IF YOU DON'T PLAN TO USE IT, "unused" HAS TO BE WRITTEN IN THE FIRST FIELD HERE. 
["unused", "zone.cfg", "zone.cfg", "a"]
); # OPTIONAL. ERASE IF IT IS UNUSED. THIS MAY REPRESENT A FIFTH CYCLE OF ACTIONS, ADDED TO THE PREVIOUS ONE THE THE SAME MORPHING PHASE. YOU HAVE TO FILL THE DATA BY YOUSELF FOLLOWING THE EXAMPLE OF THE FIELDS FOR THE FIRST CYCLE. IF YOU DON'T PLAN TO USE IT, "unused" HAS TO BE WRITTEN IN THE FIRST FIELD HERE. MORE CYCLES CAN BE ADDED.

@copy_config2 = ([ "file_old" , # file to be substituted
"file_new" ] , # file that substitutes
# END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
);

$general_variables112 = [
"y", 
# generate other models by branching? "y" or "n". (Be careful of the exponential growth of the number of cases).
"n" 
# attach the morphing operation of the next morphing phase to the present one without generating new cases? If "yes", you'll see the symbol "" attached to file names in place of "_" for morphed models.
];

$translate112 =  [ [  #####  @applytype1 = (["translation", "file_name.geo", "target_file_name.geo",
"y", 
# translate zone?   "y” or “n”.
"n", 
# translate obstructions? "y" or "n".
["9", 
# coordinate “x” for one extreme of the swing.  The other one will be simmetrical along the line.
"0",  
# coordinate “y” for one extreme of the swing.  The other one will be simmetrical along the line.
"0"], 
# coordinate “z” for one extreme of the swing.  The other one will be simmetrical along the line.
"c", 
# update radiation calculation with the "ish" module?  "a" for yes and "c" for no (= continue).
] , # END OF DATA FOR THE FIRST SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. SECOND SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. THIRD SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused], # OPTIONAL. FOURTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
[unused] # OPTIONAL. FIFTH SEQUENCE OF OPERATIONS IN THIS MORPHING PHASE.
];

$skip112 = ""; 
# THIS IS AN EXAMPLE OF CONDITION TO SKIP SOME TESTS. THIS IS A CONDITION WRITTEN IN PERL AND CAN BE AS COMPLEX AS YOU WANT.
# IT WILL BE EVALED BY THE PROGRAM TO SKIP AN INSTANCE IF CONDITION YOU HAVE SPECIFIED IS MET. NONE, IN THIS CASE

### … AND SO ON FOR ALL THE OTHER VARIABLES AND SEARCH CYCLE NUMBERS. ALL ONE HAVE TO DO IS CHANGE THE NUMBER OF THE VARIABLES FOR EACH CYCLE. (EXAMPLE: @applytype1 FOR CYCLE 1, @applytype2 FOR CYCLE TO, AND SO ON.) AND IF IN A CERTAIN CYCLE A VARIABLE IS NOT USED, IT HAS NOT TO BE SPECIFIED. JUST FEW VARIABLE ARE MANDATORY FOR EACH CYCLE: $stepsvar, @applytype and $general_variables . THE ORDER OF THE CYCLES TO BE FOLLOWED IS SPECIFIED BY @varnumbers .

1; # <- LEAVE THIS “1! HERE.
