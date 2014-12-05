package Sim::OPT::Sim;
# Copyright (C) 2008-2014 by Gian Luca Brunetti and Politecnico di Milano.
# This is the module Sim::OPT::Sim of Sim::OPT, a program for detailed metadesign managing parametric explorations through the ESP-r building performance simulation platform and performing optimization by block coordinate descent.
# This is free software.  You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.

use v5.14;
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
use Data::Dumper;
#$Data::Dumper::Indent = 0;
#$Data::Dumper::Useqq  = 1;
#$Data::Dumper::Terse  = 1;
use Data::Dump qw(dump);
#use Sub::Signatures;
use Sim::OPT;
use Sim::OPT::Morph;
use Sim::OPT::Retrieve;
use Sim::OPT::Report;
use Sim::OPT::Descend;
use feature 'say';
no strict; 
no warnings;

@ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( sim ); # our @EXPORT = qw( );

$VERSION = '0.39.6_5'; # our $VERSION = '';


#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Sim.pm", Sim::OPT::Sim
##############################################################################

# HERE FOLLOWS THE "sim" FUNCTION, CALLED FROM THE MAIN PROGRAM FILE.
# IT LAUCHES SIMULATIONS AND ALSO RETRIEVES RESULTS. 
# THE TWO OPERATIONS ARE CONTROLLED SEPARATELY 
# FROM THE OPT CONFIGURATION FILE.

#____________________________________________________________________________
# Activate or deactivate the following function calls depending from your needs

sub sim    # This function launch the simulations in ESP-r
{
	say "\nNow in Sim::OPT::Sim.\n";
	my $swap = shift;
	my %dat = %$swap;
	my @instances = @{ $dat{instances} };
	my %vals = %{ $dat{vals} };
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase); # IT WILL BE SHADOWED. CUT ZZZ
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock); # IT WILL BE SHADOWED. CUT ZZZ
	
	my %globs = %{ $dat{globs} };
	
	$configfile = $dat{configfile}; #say "dump(\$configfile): " . dump($configfile);

	my @simcases = @{ $dat{simcases} };
	my @simstruct = @{ $dat{simstruct} };
	my @morphcases = @{ $dat{morphcase} };
	my @morphstruct = @{ $dat{morphstruct} };
	my @rescases = @{ $dat{rescases} };
	my @resstruct = @{ $dat{resstruct} };
		
	my $morphlist = $dat{morphlist};
	my $morphblock = $dat{morphblock};
	my $simlist = $dat{simlist};
	my $simblock = $dat{simblock};
	my $reslist = $dat{reslist};
	my $resblock = $dat{resblock};
	my $retlist = $dat{retlist};
	my $retblock = $dat{retblock};
	my $mergecase = $dat{mergecase};
	my $mergeblock = $dat{mergeblock};
	
	my $configfile = $main::configfile; #say "dump(\$configfile): " . dump($configfile);
		
	my $mypath = $main::mypath;  #say "dumpINSIM(\$mypath): " . dump($mypath);
	my $exeonfiles = $main::exeonfiles; #say "dumpINSIM(\$exeonfiles): " . dump($exeonfiles);
	my $generatechance = $main::generatechance; 
	my $file = $main::file;
	my $preventsim = $main::preventsim;
	my $fileconfig = $main::fileconfig;
	my $outfile = $main::outfile;
	my $toshell = $main::toshell;
	my $report = $main::report;
	my $simnetwork = $main::simnetwork;
	my $reportloadsdata = $main::reportloadsdata;

	my @themereports = @main::themereports; #say "dumpINMORPH(\@themereports): " . dump(@themereports);
	my @simtitles = @main::simtitles; #say "dumpINMORPH(\@simtitles): " . dump(@simtitles);
	my @reporttitles = @main::reporttitles;
	my @simdata = @main::simdata;
	my @retrievedata = @main::retrievedata;
	my @keepcolumns = @main::keepcolumns;
	my @weights = @main::weights;
	my @weightsaim = @main::weightsaim;
	my @varthemes_report = @main::varthemes_report;
	my @varthemes_variations = @vmain::arthemes_variations;
	my @varthemes_steps = @main::varthemes_steps;
	my @rankdata = @main::rankdata;
	my @rankcolumn = @main::rankcolumn;
	my @reporttempsdata = @main::reporttempsdata;
	my @reportcomfortdata = @main::reportcomfortdata;
	my @reportradiationenteringdata = @main::reportradiationenteringdata;
	my @reporttempsstats = @main::reporttempsstats;
	my @files_to_filter = @main::files_to_filter;
	my @filter_reports = @main::filter_reports;
	my @base_columns = @main::base_columns;
	my @maketabledata = @main::maketabledata;
	my @filter_columns = @main::filter_columns;
	
	#my $getpars = shift;
	#eval( $getpars );
	
	#my $toshellsim = "$toshell" . "-2sim.txt";
	#my $outfilesim = "$outfile" . "-2sim.txt";
		
	#open ( TOSHELL, ">>$toshellsim" );
	#open ( OUTFILE, ">>$outfilesim" );
	
	open ( SIMLIST, ">$simlist") or ( say "\$simlist: $simlist" and die );
	
	#if ( fileno (SIMLIST) )
	if (not (-e $simlist ) )
	{
		if ( $countblock == 0 )
		{
			open ( SIMLIST, ">$simlist") or die;
		}
		else 
		{
			open ( SIMLIST, ">>$simlist") or die;
		}
	}
	
	#if ( fileno (SIMBLOCK) )
	if (not (-e $simblock ) )
	{
		if ( $countblock == 0 )
		{
			open ( SIMBLOCK, ">$simblock"); # or die;
		}
		else 
		{
			open ( SIMBLOCK, ">>$simblock"); # or die;
		}
	}
	
	open ( OUTFILE, ">>$outfile" ) or die "Can't open $outfile: $!"; 
	open ( TOSHELL, ">>$toshell" ) or die "Can't open $toshell: $!"; 

	foreach my $instance (@instances)
	{
		say "\nNow in Sim::OPT::Sim.\n";
		my %dat = %{$instance};
		my @rootnames = @{ $dat{rootnames} }; #say \"dump(\@rootnames): " . dump(@rootnames);
		my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase);
		my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock);
		my @sweeps = @{ $dat{sweeps} }; #say "dump(\@sweeps): " . dump(@sweeps);
		my @varinumbers = @{ $dat{varinumbers} }; #say "dump(\@varinumbers): " . dump(@varinumbers);
		my @miditers = @{ $dat{miditers} }; #say "dump(\@miditers): " . dump(@miditers);
		my @winneritems = @{ $dat{winneritems} }; #say "dumpIN( \@winneritems) " . dump(@winneritems);
		my $countvar = $dat{countvar}; #say "dump(\$countvar): " . dump($countvar);
		my $countstep = $dat{countstep}; #say "dump(\countstep): " . dump(countstep);
		#eval($getparshere);
		
		my %instancecarrier = %{ $dat{instancecarrier} }; #say "dump(\%instancecarrier): " . dump(%instancecarrier);
		my $to = $dat{to}; #say "dump(\$to): " . dump($to);
		
		my $rootname = Sim::OPT::getrootname(\@rootnames, $countcase); #say "dump(\$rootname): " . dump($rootname);
		my @blockelts = Sim::OPT::getblockelts(\@sweeps, $countcase, $countblock); #say "dumpIN( \@blockelts) " . dump(@blockelts);
		my @blocks = Sim::OPT::getblocks(\@sweeps, $countcase);  #say "dumpIN( \@blocks) " . dump(@blocks);
		my $winneritem = Sim::OPT::getitem(\@winneritems, $countcase, $countblock); #say "dump(\$winneritem): " . dump($winneritem);
		my $winnerline = Sim::OPT::getline($winneritem); #say "dump(\$winnerline): " . dump($winnerline);
		my $from = $winnerline;
		my @winnerlines = Sim::OPT::getlines( \@winneritems ); #say "dump(\@winnerlines): " . dump(@winnerlines);
		my %varnums = Sim::OPT::getcase(\@varinumbers, $countcase); #say "dumpININ---(\%varnums): " . dump(%varnums); 
		my %mids = Sim::OPT::getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids); 
		#eval($getfly);
		
		my $stepsvar = Sim::OPT::getstepsvar($countvar, $countcase, \@varinumbers);
		
		my @ress;
		my @flfs;
		my $countdir = 0;
		
		if ( not ( $to ~~ @{ $simstruct[$countcase][$countblock] } ) )
		{
				push ( @{ $simstruct[$countcase][$countblock] }, $to );
				print SIMBLOCK "$to\n";
		}
		
		if ( not ( $to ~~ @{ $simcases[$countcase] } ) )
		{
			push ( @simcases, $to );
			print SIMLIST "$to\n";
		}

		my $simelt = $to;
		my $countsim = 0;
		foreach my $date_to_sim (@simtitles)
		{
			my $simdataref = $simdata[$countsim];
			my @simdata = @{$simdataref};
			
			unless ( $preventsim eq "y" )
			{
				my $resfile = "$simelt-$date_to_sim.res";
				my $flfile = "$simelt-$date_to_sim.fl";
				push (@ress, $resfile); # ERASE
				push (@flfs, $flfile); # ERASE
				
				if ( not ($resfile ~~ @{ $rescases[$countcase] } ) )
				{
					push ( @{ $rescases[$countcase] }, $resfile );
					print SIMLIST "$resfile\n";
					
					push ( @{ $resstruct[$countcase][$countblock] }, $resfile );
					print SIMBLOCK "resfile\n";
					
					if ( not ( -e $resfile ) ) 
					{
						if ( $simnetwork eq "n" )
						{
							my $printthis =
"bps -file $simelt/cfg/$fileconfig -mode script<<XXX

c
$resfile
$simdata[0 + (4*$countsim)]
$simdata[1 + (4*$countsim)]
$simdata[2 + (4*$countsim)]
$simdata[3 + (4*$countsim)]
s
$simnetwork
Results for $simelt-$date_to_sim
y
y
-
-
-
-
-
-
-
XXX
";
							if ($exeonfiles eq "y") 
							{
								print `$printthis`;
							}
							print TOSHELL "  
#Simulating zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.
$printthis
";
						}
					
						if ( $simnetwork eq "y" )
						{
							my $printthis =
"bps -file $simelt/cfg/$fileconfig -mode script<<XXX

c
$resfile
$flfile
$simdata[0 + (4*$countsim)]
$simdata[1 + (4*$countsim)]
$simdata[2 + (4*$countsim)]
$simdata[3 + (4*$countsim)]
s
$simnetwork
Results for $simelt-$dates_to_sim
y
y
-
-
-
-
-
-
-
XXX
";
							if ($exeonfiles eq "y") 
							{
								print `$printthis`;
							}
							print TOSHELL " 
#Simulating zones for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar at iteration $countstep. Instance $countinstance.\
$printthis
\n";
							print OUTFILE "TWO, $resfile\n";
						}						
					}
				}		
			}
			$countsim++;
		}
		$countdir++;
	}

	close SIMLIST;
	close SIMBLOCK;
	#close TOSHELL;
	#close OUTFILE;
}    # END SUB sim;			

# END OF THE CONTENT OF Sim::OPT::Sim
##############################################################################
##############################################################################
			
1;			
			