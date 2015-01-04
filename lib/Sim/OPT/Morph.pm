package Sim::OPT::Morph;
# Copyright (C) 2008-2014 by Gian Luca Brunetti and Politecnico di Milano.
# This is the module Sim::OPT::Morph of Sim::OPT, a program for detailed metadesign managing parametric explorations through the ESP-r building performance simulation platform and performing optimization by block coordinate descent.
# This is free software.  You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.

use v5.14;
# use v5.20;
use Exporter;
use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Math::Trig;
use Math::Round;
use List::Util qw[ min max reduce shuffle];
use List::MoreUtils qw(uniq);
use List::AllUtils qw(sum);
use Statistics::Basic qw(:all);
use Set::Intersection;
use List::Compare;
use IO::Tee;
use Data::Dumper;
use Sim::OPT;
use Sim::OPT::Sim;
use Sim::OPT::Retrieve;
use Sim::OPT::Report;
use Sim::OPT::Descend;
use Sim::OPT::Takechance;
#$Data::Dumper::Indent = 0;
#$Data::Dumper::Useqq  = 1;
#$Data::Dumper::Terse  = 1;
use Data::Dump qw(dump);
use feature 'say';
#use feature qw(postderef);
#no warnings qw(experimental::postderef);
#use Sub::Signatures;
#no warnings qw(Sub::Signatures); 
#no strict 'refs';
no strict; 
no warnings;

@ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( 
morph translate translate_surfaces_simple translate_surfaces rotate_surface translate_vertexes shift_vertexes rotate 
rotatez make_generic_change reassign_construction change_thickness obs_modify bring_obstructions_back 
recalculateish daylightcalc daylightcalc_other change_config checkfile change_climate recalculatenet apply_constraints 
reshape_windows warp constrain_geometry read_geometry read_geo_constraints apply_geo_constraints vary_controls 
calc_newctl checkfile constrain_controls read_controls read_control_constraints apply_loopcontrol_changes 
apply_flowcontrol_changes constrain_obstructions read_obstructions read_obs_constraints apply_obs_constraints 
get_obstructions write_temporary pin_obstructions apply_pin_obstructions vary_net read_net apply_node_changes 
apply_component_changes constrain_net read_net_constraints propagate_constraints 
); # our @EXPORT = qw( );

$VERSION = '0.40.0'; # our $VERSION = '';


##############################################################################
# HERE FOLLOWS THE CONTENT OF "Morph.pm", Sim::OPT::Morph.
##############################################################################

sub morph
{
	my $swap = shift; #say $tee "swapINMORPH: " . dump($swap);
	my %dat = %$swap;
	my @instances = @{ $dat{instances} }; #say "scalar(\@instances): " . scalar(@instances);
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase); # IT WILL BE SHADOWED. CUT ZZZ
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock); # IT WILL BE SHADOWED. CUT ZZZ		
	my %dirfiles = %{ $dat{dirfiles} }; #say "dump(\%dirfiles): " . dump(%dirfiles); 
		
	$configfile = $main::configfile; #say "dump(\$configfile): " . dump($configfile);
	@sweeps = @main::sweeps; #say "dump(\@sweeps): " . dump(@sweeps);
	@varinumbers = @main::varinumbers; #say "dump(\@varinumbers): " . dump(@varinumbers);
	@mediumiters = @main::mediumiters;
	@rootnames = @main::rootnames; #say "dump(\@rootnames): " . dump(@rootnames);
	%vals = %main::vals; #say "dump(\%vals): " . dump(%vals);
	
	$mypath = $main::mypath;  #say $tee "dumpINMORPH(\$mypath): " . dump($mypath);
	$exeonfiles = $main::exeonfiles; #say $tee "dumpINMORPH(\$exeonfiles): " . dump($exeonfiles);
	$generatechance = $main::generatechance; 
	$file = $main::file;
	$preventsim = $main::preventsim;
	$fileconfig = $main::fileconfig; #say $tee "dumpINMORPH(\$fileconfig): " . dump($fileconfig); # NOW GLOBAL. TO MAKE IT PRIVATE, FIX PASSING OF PARAMETERS IN CONTRAINTS PROPAGATION SECONDARY SUBROUTINES
	$outfile = $main::outfile;
	$toshell = $main::toshell;
	$report = $main::report;
	$simnetwork = $main::simnetwork;
	$reportloadsdata = $main::reportloadsdata;
	
	$tee = new IO::Tee(\*STDOUT, ">>$toshell"); # GLOBAL ZZZ
	
	open ( OUTFILE, ">>$outfile" ) or die "Can't open $outfile: $!"; 
	open ( TOSHELL, ">>$toshell" ) or die "Can't open $toshell: $!"; 
	say $tee "\n# Now in Sim::OPT::Morph.\n";
	
	%dowhat = %main::dowhat;

	@themereports = @main::themereports; #say "dumpINMORPH(\@themereports): " . dump(@themereports);
	@simtitles = @main::simtitles; #say "dumpINMORPH(\@simtitles): " . dump(@simtitles);
	@reporttitles = @main::reporttitles;
	@simdata = @main::simdata;
	@retrievedata = @main::retrievedata;
	@keepcolumns = @main::keepcolumns;
	@weights = @main::weights;
	@weightsaim = @main::weightsaim;
	@varthemes_report = @main::varthemes_report;
	@varthemes_variations = @vmain::arthemes_variations;
	@varthemes_steps = @main::varthemes_steps;
	@rankdata = @main::rankdata; # CUT ZZZ
	@rankcolumn = @main::rankcolumn;
	@reporttempsdata = @main::reporttempsdata;
	@reportcomfortdata = @main::reportcomfortdata;
	@reportradiationenteringdata = @main::reportradiationenteringdata;
	@reporttempsstats = @main::reporttempsstats;
	@files_to_filter = @main::files_to_filter;
	@filter_reports = @main::filter_reports;
	@base_columns = @main::base_columns;
	@maketabledata = @main::maketabledata;
	@filter_columns = @main::filter_columns;
	
	my @simcases = @{ $dirfiles{simcases} }; #say "dump(\@simcases): " . dump(@simcases);
	my @simstruct = @{ $dirfiles{simstruct} }; #say "dump(\@simstruct): " . dump(@simstruct);
	my @morphcases = @{ $dirfiles{morphcases} };
	my @morphstruct = @{ $dirfiles{morphstruct} };
	my @retcases = @{ $dirfiles{retcases} };
	my @retstruct = @{ $dirfiles{retstruct} };
	my @repcases = @{ $dirfiles{repcases} };
	my @repstruct = @{ $dirfiles{repstruct} };
	my @mergecases = @{ $dirfiles{mergecases} };
	my @mergestruct = @{ $dirfiles{mergestruct} };
	my @descendcases = @{ $dirfiles{descendcases} };
	my @descendstruct = @{ $dirfiles{descendstruct} };
	
	my $morphlist = $dirfiles{morphlist}; #say "dump(\$dat{morphlist}): " . dump($dat{morphlist});
	my $morphblock = $dirfiles{morphblock};
	my $simlist = $dirfiles{simlist}; #say "dump(\$simlist): " . dump($simlist);
	my $simblock = $dirfiles{simblock};
	my $retlist = $dirfiles{retlist};
	my $retblock = $dirfiles{retblock};
	my $replist = $dirfiles{replist};
	my $repblock = $dirfiles{repblock};
	my $descendlist = $dirfiles{descendlist};
	my $descendblock = $dirfiles{descendblock};
	
	#my $getpars = shift;
	#eval( $getpars );

	#if ( fileno (MORPHLIST) 
	
	$countinstance = 1;
	foreach my $instance (@instances)
	{	
		my %d = %{$instance};
		my $countcase = $d{countcase}; #say $tee "#dump(\$countcase): " . dump($countcase);
		my $countblock = $d{countblock}; #say $tee "#dump(\$countblock): " . dump($countblock);
		my @miditers = @{ $d{miditers} }; #say $tee "#MORPH dump(\@miditers): " . dump(@miditers);
		my @winneritems = @{ $d{winneritems} }; #say $tee "#dumpIN( \@winneritems) " . dump(@winneritems);
		my $countvar = $d{countvar}; #say $tee "#dump(\$countvar): " . dump($countvar);
		my $countstep = $d{countstep}; #say $tee "#dump(\$countstep): " . dump($countstep);						
		my $to = $d{to}; #say $tee "#dump(\$to): " . dump($to);
		my $origin = $d{origin}; #say $tee "#dump(\$origin): " . dump($origin);
		my @uplift = @{ $d{uplift} }; #say $tee "#dump(\@uplift): " . dump(@uplift);
		#eval($getparshere);
		
		my $rootname = Sim::OPT::getrootname(\@rootnames, $countcase); #say $tee "#dump(\$rootname): " . dump($rootname);
		my @blockelts = Sim::OPT::getblockelts(\@sweeps, $countcase, $countblock); #say $tee "#dumpIN( \@blockelts) " . dump(@blockelts);
		my @blocks = Sim::OPT::getblocks(\@sweeps, $countcase);  #say $tee "#dumpIN( \@blocks) " . dump(@blocks);
		my $toitem = Sim::OPT::getitem(\@winneritems, $countcase, $countblock); #say $tee "#dump(\$toitem): " . dump($toitem);
		my $from = Sim::OPT::getline($toitem); #say $tee "#dumpIN(\$from): " . dump($from);
		my %varnums = Sim::OPT::getcase(\@varinumbers, $countcase); #say $tee "#dumpIN---(\%varnums): " . dump(%varnums); 
		my %mids = Sim::OPT::getcase(\@miditers, $countcase); #say $tee "#dumpIN---(\%mids): " . dump(%mids); 
		#eval($getfly);
		
		my $stepsvar = Sim::OPT::getstepsvar($countvar, $countcase, \@varinumbers); #say $tee "#dump(\$stepsvar): " . dump($stepsvar); 
		my $varnumber = $countvar; #say $tee "#dump---(\$varnumber): " . dump($varnumber) . "\n\n";  # LEGACY VARIABLE
		
		my $countcaseplus1 = ( $countcase + 1);
		my $countblockplus1 = ( $countblock + 1);
		
		#@totblockelts = (@totblockelts, @blockelts); # @blockelts
		#@totblockelts = uniq(@totblockelts);
		#@totblockelts = sort(@totblockelts);
		#if ( $countvar == $#blockelts )
		#{
		#	$$general_variables[0] = "n";
		#} # THIS TELLS THAT IF THE SEARCH IS ENDING (LAST SUBSEARCH CYCLE) GENERATION OF CASES HAS TO BE TURNED OFF	
		####### OLD. $stepsvar = ${ "varnums{$countvar}" . "$varnumber" };
		
		my @applytype = @{ $vals{$countvar}{applytype} }; #say "dump(\@applytype): " . dump(@applytype);
		my $general_variables = $vals{$countvar}{general_variables}; #say "dump(\$general_variables): " . dump($general_variables);
		my @generic_change = @{$vals{$countvar}{generic_change} }; 
		my $rotate = $vals{$countvar}{rotate}; 
		my $rotatez = $vals{$countvar}{rotatez};
		my $translate = $vals{$countvar}{translate}; #say "dump(\$translate): " . dump($translate); 
		my $translate_surface_simple = $vals{$countvar}{translate_surface_simple};
		my $translate_surface = $vals{$countvar}{translate_surface};
		my $keep_obstructions = $vals{$countvar}{keep_obstructions};
		my $shift_vertexes = $vals{$countvar}{shift_vertexes};
		my $construction_reassignment = $vals{$countvar}{construction_reassignment};
		my $thickness_change = $vals{$countvar}{thickness_change};
		my $recalculateish = $vals{$countvar}{recalculateish};
		my @recalculatenet = @{ $vals{$countvar}{recalculatenet} };
		my $obs_modify = $vals{$countvar}{obs_modify};
		my $netcomponentchange = $vals{$countvar}{netcomponentchange};
		my $changecontrol = $vals{$countvar}{changecontrol};
		my @apply_constraints = @{ $vals{$countvar}{apply_constraints} }; # NOW SUPERSEDED BY @constrain_geometry
		my $rotate_surface = $vals{$countvar}{rotate_surface};
		my @reshape_windows = @{ $vals{$countvar}{reshape_windows} };
		my @apply_netconstraints = @{ $vals{$countvar}{apply_netconstraints} };
		my @apply_windowconstraints = @{ $vals{$countvar}{apply_windowconstraints} };
		my @translate_vertexes = @{ $vals{$countvar}{translate_vertexes} };
		my $warp = $vals{$countvar}{warp};
		my @daylightcalc = @{ $vals{$countvar}{daylightcalc} };
		my @change_config = @{ $vals{$countvar}{change_config} };
		my @constrain_geometry = @{ $vals{$countvar}{constrain_geometry} };
		my @vary_controls = @{ $vals{$countvar}{vary_controls} };
		my @constrain_controls =  @{ $vals{$countvar}{constrain_controls} };
		my @constrain_geometry = @{ $vals{$countvar}{constrain_geometry} };
		my @constrain_obstructions = @{ $vals{$countvar}{constrain_obstructions} };
		my @get_obstructions = @{ $vals{$countvar}{get_obstructions} };
		my @pin_obstructions = @{ $vals{$countvar}{pin_obstructions} };
		my $checkfile = $vals{$countvar}{checkfile};
		my @vary_net = @{ $vals{$countvar}{vary_net} };
		my @constrain_net = @{ $vals{$countvar}{constrain_net} };
		my @propagate_constraints = @{ $vals{$countvar}{propagate_constraints} };
		my @change_climate = @{ $vals{$countvar}{change_climate} };
		my $skip = $vals{$countvar}{skip};
		my $constrain = $vals{$countvar}{constrain};
		
		my (@cases_to_sim, @files_to_convert);
		my (@v, @obs, @node, @component, @loopcontrol, @flowcontrol); # THINGS globsAL AS REGARDS TO COUNTER ZONE CYCLES
		my (@myv, @myobs, @mynode, @mycomponent, @myloopcontrol, @myflowcontrol); # THINGS LOCAL AS REGARDS TO COUNTER ZONE CYCLES
		my (@tempv, @tempobs, @tempnode, @tempcomponent, @temploopcontrol, @tempflowcontrol); # THINGS LOCAL AS REGARDS TO COUNTER ZONE CYCLES
		my (@dov, @doobs, @donode, @docomponent, @doloopcontrol, @doflowcontrol); # THINGS LOCAL AS REGARDS TO COUNTER ZONE CYCLES
		
		my $generate  = $$general_variables[0];
		my $sequencer = $$general_variables[1];
		my $dffile = "df-$file.txt";	
		
		#my $toshellmorph = "$toshell" . "-1morph.txt";
		#my $outfilemorph = "$outfile" . "-1morph.txt";
		
		#open ( TOSHELL, ">>$toshellmorph" );
		#open ( OUTFILE, ">>$outfilemorph" );
		
		#say "TELL ME: " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";
				
		if ( ( $countblock == 0 ) and ( $countstep == 1 ) )
		{
			if (not ( -e "$origin" ) )
			{
				if ($exeonfiles eq "y") 
				{ 
					print `cp -R $mypath/$file $from`; #say "FROM: $from";
				}
				say TOSHELL "cp -R $mypath/$file $from\n";
			}
		}
		
		#if ( fileno (RETLIST) )
		#if (not (-e $morphlist ) )
		#{
		#	if ( $countblock == 0 )
		#	{
				open ( MORPHLIST, ">>$morphlist"); # or die;
		#	}
		#	else 
		#	{
		#		open ( MORPHLIST, ">>$morphlist"); # or die;
		#	}
		#}
		
		#if ( fileno (MORPHBLOCK) )
		#if (not (-e $morphblock ) )
		#{
		#	if ( $countblock == 0 )
		#	{
				open (MORPHBLOCK, ">>$morphblock");# or die;
		#	}
		#	else
		#	{
		#		open (MORPHBLOCK, ">>$morphblock");# or die;
		#	}		
		#}	

		push ( @{ $morphstruct[$countcase][$countblock] }, $to );
		print MORPHBLOCK "$to\n";
		if ( not ( $to ~~ @morphcases ) )
		{
			#say "HERE2. MORPHCASES.";
			push ( @morphcases, $to );
			print MORPHLIST "$to\n";

			#my $from = "$case_to_sim";
			#my $almost_to = $from;
			#$almost_to =~ s/$varnumber-\d+/$varnumber-$countstep/ ;
			#if (     ( $generate eq "n" )
			#	 and ( ( $sequencer eq "y" ) or ( $sequencer eq "last" ) ) )
			#{
			#	if ( $almost_to =~ m/§$/ ) { $to = "$almost_to" ; }
			#	else
			#	{
			#		#$to = "$case_to_sim$varnumber-$countstep§";
			#		$to = "$almost_to" . "§";
			#	}
			#} 
			#elsif ( ( $generate eq "y" ) and ( $sequencer eq "n" ) )
			#{
			#	if ( $almost_to =~ m/_$/ ) { $to = "$almost_to" ; }
			#	else
			#	{
			#		$to = "$case_to_sim$varnumber-$countstep" . "_";
			#		$to = "$almost_to" . "_";
			#		if ( $countstep == $stepsvar )
			#		{
			#			if ($exeonfiles eq "y") { print `chmod -R 777 $from\n`; }
			#			print TOSHELL "chmod -R 777 $from\n\n";
			#		}
			#	}
			#} 
			#elsif ( ( $generate eq "y" ) and ( $sequencer eq "y" ) )
			#{
			#	#$to = "$case_to_sim$varnumber-$countstep" . "£";
			#	$to = "$almost_to" . "£";
			#} 
			#elsif ( ( $generate eq "y" ) and ( $sequencer eq "last" ) )
			#{
			#	if ( $almost_to =~ m/£$/ ) { $to = "$almost_to" ; }
			#	else
			#	{
			#		#$to = "$case_to_sim$varnumber-$countstep" . "£";
			#		$to = "$almost_to" . "£";
			#		#if ( $countstep == $stepsvar )
			#		#{
			#		#	if ($exeonfiles eq "y") { print `chmod -R 777 $from\n`; }
			#		#	print TOSHELL "chmod -R 777 $from\n\n";
			#		#}
			#	}
			#} 
			#elsif ( ( $generate eq "n" ) and ( $sequencer eq "n" ) )
			#{
			#	 $almost_to =~ s/[_|£]$// ;
			#	#$to = "$case_to_sim$varnumber-$countstep";
			#	$to = "$almost_to";
			#}
			
			if ( eval $skip) { $skipask = "yes"; }
						
			if 
			#( 
				#( $generate eq "y" )
				#and ( $countstep == $stepsvar )
				#and ( ( $sequencer eq "n" ) or ( $sequencer eq "last" ) ) 
				#and ( ($skip ne "")  and ($skipask ne "yes") )
				#and 
				( not (-e $to) )
			#)
			{
				#say TOSHELL "HERE2A. MAIN. ";
			
				if ($exeonfiles eq "y") 
				{ 
					print `cp -R $origin $to\n`; 
				}
				print TOSHELL "cp -R $origin $to\n\n";
				#say "HERE2B";
				
				$countzone = 0;
				foreach my $zone (@applytype)
				{
					#say "HERE3. APPLYTYPE. ";
					my $modification_type = $applytype[$countzone][0];
					if ( ( $applytype[$countzone][1] ne $applytype[$countzone][2] )
						 and ( $modification_type ne "changeconfig" ) )
					{
						if ($exeonfiles eq "y") 
						{  
							print `cp -f $to/zones/$applytype[$countzone][1] $to/zones/$applytype[$countzone][2]\n`; 
						}
						print TOSHELL "cp -f $to/zones/$applytype[$countzone][1] $to/zones/$applytype[$countzone][2]\n\n";
						if ($exeonfiles eq "y") 
						{  
							print `cp -f $to/cfg/$applytype[$countzone][1] $to/cfg/$applytype[$countzone][2]\n`; 
						}    # ORDINARILY, THIS PART CAN BE REMOVED
						print TOSHELL "cp -f $to/cfg/$applytype[$countzone][1] $to/cfg/$applytype[$countzone][2]\n\n";
					}# ORDINARILY, THIS PART CAN BE REMOVED
					if (
						 (
						   $applytype[$countzone][1] ne $applytype[$countzone][2]
						 )
						 and ( $modification_type eq "changeconfig" )
					  )
					{
						if ($exeonfiles eq "y") 
						{ 
							print `cp -f $to/cfg/$applytype[$countzone][1] $to/cfg/$applytype[$countzone][2]\n`; 
						}
						print TOSHELL "cp -f $to/cfg/$applytype[$countzone][1] $to/cfg/$applytype[$countzone][2]\n\n"; 
					} # ORDINARILY, THIS PART CAN BE REMOVED

					#########################################################################################
					# Sim::OPT::Morph
					#########################################################################################
					#say "HERE3B";
					print `cd $to`;
					print TOSHELL "cd $to\n\n";
					
					if ( $stepsvar > 1)
					{	#say "HERE4. DOTHINGS.";
						sub dothings
						{	# THIS CONTAINS FUNCTIONS THAT APPLY CONSTRAINTS AND UPDATE CALCULATIONS.							
							#if ( $get_obstructions[$countzone][0] eq "y" )
							#{ 
							#	get_obstructions # THIS IS TO MEMORIZE OBSTRUCTIONS.
							#	# THEY WILL BE SAVED IN A TEMPORARY FILE.
							#	($to, $fileconfig, $stepsvar, $countzone, 
							#	$countstep, $exeonfiles, \@applytype, \@get_obstructions, $configfile, $countvar, $fileconfig ); 
							#}
							if ($propagate_constraints[$countzone][0] eq "y") 
							{ 
								&propagate_constraints
								($to, $stepsvar, $countzone, 
								$countstep, \@applytype, \@propagate_constraints, $countvar, $fileconfig ); 
							}
							if ($apply_constraints[$countzone][0] eq "y") 
							{ 
								&apply_constraints
								($to, $stepsvar, $countzone, 
								$countstep, \@applytype, \@constrain_geometry, $countvar, $fileconfig ); 
							}
							if ($constrain_geometry[$countzone][0] eq "y") 
							{ 
								&constrain_geometry
								($to, $stepsvar, $countzone, 
								$countstep, \@applytype, \@constrain_geometry, $countvar, $fileconfig ); 
							}
							if ($constrain_controls[$countzone][0] eq "y") 
							{ 
								&constrain_controls
								($to, $stepsvar, $countzone, 
								$countstep, \@applytype, \@constrain_controls, $countvar, $fileconfig ); 
							}
							if ($$keep_obstructions[$countzone][0] eq "y") # TO BE SUPERSEDED BY get_obstructions AND pin_obstructions
							{ 
								&bring_obstructions_back($to, $stepsvar, $countzone, 
								$countstep, \@applytype, $keep_obstructions, $countvar, $fileconfig ); 
							}
							if ($constrain_net[$countzone][0] eq "y")
							{ 
								&constrain_net($to, $stepsvar, $countzone, 
								$countstep, \@applytype, \@constrain_net, $to_do, $countvar, $fileconfig ); 
							}
							if ($recalculatenet[0] eq "y") 
							{ 
								&recalculatenet
								($to, $stepsvar, $countzone, 
								$countstep, \@applytype, \@recalculatenet, $countvar, $fileconfig ); 
							}
							if ($constrain_obstructions[$countzone][0] eq "y") 
							{ 
								&constrain_obstructions
								($to, $stepsvar, $countzone, 
								$countstep, \@applytype, \@constrain_obstructions, $to_do, $countvar, $fileconfig ); 
							}
							#if ( $pin_obstructions[$countzone][0] eq "y" ) 
							#{ 
							#	pin_obstructions ($to, $stepsvar, $countzone, 
							#	$countstep, \@applytype, $zone_letter, \@pin_obstructions, $countvar, $fileconfig ); 
							#}
							if ($recalculateish eq "y") 
							{ 
								&recalculateish
								($to, $stepsvar, $countzone, 
								$countstep, \@applytype, \@recalculateish, $countvar, $fileconfig ); 
							}
							if ($daylightcalc[0] eq "y") 
							{ 
								&daylightcalc
								($to, $stepsvar, $countzone,  
								$countstep, \@applytype, $filedf, \@daylightcalc, $countvar, $fileconfig ); 
							}
						} # END SUB DOTHINGS

						if ( $modification_type eq "generic_change" )#
						{
							&make_generic_change
							($to, $stepsvar, $countzone, $countstep,
							\@applytype, $generic_change, $countvar, $fileconfig );
							&dothings;
						} #
						elsif ( $modification_type eq "surface_translation_simple" )
						{
							&translate_surfaces_simple
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $translate_surface_simple, $countvar, $fileconfig );
							&dothings;
						} 
						elsif ( $modification_type eq "surface_translation" )
						{
							&translate_surfaces 
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $translate_surface, $countvar, $fileconfig );
							&dothings;
						} 
						elsif ( $modification_type eq "surface_rotation" )              #
						{
							&rotate_surface
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $rotate_surface, $countvar, $fileconfig );
							&dothings;
						} 
						elsif ( $modification_type eq "vertexes_shift" )
						{
							&shift_vertexes
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $shift_vertexes, $countvar, $fileconfig );
							&dothings;
						}
						elsif ( $modification_type eq "vertex_translation" )
						{
							&translate_vertexes
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, \@translate_vertexes, $countvar, $fileconfig );                         
							&dothings;
						}  
						elsif ( $modification_type eq "construction_reassignment" )
						{
							&reassign_construction
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $construction_reassignment, $countvar, $fileconfig );
							&dothings;
						} 
						elsif ( $modification_type eq "rotation" )
						{
							&rotate
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $rotate, $countvar, $fileconfig );
							&dothings;
						} 
						elsif ( $modification_type eq "translation" )
						{
							&translate
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $translate, $countvar, $fileconfig );
							&dothings;
						} 
						elsif ( $modification_type eq "thickness_change" )
						{
							&change_thickness
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $thickness_change, $countvar, $fileconfig );
							&dothings;
						} 
						elsif ( $modification_type eq "rotationz" )
						{
							&rotatez
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $rotatez, $countvar, $fileconfig  );
							&dothings;
						} 
						elsif ( $modification_type eq "change_config" )
						{
							&change_config
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, \@change_config, $countvar, $fileconfig );
							&dothings;
						}
						elsif ( $modification_type eq "window_reshapement" ) 
						{
							&reshape_windows
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, \@reshape_windows, $countvar, $fileconfig );					
							&dothings;
						}
						elsif ( $modification_type eq "obs_modification" )  # REWRITE FOR NEW GEO FILE?
						{
							&obs_modify
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $obs_modify, $countvar, $fileconfig );
							&dothings;
						}
						elsif ( $modification_type eq "warping" )
						{
							&warp
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, $warp, $countvar, $fileconfig );
							&dothings;
						}
						elsif ( $modification_type eq "vary_controls" )
						{
							&vary_controls
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, \@vary_controls, $countvar, $fileconfig );
							&dothings;
						}
						elsif ( $modification_type eq "vary_net" )
						{
							&vary_net
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, \@vary_net, $countvar, $fileconfig );
							&dothings;
						}
						elsif ( $modification_type eq "change_climate" )
						{
							&change_climate
							($to, $stepsvar, $countzone, $countstep, 
							\@applytype, \@change_climate, $countvar, $fileconfig );
							&dothings;
						} 
						elsif ( $modification_type eq "constrain_controls" )
						{
							&dothings;
						}
						#elsif ( $modification_type eq "get_obstructions" )
						#{
						#	dothings;
						#}
						#elsif ( $modification_type eq "pin_obstructions" )
						#{
						#	dothings;
						#}
						elsif ( $modification_type eq "constrain_geometry" )
						{
							&dothings;
						}
						elsif ( $modification_type eq "apply_constraints" )
						{
							&dothings;
						}
						elsif ( $modification_type eq "constrain_net" )
						{
							&dothings;
						}
						elsif ( $modification_type eq "propagate_net" )
						{
							&dothings;
						}
						elsif ( $modification_type eq "recalculatenet" )
						{
							&dothings;
						}
						elsif ( $modification_type eq "constrain_obstructions" )
						{
							&dothings;
						}
						elsif ( $modification_type eq "propagate_constraints" )
						{
							&dothings;
						}
					}
					$countzone++;
					print `cd $mypath`;
					print TOSHELL "cd $mypath\n\n";
				}
			}
			#else
			#{
			#	if ($exeonfiles eq "y") { print `cp -R $origin $to\n`; }
			#	print TOSHELL "cp -R $origin $to\n\n";
			#}
			#push(@morphed, $to);
		}
		close MORPHLIST;
		close MORPHBLOCK;
		$countinstance++;
	}
	close TOSHELL;
	close OUTFILE;
	return (\@morphcases, \@morphsruct);
}    # END SUB morph

sub translate
{
	#say "HERE5";
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $translate = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Translating zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";
	say TOSHELL "#Translating zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	if ( $stepsvar > 1 )
	{
		my $yes_or_no_translation = "$$translate[$countzone][0]";
		my $yes_or_no_translate_obstructions = "$$translate[$countzone][1]";
		my $yes_or_no_update_radiation =  $$translate[$countzone][3];
		my $configfile =  $$translate[$countzone][4];
		if ( $yes_or_no_update_radiation eq "y" )
		{
			$yes_or_no_update_radiation = "a";
		} elsif ( $yes_or_no_update_radiation eq "n" )
		{
			$yes_or_no_update_radiation = "c";
		}
		if ( $yes_or_no_translation eq "y" )
		{
			my @coordinates_for_movement = @{ $$translate[$countzone][2] };
			my $x_end = $coordinates_for_movement[0];
			my $y_end = $coordinates_for_movement[1];
			my $z_end = $coordinates_for_movement[2];
			my $x_swingtranslate = ( 2 * $x_end );
			my $y_swingtranslate = ( 2 * $y_end );
			my $z_swingtranslate = ( 2 * $z_end );
			my $x_pace = ( $x_swingtranslate / ( $stepsvar - 1 ) );
			my $x_movement = (- ( $x_end - ( $x_pace * ( $countstep - 1 ) ) ));
			my $y_pace = ( $y_swingtranslate / ( $stepsvar - 1 ) );
			my $y_movement = (- ( $y_end - ( $y_pace * ( $countstep - 1 ) ) ));
			my $z_pace = ( $z_swingtranslate / ( $stepsvar - 1 ) );
			my $z_movement = (- ( $z_end - ( $z_pace * ( $countstep - 1 ) ) ));
#say "\$fileconfig: $fileconfig";
#say "\$exeonfiles $exeonfiles";
my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
i
e
$x_movement $y_movement $z_movement
y
$yes_or_no_translate_obstructions
-
y
c
-
-
-
-
-
-
-
-
-
YYY
";

			if ($exeonfiles eq "y") 
			{ 
				print
`prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
i
e
$x_movement $y_movement $z_movement
y
$yes_or_no_translate_obstructions
-
y
c
-
-
-
-
-
-
-
-
-
YYY
`;
			}
			print TOSHELL 
"#Translating zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.\"
$printthis
";
		}
	}
}    # end sub translate

my $countcycles_transl_surfs = 0;					
#############################################################################


#############################################################################				
sub translate_surfaces_simple # THIS IS VERSION 1, THE OLD ONE. DISMISSED? IN DOUBT, DO NOT USE IT. 
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $translate_surface_simple = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Translating surfaces for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $yes_or_no_transl_surfs =
	  $$translate_surface_simple[$countzone][0];
	my @surfs_to_transl =
	  @{ $translate_surface_simple->[$countzone][1] };
	my @ends_movs =
	  @{ $translate_surface_simple->[$countzone][2]
	  };    # end points of the movements.
	my $yes_or_no_update_radiation =
	  $$translate_surface_simple[$countzone][3];
	my $firstedge_constrainedarea = $$translate_surface_simple[$countzone][4][0];
	my $secondedge_constrainedarea = $$translate_surface_simple[$countzone][4][1];
	my $constrainedarea = ($firstedge_constrainedarea * $secondedge_constrainedarea);
	my @swings_surfs = map { $_ * 2 } @ends_movs;
	my @surfs_to_transl_constrainedarea =
	  @{ $translate_surface_simple->[$countzone][5] };
	my $countsurface = 0;
	my $end_mov;
	my $mov_surf;
	my $pace;
	my $movement;
	my $surface_letter_constrainedarea;
	my $movement_constrainedarea;

	if ( $yes_or_no_transl_surfs eq "y" )
	{
		foreach my $surface_letter (@surfs_to_transl)
		{
			if ( $stepsvar > 1 )
			{
				$end_mov = $ends_movs[$countsurface];
				$swing_surf = $end_mov * 2;
				$pace = ( $swing_surf / ( $stepsvar - 1 ) );
				$movement =
				  ( - ( ($end_mov) -
					( $pace * ( $countstep - 1 ) ) ) );
				$surface_letter_constrainedarea = $surfs_to_transl_constrainedarea[$countsurface];
				$movement_constrainedarea = 
				( ( ( $constrainedarea / ( $firstedge_constrainedarea + ( 2 * $movement ) ) ) - $secondedge_constrainedarea) /2);

				my $printthis = 
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
e
>
$surface_letter
a
$movement
y
-
-
y
c
-
-
-
-
-
-
-
-
YYY\n\n";
				if ($exeonfiles eq "y") 
				{ 
					print `$printthis`;
				}
				print TOSHELL $printthis;

				my $printthis = 
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
e
>
$surface_letter_constrainedarea
a
$movement_constrainedarea
y
-
-
y
c
-
-
-
-
-
-
-
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{ 
					print `$printthis`;
				}
				print TOSHELL $printthis;

				$countsurface++;
				$countcycles_transl_surfs++;
			}
		}
	}
}    # end sub translate_surfaces_simple								
######################################################################					


######################################################################
sub translate_surfaces
{
	my $to = shift; #say "got \$to : " . dump($to);
	my $stepsvar = shift;  #say "got \$stepsvar : " . dump($stepsvar);
	my $countzone = shift; #say "got \$countzone : " . dump($countzone);
	my $countstep = shift; #say "got \$countstep : " . dump($countstep);
	my $swap = shift; #say "got \$swap : " . dump($swap);
	my @applytype = @$swap; #say "got \@applytype : " . dump(@applytype);
	my $zone_letter = $applytype[$countzone][3]; #say "got \$zone_letter : " . dump($zone_letter);
	my $translate_surface = shift; #say "got \$translate_surface : " . dump($translate_surface);
	my $countvar = shift; #say "got \$countvar : " . dump($countvar);
	my $fileconfig = shift;
	
	say "Translating surfaces for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $yes_or_no_transl_surfs = $$translate_surface[$countzone][0];
	my $transform_type = $$translate_surface[$countzone][1];
	my @surfs_to_transl = @{ $translate_surface->[$countzone][2] };
	my @ends_movs = @{ $translate_surface->[$countzone][3] };    # end points of the movements.
	my $yes_or_no_update_radiation = $$translate_surface[$countzone][4];
	my @transform_coordinates = @{ $translate_surface->[$countzone][5] };
	my $countsurface = 0;
	my $end_mov;
	my $mov_surf;
	my $pace;
	my $movement;
	my $surface_letter_constrainedarea;
	my $movement_constrainedarea;

	if ( $yes_or_no_transl_surfs eq "y" )
	{
		foreach my $surface_letter (@surfs_to_transl)
			{
				if ( $stepsvar > 1 )
				{
					if ($transform_type eq "a")
					{
						$end_mov = $ends_movs[$countsurface];
						$swing_surf = $end_mov * 2;
						$pace = ( $swing_surf / ( $stepsvar - 1 ) );
						$movement = ( - ( ($end_mov) -( $pace * ( $countstep - 1 ) ) ) );
						
						my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
e
>
$surface_letter
$transform_type
$movement
y
-
-
y
c
-
-
-
-
-
-
-
-
YYY
";

						if ($exeonfiles eq "y") { 
						print `$printthis`;
					}
					print TOSHELL "
#Translating surfaces for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance
$printthis";

					$countsurface++;
					$countcycles_transl_surfs++;
				}
				elsif ($transform_type eq "b")
				{
					my @coordinates_for_movement = 
					@{ $transform_coordinates[$countsurface] };
					my $x_end = $coordinates_for_movement[0];
					my $y_end = $coordinates_for_movement[1];
					my $z_end = $coordinates_for_movement[2];
					my $x_swingtranslate = ( 2 * $x_end );
					my $y_swingtranslate = ( 2 * $y_end );
					my $z_swingtranslate = ( 2 * $z_end );
					my $x_pace = ( $x_swingtranslate / ( $stepsvar - 1 ) );
					my $x_movement = (- ( $x_end - ( $x_pace * ( $countstep - 1 ) ) ));
					my $y_pace = ( $y_swingtranslate / ( $stepsvar - 1 ) );
					my $y_movement = (- ( $y_end - ( $y_pace * ( $countstep - 1 ) ) ));
					my $z_pace = ( $z_swingtranslate / ( $stepsvar - 1 ) );
					my $z_movement = (- ( $z_end - ( $z_pace * ( $countstep - 1 ) ) ));

					my $printthis = 
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
e
>
$surface_letter
$transform_type
$x_movement $y_movement $z_movement
y
-
-
y
c
-
-
-
-
-
-
-
-
YYY
";

					if ($exeonfiles eq "y") 
					{ 
						print `$printthis`;
					}

					print TOSHELL "
#Translating surfaces for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance
$printthis";

					$countsurface++;
					$countcycles_transl_surfs++;
				}
			}
		}
	}								
}    # END SUB translate_surfaces
##############################################################################


##############################################################################
sub rotate_surface
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $rotate_surface = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Rotating surfaces for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";
	
	my $yes_or_no_rotate_surfs =  $$rotate_surface[$countzone][0];
	my @surfs_to_rotate =  @{ $rotate_surface->[$countzone][1] };
	my @vertexes_numbers =  @{ $rotate_surface->[$countzone][2] };   
	my @swingrotations = @{ $rotate_surface->[$countzone][3] };
	my @yes_or_no_apply_to_others = @{ $rotate_surface->[$countzone][4] };
	my $configfile = $$rotate_surface[$countzone][5];

	if ( $yes_or_no_rotate_surfs eq "y" )
	{
		my $countrotate = 0;
		foreach my $surface_letter (@surfs_to_rotate)
		{
			$swingrotate = $swingrotations[$countrotate];
			$pacerotate = ( $swingrotate / ( $stepsvar - 1 ) );
			$rotation_degrees = 
			( ( $swingrotate / 2 ) - ( $pacerotate * ( $countstep - 1 ) )) ;
			$vertex_number = $vertexes_numbers[$countrotate];
			$yes_or_no_apply = $yes_or_no_apply_to_others[$countrotate];
			if (  ( $swingrotate != 0 ) and ( $stepsvar > 1 )  and ( $yes_or_no_rotate_surfs eq "y" ) )
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
e
>
$surface_letter
c
$vertex_number
$rotation_degrees
$yes_or_no_apply
-
-
y
c
-
-
-
-
-
-
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{ 
					print `$printthis`;
				}

				print  TOSHELL "
Rotating surfaces for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance
$printthis";
			}
			$countrotate++;
		}
	}
}    # END SUB rotate_surface
##############################################################################



##############################################################################
sub translate_vertexes #STILL UNFINISHED, NOT WORKING. PROBABLY ALMOST FINISHED. The reference to @base_coordinates is not working.
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap2 = shift;
	my @translate_vertexes = @$swap2;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Translating vertexes for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";
	
	my @v;
	my @verts_to_transl = @{ $translate_vertexes[$countzone][0] };
	my @transform_coordinates = @{ $translate_vertexes[$countzone][1] };
	my @sourcefiles = @{ $translate_vertexes[$countzone][2] };
	my @targetfiles = @{ $translate_vertexes[$countzone][3] };
	my @configfiles = @{ $translate_vertexes[$countzone][4] };
	my @longmenus = @{ $translate_vertexes[$countzone][5] };
	
	$countoperations = 0;
	foreach my $sourcefile ( @sourcefiles)
	{
		my $targetfile = $targetfiles[ $countoperations ];
		my $configfile = $configfiles[ $countoperations ];
		my $longmenu = $longmenus[ $countoperations ];
		my $sourceaddress = "$mypath/$file$sourcefile";
		my $targetaddress = "$mypath/$file$targetfile";
		my $configaddress = "$to/opts/$configfile";
		checkfile($sourceaddress, $targetaddress);
		
		open( SOURCEFILE, $sourceaddress ) or die "Can't open $sourcefile 2: $!\n";
		my @lines = <SOURCEFILE>;
		close SOURCEFILE;
			
		my $countlines = 0;
		my $countvert = 0;

		my @vertex_letters;
			if ($longmenu eq "y")
			{
				@vertex_letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
				"n", "o", "p", "0\nb\nq", "0\nb\nr", "0\nb\ns", "0\nb\nt", "0\nb\nu", "0\nb\nv", 
				"0\nb\nw", "0\nb\nx", "0\nb\ny", "0\nb\nz", "0\nb\na", "0\nb\nb","0\nb\nc","0\nb\nd",
				"0\nb\ne","0\nb\n0\nb\nf","0\nb\n0\nb\ng","0\nb\n0\nb\nh","0\nb\n0\nb\ni",
				"0\nb\n0\nb\nj","0\nb\n0\nb\nk","0\nb\n0\nb\nl","0\nb\n0\nb\nm","0\nb\n0\nb\nn",
				"0\nb\n0\nb\no","0\nb\n0\nb\np","0\nb\n0\nb\nq","0\nb\n0\nb\nr","0\nb\n0\nb\ns",
				"0\nb\n0\nb\nt");
			}
			else
			{
				@vertex_letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
				"n", "o", "p", "0\nq", "0\nr", "0\ns", "0\nt", "0\nu", "0\nv", "0\nw", "0\nx", 
				"0\ny", "0\nz", "0\na", "0\nb","0\n0\nc","0\n0\nd","0\n0\ne","0\n0\nf","0\n0\ng",
				"0\n0\nh","0\n0\ni","0\n0\nj","0\n0\nk","0\n0\nl","0\n0\nm","0\n0\nn","0\n0\no",
				"0\n0\np","0\n0\nq","0\n0\nr","0\n0\ns","0\n0\nt");
			}

			foreach my $line (@lines)
			{
				$line =~ s/^\s+//; 
				my @rowelements = split(/\s+|,/, $line);
				if   ($rowelements[0] eq "*vertex" ) 
				{
					if ($countvert == 0) 
					{
						push (@v, [ "vertexes of  $sourceaddress" ]);
						push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ], $vertexletters[$countvert] );
					}

					if ($countvert > 0) 
					{
						push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3], $vertexletters[$countvert] ] );
					}
					$countvert++;
				}
				$countlines++;
			}

			if (-e $configaddress) 
			{				
				eval `cat $configaddress`; # HERE AN EXTERNAL FILE FOR PROPAGATION OF CONSTRAINTS 
				# IS EVALUATED, AND HERE BELOW CONSTRAINTS ARE PROPAGATED.

			my $countvertex = 0;
							
			foreach my $vertex_letter (@vertex_letters)
			{
				if ($countvertex > 0)
				{
					if ($vertex_letter eq $v[$countvertex][3])
					{
						my @base_coordinates = @{ $transform_coordinates[$countvertex] };
						my $x_end = $base_coordinates[0];
						my $y_end = $base_coordinates[1];
						my $z_end = $base_coordinates[2];
						my $x_swingtranslate = ( 2 * $x_end );
						my $y_swingtranslate = ( 2 * $y_end );
						my $z_swingtranslate = ( 2 * $z_end );
						my $x_pace = ( $x_swingtranslate / ( $stepsvar - 1 ) );
						my $x_movement = (- ( $x_end - ( $x_pace * ( $countstep - 1 ) ) ));
						my $y_pace = ( $y_swingtranslate / ( $stepsvar - 1 ) );
						my $y_movement = (- ( $y_end - ( $y_pace * ( $countstep - 1 ) ) ));
						my $z_pace = ( $z_swingtranslate / ( $stepsvar - 1 ) );
						my $z_movement = (- ( $z_end - ( $z_pace * ( $countstep - 1 ) ) ));
						my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
d
$vertex_letter
$x_movement $y_movement $z_movement
-
y
-
y
c
-
-
-
-
-
-
-
-
-
YYY
";
						if ($exeonfiles eq "y") 
						{ 
							print `$printthis`;
						}

						print TOSHELL "
#Translating vertexes for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.			
$printthis";
					}
				}
				$countvertex++;
			}
		}
		$countoperations++;
	}
} # END SUB translate_vertexes


##############################################################################
sub shift_vertexes
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $shift_vertexes = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Shifting vertexes for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $pace;
	my $movement;
	my $yes_or_no_shift_vertexes = $$shift_vertexes[$countzone][0];
	my $movementtype = $$shift_vertexes[$countzone][1];
	my @pairs_of_vertexes = @{ $$shift_vertexes[$countzone][2] };
	my @shift_swings = @{ $$shift_vertexes[$countzone][3] };
	my $yes_or_no_radiation_update = $$shift_vertexes[$countzone][4];
	my $configfile = $$shift_vertexes[$countzone][5];
	
	if ( $stepsvar > 1 )
	{
		if ( $yes_or_no_shift_vertexes eq "y" )
		{

			my $countthis = 0;
			if ($movementtype eq "j")
			{
			foreach my $shift_swing (@shift_swings)
				{
					$pace = ( $shift_swing / ( $stepsvar - 1 ) );
					$movement_or_vertex = 
					( ( ($shift_swing) / 2 ) - ( $pace * ( $countstep - 1 ) ) );
					$vertex1 = $pairs_of_vertexes[ 0 + ( 2 * $countthis ) ];
					$vertex2 = $pairs_of_vertexes[ 1 + ( 2 * $countthis ) ];
					
					my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
d
^
$movementtype
$vertex1
$vertex2
-
$movement_or_vertex
y
-
y
-
y
-
-
-
-
-
-
-
-
YYY
";
					if ($exeonfiles eq "y") 
					{ 
						print `$printthis`;
					}
					print TOSHELL "
#Shifting vertexes for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";

					$countthis++;
				}
			}
			elsif ($movementtype eq "h")
			{
				foreach my $shift_swing (@shift_swings)
				{
					my $printthis = 
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
d
^
$movementtype
$vertex1
$vertex2
-
$movement_or_vertex
-
y
n
n
n
-
y
-
y
-
-
-
-
-
-
-
-
YYY
";
					if ($exeonfiles eq "y") 
					{ 
						print `$printthis`;
					}
					print TOSHELL "
#Shifting vertexes for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
				}
			}
		}
	}
}    # END SUB shift_vertexes


sub rotate    # generic zone rotation
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $rotate = shift; 
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Rotating zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $rotation_degrees; 
	my $yes_or_no_rotation = "$$rotate[$countzone][0]";
	my $yes_or_no_rotate_obstructions =
	  "$$rotate[$countzone][1]";
	my $swingrotate = $$rotate[$countzone][2];
	my $yes_or_no_update_radiation =
	  $$rotate[$countzone][3];
	my $base_vertex = $$rotate[$countzone][4];
	my $configfile = $$rotate[$countzone][5];						  
	my $pacerotate; 
	my $count_rotate = 0;
	if (     ( $swingrotate != 0 )
		 and ( $stepsvar > 1 )
		 and ( $yes_or_no_rotation eq "y" ) )
	{
		$pacerotate = ( $swingrotate / ( $stepsvar - 1 ) );
		$rotation_degrees =
		  ( ( $swingrotate / 2 ) -
			 ( $pacerotate * ( $countstep - 1 ) ) );

		my $printthis = 
"prj -file $to/cfg/$fileconfig -mode script<<YYY


m
c
a
$zone_letter
i
b
$rotation_degrees
$base_vertex
-
$yes_or_no_rotate_obstructions
-
y
c
-
y
-
-
-
-
-
-
-
-
YYY
";

		if ($exeonfiles eq "y") 
		{ 
			print `$printthis`;
		}
		print TOSHELL 
"
#Rotating zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis
";
	}
}    # END SUB rotate
##############################################################################


##############################################################################
sub rotatez # PUT THE ROTATION POINT AT POINT 0, 0, 0. I HAVE NOT YET MADE THE FUNCTION GENERIC ENOUGH.
{	
	my $to = shift;
	my $stepsvar = shift; 
	
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $rotatez = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Rotating zones on the vertical plane for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $yes_or_no_rotation = "$$rotatez[0]";
	my @centerpoints = @{$$rotatez[1]};
	my $centerpointsx = $centerpoints[0];
	my $centerpointsy = $centerpoints[1];
	my $centerpointsz = $centerpoints[2];
	my $plane_of_rotation = "$$rotatez[2]";
 	my $infile = "$to/zones/$applytype[$countzone][2]";
	my $infile2 = "$to/cfg/$applytype[$countzone][2]";
	my $outfilemorph = "erase";
	my $outfile2 = "$to/zones/$applytype[$countzone][2]eraseobtained";
	open(INFILE,  "$infile")   or die "Can't open infile $infile: $!\n";
	open($_outfile_2, ">>$outfile2") or die "Can't open outfile2 $outfile2: $!\n";
	my @lines = <INFILE>;
	close(INFILE);
	my $countline = 0;
	my $countcases=0;
	my @vertexes;
	my $swingrotate = $$rotatez[3];
	my $alreadyrotation = $$rotatez[4];
	my $rotatexy = $$rotatez[5];
	my $swingrotatexy = $$rotatez[6];
	my $pacerotate;
	my $count_rotate = 0;
	my $linenew;
	my $linenew2;
	my @rowprovv;
	my @rowprovv2;
	my @row;
	my @row2;
	if ( $stepsvar > 1 and ( $yes_or_no_rotation eq "y" ) )
	{
		foreach my $line (@lines) 
		{#
			{
				$linenew = $line;
				$linenew =~ s/\:\s/\:/g ;
				@rowprovv = split(/\s+/, $linenew);
				$rowprovv[0] =~ s/\:\,/\:/g ;
				@row = split(/\,/, $rowprovv[0]);
				if ($row[0] eq "*vertex") 
				{ push (@vertexes, [$row[1], $row[2], $row[3]] ) }
			}
			$countline = $countline +1;
		}

		foreach $vertex (@vertexes)
		{
			print $_outfile_ "vanilla ${$vertex}[0], ${$vertex}[1], ${$vertex}[2]\n";
		}
		foreach $vertex (@vertexes)
		{
			${$vertex}[0] = (${$vertex}[0] - $centerpointsx); 
			${$vertex}[0] = sprintf("%.5f", ${$vertex}[0]);
			${$vertex}[1] = (${$vertex}[1] - $centerpointsy); 
			${$vertex}[1] = sprintf("%.5f", ${$vertex}[1]);
			${$vertex}[2] = (${$vertex}[2] - $centerpointsz); 
			${$vertex}[2] = sprintf("%.5f", ${$vertex}[2]);
			print $_outfile_ "aftersum ${$vertex}[0], ${$vertex}[1], ${$vertex}[2]\n";
		}

		my $anglealready = deg2rad(-$alreadyrotation);
		foreach $vertex (@vertexes)
		{
			my $x_new = cos($anglealready)*${$vertex}[0] - sin($anglealready)*${$vertex}[1]; 
			my $y_new = sin($anglealready)*${$vertex}[0] + cos($anglealready)*${$vertex}[1];
			${$vertex}[0] = $x_new; ${$vertex}[0] = sprintf("%.5f", ${$vertex}[0]);
			${$vertex}[1] = $y_new; ${$vertex}[1] = sprintf("%.5f", ${$vertex}[1]);
			print $_outfile_ "afterfirstrotation ${$vertex}[0], ${$vertex}[1], ${$vertex}[2]\n";
		}

		$pacerotate = ( $swingrotate / ( $stepsvar - 1) );
		$rotation_degrees = - ( ($swingrotate / 2) - ($pacerotate * ($countstep -1) ) );
		my $angle = deg2rad($rotation_degrees);
		foreach $vertex (@vertexes)
		{
			my $y_new = cos($angle)*${$vertex}[1] - sin($angle)*${$vertex}[2]; 
			my $z_new = sin($angle)*${$vertex}[1] + cos($angle)*${$vertex}[2];
			${$vertex}[1] = $y_new; ${$vertex}[1] = sprintf("%.5f", ${$vertex}[1]);
			${$vertex}[2] = $z_new; ${$vertex}[2] = sprintf("%.5f", ${$vertex}[2]);
			${$vertex}[0] = sprintf("%.5f", ${$vertex}[0]);
			print $_outfile_ "aftersincos ${$vertex}[0], ${$vertex}[1], ${$vertex}[2]\n";
		}

		my $angleback = deg2rad($alreadyrotation);
		foreach $vertex (@vertexes)
			{
			my $x_new = cos($angleback)*${$vertex}[0] - sin($angleback)*${$vertex}[1]; 
			my $y_new = sin($angleback)*${$vertex}[0] + cos($angleback)*${$vertex}[1];
			${$vertex}[0] = $x_new; ${$vertex}[0] = sprintf("%.5f", ${$vertex}[0]);
			${$vertex}[1] = $y_new; ${$vertex}[1] = sprintf("%.5f", ${$vertex}[1]);
			print $_outfile_ "afterrotationback ${$vertex}[0], ${$vertex}[1], ${$vertex}[2]\n";ctl type
		}

		foreach $vertex (@vertexes)
		{
			${$vertex}[0] = ${$vertex}[0] + $centerpointsx; ${$vertex}[0] = sprintf("%.5f", ${$vertex}[0]);
			${$vertex}[1] = ${$vertex}[1] + $centerpointsy; ${$vertex}[1] = sprintf("%.5f", ${$vertex}[1]);
			${$vertex}[2] = ${$vertex}[2] + $centerpointsz; ${$vertex}[2] = sprintf("%.5f", ${$vertex}[2]);
			print $_outfile_ "after final substraction ${$vertex}[0], ${$vertex}[1], ${$vertex}[2]\n";
		}

		my $countwrite = -1;
		my $countwriteand1;
		foreach $line (@lines) 
		{#	

				$linenew2 = $line;
				$linenew2 =~ s/\:\s/\:/g ;
				my @rowprovv2 = split(/\s+/, $linenew2);
				$rowprovv2[0] =~ s/\:\,/\:/g ;
				@row2 = split(/\,/, $rowprovv2[0]);
				$countwriteright = ($countwrite - 5);
				$countwriteand1 = ($countwrite + 1);			
				if ($row2[0] eq "*vertex")		
				{
					if ( $countwrite == - 1) { $countwrite = 0 }	
					print $_outfile_2 
					"*vertex"."\,"."${$vertexes[$countwrite]}[0]"."\,"."${$vertexes[$countwrite]}[1]"."\,"."${$vertexes[$countwrite]}[2]"."  #   "."$countwriteand1\n";
				}
				else 
				{
					print $_outfile_2 "$line";
				}
				if ( $countwrite > ( - 1 ) ) { $countwrite++; }
		}

		close($_outfile_);
		if ($exeonfiles eq "y") { print `chmod 777 $infile`; }
		print TOSHELL "chmod -R 777 $infile\n";
		if ($exeonfiles eq "y") { print `chmod 777 $infile2`; }
		print TOSHELL "chmod -R 777 $infile2\n";
		if ($exeonfiles eq "y") { print `rm $infile`; }
		print TOSHELL "rm $infile\n";
		if ($exeonfiles eq "y") { print `chmod 777 $outfile2`; }
		print TOSHELL "chmod 777 $outfile2\n";
		if ($exeonfiles eq "y") { print `cp $outfile2 $infile`; }
		print TOSHELL "cp $outfile2 $infile\n";
		if ($exeonfiles eq "y") { print `cp $outfile2 $infile2`; }
		print TOSHELL "cp $outfile2 $infile2\n";
	}
} # END SUB rotatez
##############################################################################


##############################################################################
sub make_generic_change # WITH THIS FUNCTION YOU TARGET PORTIONS OF A FILE AND YOU CHANGE THEM.
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap2 = shift;
	my @generic_change = @$swap2;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Manipulating geometry database for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $infile = "$to/zones/$applytype[$countzone][2]";
	my $outfilemorph = "$to/zones/$applytype[$countzone][2]provv";
	open( INFILE, "$infile" ) or die "Can't open $infile 2: $!\n";
	open( $_outfile_, ">$outfilemorph" ) or die "Can't open $outfilemorph: $!\n";
	my @lines = <INFILE>;
	close(INFILE);
	my $countline  = 0;
	my $countcases = 0;

	foreach $line (@lines)
	{    #
		$linetochange = ( $generic_change[$countzone][$countcases][1] );
		if ( $countline == ( $linetochange - 1 ) )
		{    #
			$linetochange = ( $generic_change[$countzone][$count_conditions][$countcases][1] );
			$cases = $#{ generic_change->[$countzone][$count_conditions] };
			$swing1 = $generic_change[$countzone][$countcases][2][2];
			$swing2 = $generic_change[$countzone][$countcases][3][2];
			$swing3 = $generic_change[$countzone][$countcases][4][2];
			if (     ( $stepsvar > 1 )
				 and ( $tiepacestofirst eq "n" ) )
			{
				$pace1 = ( $swing1 / ( $stepsvar - 1 ) );
				$pace2 = ( $swing2 / ( $stepsvar - 1 ) );
				$pace3 = ( $swing3 / ( $stepsvar - 1 ) );
			} elsif (     ( $stepsvar > 1 )
					  and ( $tiepacestofirst eq "y" ) )
			{
				$pace1 = ( $swing1 / ( $stepsvar - 1 ) );
				$pace2 = ( $swing2 / ( $stepsvar - 1 ) );
				$pace3 = ( $swing3 / ( $stepsvar - 1 ) );
			} elsif ( $stepsvar == 1 )
			{
				$pace1 = 0;
				$pace2 = 0;
				$pace3 = 0;
			}
			$digits1 = $generic_change[$countzone][$countcases][2][3];
			$digits2 = $generic_change[$countzone][$countcases][3][3];
			$digits3 = $generic_change[$countzone][$countcases][4][3];
			$begin_read_column1 = $generic_change[$countzone][$countcases][2][0] - 1;
			$begin_read_column2 = $generic_change[$countzone][$countcases][3][0] - 1;
			$begin_read_column3 = $generic_change[$countzone][$countcases][4][0] - 1;
			$length_read_string1 = $generic_change[$countzone][$countcases][2][1] + 1;
			$length_read_string2 = $generic_change[$countzone][$countcases][3][1] + 1;
			$length_read_string3 = $generic_change[$countzone][$countcases][4][1] + 1;
			########## COMPLETE HERE ->
			$numbertype = "f";    #floating
			$to_substitute1 =
			  substr( $line, $begin_read_column1, $length_read_string1 );
			$substitute_provv1 = ( $to_substitute1 - ( $swing1 / 2 ) + ( $pace1 * $countstep ) );
			$substitute1 = sprintf( "%.$digits1$numbertype", $substitute_provv1 );
			$to_substitute2 = substr( $line, $begin_read_column2, $length_read_string2 );
			$substitute_provv2 = ( $to_substitute2 - ( $swing2 / 2 ) + ( $pace2 * $countstep ) );
			$substitute2 = sprintf( "%.$digits2$numbertype", $substitute_provv2 );
			$to_substitute3 = substr( $line, $begin_read_column3, $length_read_string3 );
			$substitute_provv3 = ( $to_substitute3 - ( $swing3 / 2 ) + ( $pace3 * $countstep ) );
			$substitute3 = sprintf( "%.$digits3$numbertype", $substitute_provv3 );

			if ( $substitute1 >= 0 )
			{
				$begin_write_column1 = $generic_change[$countzone][$countcases][2][0];
				$length_write_string1 = $generic_change[$countzone][$countcases][2][1];
			} else
			{
				$begin_write_column1 = $generic_change[$countzone][$countcases][2][0] - 1;
				$length_write_string1 = $generic_change[$countzone][$countcases][2][1] + 1;
			}
			if ( $substitute2 >= 0 )
			{
				$begin_write_column2 = $generic_change[$countzone][$countcases][3][0];
				$length_write_string2 = $generic_change[$countzone][$countcases][3][1];
			} else
			{
				$begin_write_column2 =$generic_change[$countzone][$countcases][3][0] - 1;
				$length_write_string2 = $generic_change[$countzone][$countcases][3][1] + 1;
			}
			if ( $substitute3 >= 0 )
			{
				$begin_write_column3 = $generic_change[$countzone][$countcases][4][0];
				$length_write_string3 = $generic_change[$countzone][$countcases][4][1];
			} else
			{
				$begin_write_column3 = $generic_change[$countzone][$countcases][4][0] - 1;
				$length_write_string3 = $generic_change[$countzone][$countcases][4][1] + 1;
			}
			substr( $line, $begin_write_column1, $length_write_string1, $substitute1 );
			substr( $line, $begin_write_column2, $length_write_string2, $substitute2 );
			substr( $line, $begin_write_column3, $length_write_string3, $substitute3 );
			print $_outfile_ "$line";
			$countcases = $countcases + 1;
		} else
		{
			print $_outfile_ "$line";
		}
		$countline = $countline + 1;
	}
	close($_outfile_);
	if ($exeonfiles eq "y") { print `chmod -R 755 $infile`; }
	print TOSHELL "chmod -R 755 $infile\n";
	if ($exeonfiles eq "y") { print `chmod -R 755 $outfilemorph`; }
	print TOSHELL
	  "chmod -R 755 $outfilemorph\n";
	if ($exeonfiles eq "y") { print `cp -f $outfilemorph $infile`; }
	print TOSHELL
	  "cp -f $outfilemorph $infile\n";
}    # END SUB generic_change
##############################################################################


##############################################################################
sub reassign_construction
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $construction_reassignment = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Reassign construction solutions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $yes_or_no_reassign_construction = $$construction_reassignment[$countzone][0];
	if ( $yes_or_no_reassign_construction eq "y" )
	{
		my @surfaces_to_reassign =
		  @{ $construction_reassignment->[$countzone][1]
		  };
		my @constructions_to_choose =
		  @{ $construction_reassignment->[$countzone][2] };
		my $configfile = $$construction_reassignment[$countzone][3];
		my $surface_letter;
		my $count = 0;
		my @reassign_constructions;

		foreach $surface_to_reassign (@surfaces_to_reassign)
		{
			$construction_to_choose =  $constructions_to_choose[$count][$countstep];
			
			my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
f
$surface_to_reassign
e
n
y
$construction_to_choose
-
-
-
-
y
y
-
-
-
-
-
-
-
-
YYY
";
			if ($exeonfiles eq "y") 
			{ 
				print `$printthis`;
			}

			print TOSHELL "
#Reassign construction solutions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
			$count++;
		}
	}
}    # END SUB reassign_construction
##############################################################################


##############################################################################					
sub change_thickness
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $thickness_change = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Changing thicknesses in construction layer for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $yes_or_no_change_thickness = $$thickness_change[$countzone][0];
	my @entries_to_change = @{ $$thickness_change[$countzone][1] };
	my @groups_of_strata_to_change = @{ $$thickness_change[$countzone][2] };
	my @groups_of_couples_of_min_max_values = @{ $$thickness_change[$countzone][3] };
	my $configfile = $$thickness_change[$countzone][4];
	my $thiscount = 0;
	my $entry_to_change;
	my $countstrata;
	my @strata_to_change;
	my $stratum_to_change;
	my @min_max_values;
	my $min;
	my $max;
	my $change_stratum;
	my @change_strata;
	my $enter_change_entry;
	my @change_entries;
	my $swing;
	my $pace;
	my $thickness;
	my @change_entries_with_thicknesses;

	if ( $stepsvar > 1 )
	{
		foreach $entry_to_change (@entries_to_change)
		{
			@strata_to_change =
			  @{ $groups_of_strata_to_change[$thiscount]
			  };
			$countstrata = 0;
			foreach $stratum_to_change (@strata_to_change)
			{
				@min_max_values =
				  @{ $groups_of_couples_of_min_max_values[$thiscount][$countstrata] };
				$min   = $min_max_values[0];
				$max   = $min_max_values[1];
				$swing = $max - $min;
				$pace  = ( $swing / ( $stepsvar - 1 ) );
				$thickness = $min + ( $pace * ( $countstep - 1 ) );

				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY
b
e
a
$entry_to_change
$stratum_to_change
n
$thickness
-
-
y
y
-
y
y
-
-
-
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{ 
					print `$printthis`;
				}
				print TOSHELL "
#Changing thicknesses in construction layer for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
				$countstrata++;
			}
			$thiscount++;
		}
		$" = " ";
		if ($exeonfiles eq "y") { print `$enter_esp$go_to_construction_database@change_entries_with_thicknesses$exit_construction_database_and_esp`; }
		print TOSHELL "$enter_esp$go_to_construction_database@change_entries_with_thicknesses$exit_construction_database_and_esp\n";
	}
} # END sub change_thickness
##############################################################################		


##############################################################################					
sub obs_modify
{
	if ( $stepsvar > 1 )
	{
		my $to = shift;
		my $stepsvar = shift; 
		my $countzone = shift;
		my $countstep = shift;
		my $swap = shift;
		my @applytype = @$swap;
		my $zone_letter = $applytype[$countzone][3];
		my $obs_modify = shift;
		my $countvar = shift;
		my $fileconfig = shift;
		
		say "Modifying obstructions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";		

		my @obs_letters = @{ $$obs_modify[$countzone][0] };
		my $modification_type = $$obs_modify[$countzone][1];
		my @values = @{ $$obs_modify[$countzone][2] };
		my @base = @{ $$obs_modify[$countzone][3] };
		my $configfile = $$obs_modify[$countzone][4];
		my $xz_resolution = $$obs_modify[$countzone][5];
		my $countobs = 0;							  
		my $x_end;
		my $y_end;
		my $z_end;
		my $x_base;
		my $y_base;
		my $z_base;
		my $end_value;
		my $base_value;
		my $x_swingtranslate;
		my $y_swingtranslate;
		my $z_swingtranslate;
		my $x_pace;
		my $x_value;
		my $y_pace;
		my $y_value;
		my $z_pace;
		my $z_value;
		if ( ($modification_type eq "a") or ($modification_type eq "b"))
		{      							  
			$x_end = $values[0];
			$y_end = $values[1];
			$z_end = $values[2];
			$x_base = $base[0];
			$y_base = $base[1];
			$z_base = $base[2];
			$x_swingtranslate = ( 2 * $x_end );
			$y_swingtranslate = ( 2 * $y_end );
			$z_swingtranslate = ( 2 * $z_end );
			$x_pace = ( $x_swingtranslate / ( $stepsvar - 1 ) );
			$x_value = ($x_base + ( $x_end - ( $x_pace * ( $countstep - 1 ) ) ));
			$y_pace = ( $y_swingtranslate / ( $stepsvar - 1 ) );
			$y_value = ($y_base + ( $y_end - ( $y_pace * ( $countstep - 1 ) ) ));
			$z_pace = ( $z_swingtranslate / ( $stepsvar - 1 ) );
			$z_value = ($z_base + ( $z_end - ( $z_pace * ( $countstep - 1 ) ) ));

			my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
h
a
$obs_letter
$modification_type
a
$x_value $y_value $z_value
-
-
c
-
c
-
-
-
-
-
-
-
-
YYY
";
			foreach my $obs_letter (@obs_letters)
			{
				if ($exeonfiles eq "y") 
				{ 
					print `$printthis`;
				}
				print TOSHELL "
#Modifying obstructions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
				$countobs++;
				}
			}

			if ( ($modification_type eq "c") or ($modification_type eq "d"))
			{      							  
				$x_end = $values[0];
				$x_base = $base[0];
				$x_swingtranslate = ( 2 * $x_end );
				$x_pace = ( $x_swingtranslate / ( $stepsvar - 1 ) );
				$x_value = ($x_base + ( $x_end - ( $x_pace * ( $countstep - 1 ) ) ));

				foreach my $obs_letter (@obs_letters)
				{
					my $printthis = 
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
h
a
$obs_letter
$modification_type
$x_value
-
-
c
-
c
-
-
-
-
-
-
-
-
YYY
";
					if ($exeonfiles eq "y") 
					{ 
						print `$printthis`;
					}
					print TOSHELL "
#Modifying obstructions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
					$countobs++;
				}
			}

			if ($modification_type eq "g")
			{      							  
				foreach my $obs_letter (@obs_letters)
				{
					my $count = 0;
					foreach my $x_value (@values)
					{
						if ($count < $stepsvar)
						{
							my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
h
a
$obs_letter
$modification_type
$x_value
-
-
-
-
-
-
-
-
-
-
-
-
-
-
YYY
";
							if ($exeonfiles eq "y") 
							{ 
								print `$printthis`;
							}
							print TOSHELL "
Modifying obstructions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
						$countobs++;
						$count++;
					}
				}
			}
		}

		if ($modification_type eq "h")
		{      							  
			$x_end = $values[0];
			$x_base = $base[0];
			$x_swingtranslate = (  $x_base - $x_end );
			$x_pace = ( $x_swingtranslate / ( $stepsvar - 1 ) );
			$x_value = ($x_base - ( $x_pace * ( $countstep - 1 ) ));

			foreach my $obs_letter (@obs_letters)
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
h
a
$obs_letter
$modification_type
$x_value
-
-
-
-
-
-
-
-
-
-
-
-
-
-
YYY
";
				if ($exeonfiles eq "y")
				{ 
					print `$printthis`;
				}
				print TOSHELL $printthis;
				$countobs++;
			}
		}

		if ($modification_type eq "t")
		{      							  
			my $modification_type = "~";
			my $what_todo = $base[0];
			$x_end = $values[0];
			$y_end = $values[1];
			$z_end = $values[2];
			$x_swingtranslate = ( 2 * $x_end );
			$y_swingtranslate = ( 2 * $y_end );
			$z_swingtranslate = ( 2 * $z_end );
			$x_pace = ( $x_swingtranslate / ( $stepsvar - 1 ) );
			$x_value = ( $x_end - ( $x_pace * ( $countstep - 1 ) ) );
			$y_pace = ( $y_swingtranslate / ( $stepsvar - 1 ) );
			$y_value = ( $y_end - ( $y_pace * ( $countstep - 1 ) ) );
			$z_pace = ( $z_swingtranslate / ( $stepsvar - 1 ) );
			$z_value = ( $z_end - ( $z_pace * ( $countstep - 1 ) ) );

			foreach my $obs_letter (@obs_letters)
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
h
a
$modification_type
$what_todo
$obs_letter
-
$x_value $y_value $z_value
-
c
-
c
-
-
-
-
-
-
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{ 
					print `$printthis`;
				}
				print TOSHELL "
Modifying obstructions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
				$countobs++;
				}
			}

			#NOW THE XZ GRID RESOLUTION WILL BE PUT TO THE SPECIFIED VALUE				 						
			my $printthis = #THIS IS WHAT HAPPEN INSIDE SUB KEEP_SOME_OBSTRUCTIONS
"prj -file $to/cfg/$fileconfig -mode script<<YYY


m
c
a
$zone_letter
h
a
a
$xz_resolution
-
c
-
c
-
-
-
-
-
-
-
YYY
";
			if ($exeonfiles eq "y") 
			{ 
				print `$printthis`;
			}
			print TOSHELL "
Modifying obstructions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
	}
}    # END SUB obs_modify. FIX THE INDENTATION.
##############################################################################


##############################################################################
sub bring_obstructions_back # TO BE REWRITTEN BETTER
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $keep_obstructions = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Keeping some obstructions in positions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";
	
	my $yes_or_no_keep_some_obstructions = $$keep_obstructions[$countzone][0];
	my $yes_or_no_update_radiation_provv = $$keep_obstructions[$countzone][2];
	my $yes_or_no_update_radiation;
	my $configfile = $$keep_obstructions[$countzone][3];
	my $xz_resolution = $$keep_obstructions[$countzone][4];
	if ( $yes_or_no_update_radiation_provv eq "y" )
	{
		$yes_or_no_update_radiation = "a";
	} else
	{
		$yes_or_no_update_radiation = "c";
	}
	if ( $yes_or_no_keep_some_obstructions eq "y" )
	{
		my @group_of_obstructions_to_keep = @{ $$keep_obstructions[$countzone][1] };
		my $keep_obs_count = 0;
		my @obstruction_to_keep;
		foreach (@group_of_obstructions_to_keep)
		{
			@obstruction_to_keep =
			  @{ $group_of_obstructions_to_keep[$keep_obs_count] };
			my $obstruction_letter =
			  "$obstruction_to_keep[0]";
			my $rotation_z = "$obstruction_to_keep[1]";
			my $rotation_y = "$obstruction_to_keep[2]"; # NOT YET IMPLEMENTED 
			my $x_origin   = "$obstruction_to_keep[3]";
			my $y_origin   = "$obstruction_to_keep[4]";
			my $z_origin   = "$obstruction_to_keep[5]";
			# $rotation_degrees used here is absolute, not local. 
			# This is dangerous and it has to change.

			my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY


m
c
a
$zone_letter
h
a
$obstruction_letter
a
a
$x_origin $y_origin $z_origin
c
$rotation_z
-
-
c
-
c
-
-
-
-
-
-
-
YYY
";
			if ($exeonfiles eq "y") 
			{ 
				print `$printthis`;
			}
			print TOSHELL "
#Keeping some obstructions in positions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
			$keep_obs_count++;
		}

		# NOW THE XZ GRID RESOLUTION WILL BE PUT TO THE SPECIFIED VALUE	
		my $printthis =
"
";			 
		if ($exeonfiles eq "y") 
		{ 
			print `$printthis`;
		}
		print TOSHELL $printthis;
	}
}    # END SUB bring_obstructions_back
##################################################################					


##################################################################
sub recalculateish
{ 
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Updating the insolation calculations for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $zone_letter = $applytype[$countzone][3];

	my $printthis =
"
";
	if ($exeonfiles eq "y") 
	{ 
		print `$printthis`;
	}

	print TOSHELL "
#Updating the insolation calculations for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
} #END SUB RECALCULATEISH
##############################################################################				



##############################################################################										
sub daylightcalc # IT WORKS ONLY IF THE RAD DIRECTORY IS EMPTY
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $filedf = shift;
	my $swap = shift;
	my @daylightcalc = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Performing daylight calculations through Radiance for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $yes_or_no_daylightcalc = $daylightcalc[0];
	my $zone = $daylightcalc[1];
	my $surface = $daylightcalc[2];
	my $where = $daylightcalc[3];
	my $edge = $daylightcalc[4];
	my $distance = $daylightcalc[5];
	my $density = $daylightcalc[6];
	my $accuracy = $daylightcalc[7];
	my $filedf = $daylightcalc[8];
	my $pathdf = "$to/rad/$filedf";

	my $printthis =
"
cd $to/cfg/
e2r -file $to/cfg/$fileconfig -mode script<<YYY

a

a
d
$zone
-
$surface
$distance
$where
$edge
-
$density
y
$accuracy
a
-
-
-
-
-
YYY
\n\n
cd $mypath
";
	if ($exeonfiles eq "y") 
	{ 
		print `$printthis`;
	}

	print TOSHELL "
#Performing daylight calculations through Radiance for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";

	open( RADFILE, $pathdf) or die "Can't open $pathdf: $!\n";
	my @linesrad = <RADFILE>;
	close RADFILE;											
	my @dfs;
	my $dfaverage;
	my $sum = 0;
	foreach my $linerad (@linesrad)
	{
		$linerad =~ s/^\s+//; 
		my @rowelements = split(/\s+|,/, $linerad);
		push (@dfs, $rowelements[-1]);
	}
	foreach my $df (@dfs)
	{
		$sum = ($sum + $df);
	}
	$dfaverage = ( $sum / scalar(@dfs) );

	open( DFFILE,  ">>$dffile" )   or die "Can't open $dffile: $!";
	print DFFILE "$dfaverage\n";
	close DFFILE;

} # END SUB dayligjtcalc 
##############################################################################


##############################################################################	
sub daylightcalc_other # NOT USED. THE DIFFERENCE WITH THE ABOVE IS THAT IS WORKS IF THE RAD DIRECTORY IS NOT EMPTY. 
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $filedf = shift;
	my $swap = shift;
	my @daylightcalc = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Performing daylight calculations through Radiance for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $yes_or_no_daylightcalc = $daylightcalc[0];
	my $zone = $daylightcalc[1];
	my $surface = $daylightcalc[2];
	my $where = $daylightcalc[3];
	my $edge = $daylightcalc[4];
	my $distance = $daylightcalc[5];
	my $density = $daylightcalc[6];
	my $accuracy = $daylightcalc[7];
	my $filedf = $daylightcalc[8];
	my $pathdf = "$to/rad/$filedf";
	
	my $printthis =
"
cd $to/cfg/
e2r -file $to/cfg/$fileconfig -mode script<<YYY
a

d

g
-
e
d



y
-
g
y
$zone
-
$surface
$distance
$where
$edge
-
$density

i
$accuracy
y
a
a
-
-
YYY
\n\n
cd $mypath
";	
	if ($exeonfiles eq "y") 
	{ 
		print `$printthis`;
	}

	print TOSHELL "
#Performing daylight calculations through Radiance for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";

	open( RADFILE, $pathdf) or die "Can't open $pathdf: $!\n";
	my @linesrad = <RADFILE>;
	close RADFILE;											
	my @dfs;
	my $dfaverage;
	my $sum = 0;
	foreach my $linerad (@linesrad)
	{
		$linerad =~ s/^\s+//; 
		my @rowelements = split(/\s+|,/, $linerad);
		push (@dfs, $rowelements[-1]);
	}
	foreach my $df (@dfs)
	{
		$sum = ($sum + $df);
	}
	$dfaverage = ( $sum / scalar(@dfs) );

	open( DFFILE,  ">>$dffile" )   or die "Can't open $dffile: $!";
	print DFFILE "$dfaverage\n";
	close DFFILE;

} # END SUB daylightcalc 
##############################################################################


sub change_config
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap2 = shift;
	my @change_config = @$swap2;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Substituting a configuration file for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my @change_conf = @{$change_config[$countezone]};
	my @original_configfiles = @{$change_conf[0]};
	my @new_configfiles = @{$change_conf[1]};
	my $countconfig = 0;
	my $original_configfile = $original_configfiles[$countstep-1];
	my $new_configfile = $new_configfiles[$countstep-1];
	if (  $new_configfile ne $original_configfile )
	{
		if ($exeonfiles eq "y") { print `cp -f $to/$new_configfile $to/$original_configfile\n`; }
		print TOSHELL "cp -f $to/$new_configfile $to/$original_configfile\n";
	}
$countconfig++;
} # END SUB copy_config


sub checkfile # THIS FUNCTION DOES WHAT IS DONE BY THE PREVIOUS ONE, BUT BETTER.
{
	# THIS CHECKS IF A SOURCE FILE MUST BE SUBSTITUTED BY ANOTHER ONE BEFORE THE TRANSFORMATIONS BEGIN.
	# IT HAS TO BE CALLED WITH: checkfile($sourceaddress, $targetaddress);
	my $sourceaddress = shift;
	my $targetaddress = shift;

	unless ( ($sourceaddress eq "" ) or ( $targetaddress eq "" ))
	{
		print $_outfile_ "TARGETFILE IN FUNCTION: $targetaddress\n";
		if ( $sourceaddress ne $targetaddress )
		{
			if ($exeonfiles eq "y") 
			{ 
				print 
				`cp -f $sourceaddress $targetaddress\n`; 
			}
			print TOSHELL 
			"cp -f $sourceaddress $targetaddress\n\n";
		}
	}
} # END SUB checkfile	


sub change_climate ### THIS SIMPLE SCRIPT HAS TO BE DEBUGGED. WHY DOES IT BLOCK ITSELF IF PRINTED TO THE SHELL?
{	# THIS FUNCTION CHANGES THE CLIMATE FILES. 
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap = shift;
	my @change_climate = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Substituting climate database for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my @climates = @{$change_climate[$countzone]};
	my $climate = $climates[$countstep-1];

	my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<ZZZ

b
a
b
$climate
a
-
-
y
n
-
-
ZZZ
\n
";
	if ($exeonfiles eq "y")
	{
		print `$printthis`;
	}
	print TOSHELL "
#Substituting a configuration file for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
}	


##############################################################################	
# THIS FUNCTION HAS BEEN OUTDATED BY THOSE FOR CONSTRAINING THE NETS, BELOW				
sub recalculatenet
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap2 = shift;
	my @recalculatenet = @$swap2;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Adequating the ventilation network for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";
	
	my $filenet = $recalculatenet[1];
	my $infilenet = "$mypath/$file/nets/$filenet";
	my @nodezone_data = @{$recalculatenet[2]};
	my @nodesdata = @{$recalculatenet[3]};
	my $geosourcefile = $recalculatenet[4];
	my $configfile = $recalculatenet[5];
	my $y_or_n_reassign_cp = $recalculatenet[6];
	my $y_or_n_detect_obs = $recalculatenet[7];
	my @crackwidths = @{$recalculatenet[9]};

	my @obstaclesdata;
	my $countlines = 0;
	my $countnode = 0;
	my @differences;
	my @ratios;
	my $sourceaddress = "$to$geosourcefile";
	my $configaddress = "$to/opts/$configfile";
	open( SOURCEFILE, $sourceaddress ) or die "Can't open $geosourcefile 2: $!\n";
	my @linesgeo = <SOURCEFILE>;
	close SOURCEFILE;
	my $countvert = 0;
	my $countobs = 0;
	my $zone;
	my @rowelements;
	my $line;
	my @node;
	my @component;
	my @v;
	my @obs;
	my @obspoints;
	my @obstructionpoint;
	my $xlenght;
	my $ylenght;
	my $truedistance;
	my $heightdifference;

	foreach my $line (@linesgeo)
	{
		$line =~ s/^\s+//; 

		my @rowelements = split(/\s+|,/, $line);
		if   ($rowelements[0] eq "*vertex" ) 
		{
			if ($countvert == 0) 
			{
				push (@v, [ "vertexes of  $sourceaddress" ]);
				push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ] );
			}

			if ($countvert > 0) 
			{
				push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ] );
			}
			$countvert++;
		}
		elsif   ($rowelements[0] eq "*obs" ) 
		{
			push (@obs, [ $rowelements[1], $rowelements[2], $rowelements[3], $rowelements[4], 
			$rowelements[5], $rowelements[6], $rowelements[7], $rowelements[8], $rowelements[9], $rowelements[10] ] );
			$countobs++;
		}
		$countlines++;
	}

	if ( $y_or_n_detect_obs eq "y") ### THIS HAS YET TO BE DONE AND WORK.
	{
		foreach my $ob (@obs)
		{
			push (@obspoints , [ $$ob[0], $$ob[1],$$ob[5] ] );
			push (@obspoints , [ ($$ob[0] + ( $$ob[3] / 2) ), ( $$ob[1] + ( $$ob[4] / 2 ) ) , $$ob[5] ] );
			push (@obspoints , [ ($$ob[0] + $$ob[3]), ( $$ob[1] + $$ob[4] ) , $$ob[5] ] );
		}
	}

	else {@obspoints = @{$recalculatenet[8]};}
	my @winpoints;
	my @windowpoints;
	my @windimsfront;
	my @windimseast;
	my @windimsback;
	my @windimswest;
	my $jointfront,
	my $jointeast;
	my $jointback;
	my $jointwest;
	my @windsims;
	my @windareas;
	my @jointlenghts;
	my $windimxfront;
	my $windimyfront;
	my $windimxback;
	my $windimyback;
	my $windimxeast; 
	my $windimyeast;
	my $windimxwest; 
	my $windimywest;

	if ($constrain) { eval ($constrain); } # HERE THE INSTRUCTION WRITTEN IN THE OPT CONFIGURATION FILE CAN BE SPEFICIED
	# FOR PROPAGATION OF CONSTRAINTS

	if ($y_or_n_reassign_cp == "y")
	{										
		eval `cat $configaddress`; # HERE AN EXTERNAL FILE FOR PROPAGATION OF CONSTRAINTS 
		# IS EVALUATED, AND HERE BELOW CONSTRAINTS ARE PROPAGATED. 
	}



	open( INFILENET, $infilenet ) or die "Can't open $infilenet 2: $!\n";
	my @linesnet = <INFILENET>;
	close INFILENET;

	my @letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", 
	"t", "u", "v", "w", "x", "y", "z");
	my $countnode = 0;
	my $interfaceletter;
	my $calcpressurecoefficient;
	my $nodetype;
	my $nodeletter;
	my $mode;
	my $countlines = 0;
	my $countopening = 0;
	my $countcrack = 0;
	my $countthing = 0;
	my $countjoint = 0;
	foreach my $line (@linesnet)
	{
		$line =~ s/^\s+//;
		@rowelements = split(/\s+/, $line);

		if ($rowelements[0] eq "Node") { $mode = "nodemode"; }
		if ($rowelements[0] eq "Component") { $mode = "componentmode"; }
		if ( ( $mode eq "nodemode" ) and ($countlines > 1) and ($countlines < (2 + scalar(@nodesdata) ) ) )
		{
			$countnode = ($countlines - 2); 
			$zone = $nodesdata[$countnode][0];
			$interfaceletter = $nodesdata[$countnode][1];
			$calcpressurecoefficient = $nodesdata[$countnode][2];
			$nodetype = $rowelements[2];
			$nodeletter = $letters[$countnode];

			if ( $nodetype eq "0")
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY


m
e
c

n
c
$nodeletter

a
a
y
$zone


a

-
-
y

y
-
-
-
-
-
-
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{ 
					print `$printthis`;
				}

				print TOSHELL "
#Adequating the ventilation network for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
				$countnode++;
			}
			elsif ( $nodetype eq "3")							
			{	
				if ($y_or_n_reassign_cp == "y")
				{
					my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY


m
e
c

n
c
$nodeletter

a
e
$zone
$interfaceletter
$calcpressurecoefficient
y


-
-
y

y
-
-
-
-
-
-
-
-
YYY
";
					if ($exeonfiles eq "y") 
					{ 
						print `printthis`;
					}

					print TOSHELL "
#Adequating the ventilation network for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
					$countnode++;
				}
			}
		}

		my @node_letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", 
		"q", "r", "s", "t", "u", "v", "w", "x", "y", "z");
		if ( ($mode eq "componentmode") and ( $line =~ "opening"))
		{
			my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY


m
e
c

n
d
$node_letters[$countthing]

k
-
$windareas[$countopening]
-
-
y

y
-
-
-
-
-
-
-
YYY
";
			if ($exeonfiles eq "y") 
			{ 
				print `$printthis`;
			}

			print TOSHELL "
#Adequating the ventilation network for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";

			$countopening++;
			$countthing++;
		}
		elsif ( ($mode eq "componentmode") and ( $line =~ "crack "))
		{
			MY $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY


m
e
c

n
d
$node_letters[$countthing]

l
-
$crackwidths[$countjoint] $jointlenghts[$countjoint]
-
-
y

y
-
-
-
-
-
-
-
YYY
";
			if ($exeonfiles eq "y") 
			{ 
				print `$printthis`;
			}

			print TOSHELL $printthis;

			$countcrack++;
			$countthing++;
			$countjoint++;
		}
		$countlines++;
	}
} # END SUB recalculatenet
##############################################################################


##############################################################################
sub apply_constraints
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap2 = shift;
	my @apply_constraints = @$swap2;
	my $countvar = shift;
	my $fileconfig = shift;

	my $value_reshape;
	my $ybasewall; 
	my $ybasewindow;
	my @v;
	
	say "Propagating geometry constraints for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";


	foreach my $group_operations ( @apply_constraints )
	{
		my @group = @{$group_operations};
		my $yes_or_no_apply_constraints = $group[0];

		my @sourcefiles = @{$group[1]};
		my @targetfiles = @{$group[2]};
		my @configfiles = @{$group[3]};
		my @basevalues = @{$group[4]};
		my @swingvalues = @{$group[5]}; 
		my @work_values = @{$group[6]}; 
		my $longmenu =  $group[7]; 
		my $basevalue;		
		my $targetfile;	
		my $configfile;		
		my $swingvalue;	
		my $sourceaddress;	
		my $targetaddress;
		my $configaddress;
		my $countoperations = 0;

		foreach $sourcefile ( @sourcefiles )
		{ 
			$basevalue = $basevalues[$countoperations];
			$sourcefile = $sourcefiles[$countoperations];
			$targetfile = $targetfiles[$countoperations];
			$configfile = $configfiles[$countoperations];
			$swingvalue = $swingvalues[$countoperations];
			$sourceaddress = "$to$sourcefile";
			$targetaddress = "$to$targetfile";
			$configaddress = "$to/opts/$configfile";
			$longmenu = $longmenus[$countoperations];
			checkfile($sourceaddress, $targetaddress);

			open( SOURCEFILE, $sourceaddress ) or die "Can't open $sourcefile 2: $!\n";
			my @lines = <SOURCEFILE>;
			close SOURCEFILE;
			my $countlines = 0;
			my $countvert = 0;
			foreach my $line (@lines)
			{
				$line =~ s/^\s+//; 
				my @rowelements = split(/\s+|,/, $line);
				if   ($rowelements[0] eq "*vertex" ) 
				{
					if ($countvert == 0) 
					{
						push (@v, [ "vertexes of  $sourceaddress" ]);
						push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ] );
					}

					if ($countvert > 0) 
					{
						push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ] );
					}
					$countvert++;
				}
				$countlines++;
			}

			my @vertexletters;
			if ($longmenu eq "y")
			{
				@vertexletters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", 
				"o", "p", "0\nb\nq", "0\nb\nr", "0\nb\ns", "0\nb\nt", "0\nb\nu", "0\nb\nv", "0\nb\nw", 
				"0\nb\nx", "0\nb\ny", "0\nb\nz", "0\nb\na", "0\nb\nb","0\nb\nc","0\nb\nd","0\nb\ne",
				"0\nb\n0\nb\nf","0\nb\n0\nb\ng","0\nb\n0\nb\nh","0\nb\n0\nb\ni","0\nb\n0\nb\nj",
				"0\nb\n0\nb\nk","0\nb\n0\nb\nl","0\nb\n0\nb\nm","0\nb\n0\nb\nn","0\nb\n0\nb\no",
				"0\nb\n0\nb\np","0\nb\n0\nb\nq","0\nb\n0\nb\nr","0\nb\n0\nb\ns","0\nb\n0\nb\nt");
			}
			else
			{
				@vertexletters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
				"n", "o", "p", "0\nq", "0\nr", "0\ns", "0\nt", "0\nu", "0\nv", "0\nw", "0\nx", 
				"0\ny", "0\nz", "0\na", "0\nb","0\n0\nc","0\n0\nd","0\n0\ne","0\n0\nf","0\n0\ng",
				"0\n0\nh","0\n0\ni","0\n0\nj","0\n0\nk","0\n0\nl","0\n0\nm","0\n0\nn","0\n0\no",
				"0\n0\np","0\n0\nq","0\n0\nr","0\n0\ns","0\n0\nt");
			}

			if ($constrain) { eval ($constrain); } # HERE THE INSTRUCTION WRITTEN IN THE OPT CONFIGURATION FILE CAN BE SPEFICIED
			# FOR PROPAGATION OF CONSTRAINTS

			if (-e $configaddress) 
			{	
				eval `cat $configaddress`; # HERE AN EXTERNAL FILE FOR PROPAGATION OF CONSTRAINTS 
				# IS EVALUATED, AND HERE BELOW CONSTRAINTS ARE PROPAGATED.

				if ($constrain) { eval ($constrain); } # HERE THE INSTRUCTION WRITTEN IN THE OPT CONFIGURATION FILE CAN BE SPEFICIED
				# FOR PROPAGATION OF CONSTRAINTS


				my $countvertex = 0;
				foreach (@v)
				{
					if ($countvertex > 0)
					{			
						my $vertexletter = $vertexletters[$countvertex-1];
						if ($vertexletter ~~ @work_values)
						{
							my $printthis = 
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
d
$vertexletter
$v[$countvertex][0] $v[$countvertex][1] $v[$countvertex][2]
-
y
-
y
c
-
-
-
-
-
-
-
-
-
YYY
";
							if ($exeonfiles eq "y") 
							{ 
								print `$printthis`;
							}

							print TOSHELL "
#Propagating geometry constraints for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
						}
					}
					$countvertex++;
				}
			}
			$countoperations++;
		}
	}
} # END SUB apply_constraints
##############################################################################


##############################################################################
sub reshape_windows # IT APPLIES CONSTRAINTS
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap2 = shift;
	my @reshape_windows = @$swap2;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Reshaping windows for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my @work_letters ;
	my @v;						

	foreach my $group_operations ( @{$reshape_windows[$countzone]} )
	{
		my @group = @{$group_operations};
		my @sourcefiles = @{$group[0]};
		my @targetfiles = @{$group[1]};
		my @configfiles = @{$group[2]};
		my @basevalues = @{$group[3]};
		my @swingvalues = @{$group[4]};
		my @work_letters = @{$group[5]}; 
		my @longmenus = @{$group[6]}; 

		my $countoperations = 0;
		foreach $sourcefile ( @sourcefiles )
		{ 
			my $basevalue = $basevalues[$countoperations];
			my $sourcefile = $sourcefiles[$countoperations];
			my $targetfile = $targetfiles[$countoperations];
			my $configfile = $configfiles[$countoperations];
			my $swingvalue = $swingvalues[$countoperations];
			my $longmenu = $longmenus[$countoperations];
			my $sourceaddress = "$to$sourcefile";
			my $targetaddress = "$to$targetfile";
			my $configaddress = "$to/opts/$configfile";
			my $totalswing = ( 2 * $swingvalue );			
			my $pace = ( $totalswing / ( $stepsvar - 1 ) );
			checkfile($sourceaddress, $targetaddress);
			
			open( SOURCEFILE, $sourceaddress ) or die "Can't open $sourcefile 2: $!\n";
			my @lines = <SOURCEFILE>;
			close SOURCEFILE;

			my $countlines = 0;
			my $countvert = 0;
			foreach my $line (@lines)
			{
				$line =~ s/^\s+//; 

				my @rowelements = split(/\s+|,/, $line);
				if   ($rowelements[0] eq "*vertex" ) 
				{
					if ($countvert == 0) 
					{
						push (@v, [ "vertexes of  $sourceaddress", [], [] ]);
						push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ] );
					}

					if ($countvert > 0) 
					{
						push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ] );
					}

					$countvert++;
				}
				$countlines++;
			}

			my @vertexletters;
			if ($longmenu eq "y")
			{																
				@vertexletters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
				"n", "o", "p", "0\nb\nq", "0\nb\nr", "0\nb\ns", "0\nb\nt", "0\nb\nu", "0\nb\nv", 
				"0\nb\nw", "0\nb\nx", "0\nb\ny", "0\nb\nz", "0\nb\na", "0\nb\nb","0\nb\nc","0\nb\nd",
				"0\nb\ne","0\nb\n0\nb\nf","0\nb\n0\nb\ng","0\nb\n0\nb\nh","0\nb\n0\nb\ni",
				"0\nb\n0\nb\nj","0\nb\n0\nb\nk","0\nb\n0\nb\nl","0\nb\n0\nb\nm","0\nb\n0\nb\nn",
				"0\nb\n0\nb\no","0\nb\n0\nb\np","0\nb\n0\nb\nq","0\nb\n0\nb\nr","0\nb\n0\nb\ns",
				"0\nb\n0\nb\nt");
			}
			else
			{
				@vertexletters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
				"n", "o", "p", "0\nq", "0\nr", "0\ns", "0\nt", "0\nu", "0\nv", "0\nw", "0\nx", 
				"0\ny", "0\nz", "0\na", "0\nb","0\n0\nc","0\n0\nd","0\n0\ne","0\n0\nf","0\n0\ng",
				"0\n0\nh","0\n0\ni","0\n0\nj","0\n0\nk","0\n0\nl","0\n0\nm","0\n0\nn","0\n0\no",
				"0\n0\np","0\n0\nq","0\n0\nr","0\n0\ns","0\n0\nt");
			}

			$value_reshape_window =  ( ( $basevalue - $swingvalue) + ( $pace * ( $countstep - 1 )) );

			if (-e $configaddress)
			{				

				eval `cat $configaddress`;	# HERE AN EXTERNAL FILE FOR PROPAGATION OF CONSTRAINTS 
				# IS EVALUATED, AND HERE BELOW CONSTRAINTS ARE PROPAGATED.

				if (-e $constrain) { eval ($constrain); } # HERE THE INSTRUCTION WRITTEN IN THE OPT CONFIGURATION FILE CAN BE SPEFICIED
				# FOR PROPAGATION OF CONSTRAINTS					

				my $countvertex = 0;

				foreach (@v)
				{
					if ($countvertex > 0)
					{
						my $vertexletter = $vertexletters[$countvertex];
						if ($vertexletter  ~~ @work_letters)
						{
							my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
d
$vertexletter
$v[$countvertex+1][0] $v[$countvertex+1][1] $v[$countvertex+1][2]
-
y
-
y
c
-
-
-
-
-
-
-
-
-
YYY
";
							if ($exeonfiles eq "y") 
							{ 
								print `$printthis`;
							}

							print TOSHELL "
#Reshaping windows for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
						}
					}
					$countvertex++;
				}
			}
			$countoperations++;
		}

	}
} # END SUB reshape_windows
##############################################################################


sub warp #
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $warp = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Warping zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $yes_or_no_warp =  $$warp[$countzone][0];
	my @surfs_to_warp =  @{ $warp->[$countzone][1] };
	my @vertexes_numbers =  @{ $warp->[$countzone][2] };   
	my @swingrotations = @{ $warp->[$countzone][3] };
	my @yes_or_no_apply_to_others = @{ $warp->[$countzone][4] };
	my $configfilename = $$warp[$countzone][5];
	my $configfile = $to."/opts/".$configfilename;
	my @pairs_of_vertexes = @{ $warp->[$countzone][6] }; # @pairs_of_vertexes defining axes
	my @windows_to_reallign = @{ $warp->[$countzone][7] };
	my $sourcefilename = $$warp[$countzone][8];
	my $sourcefile = $to.$sourcefilename;
	my $longmenu = $$warp[$countzone][9];
	if ( $yes_or_no_warp eq "y" )
	{
		my $countrotate = 0;
		foreach my $surface_letter (@surfs_to_warp)
		{
			$swingrotate = $swingrotations[$countrotate];
			$pacerotate = ( $swingrotate / ( $stepsvar - 1 ) );
			$rotation_degrees = ( ( $swingrotate / 2 ) - ( $pacerotate * ( $countstep - 1 ) )) ;
			$vertex_number = $vertexes_numbers[$countrotate];
			$yes_or_no_apply = $yes_or_no_apply_to_others[$countrotate];
			if (  ( $swingrotate != 0 ) and ( $stepsvar > 1 ) and ( $yes_or_no_warp eq "y" ) )
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
e
>
$surface_letter
c
$vertex_number
$rotation_degrees
$yes_or_no_apply
-
-
y
c
-
-
-
-
-
-
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{ 
					print `$printthis`;
				}
				print  TOSHELL "
#Warping zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
			}
			$countrotate++;
		}

		# THIS SECTION READS THE CONFIG FILE FOR DIMENSIONS
		open( SOURCEFILE, $sourcefile ) or die "Can't open $sourcefile: $!\n";
		my @lines = <SOURCEFILE>;
		close SOURCEFILE;
		my $countlines = 0;
		my $countvert = 0;
		foreach my $line (@lines)
		{
			$line =~ s/^\s+//; 
				
			my @rowelements = split(/\s+|,/, $line);
			if   ($rowelements[0] eq "*vertex" ) 
			{
				if ($countvert == 0) 
				{
					push (@v, [ "vertexes of  $sourceaddress" ]);
					push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ] );
				}

				if ($countvert > 0) 
				{
					push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ] );
				}
				$countvert++;
			}
			$countlines++;
		}


		my @vertexletters;
			if ($longmenu eq "y")
			{
				@vertexletters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", 
				"o", "p", "0\nb\nq", "0\nb\nr", "0\nb\ns", "0\nb\nt", "0\nb\nu", "0\nb\nv", "0\nb\nw", 
				"0\nb\nx", "0\nb\ny", "0\nb\nz", "0\nb\na", "0\nb\nb","0\nb\nc","0\nb\nd","0\nb\ne",
				"0\nb\n0\nb\nf","0\nb\n0\nb\ng","0\nb\n0\nb\nh","0\nb\n0\nb\ni","0\nb\n0\nb\nj",
				"0\nb\n0\nb\nk","0\nb\n0\nb\nl","0\nb\n0\nb\nm","0\nb\n0\nb\nn","0\nb\n0\nb\no",
				"0\nb\n0\nb\np","0\nb\n0\nb\nq","0\nb\n0\nb\nr","0\nb\n0\nb\ns","0\nb\n0\nb\nt");
			}
			else
			{
				@vertexletters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", 
				"o", "p", "0\nq", "0\nr", "0\ns", "0\nt", "0\nu", "0\nv", "0\nw", "0\nx", "0\ny", 
				"0\nz", "0\na", "0\nb","0\n0\nc","0\n0\nd","0\n0\ne","0\n0\nf","0\n0\ng","0\n0\nh",
				"0\n0\ni","0\n0\nj","0\n0\nk","0\n0\nl","0\n0\nm","0\n0\nn","0\n0\no","0\n0\np",
				"0\n0\nq","0\n0\nr","0\n0\ns","0\n0\nt");
			}


		if (-e $configfile)
		{				
			eval `cat $configfile`; # HERE AN EXTERNAL FILE FOR PROPAGATION OF CONSTRAINTS IS EVALUATED 
			# AND PROPAGATED.

			if (-e $constrain) { eval ($constrain); } # HERE THE INSTRUCTION WRITTEN IN THE OPT CONFIGURATION FILE CAN BE SPEFICIED
			# FOR PROPAGATION OF CONSTRAINTS

		}
		# THIS SECTION SHIFTS THE VERTEX TO LET THE BASE SURFACE AREA UNCHANGED AFTER THE WARPING.

		my $countthis = 0;
		$number_of_moves = ( (scalar(@pairs_of_vertexes)) /2 ) ;
		foreach my $pair_of_vertexes (@pairs_of_vertexes)
		{
			if ($countthis < $number_of_moves)
			{
				$vertex1 = $pairs_of_vertexes[ 0 + ( 2 * $countthis ) ];
				$vertex2 = $pairs_of_vertexes[ 1 + ( 2 * $countthis ) ];

				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
d
^
j
$vertex1
$vertex2
-
$addedlength
y
-
y
-
y
-
-
-
-
-
-
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{ 
					print `$printthis`;
				}
				print TOSHELL "
#Warping zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis";
			}
			$countthis++;
		}
	}
}    # END SUB warp
##############################################################################


##############################################################################
##############################################################################
# BEGINNING OF SECTION DEDICATED TO FUNCTIONS FOR CONSTRAINING GEOMETRY

sub constrain_geometry # IT APPLIES CONSTRAINTS TO ZONE GEOMETRY
{
	# IT CONSTRAIN GEOMETRY FILES. IT HAS TO BE CALLED FROM THE MAIN FILE WITH:
	# constrain_geometry($to, $fileconfig, $stepsvar, $countzone, $countstep, $exeonfiles, \@applytype, \@constrain_geometry);
	# constrain_geometry($to, $fileconfig, $stepsvar, $countzone, 
	# $countstep, $exeonfiles, \@applytype, \@constrain_geometry, $to_do);
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap = shift;
	my @constrain_geometry = @$swap;
	my $to_do = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Propagating constraints on geometry for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	# print $_outfile_ "YOUCALLED!\n\n";
	# print $_outfile_ "HERE: \@constrain_geometry:" . Dumper(@constrain_geometry) . "\n\n";
	if ($longmenu eq "y")
	{																
		@vertexletters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", 
		"o", "p", "0\nb\nq", "0\nb\nr", "0\nb\ns", "0\nb\nt", "0\nb\nu", "0\nb\nv", "0\nb\nw", 
		"0\nb\nx", "0\nb\ny", "0\nb\nz", "0\nb\na", "0\nb\nb","0\nb\nc","0\nb\nd","0\nb\ne",
		"0\nb\n0\nb\nf","0\nb\n0\nb\ng","0\nb\n0\nb\nh","0\nb\n0\nb\ni","0\nb\n0\nb\nj",
		"0\nb\n0\nb\nk","0\nb\n0\nb\nl","0\nb\n0\nb\nm","0\nb\n0\nb\nn","0\nb\n0\nb\no",
		"0\nb\n0\nb\np","0\nb\n0\nb\nq","0\nb\n0\nb\nr","0\nb\n0\nb\ns","0\nb\n0\nb\nt");
	}
	else
	{
		@vertexletters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
		"n", "o", "p", "0\nq", "0\nr", "0\ns", "0\nt", "0\nu", "0\nv", "0\nw", "0\nx", 
		"0\ny", "0\nz", "0\na", "0\nb","0\n0\nc","0\n0\nd","0\n0\ne","0\n0\nf","0\n0\ng",
		"0\n0\nh","0\n0\ni","0\n0\nj","0\n0\nk","0\n0\nl","0\n0\nm","0\n0\nn","0\n0\no",
		"0\n0\np","0\n0\nq","0\n0\nr","0\n0\ns","0\n0\nt");
	}

	foreach my $elm (@constrain_geometry)
	{
		my @group = @{$elm};
		# print $_outfile_ "INSIDE: \@constrain_geometry:" . Dumper(@constrain_geometry) . "\n\n";
		# print $_outfile_ "INSIDE: \@group:" . Dumper(@group) . "\n\n";
		my $zone_letter = $group[1];
		my $sourcefile = $group[2];
		my $targetfile = $group[3];
		my $configfile = $group[4];
		my $sourceaddress = "$to$sourcefile";
		my $targetaddress = "$to$targetfile";
		my @work_letters = @{$group[5]}; 
		my $longmenus = $group[6]; 

		# print $_outfile_ "VARIABLES: \$to:$to, \$fileconfig:$fileconfig, \$stepsvar:$stepsvar, \$countzone:$countzone, \$countstep:$countstep, \$exeonfiles:$exeonfiles, 
		# \$zone_letter:$zone_letter, \$sourceaddress:$sourceaddress, \$targetaddress:$targetaddress, \$longmenus:$longmenus, \@work_letters, " . Dumper(@work_letters) . "\n\n";

		unless ($to_do eq "justwrite")
		{
			checkfile($sourceaddress, $targetaddress);
			read_geometry($to, $sourcefile, $targetfile, $configfile, \@work_letters, $longmenus);
			read_geo_constraints($to, $fileconfig, $stepsvar, $countzone, $countstep, $configaddress, \@v, \@tempv, $countvar, $configfile );
		}

		unless ($to_do eq "justread")
		{
			apply_geo_constraints(\@dov, \@vertexletters, \@work_letters, $exeonfiles, $zone_letter, $toshellmorph, $outfilemorph, $configfile, \@tempv);
		}
		# print $_outfile_ "\@v: " . Dumper(@v) . "\n\n";
	}
} # END SUB constrain_geometry


sub read_geometry
{
	# THIS READS GEOMETRY FILES. # IT HAS TO BE CALLED WITH:
	# read_geometry($to, $sourcefile, $targetfile, $configfiles, \@work_letters, $longmenus);
	my $to = shift;
	my $sourcefile = shift;
	my $targetfile = shift;
	my $configfile = shift;
	my $swap = shift;
	my @work_letters = @$swap;
	my $longmenus = shift;
	my $sourceaddress = "$to$sourcefile";
	my $targetaddress = "$to$targetfile";
	my $configaddress = "$to$configfile";
	my $configfile = shift;
	my $countvar = shift;
			
	open( SOURCEFILE, $sourceaddress ) or die "Can't open $sourcefile 2: $!\n";
	my @lines = <SOURCEFILE>;
	close SOURCEFILE;

	my $countlines = 0;
	my $countvert = 0;
	foreach my $line (@lines)
	{
		$line =~ s/^\s+//; 

		my @rowelements = split(/\s+|,/, $line);
		if   ($rowelements[0] eq "*vertex" ) 
		{
			push (@v, [ $rowelements[1], $rowelements[2], $rowelements[3] ] );
			$countvert++;
		}
		$countlines++;
	}
	@dov = @v;
} # END SUB read_geometry


sub read_geo_constraints
{	
	# THIS FILE IS FOR OPT TO READ GEOMETRY USER-IMPOSED CONSTRAINTS.
	# IT IS CALLED WITH: read_geo_constraints($configaddress);
	# THIS MAKES AVAILABLE THE VERTEXES IN THE GEOMETRY FILES TO THE USER FOR MANIPULATION, IN THE FOLLOWING FORM:
	# $v[$countzone][$number][$x], $v[$countzone][$number][$y], $v[$countzone][$number][$z]. EXAMPLE: $v[0][4][$x] = 1. 
	# OR: @v[0][4][$x] =  @v[0][4][$y]. OR EVEN: @v[1][4][$x] =  @v[0][3][$z].
	# The $countzone that is actuated is always the last, the one which is active. 
	# It would have therefore no sense writing $v[0][4][$x] =  $v[1][2][$y].
	# Differentent $countzones can be referred to the same zone. Different $countzones just number mutations in series.
	# ALSO, IT MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS 
	# AND THE STEPS THE MODEL HAVE TO FOLLOW. 
	# THIS ALLOWS TO IMPOSE EQUALITY CONSTRAINTS TO THESE VARIABLES, 
	# WHICH COULD ALSO BE COMBINED WITH THE FOLLOWING ONES: 
	# $stepsvar, WHICH TELLS THE PROGRAM HOW MANY ITERATION STEPS IT HAS TO DO IN THE CURRENT MORPHING PHASE.
	# $countzone, WHICH TELLS THE PROGRAM WHAT OPERATION IS BEING EXECUTED IN THE CHAIN OF OPERATIONS 
	# THAT MAY BE EXECUTES AT EACH MORPHING PHASE. EACH $countzone WILL CONTAIN ONE OR MORE ITERATION STEPS.
	# TYPICALLY, IT WILL BE USED FOR A ZONE, BUT NOTHING PREVENTS THAT SEVERAL OF THEM CHAINED ONE AFTER 
	# THE OTHER ARE APPLIED TO THE SAME ZONE.
	# $countstep, WHICH TELLS THE PROGRAM WHAT THE CURRENT ITERATION STEP IS.
	my $to = shift;
	my $fileconfig = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $configaddress = shift;
	my $swap = shift;
	my @myv = @$swap;
	@tempv = @myv;
	my $configfile = shift;
	my $countvar = shift;

	my $x = 0;
	my $y = 1;
	my $z = 2;
	unshift (@myv, [ "vertexes of  $sourceaddress. \$countzone: $countzone ", [], [] ]);

	if (-e $configaddress)
	{	
		push (@v, [@myv]); #
		eval `cat $configaddress`; # HERE AN EXTERNAL FILE FOR PROPAGATION OF CONSTRAINTS IS EVALUATED.

		if (-e $constrain) { eval ($constrain); } # HERE THE INSTRUCTION WRITTEN IN THE OPT CONFIGURATION FILE CAN BE SPEFICIED
		# FOR PROPAGATION OF CONSTRAINTS

		@dov = @{$v[$#v]}; #
		shift (@dov); #
	}
} # END SUB read_geo_constraints


sub apply_geo_constraints
{
	# IT APPLY USER-IMPOSED CONSTRAINTS TO A GEOMETRY FILES VIA SHELL
	# IT HAS TO BE CALLED WITH: 
	# apply_geo_constraints(\@v, \@vertexletters, \@work_letters, \$exeonfiles, \$zone_letter);
	my $swap = shift;
	my @v = @$swap;
	my $swap = shift;
	my @vertexletters = @$swap;

	my $swap = shift;
	my @work_letters = @$swap;

	my $exeonfiles = shift;
	my $zone_letter = shift;
	my $toshellmorph = shift;
	my $outfilemorph = shift;
	my $configfile = shift;
	my $swap = shift;
	my @tempv = @$swap;
	my $configfile = shift;
	my $countvar = shift;

	my $countvertex = 0;

	foreach my $v (@v)
	{
		my $vertexletter = $vertexletters[$countvertex];
		if 
		( 
			( 
				(@work_letters eq "") or ($vertexletter  ~~ @work_letters) 
			)
			and 
			( 
				not ( @{$v[$countvertex]} ~~ @{$tempv[$countvertex]} ) 
			)
		)
		{ 
			my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
d
$vertexletter
$v[$countvertex+1][0] $v[$countvertex+1][1] $v[$countvertex+1][2]
-
y
-
y
c
-
-
-
-
-
-
-
-
-
YYY
";
			if ($exeonfiles eq "y") 
			{
				print `$printthis`;
			}

			print TOSHELL $printthis;
		}
		$countvertex++;
	}

} # END SUB apply_geo_constraints

# END OF SECTION DEDICATED TO FUNCTIONS FOR CONSTRAINING GEOMETRY
##############################################################################
##############################################################################



##############################################################################
##############################################################################
# BEGINNING OF SECTION DEDICATED TO FUNCTIONS FOR CONSTRAINING CONTROLS

sub vary_controls
{  	# IT IS CALLED FROM THE MAIN FILE
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap = shift;
	my @vary_controls = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Propagating constraints on controls for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $semaphore_zone;
	my $semaphore_dataloop;
	my $semaphore_massflow;
	my $count_controlmass = -1;
	my $semaphore_setpoint;
	my $countline = 0;
	my $doline;
	my @letters = ("e", "f", "g", "h", "i", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "z"); # CHECK IF THE LAST LETTERS ARE CORRECT, ZZZ
	my @period_letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "l", "m", "n", "o", "p", "q", "r", "s"); # CHECK IF THE LAST LETTERS ARE CORRECT, ZZZ
	my $loop_hour = 2; # NOTE: THE FOLLOWING VARIABLE NAMES ARE SHADOWED IN THE FOREACH LOOP BELOW, 
	# BUT ARE THE ONES USED IN THE OPT CONSTRAINTS FILES.
	my $max_heating_power = 3;
	my $min_heating_power = 4;
	my $max_cooling_power = 5,
	my $min_cooling_power = 6;
	my $heating_setpoint = 7;
	my $cooling_setpoint = 8;
	my $flow_hour = 2;
	my $flow_setpoint = 3;
	my $flow_onoff = 4;
	my $flow_fraction = 5;
	my $loop_letter;
	my $loopcontrol_letter;

	my @group = @{$vary_controls[$countzone]};
	my $sourcefile = $group[0];
	my $targetfile = $group[1];
	my $configfile = $group[2];
	my @buildbulk = @{$group[3]};
	my @flowbulk = @{$group[4]};
	my $countbuild = 0;
	my $countflow = 0;

	my $countcontrol = 0;
	my $sourceaddress = "$to$sourcefile";
	my $targetaddress = "$to$targetfile";
	my $configaddress = "$to$configfile";	

	#@loopcontrol; # DON'T PUT "my" HERE.
	#@flowcontrol; # DON'T PUT "my" HERE.
	#@new_loopcontrols; # DON'T PUT "my" HERE.
	#@new_flowcontrols; # DON'T PUT "my" HERE.
	my @groupzone_letters;
	my @zone_period_letters;
	my @flow_letters;
	my @fileloopbulk;
	my @fileflowbulk;

	checkfile($sourceaddress, $targetaddress);

	if ($countstep == 1)
	{
		read_controls($sourceaddress, $targetaddress, \@letters, \@period_letters);
	}


	sub calc_newctl
	{	# TO BE CALLED WITH: calc_newcontrols($to, $fileconfig, $stepsvar, $countzone, $countstep, \@buildbulk, \@flowbulk, \@loopcontrol, \@flowcontrol);
		# THIS COMPUTES CHANGES TO BE MADE TO CONTROLS BEFORE PROPAGATION OF CONSTRAINTS
		my $to = shift;
		my $stepsvar = shift; 
		
		my $countzone = shift;
		my $countstep = shift;
		my $swap = shift;
		my @buildbulk = @$swap;
		my $swap = shift;
		my @flowbulk = @$swap;
		my $swap = shift;
		my @loopcontrol = @$swap;
		my $swap = shift;
		my @flowcontrol = @$swap;
		my $countvar = shift;
		my $fileconfig = shift;

		my @new_loop_hours;
		my @new_max_heating_powers;
		my @new_min_heating_powers;
		my @new_max_cooling_powers;
		my @new_min_cooling_powers;
		my @new_heating_setpoints;
		my @new_cooling_setpoints;
		my @new_flow_hours;
		my @new_flow_setpoints;
		my @new_flow_onoffs;
		my @new_flow_fractions;

		# HERE THE MODIFICATIONS TO BE EXECUTED ON EACH PARAMETERS ARE CALCULATED.
		if ($stepsvar == 0) {$stepsvar = 1;}
		if ($stepsvar > 1) 
		{
			foreach $each_buildbulk (@buildbulk)
			{
				my @askloop = @{$each_buildbulk};
				my $new_loop_letter = $askloop[0];
				my $new_loopcontrol_letter = $askloop[1];
				my $swing_loop_hour = $askloop[2];
				my $swing_max_heating_power = $askloop[3];
				my $swing_min_heating_power = $askloop[4];
				my $swing_max_cooling_power = $askloop[5];
				my $swing_min_cooling_power = $askloop[6];
				my $swing_heating_setpoint = $askloop[7];
				my $swing_cooling_setpoint = $askloop[8];

				my $countloop = 0; #IT IS FOR THE FOLLOWING FOREACH. LEAVE IT ATTACHED TO IT.
				foreach $each_loop (@loopcontrol) # THIS DISTRIBUTES THIS NESTED DATA STRUCTURES IN A FLAT MODE TO PAIR THE INPUT FILE, USER DEFINED ONE.
				{
					my $countcontrol = 0;
					@thisloop = @{$each_loop};
					# my $letterfile = $letters[$countloop];
					foreach $lp (@thisloop)
					{
						my @control = @{$lp};
						# my $letterfilecontrol = $period_letters[$countcontrol];
						$loop_letter = $loopcontrol[$countloop][$countcontrol][0];
						$loopcontrol_letter = $loopcontrol[$countloop][$countcontrol][1];
						if ( ( $new_loop_letter eq $loop_letter ) and ($new_loopcontrol_letter eq $loopcontrol_letter ) )
						{
							# print $_outfile_ "YES!: \n\n\n";
							$loop_hour__ = $loopcontrol[$countloop][$countcontrol][$loop_hour];
							$max_heating_power__ = $loopcontrol[$countloop][$countcontrol][$max_heating_power];
							$min_heating_power__ = $loopcontrol[$countloop][$countcontrol][$min_heating_power];
							$max_cooling_power__ = $loopcontrol[$countloop][$countcontrol][$max_cooling_power];
							$min_cooling_power__ = $loopcontrol[$countloop][$countcontrol][$min_cooling_power];
							$heating_setpoint__ = $loopcontrol[$countloop][$countcontrol][$heating_setpoint];
							$cooling_setpoint__ = $loopcontrol[$countloop][$countcontrol][$cooling_setpoint];
						}
						$countcontrol++;
					}
					$countloop++;
				}

				my $pace_loop_hour =  ( $swing_loop_hour / ($stepsvar - 1) );
				my $floorvalue_loop_hour = ($loop_hour__ - ($swing_loop_hour / 2) );
				my $new_loop_hour = $floorvalue_loop_hour + ($countstep * $pace_loop_hour);

				my $pace_max_heating_power =  ( $swing_max_heating_power / ($stepsvar - 1) );
				my $floorvalue_max_heating_power = ($max_heating_power__ - ($swing_max_heating_power / 2) );
				my $new_max_heating_power = $floorvalue_max_heating_power + ($countstep * $pace_max_heating_power);

				my $pace_min_heating_power =  ( $swing_min_heating_power / ($stepsvar - 1) );
				my $floorvalue_min_heating_power = ($min_heating_power__ - ($swing_min_heating_power / 2) );
				my $new_min_heating_power = $floorvalue_min_heating_power + ($countstep * $pace_min_heating_power);

				my $pace_max_cooling_power =  ( $swing_max_cooling_power / ($stepsvar - 1) );
				my $floorvalue_max_cooling_power = ($max_cooling_power__ - ($swing_max_cooling_power / 2) );
				my $new_max_cooling_power = $floorvalue_max_cooling_power + ($countstep * $pace_max_cooling_power);

				my $pace_min_cooling_power =  ( $swing_min_cooling_power / ($stepsvar - 1) );
				my $floorvalue_min_cooling_power = ($min_cooling_power__ - ($swing_min_cooling_power / 2) );
				my $new_min_cooling_power = $floorvalue_min_cooling_power + ($countstep * $pace_min_cooling_power);

				my $pace_heating_setpoint =  ( $swing_heating_setpoint / ($stepsvar - 1) );
				my $floorvalue_heating_setpoint = ($heating_setpoint__ - ($swing_heating_setpoint / 2) );
				my $new_heating_setpoint = $floorvalue_heating_setpoint + ($countstep * $pace_heating_setpoint);

				my $pace_cooling_setpoint =  ( $swing_cooling_setpoint / ($stepsvar - 1) );
				my $floorvalue_cooling_setpoint = ($cooling_setpoint__ - ($swing_cooling_setpoint / 2) );
				my $new_cooling_setpoint = $floorvalue_cooling_setpoint + ($countstep * $pace_cooling_setpoint);

				$new_loop_hour = sprintf("%.2f", $new_loop_hour);
				$new_max_heating_power = sprintf("%.2f", $new_max_heating_power);
				$new_min_heating_power = sprintf("%.2f", $new_min_heating_power);
				$new_max_cooling_power = sprintf("%.2f", $new_max_cooling_power);
				$new_min_cooling_power = sprintf("%.2f", $new_min_cooling_power);
				$new_heating_setpoint = sprintf("%.2f", $new_heating_setpoint);
				$new_cooling_setpoint = sprintf("%.2f", $new_cooling_setpoint);

				push(@new_loopcontrols, 
				[ $new_loop_letter, $new_loopcontrol_letter, $new_loop_hour, 
				$new_max_heating_power, $new_min_heating_power, $new_max_cooling_power, 
				$new_min_cooling_power, $new_heating_setpoint, $new_cooling_setpoint ] );
			}

			my $countflow = 0;

			foreach my $elm (@flowbulk)
			{
				my @askflow = @{$elm};
				my $new_flow_letter = $askflow[0];
				my $new_flowcontrol_letter = $askflow[1];
				my $swing_flow_hour = $askflow[2];
				my $swing_flow_setpoint = $askflow[3];
				my $swing_flow_onoff = $askflow[4];
				if ( $swing_flow_onoff eq "ON") { $swing_flow_onoff = 1; }
				elsif ( $swing_flow_onoff eq "OFF") { $swing_flow_onoff = -1; }
				my $swing_flow_fraction = $askflow[5];

				my $countflow = 0; # IT IS FOR THE FOLLOWING FOREACH. LEAVE IT ATTACHED TO IT.
				foreach $each_flow (@flowcontrol) # THIS DISTRIBUTES THOSE NESTED DATA STRUCTURES IN A FLAT MODE TO PAIR THE INPUT FILE, USER DEFINED ONE.
				{
					my $countcontrol = 0;
					@thisflow = @{$each_flow};
					# my $letterfile = $letters[$countflow];
					foreach $elm (@thisflow)
					{
						my @control = @{$elm};
						# my $letterfilecontrol = $period_letters[$countcontrol];
						$flow_letter = $flowcontrol[$countflow][$countcontrol][0];
						$flowcontrol_letter = $flowcontrol[$countflow][$countcontrol][1];
						if ( ( $new_flow_letter eq $flow_letter ) and ($new_flowcontrol_letter eq $flowcontrol_letter ) )
						{
							$flow_hour__ = $flowcontrol[$countflow][$countcontrol][$flow_hour];
							$flow_setpoint__ = $flowcontrol[$countflow][$countcontrol][$flow_setpoint];
							$flow_onoff__ = $flowcontrol[$countflow][$countcontrol][$flow_onoff];
							if ( $flow_onoff__ eq "ON") { $flow_onoff__ = 1; }
							elsif ( $flow_onoff__ eq "OFF") { $flow_onoff__ = -1; }
							$flow_fraction__ = $flowcontrol[$countflow][$countcontrol][$flow_fraction];
						}
						$countcontrol++;
					}
					$countflow++;
				}
	
				my $pace_flow_hour =  ( $swing_flow_hour / ($stepsvar - 1) );
				my $floorvalue_flow_hour = ($flow_hour__ - ($swing_flow_hour / 2) );
				my $new_flow_hour = $floorvalue_flow_hour + ($countstep * $pace_flow_hour);

				my $pace_flow_setpoint =  ( $swing_flow_setpoint / ($stepsvar - 1) );
				my $floorvalue_flow_setpoint = ($flow_setpoint__ - ($swing_flow_setpoint / 2) );
				my $new_flow_setpoint = $floorvalue_flow_setpoint + ($countstep * $pace_flow_setpoint);

				my $pace_flow_onoff =  ( $swing_flow_onoff / ($stepsvar - 1) );
				my $floorvalue_flow_onoff = ($flow_onoff__ - ($swing_flow_onoff / 2) );
				my $new_flow_onoff = $floorvalue_flow_onoff + ($countstep * $pace_flow_onoff);

				my $pace_flow_fraction =  ( $swing_flow_fraction / ($stepsvar - 1) );
				my $floorvalue_flow_fraction = ($flow_fraction__ - ($swing_flow_fraction / 2) );
				my $new_flow_fraction = $floorvalue_flow_fraction + ($countstep * $pace_flow_fraction);

				$new_flow_hour = sprintf("%.2f", $new_flow_hour);
				$new_flow_setpoint = sprintf("%.2f", $new_flow_setpoint);
				$new_flow_onoff = sprintf("%.2f", $new_flow_onoff);
				$new_flow_fraction = sprintf("%.2f", $new_flow_fraction);

				push(@new_flowcontrols, 
				[ $new_flow_letter, $new_flowcontrol_letter, $new_flow_hour,  $new_flow_setpoint, $new_flow_onoff, $new_flow_fraction ] );
			}
			# HERE THE MODIFICATIONS TO BE EXECUTED ON EACH PARAMETERS ARE APPLIED TO THE MODELS THROUGH ESP-r.
			# FIRST, HERE THEY ARE APPLIED TO THE ZONE CONTROLS, THEN TO THE FLOW CONTROLS
		}
	} # END SUB calc_newcontrols

	print $_outfile_ "\@new_loopcontrols: " . Dumper(@new_loopcontrols) . "\n\n";

	apply_loopcontrol_changes(\@new_loopcontrols);
	apply_flowcontrol_changes(\@new_flowcontrols);

} # END SUB vary_controls.



calc_newctl($to, $stepsvar, $countzone, $countstep, \@buildbulk, 
\@flowbulk, \@loopcontrol, \@flowcontrol, $countvar, $fileconfig );


sub constrain_controls 
{	# IT READS CONTROL USER-IMPOSED CONSTRAINTS
	my $to = shift;
	my $filecon = shift;
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap = shift;
	my @constrain_controls = @$swap;
	my $to_do = shift;
	my $countvar = shift;
	my $fileconfig = shift;

	my $elm = $constrain_controls[$countzone];
	my @group = @{$elm};
	my $sourcefile = $group[2];
	my $targetfile = $group[3];
	my $configfile = $group[4];
	my $sourceaddress = "$to$sourcefile";
	my $targetaddress = "$to$targetfile";
	my $configaddress = "$to$configfile";
	#@loopcontrol; @flowcontrol; @new_loopcontrols; @new_flowcontrols; # DON'T PUT "my" HERE. THEY ARE globsAL!!!
	my $semaphore_zone;
	my $semaphore_dataloop;
	my $semaphore_massflow;
	my $count_controlmass = -1;
	my $semaphore_setpoint;
	my $countline = 0;
	my $doline;
	my @letters = ("e", "f", "g", "h", "i", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "z"); # CHECK IF THE LAST LETTERS ARE CORRECT, ZZZ
	my @period_letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "l", "m", "n", "o", "p", "q", "r", "s"); # CHECK IF THE LAST LETTERS ARE CORRECT, ZZZ
	my $loop_hour = 2; # NOTE: THE FOLLOWING VARIABLE NAMES ARE SHADOWED IN THE FOREACH LOOP BELOW, 
	# BUT ARE THE ONES USED IN THE OPT CONSTRAINTS FILES.
	my $max_heating_power = 3;
	my $min_heating_power = 4;
	my $max_cooling_power = 5,
	my $min_cooling_power = 6;
	my $heating_setpoint = 7;
	my $cooling_setpoint = 8;
	my $flow_hour = 2;
	my $flow_setpoint = 3;
	my $flow_onoff = 4;
	my $flow_fraction = 5;
	my $loop_letter;
	my $loopcontrol_letter;
	my $countbuild = 0;
	my $countflow = 0;
	my $countcontrol = 0;	

	my @groupzone_letters;
	my @zone_period_letters;
	my @flow_letters;
	my @fileloopbulk;
	my @fileflowbulk;

	unless ($to_do eq "justwrite")
	{
		if ($countstep == 1)
		{
			print $_outfile_ "THIS\n";
			checkfile($sourceaddress, $targetaddress);
			read_controls($sourceaddress, $targetaddress, \@letters, \@period_letters);
			read_control_constraints($to, $stepsvar, 
			$countzone, $countstep, $configaddress, \@loopcontrol, \@flowcontrol, \@temploopcontrol, \@tempflowcontrol, $countvar, $fileconfig );
		}
	}

	unless ($to_do eq "justread")
	{
		print $_outfile_ "THAT\n";
		apply_loopcontrol_changes( \@new_loopcontrol, \@temploopcontrol);
		apply_flowcontrol_changes(\@new_flowcontrol, \@tempflowcontrol);
	}

} # END SUB constrain_controls.


sub read_controls
{	# TO BE CALLED WITH: read_controls($sourceaddress, $targetaddress, \@letters, \@period_letters);
	# THIS MAKES THE CONTROL CONFIGURATION FILE BE READ AND THE NEEDED VALUES ACQUIRED.
	# NOTICE THAT CURRENTLY ONLY THE "basic control law" IS SUPPORTED.

	my $sourceaddress = shift;
	my $targetaddress = shift;
	# checkfile($sourceaddress, $targetaddress); # THIS HAS TO BE _FIXED!_
	my $swap = shift;
	my @letters = @$swap;
	my $swap = shift;
	my @period_letters = @$swap;
	my $countvar = shift;

	open( SOURCEFILE, $sourceaddress ) or die "Can't open $sourceaddress: $!\n";
	my @lines = <SOURCEFILE>;
	close SOURCEFILE;
	my $countlines = 0;
	my $countloop = -1;
	my $countloopcontrol;
	my $countflow = -1;
	my $countflowcontrol = -1;
	my $semaphore_building;
	my $semaphore_loop;
	my $loop_hour;
	my $semaphore_loopcontrol;
	my $semaphore_massflow;
	my $flow_hour;
	my $semaphore_flow;
	my $semaphore_flowcontrol;
	my $loop_letter;
	my $loopcontrol_letter;
	my $flow_letter;
	my $flowcontrol_letter;

	foreach my $line (@lines)
	{
		if ( $line =~ /Control function/ )
		{
			$semaphore_loop = "yes";
			$countloopcontrol = -1;
			$countloop++;
			$loop_letter = $letters[$countloop];
		}
		if ( ($line =~ /ctl type, law/ ) )
		{
			$countloopcontrol++;
			my @row = split(/\s+/, $line);
			$loop_hour = $row[3];
			$semaphore_loopcontrol = "yes";
			$loopcontrol_letter = $period_letters[$countloopcontrol];
		}

		if ( ($semaphore_loop eq "yes") and ($semaphore_loopcontrol eq "yes") and ($line =~ /No. of data items/ ) ) 
		{  
			$doline = $countlines + 1;
		}

		if ( ($semaphore_loop eq "yes" ) and ($semaphore_loopcontrol eq "yes") and ($countlines == $doline) ) 
		{
			my @row = split(/\s+/, $line);
			my $max_heating_power = $row[1];
			my $min_heating_power = $row[2];
			my $max_cooling_power = $row[3];
			my $min_cooling_power = $row[4];
			my $heating_setpoint = $row[5];
			my $cooling_setpoint = $row[6];

			push(@{$loopcontrol[$countloop][$countloopcontrol]}, 
			$loop_letter, $loopcontrol_letter, $loop_hour, 
			$max_heating_power, $min_heating_power, $max_cooling_power, 
			$min_cooling_power, $heating_setpoint, $cooling_setpoint );

			$semaphore_loopcontrol = "no";
			$doline = "";
		}

		if ($line =~ /Control mass/ )
		{
			$semaphore_flow = "yes";
			$countflowcontrol = -1;
			$countflow++;
			$flow_letter = $letters[$countflow];
		}
		if ( ($line =~ /ctl type \(/ ) )
		{
			$countflowcontrol++;
			my @row = split(/\s+/, $line);
			$flow_hour = $row[3];
			$semaphore_flowcontrol = "yes";
			$flowcontrol_letter = $period_letters[$countflowcontrol];
		}

		if ( ($semaphore_flow eq "yes") and ($semaphore_flowcontrol eq "yes") and ($line =~ /No. of data items/ ) ) 
		{  
			$doline = $countlines + 1;
		}

		if ( ($semaphore_flow eq "yes" ) and ($semaphore_flowcontrol eq "yes") and ($countlines == $doline) ) 
		{
			my @row = split(/\s+/, $line);
			my $flow_setpoint = $row[1];
			my $flow_onoff = $row[2];
			my $flow_fraction = $row[3];
			push(@{$flowcontrol[$countflow][$countflowcontrol]}, 
			$flow_letter, $flowcontrol_letter, $flow_hour, $flow_setpoint, $flow_onoff, $flow_fraction);
			$semaphore_flowcontrol = "no";
			$doline = "";
		}
		$countlines++;
	}			
} # END SUB read_controls.


sub read_control_constraints
{
	#  #!/usr/bin/perl
	# THIS FILE CAN CONTAIN USER-IMPOSED CONSTRAINTS FOR CONTROLS TO BE READ BY OPT.
	# THE FOLLOWING VALUES CAN BE ADDRESSED IN THE OPT CONSTRAINTS CONFIGURATION FILE, 
	# SET BY THE PRESENT FUNCTION:
	# 1) $loopcontrol[$countzone][$countloop][$countloopcontrol][$loop_hour] 
	# Where $countloop and  $countloopcontrol has to be set to a specified number in the OPT file for constraints.
	# 2) $loopcontrol[$countzone][$countloop][$countloopcontrol][$max_heating_power] # Same as above.
	# 3) $loopcontrol[$countzone][$countloop][$countloopcontrol][$min_heating_power] # Same as above.
	# 4) $loopcontrol[$countzone][$countloop][$countloopcontrol][$max_cooling_power] # Same as above.
	# 5) $loopcontrol[$countzone][$countloop][$countloopcontrol][$min_cooling_power] # Same as above.
	# 6) $loopcontrol[$countzone][$countloop][$countloopcontrol][heating_setpoint] # Same as above.
	# 7) $loopcontrol[$countzone][$countloop][$countloopcontrol][cooling_setpoint] # Same as above.
	# 8) $flowcontrol[$countzone][$countflow][$countflowcontrol][$flow_hour] 
	# Where $countflow and  $countflowcontrol has to be set to a specified number in the OPT file for constraints.
	# 9) $flowcontrol[$countzone][$countflow][$countflowcontrol][$flow_setpoint] # Same as above.
	# 10) $flowcontrol[$countzone][$countflow][$countflowcontrol][$flow_onoff] # Same as above.
	# 11) $flowcontrol[$countzone][$countflow][$countflowcontrol][$flow_fraction] # Same as above.
	# EXAMPLE : $flowcontrol[0][1][2][$flow_fraction] = 0.7
	# OTHER EXAMPLE: $flowcontrol[2][1][2][$flow_fraction] = $flowcontrol[0][2][1][$flow_fraction]
	# The $countzone that is actuated is always the last, the one which is active. 
	# It would have therefore no sense writing $flowcontrol[1][1][2][$flow_fraction] = $flowcontrol[3][2][1][$flow_fraction].
	# Differentent $countzones can be referred to the same zone. Different $countzones just number mutations in series.
	# ALSO, THIS MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS 
	# AND THE STEPS THE MODEL HAS TO FOLLOW. 
	# THIS ALLOWS TO IMPOSE EQUALITY CONSTRAINTS TO THESE VARIABLES, 
	# WHICH COULD ALSO BE COMBINED WITH THE FOLLOWING ONES: 
	# $stepsvar, WHICH TELLS THE PROGRAM HOW MANY ITERATION STEPS IT HAS TO DO IN THE CURRENT MORPHING PHASE.
	# $countzone, WHICH TELLS THE PROGRAM WHAT OPERATION IS BEING EXECUTED IN THE CHAIN OF OPERATIONS 
	# THAT MAY BE EXECUTES AT EACH MORPHING PHASE. EACH $countzone WILL CONTAIN ONE OR MORE ITERATION STEPS.
	# TYPICALLY, IT WILL BE USED FOR A ZONE, BUT NOTHING PREVENTS THAT SEVERAL OF THEM CHAINED ONE AFTER 
	# THE OTHER ARE APPLIED TO THE SAME ZONE.
	# $countstep, WHICH TELLS THE PROGRAM WHAT THE CURRENT ITERATION STEP IS.
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	@loopcontrol = @$swap;
	my $swap = shift;
	@flowcontrol = @$swap;
	my $swap = shift;
	@temploopcontrol = @$swap;
	my $swap = shift;
	@tempflowcontrol = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;

	if (-e $configaddress) # TEST THIS, DDD
	{	# THIS APPLIES CONSTRAINST, THE FLATTEN THE HIERARCHICAL STRUCTURE OF THE RESULTS,
		# TO BE PREPARED THEN FOR BEING APPLIED TO CHANGE PROCEDURES. IT HAS TO BE TESTED.
		push (@loopcontrol, [@myloopcontrol]); #
		push (@flowcontrol, [@myflowcontrol]); #

		eval `cat $configaddress`;	# HERE AN EXTERNAL FILE FOR PROPAGATION OF CONSTRAINTS 
		# IS EVALUATED, AND HERE BELOW CONSTRAINTS ARE PROPAGATED.	

		if (-e $constrain) { eval ($constrain); } # HERE THE INSTRUCTION WRITTEN IN THE OPT CONFIGURATION FILE CAN BE SPEFICIED
		# FOR PROPAGATION OF CONSTRAINTS

		@doloopcontrol = @{$loopcontrol[$#loopcontrol]}; #
		@doflowcontrol = @{$flowcontrol[$#flowcontrol]}; #

		shift (@doloopcontrol);
		shift (@doflowcontrol);

		sub flatten_loopcontrol_constraints
		{
			my @looptemp = @doloopcontrol;
			@new_loopcontrol = "";
			foreach my $elm (@looptemp)
			{
				my @loop = @{$elm};
				foreach my $elm (@loop)
				{
					my @loop = @{$elm};
					push (@new_loopcontrol, [@loop]);
				}
			}
		}
		flatten_loopcontrol_constraints;

		sub flatten_flowcontrol_constraints
		{
			my @flowtemp = @doflowcontrol;
			@new_flowcontrol = "";
			foreach my $elm (@flowtemp)
			{
				my @flow = @{$elm};
				foreach my $elm (@flow)
				{
					my @loop = @{$elm};
					push (@new_flowcontrol, [@flow]);
				}
			}
		}
		flatten_flowcontrol_constraints;

		shift @new_loopcontrol;
		shift @new_flowcontrol;
	}
} # END SUB read_control_constraints


sub apply_loopcontrol_changes
{ 	# TO BE CALLED WITH: apply_loopcontrol_changes($exeonfiles, \@new_loopcontrol);
	# THIS APPLIES CHANGES TO LOOPS IN CONTROLS (ZONES)
	my $swap = shift;
	my @new_loop_ctls = @$swap;
	my $swap = shift;
	my @temploopcontrol = @$swap;
	my $countvar = shift;
	
	my $countloop = 0;

	foreach my $elm (@new_loop_ctls)
	{
		my @loop = @{$elm};
		$new_loop_letter = $loop[0];
		$new_loopcontrol_letter = $loop[1];
		$new_loop_hour = $loop[2];
		$new_max_heating_power = $loop[3];
		$new_min_heating_power = $loop[4];
		$new_max_cooling_power = $loop[5];
		$new_min_cooling_power = $loop[6];
		$new_heating_setpoint = $loop[7];
		$new_cooling_setpoint = $loop[8];
		unless ( @{$new_loop_ctls[$countloop]} ~~ @{$temploopcontrol[$countloop]} )
		{
			my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
j

$new_loop_letter
c
$new_loopcontrol_letter
1
$new_loop_hour
b
$new_max_heating_power
c
$new_min_heating_power
d
$new_max_cooling_power
e
$new_min_cooling_power
f
$new_heating_setpoint
g
$new_cooling_setpoint
-
y
-
-
-
n
d

-
y
y
-
-
YYY
";
			if ($exeonfiles eq "y") 
			{
				print `$printthis`;
			}
			print TOSHELL $printthis;
		}
		$countloop++;
	}
} # END SUB apply_loopcontrol_changes();




sub apply_flowcontrol_changes
{	# THIS HAS TO BE CALLED WITH: apply_flowcontrol_changes($exeonfiles, \@new_flowcontrols);
	# # THIS APPLIES CHANGES TO NETS IN CONTROLS
	my $swap = shift;
	my @new_flowcontrols = @$swap;
	my $swap = shift;
	my @tempflowcontrol = @$swap;
	my $countflow = 0;
	my $countvar = shift;

	foreach my $elm (@new_flowcontrols)
	{
		my @flow = @{$elm};
		$flow_letter = $flow[0];
		$flowcontrol_letter = $flow[1];
		$new_flow_hour = $flow[2];
		$new_flow_setpoint = $flow[3];
		$new_flow_onoff = $flow[4];
		$new_flow_fraction = $flow[5];
		unless ( @{$new_flowcontrols[$countflow]} ~~ @{$tempflowcontrol[$countflow]} )
		{
			my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
l

$flow_letter
c
$flowcontrol_letter
a
$new_flow_hour
$new_flow_setpoint $new_flow_onoff $new_flow_fraction
-
-
-
y
y
-
-
YYY
";
			if ($exeonfiles eq "y") # if ($exeonfiles eq "y") 
			{ 
				print `$printthis`;
			}

			print TOSHELL $printthis;
		}
		$countflow++;
	}
} # END SUB apply_flowcontrol_changes;

# END OF SECTION DEDICATED TO FUNCTIONS FOR CONSTRAINING CONTROLS
##############################################################################
##############################################################################

##############################################################################
##############################################################################
# BEGINNING OF SECTION DEDICATED TO FUNCTIONS FOR CONSTRAINING OBSTRUCTIONS	

sub constrain_obstructions # IT APPLIES CONSTRAINTS TO OBSTRUCTIONS
{
	# THIS CONSTRAINS OBSTRUCTION FILES. IT HAS TO BE CALLED FROM THE MAIN FILE WITH:
	# constrain_obstruction($to, $fileconfig, $stepsvar, $countzone, $countstep, $exeonfiles, \@applytype, \@constrain_obstructions);
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap2 = shift;
	my @constrain_obstructions = @$swap2;
	my $to_do = shift;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Propagating constraints on obstructions for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my @work_letters;
	#@obs;	# globsAL!

	foreach my $elm (@constrain_obstructions)
	{
		my @group = @{$elm};
		my $zone_letter = $group[1];
		my $sourcefile = $group[2];
		my $targetfile = $group[3];
		my $configfile_ = $group[4];
		my $sourceaddress = "$to$sourcefile";
		my $targetaddress = "$to$targetfile";
		my $configaddress = "$to$configfile";
		my @work_letters = @{$group[5]}; 
		my $actonmaterials = $group[6];
	
		unless ($to_do eq "justwrite")
		{
			checkfile($sourceaddress, $targetaddress);
			read_obstructions($to, $sourceaddress, $targetaddress, $configaddress, \@work_letters, $actonmaterials);
			read_obs_constraints($to, $stepsvar, $countzone, $countstep, $configaddress, $actonmaterials, \@tempobs, $countvar, $fileconfig  ); # IT WORKS ON THE VARIABLE @obs, WHICH IS globsAL.
		}

		unless ($to_do eq "justread")
		{
			apply_obs_constraints(\@doobs, \@obs_letters, \@work_letters, $zone_letter, $actonmaterials, \@tempobs);
		}
	}
} # END SUB constrain_obstructions


sub read_obstructions
{
	# THIS READS GEOMETRY FILES. # IT HAS TO BE CALLED WITH:
	# read_geometry($to, $sourcefile, $targetfile, $configfiles, \@work_letters, $longmenus);
	my $to = shift;
	my $sourceaddress = shift;
	my $targetaddress = shift;
	my $configaddress = shift;
	my $swap = shift;
	@work_letters = @$swap;
	my $actonmaterials = shift;
	my $countvar = shift;
				
	open( SOURCEFILE, $sourceaddress) or die "Can't open $sourceaddress: $!\n";
	my @lines = <SOURCEFILE>;
	close SOURCEFILE;

	my $count = 0;
	foreach my $line (@lines)
	{
		#$line =~ s/^\s+//; 
		if  ( $line =~ m/\*obs/ ) 
		{
			unless ( $line =~ m/\*obs =/ ) 
			{
				$count++;
			}
		}
	}

	if ( $count > 21 )
	{																
		@obs_letters = ("e", "f", "g", "h", "i", "j", "k", "l", "m", "n", 
		"o", "0\nb\nf", "0\nb\ng", "0\nb\nh", "0\nb\ni", "0\nb\nj", "0\nb\nk", "0\nb\nm", 
		"0\nb\nn", "0\nb\no", "0\nb\n0\nb\nf","0\nb\n0\nb\ng",
		"0\nb\n0\nb\nh","0\nb\n0\nb\ni","0\nb\n0\nb\nj","0\nb\n0\nb\nk","0\nb\n0\nb\nl",
		"0\nb\n0\nb\nm","0\nb\n0\nb\nn","0\nb\n0\nb\no","0\nb\n0\nb\n0\nb\nf",
		"0\nb\n0\nb\n0\nb\ng","0\nb\n0\nb\n0\nb\nh","0\nb\n0\nb\n0\nb\ni","0\nb\n0\nb\n0\nb\nj",
		"0\nb\n0\nb\n0\nb\nk","0\nb\n0\nb\n0\nb\nl","0\nb\n0\nb\n0\nb\nm","0\nb\n0\nb\n0\nb\nn",
		"0\nb\n0\nb\n0\nb\no");
	}
	else
	{	
		@obs_letters = ("e", "f", "g", "h", "i", "j", "k", "l", "m", 
		"n", "o", "0\nf", "0\ng", "0\nh", "0\ni", "0\nj", "0\nk", "0\nl", 
		"0\nm", "0\nn", "0\no");
	}

	my $count = 0;
	foreach my $line (@lines)
	{
		if  ( $line =~ m/\*obs/ ) 
		{
			unless ( $line =~ m/\*obs =/ ) 
			{
				#$line =~ s/^\s+//; 
				my @rowelements = split(/,/, $line);	
				push (@obs, [ $rowelements[1], $rowelements[2], $rowelements[3], 
				$rowelements[4], $rowelements[5], $rowelements[6], 
				$rowelements[7], $rowelements[8], $rowelements[9], 
				$rowelements[10], $rowelements[11], $rowelements[12], $obs_letters[$count] ] );
				$count++;
			}
		}
	}
} # END SUB read_obstructions


sub read_obs_constraints
{	
	# THE VARIABLE @obs REGARDS OBSTRUCTION USER-IMPOSED CONSTRAINTS
	# THIS CONSTRAINT CONFIGURATION FILE MAKES AVAILABLE TO THE USER THE FOLLOWING VARIABLES:
	# $obs[$countzone][$obs_number][$x], $obs[$countzone][$obs_number][$y], $obs[$countzone][$obs_number][$y]
	# $obs[$countzone][$obs_number][$width], $obs[$countzone][$obs_number][$depth], $obs[$countzone][$obs_number][$height]
	# $obs[$countzone][$obs_number][$z_rotation], $obs[$countzone][$obs_number][$y_rotation], 
	# $obs[$countzone][$obs_number][$tilt], $obs[$countzone][$obs_number][$opacity], $obs[$countzone][$obs_number][$material], 
	# EXAMPLE: $obs[0][2][$x] = 2. THIS MEANS: AT COUNTERZONE 0, COORDINATE x OF OBSTRUCTION HAS TO BE SET TO 2.
	# OTHER EXAMPLE: $obs[0][2][$x] = $obs[2][2][$y].
	# The $countzone that is actuated is always the last, the one which is active. 
	# There would be therefore no sense in writing $obs[0][4][$x] =  $obs[1][2][$y].
	# Differentent $countzones can be referred to the same zone. Different $countzones just number mutations in series.
	# NOTE THAT THE MATERIAL TO BE SPECIFIED IS A MATERIAL LETTER, BETWEEN QUOTES. EXAMPLE: $obs[1][$material] = "a".
	#  $tilt IS PRESENTLY UNUSED.
	# ALSO, THIS MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS 
	# AND THE STEPS THE MODEL HAVE TO FOLLOW.
	# THIS ALLOWS TO IMPOSE EQUALITY CONSTRAINTS TO THESE VARIABLES, 
	# WHICH COULD ALSO BE COMBINED WITH THE FOLLOWING ONES: 
	# $stepsvar, WHICH TELLS THE PROGRAM HOW MANY ITERATION STEPS IT HAS TO DO IN THE CURRENT MORPHING PHASE.
	# $countzone, WHICH TELLS THE PROGRAM WHAT OPERATION IS BEING EXECUTED IN THE CHAIN OF OPERATIONS 
	# THAT MAY BE EXECUTES AT EACH MORPHING PHASE. EACH $countzone WILL CONTAIN ONE OR MORE ITERATION STEPS.
	# TYPICALLY, IT WILL BE USED FOR A ZONE, BUT NOTHING PREVENTS THAT SEVERAL OF THEM CHAINED ONE AFTER 
	# THE OTHER ARE APPLIED TO THE SAME ZONE.
	# $countstep, WHICH TELLS THE PROGRAM WHAT THE CURRENT ITERATION STEP IS.
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $configaddress = shift;
	my $actonmaterials = shift;
	my $swap = shift;
	@tempobs = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;

	my $obs_letter = 13;
	my $x = 1;
	my $y = 2;
	my $z = 3;
	my $width = 4;
	my $depth = 5;
	my $height = 6;
	my $z_rotation = 7;
	my $y_rotation = 8;
	my $tilt = 9; # UNUSED
	my $opacity = 10;
	my $name = 11; # NOT TO BE CHANGED
	my $material = 12;
	if (-e $configaddress)
	{	
		unshift (@obs, []);	
		push (@obs, [@myobs]); #	
		eval `cat $configaddress`; # HERE AN EXTERNAL FILE FOR PROPAGATION OF CONSTRAINTS IS EVALUATED.

		if (-e $constrain) { eval ($constrain); } # HERE THE INSTRUCTION WRITTEN IN THE OPT CONFIGURATION FILE CAN BE SPEFICIED
		# FOR PROPAGATION OF CONSTRAINTS

		@doobs = @{$obs[$#obs]}; #
		shift @doobs;
	}
} # END SUB read_geo_constraints


sub apply_obs_constraints
{
	# IT APPLY USER-IMPOSED CONSTRAINTS TO A GEOMETRY FILES VIA SHELL
	# IT HAS TO BE CALLED WITH: 
	# apply_geo_constraints(\@obs, \@obsletters, \@work_letters, \$exeonfiles, \$zone_letter, $actonmaterials);
	my $swap = shift;
	my @obs = @$swap;
	my $swap = shift;
	my @obs_letters = @$swap;
	my $swap = shift;
	my @work_letters = @$swap;
	my $zone_letter = shift;
	#print $_outfile_ "ZONE LETTER: $zone_letter\n\n";
	my $actonmaterials = shift;
	my $swap = shift;
	my @tempobs = @$swap;
	my $countvar = shift;

	my $countobs = 0;
	print $_outfile_ "OBS_LETTERS IN APPLY" . Dumper(@obs_letters) . "\n\n";
	foreach my $ob (@obs)
	{
		my $obs_letter = $obs_letters[$countobs];
		if ( ( @work_letters eq "") or ($obs_letter  ~~ @work_letters))
		{
			my @obstr = @{$ob};
			my $x = $obstr[0];
			my $y = $obstr[1];
			my $z = $obstr[2];
			my $width = $obs[3];
			my $depth = $obs[4];
			my $height = $obs[5];
			my $z_rotation = $obs[6];
			my $y_rotation = $obs[7];
			my $tilt = $obs[8];
			my $opacity = $obs[9];
			my $name = $obs[10];
			my $material = $obs[11];
			unless
			( 
				( @{$obs[$countobs]} ~~ @{$tempobs[$countobs]} ) 
			)
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
h
a
$obs_letter
a
a
$x $y $z
b
$width $depth $height
c
$z_rotation
d
$y_rotation
e # HERE THE DATUM IS STILL UNUSED. WHEN IT WILL, A LINE MUST BE ADDED WITH THE VARIABLE $tilt.
h
$opacity
-
-
c
-
c
-
-
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{
					print `$printthis`;
				}

				print TOSHELL $printthis;
			}

			my $obs_letter = $obs_letters[$countobs];
			if ($obs_letter  ~~ @work_letters)
			{
				if ($actonmaterials eq "y")
				{	
					my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
h
a
$obs_letter
g
$material
-
-
-
c
-
c
-
-
-
-
YYY
";		
					if ($exeonfiles eq "y") 
					{
						print `$printthis`;
					}

					print TOSHELL $printthis;
				}
			}
		}
		$countobs++;
	}
} # END SUB apply_obs_constraints


############################################################## BEGINNING OF GROUP GET AND PIN OBSTRUCTIONS
sub get_obstructions # IT APPLIES CONSTRAINTS TO ZONE GEOMETRY. TO DO. STILL UNUSED. 
# THE SAME FUNCTIONALITIES CAN BE OBTAINED, WITH MORE WORK, BY SPECIFYING APPROPRIATE SETTINGS IN THE OPT CONFIG FILE.
{
	# THIS CONSTRAINS OBSTRUCTION FILES. IT HAS TO BE CALLED FROM THE MAIN FILE WITH:
	# constrain_obstruction($to, $fileconfig, $stepsvar, $countzone, $countstep, $exeonfiles, \@applytype, \@constrain_obstructions);
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap2 = shift;
	my @get_obstructions = @$swap2;
	my $countvar = shift;

	my @work_letters ;
	@obs;	# globsAL!
	foreach my $elm (@constrain_obstructions)
	{
		my @group = @{$elm};
		my $zone_letter = $group[1];
		my $sourcefile = $group[2];
		my $targetfile = $group[3];
		my $sourceaddress = "$to$sourcefile";
		my $targetaddress = "$to$targetfile";
		my $temp = $group[4];
		my @work_letters = @{$group[5]}; 
		my @obs_letters;
		checkfile($sourceaddress, $targetaddress);
		read_obstructions($to, $sourceaddress, $targetaddress, $configaddress, \@work_letters);
		write_temporary(\@obs, \@obs_letters, \@work_letters, $zone_letter, $temp);
	}
} # END SUB constrain_obstructions


sub write_temporary
{
	# IT APPLY USER-IMPOSED CONSTRAINTS TO A GEOMETRY FILES VIA SHELL. TO DO. STILL UNUSED. ZZZ
	# IT HAS TO BE CALLED WITH: 
	# apply_geo_constraints(\obs, \@obsletters, \@work_letters, \$exeonfiles, \$zone_letter, $actonmaterials);
	my $swap = shift;
	my @obs = @$swap;
	my $swap = shift;
	my @obs_letters = @$swap;
	my $swap = shift;
	my @work_letters = @$swap;
	my $zone_letter = shift;
	my $temp = shift;
	my $countvar = shift;

	open( SOURCEFILE, ">$temp" ) or die "Can't open $temp: $!\n";
	my $countobs = 0;

	foreach my $ob (@obs)
	{
		my $obs_letter = $obs_letters[$countobs];
		if ($obs_letter  ~~ @work_letters)
		{
			my @obs = @{$ob};
			print SOURCEFILE . "*obs $obs[1] $obs[2] $obs[3] $obs[4] $obs[5] $obs[6] $obs[7] $obs[8] $obs[10] $obs[11] $obs[12] $obs_letter\n";
		}
		$countobs++;
		close SOURCEFILE;
	}
} # END SUB write_temporary


sub pin_obstructions  # TO DO. ZZZ
{
	# THIS CONSTRAINS OBSTRUCTION FILES. TO DO. STILL UNUSED. ZZZ
	# IT HAS TO BE CALLED FROM THE MAIN FILE WITH:
	# constrain_obstruction($to, $fileconfig, $stepsvar, $countzone, $countstep, $exeonfiles, \@applytype, \@pin_obstructions);
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap = shift;
	my @pin_obstructions = @$swap;
	my $countvar = shift;

	my @work_letters ;
	my @obs;	
	my @newobs;
	foreach my $elm (@pin_obstructions)
	{
		my @group = @{$elm};
		my $zone_letter = $group[1];
		my $sourcefile = $group[2];
		my $targetfile = $group[3];
		my $sourceaddress = "$to$sourcefile";
		my $targetaddress = "$to$targetfile";
		my $temp = $group[4];
		my @obs_letters;
		checkfile($sourceaddress, $targetaddress);

		open( SOURCEFILE, $temp ) or die "Can't open $temp: $!\n";
		my @rows = < SOURCEFILE >;
		foreach my $line (@rows)
		{
			my @elts = split(/\s+|,/, $line);
			push (@newobs, [ $elts[1],  $elts[2], $elts[3], $elts[4], $elts[5], $elts[6], $elts[7], $elts[8], $elts[9], $elts[10], $elts[11], $elts[12], $elts[13] ] );
		}
		apply_pin_obstructions($to, $stepsvar, $countzone, $countstep, \@newobs, $countvar, $fileconfig  );
	}
	close SOURCEFILE;
} # END SUB pin_obstructions


sub apply_pin_obstructions # TO DO. STILL UNUSED. ZZZ
{
	# IT APPLY USER-IMPOSED CONSTRAINTS TO A GEOMETRY FILES VIA SHELL
	# IT HAS TO BE CALLED WITH: 
	# apply_pin_obstructions( $to, $fileconfig,$stepsvar, $countzone, $countstep, $exeonfiles, \@obs );
	my $to = shift;
	my $stepsvar = shift; 
	
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @obs = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;

	my $countobs = 0;
	foreach my $ob (@obs)
	{
		my @obs = @{$ob};
		my $x = $obs[1];
		my $y = $obs[2];
		my $z = $obs[3];
		my $width = $obs[4];
		my $depth = $obs[5];
		my $height = $obs[6];
		my $z_rotation = $obs[7];
		my $y_rotation = $obs[8];
		my $tilt = $obs[9];
		my $opacity = $obs[10];
		my $name = $obs[11];
		my $material = $obs[12];
		my $obs_letter = $obs[13];

		my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
c
a
$zone_letter
h
a
$obs_letter
a
a
$x $y $z
b
$width $depth $height
c
$z_rotation
d
$y_rotation
e # HERE THE DATUM IS STILL UNUSED. WHEN IT WILL, A LINE MUST BE ADDED WITH THE VARIABLE $tilt.
h
$opacity
-
-
c
-
c
-
-
-
-
YYY
";
		if ($exeonfiles eq "y") 
		{
			print `$printthis`;
		}

		print TOSHELL $printthis;
	}
	$countvertex++;
} # END SUB apply_pin_obstructions
############################################################## END OF GROUP GET AND PIN OBSTRUCTIONS


##############################################################################
##############################################################################
# END OF SECTION DEDICATED TO FUNCTIONS FOR CONSTRAINING OBSTRUCTIONS



##############################################################################
##############################################################################
# BEGINNING OF SECTION DEDICATED TO FUNCTIONS FOR CONSTRAINING THE MASS-FLOW NETWORKS

sub vary_net
{  	# IT IS CALLED FROM THE MAIN FILE
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap = shift;
	my @vary_net = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Propagating constraints on networks for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $activezone = $applytype[$countzone][3];
	my ($semaphore_node, $semaphore_component, $node_letter);
	my $count_component = -1;
	my $countline = 0;
	my @node_letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "l", "m", "n", "o", "p", "q", "r", "s"); # CHECK IF THE LAST LETTERS ARE CORRECT, ZZZ
	my @component_letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "l", "m", "n", "o", "p", "q", "r", "s"); # CHECK IF THE LAST LETTERS ARE CORRECT, ZZZ
	# NOTE: THE FOLLOWING VARIABLE NAMES ARE SHADOWED IN THE FOREACH LOOP BELOW, 
	# BUT ARE THE ONES USED IN THE OPT CONSTRAINTS FILES.

	my @group = @{$vary_net[$countzone]};
	my $sourcefile = $group[0];
	my $targetfile = $group[1];
	my $configfile = $group[2];
	my @nodebulk = @{$group[3]};
	my @componentbulk = @{$group[4]};
	my $countnode = 0;
	my $countcomponent = 0;

	my $sourceaddress = "$to$sourcefile";
	my $targetaddress = "$to$targetfile";
	my $configaddress = "$to$configfile";	

	#@node; @component; # PLURAL. DON'T PUT "my" HERE!
	#@new_nodes; @new_components; # DON'T PUT "my" HERE.

	my @flow_letters;

	checkfile($sourceaddress, $targetaddress);

	if ($countstep == 1)
	{
		read_net($sourceaddress, $targetaddress, \@node_letters, \@component_letters);
	}

	sub calc_newnet
	{	# TO BE CALLED WITH: calc_newnet($to, $fileconfig, $stepsvar, $countzone, $countstep, \@nodebulk, \@componentbulk, \@node_, \@component);
		# THIS COMPUTES CHANGES TO BE MADE TO CONTROLS BEFORE PROPAGATION OF CONSTRAINTS
		my $to = shift;
		my $stepsvar = shift; 
		my $countzone = shift;
		my $countstep = shift;
		my $swap = shift;
		my @nodebulk = @$swap;
		my $swap = shift;
		my @componentbulk = @$swap;
		my $swap = shift;
		my @node = @$swap; # PLURAL
		my $swap = shift;
		my @component = @$swap; # PLURAL
		my $countvar = shift;
		my $fileconfig = shift;
		
		my @new_volumes_or_surfaces;
		my @node_heights_or_cps;
		my @new_azimuths;
		my @boundary_heights;

		# HERE THE MODIFICATIONS TO BE EXECUTED ON EACH PARAMETERS ARE CALCULATED.
		if ($stepsvar == 0) {$stepsvar = 1;}
		if ($stepsvar > 1) 
		{
			foreach $each_nodebulk (@nodebulk)
			{
				my @asknode = @{$each_nodebulk};
				my $new_node_letter = $asknode[0];
				my $new_fluid = $asknode[1];
				my $new_type = $asknode[2];
				my $new_zone = $activezone;
				my $swing_height = $asknode[3];
				my $swing_data_2 = $asknode[4];
				my $new_surface = $asknode[5];
				my @askcp = @{$asknode[6]};
				my ($height__, $data_2__, $data_1__, $new_cp);					
				my $countnode = 0; #IT IS FOR THE FOLLOWING FOREACH. LEAVE IT ATTACHED TO IT.
				foreach $each_node (@node)
				{
					@node_ = @{$each_node};
					my $node_letter = $node_[0]; 
					if ( $new_node_letter eq $node_letter ) 
					{
						$height__ = $node_[3];
						$data_2__ = $node_[4];
						$data_1__ = $node_[5];
						$new_cp = $askcp[$countstep-1];
					}
					$countnode++;
				}
				my $height = ( $swing_height / ($stepsvar - 1) );
				my $floorvalue_height = ($height__ - ($swing_height / 2) );
				my $new_height = $floorvalue_height + ($countstep * $pace_height);
				$new_height = sprintf("%.3f", $height);
				if ($swing_height == 0) { $new_height = ""; }

				my $pace_data_2 =  ( $swing_data_2 / ($stepsvar - 1) );
				my $floorvalue_data_2 = ($data_2__ - ($swing_data_2 / 2) );
				my $new_data_2 = $floorvalue_data_2 + ($countstep * $pace_data_2);
				$new_data_2 = sprintf("%.3f", $new_data_2);
				if ($swing_data_2 == 0) { $new_data_2 = ""; }

				my $pace_data_1 =  ( $swing_data_1 / ($stepsvar - 1) ); # UNUSED
				my $floorvalue_data_1 = ($data_1__ - ($swing_data_1 / 2) );
				my $new_data_1 = $floorvalue_data_1 + ($countstep * $pace_data_1);
				$new_data_1  = sprintf("%.3f", $new_data_1);
				if ($swing_data_1 == 0) { $new_data_1 = ""; }

				push(@new_nodes, 
				[ $new_node_letter, $new_fluid, $new_type, $new_zone, $new_height, $new_data_2, $new_surface, $new_cp ] );
			}

			foreach $each_componentbulk (@componentbulk)
			{
				my @askcomponent = @{$each_componentbulk};
				my $new_component_letter = $askcomponent[0];

				my $new_type = $askcomponent[1];
				my $swing_data_1 = $askcomponent[2];
				my $swing_data_2 = $askcomponent[3];
				my $swing_data_3 = $askcomponent[4];	
				my $swing_data_4 = $askcomponent[5];
				my $component_letter;				
				my $countcomponent = 0;    #IT IS FOR THE FOLLOWING FOREACH.
				my ($new_type, $data_1__, $data_2__, $data_3__, $data_4__ );
				foreach $each_component (@component) # PLURAL
				{
					@component_ = @{$each_component};
					$component_letter = $component_letters[$countcomponent]; 
					if ( $new_component_letter eq $component_letter ) 
					{
						$new_component_letter = $component_[0];
						$new_fluid = $component_[1];
						$new_type = $component_[2];
						$data_1__ = $component_[3];
						$data_2__ = $component_[4];
						$data_3__ = $component_[5];
						$data_4__ = $component_[6];
					}
					$countcomponent++;
				}

				my $pace_data_1 =  ( $swing_data_1 / ($stepsvar - 1) ); 
				my $floorvalue_data_1 = ($data_1__ - ($swing_data_1 / 2) );
				my $new_data_1 = $floorvalue_data_1 + ($countstep * $pace_data_1);
				if ($swing_data_1 == 0) { $new_data_1 = ""; }

				my $pace_data_2 =  ( $swing_data_2 / ($stepsvar - 1) );
				my $floorvalue_data_2 = ($data_2__ - ($swing_data_2 / 2) );
				my $new_data_2 = $floorvalue_data_2 + ($countstep * $pace_data_2);
				if ($swing_data_2 == 0) { $new_data_2 = ""; }

				my $pace_data_3 =  ( $swing_data_3 / ($stepsvar - 1) ); 
				my $floorvalue_data_3 = ($data_3__ - ($swing_data_3 / 2) );
				my $new_data_3 = $floorvalue_data_3 + ($countstep * $pace_data_3 );
				if ($swing_data_3 == 0) { $new_data_3 = ""; }

				my $pace_data_4 =  ( $swing_data_4 / ($stepsvar - 1) ); 
				my $floorvalue_data_4 = ($data_4__ - ($swing_data_4 / 2) );
				my $new_data_4 = $floorvalue_data_4 + ($countstep * $pace_data_4 );
				if ($swing_data_4 == 0) { $new_data_4 = ""; }

				$new_data_1 = sprintf("%.3f", $new_data_1);
				$new_data_2 = sprintf("%.3f", $new_data_2);
				$new_data_3 = sprintf("%.3f", $new_data_3);
				$new_data_4 = sprintf("%.3f", $new_data_4);
				$new_data_4 = sprintf("%.3f", $new_data_4);

				push(@new_components, [ $new_component_letter, $new_fluid, $new_type, $new_data_1, $new_data_2, $new_data_3, $new_data_4 ] );
			}
		}
	} # END SUB calc_newnet

	calc_newnet($to, $stepsvar, $countzone, $countstep, \@nodebulk, \@componentbulk, \@node, \@component, $countvar, $fileconfig  );	# PLURAL

	apply_node_changes(\@new_nodes);
	apply_component_changes(\@new_components);

} # END SUB vary_net.


sub read_net
{
	my $sourceaddress = shift;
	my $targetaddress = shift;
	# checkfile($sourceaddress, $targetaddress); # THIS HAS TO BE _FIXED!_
	my $swap = shift;
	my @node_letters = @$swap;
	my $swap = shift;
	my @component_letters = @$swap;
	my $countvar = shift;

	open( SOURCEFILE, $sourceaddress ) or die "Can't open $sourcefile : $!\n";
	my @lines = <SOURCEFILE>;
	close SOURCEFILE;
	my $countlines = 0;
	my $countnode = -1;
	my $countcomponent = -1;
	my $countcomp = 0;
	my $semaphore_node = "no";
	my $semaphore_component = "no";
	my $semaphore_connection = "no";
	my ($component_letter, $type, $data_1, $data_2, $data_3, $data_4);
	foreach my $line (@lines)
	{
		if ( $line =~ m/Fld. Type/ )
		{
			$semaphore_node = "yes";
		}
		if ( $semaphore_node eq "yes" )
		{
			$countnode++;
		}
		if ( $line =~ m/Type C\+ L\+/ )
		{
			$semaphore_component = "yes";
			$semaphore_node = "no";
		}



		if ( ($semaphore_node eq "yes") and ( $semaphore_component eq "no" ) and ( $countnode >= 0))
		{
			$line =~ s/^\s+//; 
			my @row = split(/\s+/, $line);
			my $node_letter = $node_letters[$countnode];
			my $fluid = $row[1];
			my $type = $row[2];
			my $height = $row[3];
			my $data_2 = $row[6]; # volume or azimuth
			my $data_1 = $row[5]; #surface
			push(@node, [ $node_letter, $fluid, $type, $height, $data_2, $data_1 ] ); # PLURAL
		}

		if ( $semaphore_component eq "yes" )
		{
			$countcomponent++;
		}

		if ( $line =~ m/\+Node/ )
		{
			$semaphore_connection = "yes";
			$semaphore_component = "no";
			$semaphore_node = "no";
		}

		if ( ($semaphore_component eq "yes") and ( $semaphore_connection eq "no" ) and ( $countcomponent > 0))
		{
			$line =~ s/^\s+//; 
			my @row = split(/\s+/, $line);
			if ($countcomponent % 2 == 1) # $number is odd 
			{ 
				$component_letter = $component_letters[$countcomp];
				$fluid = $row[0];
				$type = $row[1];
				if ($type eq "110") { $type = "k";}
				if ($type eq "120") { $type = "l";}
				if ($type eq "130") { $type = "m";}
				$countcomp++;
			}
			else # $number is even 
			{ 
				$data_1 = $row[1];
				$data_2 = $row[2];
				$data_3 = $row[3];
				$data_4 = $row[4];
				push( @component, [ $component_letter, $fluid, $type, $data_1, $data_2, $data_3, $data_4 ] ); # PLURAL
			}

		}

		$countlines++;
	}
} # END SUB read_controls.


sub apply_node_changes
{ 	# TO BE CALLED WITH: apply_node_changes($exeonfiles, \@new_nodes);
	# THIS APPLIES CHANGES TO NODES IN NETS
	my $swap = shift;
	my @new_nodes = @$swap;
	my $swap = shift;
	my @tempnodes = @$swap;
	my $countvar = shift;

	my $countnode = 0;
	foreach my $elm (@new_nodes)
	{
		my @node_ = @{$elm};
		my $new_node_letter = $node_[0];
		my $new_fluid = $node_[1];
		my $new_type = $node_[2];
		my $new_zone = $node_[3];
		my $new_height = $node_[4];
		my $new_data_2 = $node_[5];
		my $new_surface = $node_[6];
		my $new_cp = $node_[7];

		unless ( @{$new_nodes[$countnode]} ~~ @{$tempnodes[$countnode]} )
		{
			if ($new_type eq "a" ) # IF NODES ARE INTERNAL
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
e
c

n
c
$new_node_letter

$new_fluid
$new_type
y
$new_zone
$new_data_2
$new_height
a

-
-
y

y
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{
					print `$printthis`;
				}
				print TOSHELL $printthis;
			}

			if ($new_type eq "e" ) # IF NODES ARE BOUNDARY ONES, WIND-INDUCED
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
e
c

n
c
$new_node_letter

$new_fluid
$new_type
$new_zone
$new_surface
$new_cp
y
$new_data_2
$new_height
-
-
y

y
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{
					print `$printthis`;
				}
				print TOSHELL $printthis;
			}
		}
		$countnode++;
	}
} # END SUB apply_node_changes;



sub apply_component_changes
{ 	# TO BE CALLED WITH: apply_component_changes($exeonfiles, \@new_components);
	# THIS APPLIES CHANGES TO COMPONENTS IN NETS
	my $swap = shift;
	my @new_components = @$swap; # [ $new_component_letter, $new_type, $new_data_1, $new_data_2, $new_data_3, $new_data_4 ] 
	my $swap = shift;
	my @tempcomponents = @$swap;
	my $countvar = shift;

	my $countcomponent = 0;
	foreach my $elm (@new_components)
	{
		my @component_ = @{$elm};
		my $new_component_letter = $component_[0];
		my $new_fluid = $component_[1];
		my $new_type = $component_[2];
		my $new_data_1 = $component_[3];
		my $new_data_2 = $component_[4];
		my $new_data_3 = $component_[5];
		my $new_data_4 = $component_[6];

		unless
		( @{$new_components[$countcomponents]} ~~ @{$tempcomponents[$countcomponents]} )
		{
			if ($new_type eq "k" ) # IF THE COMPONENT IS A GENERIC OPENING
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
e
c

n
d
$new_component_letter
$new_fluid
$new_type
-
$new_data_1
-
-
y

y
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{
					print `$printthis`;
				}
				print TOSHELL $printthis;
			}

			if ($new_type eq "l" ) # IF THE COMPONENT IS A CRACK
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
e
c

n
d
$new_component_letter
$new_fluid
$new_type
-
$new_data_1 $new_data_2
-
-
y

y
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{
					print `$printthis`;
				}
				print TOSHELL $printthis;
			}

			if ($new_type eq "m" ) # IF THE COMPONENT IS A DOOR
			{
				my $printthis =
"prj -file $to/cfg/$fileconfig -mode script<<YYY

m
e
c

n
d
$new_component_letter
$new_fluid
$new_type
-
$new_data_1 $new_data_2 $new_data_3 $new_data_4
-
-
y

y
-
-
YYY
";
				if ($exeonfiles eq "y") 
				{
					print `$printthis`;
				}
				print TOSHELL "$printthis";
			}
		}
		$countcomponent++;
	}
} # END SUB apply_component_changes;


sub constrain_net 
{	# IT ALLOWS TO MANIPULATE USER-IMPOSED CONSTRAINTS REGARDING NETS
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap = shift;
	my @constrain_net = @$swap;
	my $to_do = shift;
	my $countvar = shift;
	my $fileconfig = shift;

	my $elm = $constrain_net[$countzone];
	my @group = @{$elm};
	my $sourcefile = $group[2];
	my $targetfile = $group[3];
	my $configfile = $group[4];
	my $sourceaddress = "$to$sourcefile";
	my $targetaddress = "$to$targetfile";
	my $configaddress = "$to$configfile";

	my $node = 0;
	my $fluid = 1;
	my $type = 2;
	my $height = 3;
	my $volume = 4;
	my $volume = 4;
	my $azimuth = 4;
	my $component = 0;
	my $area = 3;
	my $width = 4;
	my $length = 5;
	my $door_width = 4;
	my $door_height = 5;
	my $door_nodeheight = 6;
	my $door_discharge = 7;

	my $activezone = $applytype[$countzone][3];
	my ($semaphore_node, $semaphore_component, $node_letter);
	my $count_component = -1;
	my $countline = 0;
	my @node_letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "l", "m", "n", "o", "p", "q", "r", "s"); # CHECK IF THE LAST LETTERS ARE CORRECT, ZZZ
	my @component_letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "l", "m", "n", "o", "p", "q", "r", "s"); # CHECK IF THE LAST LETTERS ARE CORRECT, ZZZ
	my $countnode = 0;
	my $countcomponent = 0;

	#@node; @component; # PLURAL! DON'T PUT "MY" HERE. globsAL.
	#@new_nodes; @new_components; # DON'T PUT "my" HERE. THEY ARE globsAL!!!

	unless ($to_do eq "justwrite")
	{
		checkfile($sourceaddress, $targetaddress);
		if ($countstep == 1)
		{
			read_net($sourceaddress, $targetaddress, \@node_letters, \@component_letters);
			read_net_constraints
			($to, $stepsvar, $countzone, $countstep, $configaddress, \@node, \@component, \@tempnode, \@tempcomponent, $countvar, $fileconfig  ); # PLURAL
		}
	}

	unless ($to_do eq "justread")
	{
		apply_node_changes(\@donode, \@tempnode); #PLURAL
		apply_component_changes(\@docomponent, \@tempcomponent);
	}
} # END SUB constrain_net.

sub read_net_constraints
{
	my $to = shift;
	my $stepsvar = shift; 
	my $countzone = shift;
	my $countstep = shift;
	my $configaddress = shift;
	my $swap = shift;
	@node = @$swap; # PLURAL
	my $swap = shift;
	@component = @$swap;
	my $swap = shift;
	@tempnode = @$swap;
	my $swap = shift;
	@tempcomponent = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;

	unshift (@node, []); # PLURAL
	unshift (@component, []);
	if (-e $configaddress) # TEST THIS
	{	# THIS APPLIES CONSTRAINST, THE FLATTEN THE HIERARCHICAL STRUCTURE OF THE RESULTS,
		# TO BE PREPARED THEN FOR BEING APPLIED TO CHANGE PROCEDURES. IT IS TO BE TESTED.

		push (@node, [@mynode]); #
		push (@component, [@mycomponent]); #

		eval `cat $configaddress`;	# HERE AN EXTERNAL FILE FOR PROPAGATION OF CONSTRAINTS 
		# IS EVALUATED, AND HERE BELOW CONSTRAINTS ARE PROPAGATED.
		# THIS FILE CAN CONTAIN USER-IMPOSED CONSTRAINTS FOR MASS-FLOW NETWORKS TO BE READ BY OPT.
		# IT MAKES AVAILABLE VARIABLES REGARDING THE SETTING OF NODES IN A NETWORK.
		# CURRENTLY: INTERNAL UNKNOWN AIR NODES AND BOUNDARY WIND-CONCERNED NODES.
		# IT MAKES AVAILABLE VARIABLES REGARDING COMPONENTS
		# CURRENTLY: WINDOWS, CRACKS, DOORS.
		# ALSO, THIS MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS.
		# SPECIFICALLY, THE FOLLOWING VARIABLES WHICH REGARD BOTH INTERNAL AND BOUNDARY NODES.
		# NOTE THAT "node_number" IS THE NUMBER OF THE NODE IN THE ".afn" ESP-r FILE. 
		# $node[$countzone][node_number][$node]. # EXAMPLE: $node[0][3][$node]. THIS IS THE LETTER OF THE THIRD NODE, 
		# AT THE FIRST CONTERZONE (NUMBERING STARTS FROM 0)
		# $node[$countzone][node_number][$type]
		# $node[$countzone][node_number][$height]. # EXAMPLE: $node[0][3][$node]. THIS IS THE HEIGHT OF THE 3RD NODE AT THE FIRST COUNTERZONE
		# THEN IT MAKES AVAILABLE THE FOLLOWING VARIABLES REGARDING NODES:
		# $node[$countzone][node_number][$volume] # REGARDING INTERNAL NODES
		# $node[$countzone][node_number][$azimut] # REGARDING BOUNDARY NODES
		# THEN IT MAKE AVAILABLE THE FOLLOWING VARIABLES REGARDING COMPONENTS:
		# $node[$countzone][node_number][$area] # REGARDING SIMPLE OPENINGS
		# $node[$countzone][node_number][$width] # REGARDING CRACKS
		# $node[$countzone][node_number][$length] # REGARDING CRACKS
		# $node[$countzone][node_number][$door_width] # REGARDING DOORS
		# $node[$countzone][node_number][$door_height] # REGARDING DOORS
		# $node[$countzone][node_number][$door_nodeheight] # REGARDING DOORS
		# $node[$countzone][node_number][$door_discharge] # REGARDING DOORS (DISCHARGE FACTOR)
		# ALSO, THIS MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS 
		# AND THE STEPS THE MODEL HAVE TO FOLLOW.
		# THIS ALLOWS TO IMPOSE EQUALITY CONSTRAINTS TO THESE VARIABLES, 
		# WHICH COULD ALSO BE COMBINED WITH THE FOLLOWING ONES: 
		# $stepsvar, WHICH TELLS THE PROGRAM HOW MANY ITERATION STEPS IT HAS TO DO IN THE CURRENT MORPHING PHASE.
		# $countzone, WHICH TELLS THE PROGRAM WHAT OPERATION IS BEING EXECUTED IN THE CHAIN OF OPERATIONS 
		# THAT MAY BE EXECUTES AT EACH MORPHING PHASE. EACH $countzone WILL CONTAIN ONE OR MORE ITERATION STEPS.
		# TYPICALLY, IT WILL BE USED FOR A ZONE, BUT NOTHING PREVENTS THAT SEVERAL OF THEM CHAINED ONE AFTER 
		# THE OTHER ARE APPLIED TO THE SAME ZONE.
		# $countstep, WHICH TELLS THE PROGRAM WHAT THE CURRENT ITERATION STEP IS.
		# The $countzone that is actuated is always the last, the one which is active. 
		# It would have therefore no sense writing $node[0][3][$node] =  $node[1][3][$node].
		# Differentent $countzones can be referred to the same zone. Different $countzones just number mutations in series.

		if (-e $constrain) { eval ($constrain); } # HERE THE INSTRUCTION WRITTEN IN THE OPT CONFIGURATION FILE CAN BE SPEFICIED
		# FOR PROPAGATION OF CONSTRAINTS

		@donode = @{$node[$#node]}; #
		@docomponent = @{$component[$#component]}; #

		shift (@donode);
		shift (@docomponent);
	}
} # END SUB read_net_constraints

##############################################################################
##############################################################################
# END OF SECTION DEDICATED TO FUNCTIONS FOR CONSTRAINING MASS-FLOW NETWORKS



##############################################################################
##############################################################################
# BEGINNING OF SECTION DEDICATED TO GENERIC FUNCTIONS FOR PROPAGATING CONSTRAINTS

sub propagate_constraints
{
	# THIS FUNCTION ALLOWS TO MANIPULATE COMPOUND USER-IMPOSED CONSTRAINTS.
	# IT COMPOUNDS ALL FOUR PRINCIPAL PROPAGATION TYPES. THAT MEANS THAT ONE COULD DO
	# ANY TYPE OF THE AVAILABLE PROPAGATIONS JUST USING THIS FUNCTION.
	# IT MAKES AVAILABLE TO THE USER THE FOLLOWING VARIABLES FOR MANIPULATION.

	# REGARDING GEOMETRY:
	# $v[$countzone][$number][$x], $v[$countzone][$number][$y], $v[$countzone][$number][$z]. EXAMPLE: $v[0][4][$x] = 1. 
	# OR: @v[0][4][$x] =  @v[0][4][$y]. OR EVEN: @v[1][4][$x] =  @v[0][3][$z].

	# REGARDING OBSTRUCTIONS:
	# $obs[$countzone][$obs_number][$x], $obs[$countzone][$obs_number][$y], $obs[$countzone][$obs_number][$y]
	# $obs[$countzone][$obs_number][$width], $obs[$countzone][$obs_number][$depth], $obs[$countzone][$obs_number][$height]
	# $obs[$countzone][$obs_number][$z_rotation], $obs[$countzone][$obs_number][$y_rotation], 
	# $obs[$countzone][$obs_number][$tilt], $obs[$countzone][$obs_number][$opacity], $obs[$countzone][$obs_number][$material], 
	# EXAMPLE: $obs[0][2][$x] = 2. THIS MEANS: AT COUNTERZONE 0, COORDINATE x OF OBSTRUCTION HAS TO BE SET TO 2.
	# OTHER EXAMPLE: $obs[0][2][$x] = $obs[2][2][$y].
	# NOTE THAT THE MATERIAL TO BE SPECIFIED IS A MATERIAL LETTER, BETWEEN QUOTES! EXAMPLE: $obs[1][$material] = "a".
	#  $tilt IS PRESENTLY UNUSED.

	# REGARDING MASS-FLOW NETWORKS:
	# @node and @component.
	# CURRENTLY: INTERNAL UNKNOWN AIR NODES AND BOUNDARY WIND-CONCERNED NODES.
	# IT MAKES AVAILABLE VARIABLES REGARDING COMPONENTS
	# CURRENTLY: WINDOWS, CRACKS, DOORS.
	# ALSO, THIS MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS.
	# SPECIFICALLY, THE FOLLOWING VARIABLES WHICH REGARD BOTH INTERNAL AND BOUNDARY NODES.
	# NOTE THAT "node_number" IS THE NUMBER OF THE NODE IN THE ".afn" ESP-r FILE. 
	# 1) $loopcontrol[$countzone][$countloop][$countloopcontrol][$loop_hour] 
	# Where $countloop and  $countloopcontrol has to be set to a specified number in the OPT file for constraints.
	# 2) $loopcontrol[$countzone][$countloop][$countloopcontrol][$max_heating_power] # Same as above.
	# 3) $loopcontrol[$countzone][$countloop][$countloopcontrol][$min_heating_power] # Same as above.
	# 4) $loopcontrol[$countzone][$countloop][$countloopcontrol][$max_cooling_power] # Same as above.
	# 5) $loopcontrol[$countzone][$countloop][$countloopcontrol][$min_cooling_power] # Same as above.
	# 6) $loopcontrol[$countzone][$countloop][$countloopcontrol][heating_setpoint] # Same as above.
	# 7) $loopcontrol[$countzone][$countloop][$countloopcontrol][cooling_setpoint] # Same as above.
	# 8) $flowcontrol[$countzone][$countflow][$countflowcontrol][$flow_hour] 
	# Where $countflow and  $countflowcontrol has to be set to a specified number in the OPT file for constraints.
	# 9) $flowcontrol[$countzone][$countflow][$countflowcontrol][$flow_setpoint] # Same as above.
	# 10) $flowcontrol[$countzone][$countflow][$countflowcontrol][$flow_onoff] # Same as above.
	# 11) $flowcontrol[$countzone][$countflow][$countflowcontrol][$flow_fraction] # Same as above.
	# EXAMPLE : $flowcontrol[0][1][2][$flow_fraction] = 0.7
	# OTHER EXAMPLE: $flowcontrol[2][1][2][$flow_fraction] = $flowcontrol[0][2][1][$flow_fraction]

	# REGARDING CONTROLS:
	# IT MAKES AVAILABLE VARIABLES REGARDING COMPONENTS
	# CURRENTLY: WINDOWS, CRACKS, DOORS.
	# ALSO, THIS MAKES AVAILABLE TO THE USER INFORMATIONS ABOUT THE MORPHING STEP OF THE MODELS.
	# SPECIFICALLY, THE FOLLOWING VARIABLES WHICH REGARD BOTH INTERNAL AND BOUNDARY NODES.
	# NOTE THAT "node_number" IS THE NUMBER OF THE NODE IN THE ".afn" ESP-r FILE. 
	# $node[$countzone][node_number][$node]. # EXAMPLE: $node[0][3][$node]. THIS IS THE LETTER OF THE THIRD NODE, 
	# AT THE FIRST CONTERZONE (NUMBERING STARTS FROM 0)
	# $node[$countzone][node_number][$type]
	# $node[$countzone][node_number][$height]. # EXAMPLE: $node[0][3][$node]. THIS IS THE HEIGHT OF THE 3RD NODE AT THE FIRST COUNTERZONE
	# THEN IT MAKES AVAILABLE THE FOLLOWING VARIABLES REGARDING NODES:
	# $node[$countzone][node_number][$volume] # REGARDING INTERNAL NODES
	# $node[$countzone][node_number][$azimut] # REGARDING BOUNDARY NODES
	# THEN IT MAKE AVAILABLE THE FOLLOWING VARIABLES REGARDING COMPONENTS:
	# $node[$countzone][node_number][$area] # REGARDING SIMPLE OPENINGS
	# $node[$countzone][node_number][$width] # REGARDING CRACKS
	# $node[$countzone][node_number][$length] # REGARDING CRACKS
	# $node[$countzone][node_number][$door_width] # REGARDING DOORS
	# $node[$countzone][node_number][$door_height] # REGARDING DOORS
	# $node[$countzone][node_number][$door_nodeheight] # REGARDING DOORS
	# $node[$countzone][node_number][$door_discharge] # REGARDING DOORS (DISCHARGE FACTOR)

	# ALSO, THIS KIND OF FILE MAKES INFORMATION AVAILABLE ABOUT 
	# THE MORPHING STEP OF THE MODELS AND THE STEPS THE MODEL HAVE TO FOLLOW.
	# THIS ALLOWS TO IMPOSE EQUALITY CONSTRAINTS TO THESE VARIABLES, 
	# WHICH COULD ALSO BE COMBINED WITH THE FOLLOWING ONES: 
	# $stepsvar, WHICH TELLS THE PROGRAM HOW MANY ITERATION STEPS IT HAS TO DO IN THE CURRENT MORPHING PHASE.
	# $countzone, WHICH TELLS THE PROGRAM WHAT OPERATION IS BEING EXECUTED IN THE CHAIN OF OPERATIONS 
	# THAT MAY BE EXECUTES AT EACH MORPHING PHASE. EACH $countzone WILL CONTAIN ONE OR MORE ITERATION STEPS.
	# TYPICALLY, IT WILL BE USED FOR A ZONE, BUT NOTHING PREVENTS THAT SEVERAL OF THEM CHAINED ONE AFTER 
	# THE OTHER ARE APPLIED TO THE SAME ZONE.
	# $countstep, WHICH TELLS THE PROGRAM WHAT THE CURRENT ITERATION STEP IS.

	# The $countzone that is actuated is always the last, the one which is active. 
	# It would have therefore no sense writing for example @v[0][4][$x] =  @v[1][2][$y], because $countzone 0 is before than $countzone 1.
	# Also, it would not have sense setting $countzone 1 if the current $countzone is already 2.
	# Differentent $countzones can be referred to the same zone. Different $countzones just number mutations in series.

	my $to = shift;
	my $stepsvar = shift; 
	
	my $countzone = shift;
	my $countstep = shift;
	my $swap = shift;
	my ($justread, $justwrite);
	my @applytype = @$swap;
	my $zone_letter = $applytype[$countzone][3];
	my $swap = shift;
	my @propagate_constraints = @$swap;
	my $countvar = shift;
	my $fileconfig = shift;
	
	say "Propagating constraints on multiple databases " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.";

	my $zone = $applytype[$countzone][3];
	my $count = 0;
	my @group = @{$propagate_constraints[$countzone]};
	foreach my $elm (@group)
	{
		if ($count > 0)
		{
			my @items = @{$elm};
			my $what_to_do = $items[0];
			my $sourcefile = $items[1];
			my $targetfile = $items[2];
			my $configfile = $items[3];
			if ($what_to_do eq "read_geo")
			{
				$to_do = "justread";
				my @vertex_letters = @{$items[4]};
				my $long_menus = $items[5];
				my @constrain_geometry = ( [ "", $zone,  $sourcefile, $targetfile, $configfile , \@vertex_letters, $long_menus ] );
				constrain_geometry($to, $fileconfig, $stepsvar, $countzone, 
				$countstep, $exeonfiles, \@applytype, \@constrain_geometry, $to_do, $countvar, $fileconfig );

			}
			if ($what_to_do eq "read_obs")
			{
				$to_do = "justread";
				my @obs_letters = @{$items[4]};
				my $act_on_materials = $items[5];
				my @constrain_obstructions = ( [ "", $applytype[$countzone][3], $sourcefile, $targetfile, $configfile , \@obs_letters, $act_on_materials ] );
				constrain_obstructions($to, $stepsvar, $countzone, 
				$countstep, \@applytype, \@constrain_obstructions, $to_do, $countvar, $fileconfig );
			}
			if ($what_to_do eq "read_ctl")
			{
				$to_do = "justread";
				my @constrain_controls = ( [ "", $zone, $sourcefile, $targetfile, $configfile ] );
				constrain_controls($to, $stepsvar, $countzone, 
				$countstep, \@applytype, \@constrain_controls, $to_do, $countvar, $fileconfig  );
			}
			if ($what_to_do eq "read_net")
			{
				$to_do = "justread";
				my @surfaces = @{$items[4]};
				my @cps = @{$items[5]};
				my @constrain_net = ( [ "", $zone, $sourcefile, $targetfile, $configfile , \@surfaces, \@cps ] );
				constrain_net($to, $stepsvar, $countzone, 
				$countstep, \@applytype, \@constrain_net, $to_do, $countvar, $fileconfig  );
			}

			if ($what_to_do eq "write_geo")
			{
				$to_do = "justwrite";
				my @vertex_letters = @{$items[4]};
				my $long_menus = $items[5];
				my @constrain_geometry = ( [ "", $zone,  $sourcefile, $targetfile, $configfile , \@vertex_letters, $long_menus ] );
				constrain_geometry($to, $stepsvar, $countzone, 
				$countstep, \@applytype, \@constrain_geometry, $to_do, $countvar, $fileconfig );
			}
			if ($what_to_do eq "write_obs")
			{
				$to_do = "justwrite";
				my @obs_letters = @{$items[4]};
				my $act_on_materials = $items[5];
				my @constrain_obstructions = ( [ "", $zone, $sourcefile, $targetfile, $configfile , \@obs_letters, $act_on_materials] );
				constrain_obstructions($to, $stepsvar, $countzone, 
				$countstep, \@applytype, \@constrain_obstructions, $to_do, $countvar, $fileconfig  );
			}
			if ($what_to_do eq "write_ctl")
			{
				$to_do = "justwrite";
				my @constrain_controls = ( [ "", $zone, $sourcefile, $targetfile, $configfile ] );
				constrain_controls($to, $stepsvar, $countzone, 
				$countstep, \@applytype, \@constrain_controls, $to_do, $countvar, $fileconfig  );
			}
			if ($what_to_do eq "write_net")
			{
				$to_do = "justwrite";
				my @surfaces = @{$items[4]};
				my @cps = @{$items[5]};
				my @constrain_net = ( [ "", $zone, $sourcefile, $targetfile, $configfile , \@surfaces, \@cps ] );
				constrain_net($to, $stepsvar, $countzone, 
				$countstep, \@applytype, \@constrain_net, $to_do, $countvar, $fileconfig );
			}		
		}
		$count++;
	}
}

###########################################################################
# END OF SECTION DEDICATED TO GENERIC FUNCTIONS FOR PROPAGATING CONSTRAINTS

# END OF THE CONTENT OF THE "Morph.pm" FILE.
#########################################################################################
#########################################################################################

1;
