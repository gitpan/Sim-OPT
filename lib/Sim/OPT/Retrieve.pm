package Sim::OPT::Retrieve;
# Copyright (C) 2008-2014 by Gian Luca Brunetti and Politecnico di Milano.
# This is the module Sim::OPT::Retrieve of Sim::OPT, a program for detailed metadesign managing parametric explorations through the ESP-r building performance simulation platform and performing optimization by block coordinate descent.
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
use Sim::OPT;
use Sim::OPT::Morph;
use Sim::OPT::Sim;
use Sim::OPT::Report;
use Sim::OPT::Descend;
use Data::Dumper;
#$Data::Dumper::Indent = 0;
#$Data::Dumper::Useqq  = 1;
#$Data::Dumper::Terse  = 1;
use Data::Dump qw(dump);
#use Sub::Signatures;
use feature 'say';
no strict; 
no warnings;

@ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( 
retrieve retrieve_comfort_results retrieve_loads_results retrieve_temps_stats 
); # our @EXPORT = qw( );

$VERSION = '0.39.6_7'; # our $VERSION = '';


#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Retrieve.pm", Sim::OPT::Retrieve
##############################################################################

sub retrieve
{	
	say "Now in Sim::OPT::Retrieve.\n";
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
		
	my $mypath = $main::mypath; #say "dumpINRETRIEVE(\$mypath): " . dump($mypath);
	my $exeonfiles = $main::exeonfiles; #say "dumpINRETRIEVE(\$exeonfiles): " . dump($exeonfiles);
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
	
	#my $toshellret = "$toshell" . "-3ret.txt";
	#my $outfileret = "$outfile" . "-3ret.txt";
		
	#open ( TOSHELL, ">>$toshellret" );
	#open ( OUTFILE, ">>$outfileret" );
	
	
	#if ( fileno (RETLIST) )
	if (not (-e $retlist ) )
	{
		if ( $countblock == 0 )
		{
			open ( RETLIST, ">$retlist"); # or die;
		}
		else 
		{
			open ( RETLIST, ">>$retlist"); # or die;
		}
	}
	
	#if ( fileno (RETLIST) ) # SAME LEVEL OF RETLIST. JUST ANOTHER CONTAINER.
	if (not (-e $retblock ) )
	{
		if ( $countblock == 0 )
		{
			open ( RETBLOCK, ">$retblock"); # or die;
		}
		else 
		{
			open ( RETBLOCK, ">>$retblock"); # or die;
		}
	}
	
	open ( OUTFILE, ">>$outfile" ) or die "Can't open $outfile: $!"; 
	open ( TOSHELL, ">>$toshell" ) or die "Can't open $toshell: $!"; 
	
	unless (-e "$mypath/results") 
	{ 
		print  `mkdir $mypath/results`; 
		print TOSHELL "mkdir $mypath/results\n\n"; 
	}

	sub retrieve_temperatures_results 
	{
		my $result = shift;
		my $resfile = shift;
		my $swap = shift;
		my @retrdata = @$swap;
		my $reporttitle = shift;
		my $theme = shift;
		#my $existingfile = "$resfile-$theme.grt";
		#if (-e $existingfile) { print `chmod 777 $existingfile\n`;} 
		#print $_toshell_ "chmod 777 $existingfile\n";
		#if (-e $existingfile) { print `rm $existingfile\n` ;}
		#print $_toshell_ "rm $existingfile\n";
		#if ($exeonfiles eq "y") { print `rm -f $existingfile*par\n`; }
		#print $_toshell_ "rm -f $existingfile*par\n";

		unless (-e "$result-$reporttitle-$theme-$countcase-$countblock.grt-")
		{
			my $printthis = 
"res -file $resfile -mode script<<YYY

3
$retrdata[0]
$retredata[1]
$retrdata[2]
c
g
a
a
b
a
b
e
b
f
>
a
$result-$reporttitle-$theme-$countcase-$countblock.grt
!
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
				say "Retrieving temperature results.";
				say TOSHELL "#Retrieving temperature results.";
				print `$printthis`;
			}
			print TOSHELL "
#Retrieving results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar.\
$printthis";
		#if (-e $existingfile) { print `rm -f $existingfile*par`;}
		#print $_toshell_ "rm -f $existingfile*par\n";
		}
	}

	sub retrieve_comfort_results
	{
		my $result = shift;
		my $resfile = shift;
		my $swap = shift;
		my @retrdata = @$swap;
		my $reporttitle = shift;
		my $stripcheck = shift;
		my $theme = shift;
		#my $existingfile = "$resfile-$theme.grt"; 
		#if (-e $existingfile) { print `chmod 777 $existingfile\n`;} 
		#print $_toshell_ "chmod 777 $existingfile\n";
		#if (-e $existingfile) { print `rm $existingfile\n` ;}
		#print $_toshell_ "rm $existingfile\n";
		#if ($exeonfiles eq "y") { print `rm -f $existingfile*par\n`;}
		#print $_toshell_ "rm -f $existingfile*par\n";

		unless (-e "$result-$reporttitle-$theme-$countcase-$countblock.grt-")
		{
			my $printthis =
"res -file $resfile -mode script<<ZZZ

3
$retrdata[0]
$retrdata[1]
$retrdata[2]
c
g
c
a

b


a
>
a
$result-$reporttitle-$theme-$countcase-$countblock.grt
!
-
-
-
-
-
-
-
-
ZZZ
";
				if ($exeonfiles eq "y") 
				{ 
					say "Retrieving comfort results.";
					say TOSHELL "#Retrieving comfort results.";
					print `$printthis`;
				}
				print TOSHELL "
#Retrieving results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar.\
$printthis";
				#if (-e $existingfile) { `rm -f $existingfile*par\n`;}
				#print $_toshell_ "rm -f $existingfile*par\n";
			}
		}

		sub retrieve_loads_results
		{	
			my $result = shift; #say TOSHELL "\$result: " . dump($result);
			my $resfile = shift; #say TOSHELL "\$resfile " . dump($resfile);
			my $swap = shift; 
			my @retrdata = @$swap; #say TOSHELL "\@retrdata " . dump(@retrdata);
			my $reporttitle = shift; #say TOSHELL "\$reporttitle " . dump($reporttitle);
			my $theme = shift; #say TOSHELL "\$theme " . dump($theme);
			#my $existingfile = "$resfile-$theme.grt";
			#if (-e $existingfile) { `chmod 777 $existingfile\n`;}
			#print $_toshell_ "chmod 777 $existingfile\n";
			#if (-e $existingfile) { `rm $existingfile\n` ;}
			#print $_toshell_ "rm $existingfile\n";

			unless (-e "$result-$reporttitle-$theme-$countcase-$countblock.grt-")
			{
				my $printthis =
"res -file $resfile -mode script<<TTT

3
$retrdata[0]
$retrdata[1]
$retrdata[2]
d
>
a
$result-$reporttitle-$theme-$countcase-$countblock.grt
l
a

-
-
-
-
-
-
-
TTT
";
			if ($exeonfiles eq "y") 
			{
				say "Retrieving loads results.";
				say TOSHELL "#Retrieving loads results.";
				print `$printthis`;
			}
			print TOSHELL " 
#Retrieving results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar
$printthis
";

			print RETLIST "$result-$reporttitle-$theme-$countcase-$countblock.grt ";
			if ($stripcheck)
			{
				open (CHECKDATUM, "$result-$reporttitle-$theme-$countcase-$countblock.grt") or die;
				open (STRIPPED, ">$result-$reporttitle-$theme-$countcase-$countblock.grt-") or die;
				my @lines = <CHECKDATUM>;
				foreach my $line (@lines)
				{
					$line =~ s/^\s+//;
					@lineelms = split(/\s+|,/, $line);
					if ($lineelms[0] eq $stripcheck) 
					{
						print STRIPPED "$line";
					}
				}
				close STRIPPED;
				close CHECKDATUM;
			}
		}
		}

		sub retrieve_temps_stats
		{
			my $result = shift;
			my $resfile = shift;
			my $swap = shift;
			my @retrdata = @$swap;
			my $reporttitle = shift;
			my $theme = shift;
			#my $existingfile = "$resfile-$theme.grt";
			#if (-e $existingfile) { `chmod 777 $existingfile\n`; }
			#print $_toshell_ "chmod 777 $existingfile\n";
			#if (-e $existingfile) { `rm $existingfile\n` ;}
			#print $_toshell_ "rm $existingfile\n";
			#if (-e $existingfile) { `rm -f $existingfile*par\n`;}
			#print $_toshell_ "rm -f $existingfile*par\n";

			unless (-e "$result-$reporttitle-$theme-$countcase-$countblock.grt-")
			{
				my $printthis =
				"res -file $resfile -mode script<<TTT

3
$retrdatatemps[0]
$retrdatatemps[1]
$retrdatatemps[2]
d
>
a
$result-$reporttitle-$theme-$countcase-$countblock.grt
m
-
-
-
-
-
TTT
";

			if ($exeonfiles eq "y") 
			{
				say "Retrieving temperature statistics.";
				say TOSHELL "#Retrieving statistics.";
				print `$printthis`;
				#print OUTFILE "CALLED RETRIEVE TEMPS STATS\n";
				#print OUTFILE "\$resfile: $resfile, \$retrdata[0]: $retrdata[0], \$retrdata[1]: $retrdata[1], \$retrdata[2]:$retrdataloads[2]\n";
				#print OUTFILE "\$reporttitle: $reporttitle, \$theme: $theme\n";
				#print OUTFILE "\$resfile-\$reporttitle-\$theme: $resfile-$reporttitle-$theme";
			}
			print TOSHELL "
#Retrieving results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", parameter $countvar.\
$printthis";

			#if ($exeonfiles eq "y") { print `rm -f $existingfile*par\n`;}
			#print $_toshell_ "rm -f $existingfile*par\n";
			print RETLIST "$resfile-$reporttitle-$theme-$countcase-$countblock.grt ";
			if ($stripcheck) ### ZZZ
			{
				open (CHECKDATUM, "$result-$reporttitle-$theme-$countcase-$countblock.grt") or die;
				open (STRIPPED, ">$result-$reporttitle-$theme-$countcase-$countblock.grt-") or die;
				my @lines = <CHECKDATUM>;
				foreach my $line (@lines)
				{
					$line =~ s/^\s+//;
					@lineelms = split(/\s+|,/, $line);
					if ($lineelms[0] eq $stripcheck) 
					{
						print STRIPPED "$line";
					}
				}
				close STRIPPED;
				close CHECKDATUM;
			}
		}
	}

	open (OPENSIMS, "$simlist") or die;
	my @sims = <OPENSIMS>;
	# print OUTFILE "SIMS: " . Dumper(@sims) . "\n";
	close OPENSIMS;
				
	my $counttheme = 0;
	foreach my $themereportref (@themereports)
	{
		# print OUTFILE "SIMS: \n";
		my @themereports = @{$themereportref}; #say "\@themereports " . dump(@themereports);
		my $reporttitlesref = $reporttitles[$counttheme];
		my @reporttitles = @{$reporttitlesref}; #say "\@reporttitles " . dump(@reporttitles);
		my $retrievedatarefsdeep = $retrievedata[$counttheme];
		my @retrievedatarefs = @{$retrievedatarefsdeep};
		my $simtitle = $simtitles[$counttheme];

		my $countreport = 0;
		foreach my $reporttitle (@reporttitles)
		{
			# print OUTFILE "SIMS: \n";
			my $theme = $themereports[$countreport]; #say "\$theme: " . dump($theme);
			my $reporttitle = $reporttitles[$countreport]; #say "\$reporttitle " . dump($reporttitle);
			my $retrieveref = $retrievedatarefs[$countreport];
			my @retrdata = @{$retrievedatarefs[$countreport]}; #say "\@retrdata " . dump(@retrdata);
			my $countersim = 0;
			foreach my $sim (@sims)
			{
				chomp($sim);
				my $targetprov = $sim;
				$targetprov =~ s/$mypath\///;
				my $result = "$mypath" . "/results/$targetprov";

				if ( $theme eq "temps" ) { &retrieve_temperatures_results($result, $sim, \@retrdata, $reporttitle, $theme); }
				if ( $theme eq "comfort"  ) { &retrieve_comfort_results($result, $sim, \@retrdata, $reporttitle, $theme); }
				if ( $theme eq "loads" ) 	{ &retrieve_loads_results($result, $sim, \@retrdata, $reporttitle, $theme); }
				if ( $theme eq "tempsstats"  ) { &retrieve_temps_stats($result, $sim, \@retrdata, $reporttitle, $theme); }
				print RETBLOCK "\$sim: $sim, \$result: $result, \@retrievedata: @retrievedata, \$reporttitle: $reporttitle, \$theme: $theme\n";
				$countersim++;
			}
			$countreport++;
		}
		$counttheme++;
	}
#print `rm -f ./results/*.grt`;
#print TOSHELL "rm -f ./results/*.grt\n";
#print `rm -f ./results/*.par`;
#print TOSHELL "rm -f ./results/*.par\n";
#close OUTFILE;
#close TOSHELL;
}	# END SUB RETRIEVE

##############################################################################
##############################################################################
##############################################################################
# END SUB RETRIEVE

sub report { ; } # NO MORE USED # This function retrieved the results of interest from the text file created by the "retrieve" function

1;