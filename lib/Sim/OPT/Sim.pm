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
use IO::Tee;
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
use Sim::OPT::Takechance;
use feature 'say';
no strict; 
no warnings;

@ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( sim ); # our @EXPORT = qw( );

$VERSION = '0.40.0'; # our $VERSION = '';


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
	my $swap = shift; #say $tee "swapINSIM: " . dump($swap);
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
	
	$mypath = $main::mypath;  #say $tee "dumpINSIM(\$mypath): " . dump($mypath);
	$exeonfiles = $main::exeonfiles; #say $tee "dumpINSIM(\$exeonfiles): " . dump($exeonfiles);
	$generatechance = $main::generatechance; 
	$file = $main::file;
	$preventsim = $main::preventsim;
	$fileconfig = $main::fileconfig; #say $tee "dumpINSIM(\$fileconfig): " . dump($fileconfig); # NOW GLOBAL. TO MAKE IT PRIVATE, FIX PASSING OF PARAMETERS IN CONTRAINTS PROPAGATION SECONDARY SUBROUTINES
	$outfile = $main::outfile;
	$toshell = $main::toshell;
	$report = $main::report;
	$simnetwork = $main::simnetwork;
	$reportloadsdata = $main::reportloadsdata;
	
	$tee = new IO::Tee(\*STDOUT, ">>$toshell"); # GLOBAL ZZZ
	
	open ( OUTFILE, ">>$outfile" ) or die "Can't open $outfile: $!"; 
	open ( TOSHELL, ">>$toshell" ) or die "Can't open $toshell: $!"; 
	say  "\nNow in Sim::OPT::Sim.\n";
	say TOSHELL "\n#Now in Sim::OPT::Sim.\n";
	
	%dowhat = %main::dowhat;

	@themereports = @main::themereports; #say "dumpINSIM(\@themereports): " . dump(@themereports);
	@simtitles = @main::simtitles; #say "dumpINSIM(\@simtitles): " . dump(@simtitles);
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

	my @container;

	foreach my $instance (@instances)
	{
		my %d = %{$instance};
		my $countcase = $d{countcase}; #say TOSHELL "dump(\$countcase): " . dump($countcase);
		my $countblock = $d{countblock}; #say TOSHELL "dump(\$countblock): " . dump($countblock);
		my @miditers = @{ $d{miditers} }; #say TOSHELL "dump(\@miditers): " . dump(@miditers);
		my @winneritems = @{ $d{winneritems} }; #say TOSHELL "dumpIN( \@winneritems) " . dump(@winneritems);
		my $countvar = $d{countvar}; #say TOSHELL "dump(\$countvar): " . dump($countvar);
		my $countstep = $d{countstep}; #say TOSHELL "dump(\$countstep): " . dump($countstep);						
		my $to = $d{to}; #say TOSHELL "dump(\$to): " . dump($to);
		my $origin = $d{origin}; #say TOSHELL "dump(\$origin): " . dump($origin);
		my @uplift = @{ $d{uplift} }; #say TOSHELL "dump(\@uplift): " . dump(@uplift);
		#eval($getparshere);
		
		my $rootname = Sim::OPT::getrootname(\@rootnames, $countcase); #say TOSHELL "dump(\$rootname): " . dump($rootname);
		my @blockelts = Sim::OPT::getblockelts(\@sweeps, $countcase, $countblock); #say TOSHELL "dumpIN( \@blockelts) " . dump(@blockelts);
		my @blocks = Sim::OPT::getblocks(\@sweeps, $countcase);  #say TOSHELL "dumpIN( \@blocks) " . dump(@blocks);
		my $toitem = Sim::OPT::getitem(\@winneritems, $countcase, $countblock); #say TOSHELL "dump(\$toitem): " . dump($toitem);
		my $from = Sim::OPT::getline($toitem); #say TOSHELL "dumpIN(\$from): " . dump($from);
		my %varnums = Sim::OPT::getcase(\@varinumbers, $countcase); #say TOSHELL "dumpIN---(\%varnums): " . dump(%varnums); 
		my %mids = Sim::OPT::getcase(\@miditers, $countcase); #say TOSHELL "dumpIN---(\%mids): " . dump(%mids); 
		#eval($getfly);
		
		my $stepsvar = Sim::OPT::getstepsvar($countvar, $countcase, \@varinumbers); #say TOSHELL "dump(\$stepsvar): " . dump($stepsvar); 
		my $varnumber = $countvar; #say TOSHELL "dump---(\$varnumber): " . dump($varnumber) . "\n\n";  # LEGACY VARIABLE
		
		my @ress;
		my @flfs;
		my $countdir = 0;
		
		#my $prov = $to;
		#my $prov =~ s/$mypath\/$file//;
		#my $prov =~ s/_$//;
		#my $prov =~ s/_-*$//;
		#if ( not ( $to ~~ @{ $simcases[$countcase] } ) )
		#{
		#	push ( @simcases, $to ); say TOSHELL "simcases: " . dump(@simcases);
		#	print SIMLIST "$to\n";
		#}

		my $simelt = $to;
		my $countsim = 0;
		foreach my $date_to_sim (@simtitles)
		{
			my $simdataref = $simdata[$countsim];
			my @simdata = @{$simdataref};
			my $resfile = "$simelt-$date_to_sim.res";
			my $flfile = "$simelt-$date_to_sim.fl";
			push (@ress, $resfile); # ERASE
			push (@flfs, $flfile); # ERASE
			
			#if ( fileno (SIMLIST) )
			#if (not (-e $simlist ) )
			#{
			#	if ( $countblock == 0 )
			#	{
					open ( SIMLIST, ">>$simlist") or die;
			#	}
			#	else 
			#	{
			#		open ( SIMLIST, ">>$simlist") or die;
			#	}
			#}
			
			#if ( fileno (SIMBLOCK) )
			if (not (-e $simblock ) )
			{
				if ( $countblock == 0 )
				{
					open ( SIMBLOCK, ">>$simblock"); # or die;
				}
				else 
				{
					open ( SIMBLOCK, ">>$simblock"); # or die;
				}
			}
			
			#say "INSIM1\$countcase : " . dump($countcase);
			#say "INSIM1\@rootnames : " . dump(@rootnames);
			#say "INSIM1\$countblock : " . dump($countblock);
			#say "INSIM1\@sweeps : " . dump(@sweeps);
			#say "INSIM1\@varinumbers : " . dump(@varinumbers);
			#say "INSIM1\@miditers : " . dump(@miditers);
			#say "INSIM1\@winneritems : " . dump(@winneritems);
			#say "INSIM1\@morphcases : " . dump(@morphcases);
			#say "INSIM1\@morphstruct : " . dump(@morphstruct);
		
			push ( @{ $simstruct[$countcase][$countblock] }, $resfile );
			print SIMBLOCK "$resfile\n";
			
			if ( not ( $resfile ~~ @simcases ) )
			{
				push ( @simcases, $resfile );
				print SIMLIST "$resfile\n";
					
				unless ( $preventsim eq "y" )
				{
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
	return ( \@simcases, \@simstruct );
	close TOSHELL;
	close OUTFILE;
}    # END SUB sim;			

# END OF THE CONTENT OF Sim::OPT::Sim
##############################################################################
##############################################################################
			
1;			
			
