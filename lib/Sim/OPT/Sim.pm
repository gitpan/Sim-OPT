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
use feature 'say';
no strict; 
no warnings;

@ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( sim ); # our @EXPORT = qw( );

$VERSION = '0.37'; # our $VERSION = '';


#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Sim.pm", Sim::OPT::Sim
##############################################################################

# HERE FOLLOWS THE "sim" FUNCTION, CALLED FROM THE MAIN PROGRAM FILE.
# IT LAUCHES SIMULATIONS AND ALSO RETRIEVES RESULTS. 
# THE TWO OPERATIONS ARE CONTROLLED SEPARATELY 
# FROM THE OPT CONFIGURATION FILE.

#____________________________________________________________________________
# Activate or deactivate the following function calls depending from your needs

sub getglobals
{
	$configfile = shift;
	
}

sub sim    # This function launch the simulations in ESP-r
{
	say "\nIn Sim::OPT::Sim.\n";
	my $swap = shift;
	my %dat = %$swap;
	my @instances = @{ $dat{instances} };
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase); # IT WILL BE SHADOWED. CUT ZZZ
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock); # IT WILL BE SHADOWED. CUT ZZZ
	
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
	
	#my $getpars = shift;
	#eval( $getpars );
	
	#open ( TOSHELL, ">>$toshell" );
	#open ( OUTFILE, ">>$outfile" );
	
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

	foreach my $instance (@instances)
	{
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
		my $countersim = 0;
		foreach my $date_to_sim (@simtitles)
		{
			my $simdataref = $simdata[$countersim];
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
$simdata[0 + (4*$countersim)]
$simdata[1 + (4*$countersim)]
$simdata[2 + (4*$countersim)]
$simdata[3 + (4*$countersim)]
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
							print TOSHELL $printthis;
						}
					
						if ( $simnetwork eq "y" )
						{
							my $printthis =
"bps -file $simelt/cfg/$fileconfig -mode script<<XXX

c
$resfile
$flfile
$simdata[0 + (4*$countersim)]
$simdata[1 + (4*$countersim)]
$simdata[2 + (4*$countersim)]
$simdata[3 + (4*$countersim)]
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
							print TOSHELL $printthis;
							print OUTFILE "TWO, $resfile\n";
						}						
					}
				}		
			}
			$countersim++;
		}
		$countdir++;
	}

	close SIMLIST;
	close SIMBLOCK;
}    # END SUB sim;			

# END OF THE CONTENT OF Sim::OPT::Sim
##############################################################################
##############################################################################
			
1;			
			