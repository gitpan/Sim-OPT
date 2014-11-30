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

$VERSION = '0.37'; # our $VERSION = '';


#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Retrieve.pm", Sim::OPT::Retrieve
##############################################################################

sub getglobals
{
	$configfile = shift;
	require $configfile;
}

sub retrieve
{	
	say "In Sim::OPT::Retrieve.\n";
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
	
	#unless (-e "$mypath/results") 
	#{ 
	#	print  `mkdir $mypath/results`; 
	#	print TOSHELL "mkdir $mypath/results\n\n"; 
	#}

	sub retrieve_temperatures_results 
	{
		my $result = shift;
		my $resfile = shift;
		my $swap = shift;
		my @retrievedatatemps = @$swap;
		my $reporttitle = shift;
		my $stripcheck = shift;
		my $theme = shift;
		#my $existingfile = "$resfile-$theme.grt";
		#if (-e $existingfile) { print `chmod 777 $existingfile\n`;} 
		#print $_toshell_ "chmod 777 $existingfile\n";
		#if (-e $existingfile) { print `rm $existingfile\n` ;}
		#print $_toshell_ "rm $existingfile\n";
		#if ($exeonfiles eq "y") { print `rm -f $existingfile*par\n`; }
		#print $_toshell_ "rm -f $existingfile*par\n";

		unless (-e "$result-$reporttitle-$theme.grt-")
		{
			my $printthis =
"res -file $resfile -mode script<<YYY

3
$retrievedatatemps[0]
$retrievedatatemps[1]
$retrievedatatemps[2]
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
$result-$reporttitle-$theme.grt
Simulation results $result-$reporttitle-$theme
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
				print `$printthis`;
			}
			print TOSHELL $printthis;
		#if (-e $existingfile) { print `rm -f $existingfile*par`;}
		#print $_toshell_ "rm -f $existingfile*par\n";
		}
	}

	sub retrieve_comfort_results
	{
		my $result = shift;
		my $resfile = shift;
		my $swap = shift;
		my @retrievedatacomf = @$swap;
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

		unless (-e "$result-$reporttitle-$theme.grt-")
		{
			my $printthis =
"res -file $resfile -mode script<<ZZZ

3
$retrievedatacomf[0]
$retrievedatacomf[1]
$retrievedatacomf[2]
c
g
c
a

b


a
>
a
$result-$reporttitle-$theme.grt
Simulation results $result-$reporttitle-$theme
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
				print `$printthis`;
			}
			print TOSHELL $printthis;
			#if (-e $existingfile) { `rm -f $existingfile*par\n`;}
			#print $_toshell_ "rm -f $existingfile*par\n";
		}
	}

	sub retrieve_loads_results
	{
		my $swap = shift;
		my %dat = %$swap;
		my $getpars = shift;
		eval( $getpars );	
		
	my $result = shift;
	my $resfile = shift;
	my $swap = shift;
	my @retrievedataloads = @$swap;
	my $reporttitle = shift;
	my $stripcheck = shift;
	my $theme = shift;
	#my $existingfile = "$resfile-$theme.grt";
	#if (-e $existingfile) { `chmod 777 $existingfile\n`;}
	#print $_toshell_ "chmod 777 $existingfile\n";
	#if (-e $existingfile) { `rm $existingfile\n` ;}
	#print $_toshell_ "rm $existingfile\n";

	unless (-e "$result-$reporttitle-$theme.grt-")
	{
		my $printthis =
"res -file $resfile -mode script<<TTT

3
$retrievedataloads[0]
$retrievedataloads[1]
$retrievedataloads[2]
d
>
a
$result-$reporttitle-$theme.grt
Simulation results $result-$reporttitle-$theme
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
			print `$printthis`;
		}
		print TOSHELL $printthis;

		print RETLIST "$result-$reporttitle-$theme.grt ";
		if ($stripcheck)
		{
			open (CHECKDATUM, "$result-$reporttitle-$theme.grt") or die;
			open (STRIPPED, ">$result-$reporttitle-$theme.grt-") or die;
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
	my @retrievedatatempsstats = @$swap;
	my $reporttitle = shift;
	my $stripcheck = shift;
	my $theme = shift;
	#my $existingfile = "$resfile-$theme.grt";
	#if (-e $existingfile) { `chmod 777 $existingfile\n`; }
	#print $_toshell_ "chmod 777 $existingfile\n";
	#if (-e $existingfile) { `rm $existingfile\n` ;}
	#print $_toshell_ "rm $existingfile\n";
	#if (-e $existingfile) { `rm -f $existingfile*par\n`;}
	#print $_toshell_ "rm -f $existingfile*par\n";

	unless (-e "$result-$reporttitle-$theme.grt-")
	{
		my $printthis =
		"res -file $resfile -mode script<<TTT

3
$retrievedatatempsstats[0]
$retrievedatatempsstats[1]
$retrievedatatempsstats[2]
d
>
a
$result-$reporttitle-$theme.grt
Simulation results $result-$reporttitle-$theme.grt
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
			print `$printthis`;
			print OUTFILE "CALLED RETRIEVE TEMPS STATS\n";
			print OUTFILE "\$resfile: $resfile, \$retrievedataloads[0]: $retrievedataloads[0], \$retrievedataloads[1]: $retrievedataloads[1], \$retrievedataloads[2]:$retrievedataloads[2]\n";
			print OUTFILE "\$reporttitle: $reporttitle, \$theme: $theme\n";
			print OUTFILE "\$resfile-\$reporttitle-\$theme: $resfile-$reporttitle-$theme";
		}
		print TOSHELL $printthis;

		#if ($exeonfiles eq "y") { print `rm -f $existingfile*par\n`;}
		#print $_toshell_ "rm -f $existingfile*par\n";
		print RETLIST "$resfile-$reporttitle-$theme.grt ";
		if ($stripcheck)
		{
			open (CHECKDATUM, "$result-$reporttitle-$theme.grt") or die;
			open (STRIPPED, ">$result-$reporttitle-$theme.grt-") or die;
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
			
my $countertheme = 0;
foreach my $themereportref (@themereports)
{
	# print OUTFILE "SIMS: \n";
	my @themereports = @{$themereportref};
	my $reporttitlesref = $reporttitles[$countertheme];
	my @reporttitles = @{$reporttitlesref};
	my $retrievedatarefsdeep = $retrievedata[$countertheme];
	my @retrievedatarefs = @{$retrievedatarefsdeep};
	my $stripcheckref = $stripchecks[$countertheme];
	my @stripckecks = @{$stripcheckref};

	my $countreport = 0;
	foreach my $reporttitle (@reporttitles)
	{
		# print OUTFILE "SIMS: \n";
		my $theme = $themereports[$countreport];
		my $retrieveref = $retrievedatarefs[$countreport];
		my $stripcheck = $stripckecks[$countreport];
		my @retrievedata = @{$retrieveref};
		my $countersim = 0;
		foreach my $sim (@sims)
		{
			chomp($sim);
			my $targetprov = $sim;
			$targetprov =~ s/$mypath\///;
			my $result = "$mypath" . "/results/$targetprov";

			if ( $theme eq "temps" ) { &retrieve_temperatures_results($result, $sim, \@retrievedata, $reporttitle, $stripcheck, $theme); }
			if ( $theme eq "comfort"  ) { &retrieve_comfort_results($result, $sim, \@retrievedata, $reporttitle, $stripcheck, $theme); }
			if ( $theme eq "loads" ) 	{ &retrieve_loads_results($result, $sim, \@retrievedata, $reporttitle, $stripcheck, $theme); }
			if ( $theme eq "tempsstats"  ) { &retrieve_temps_stats($result, $sim, \@retrievedata, $reporttitle, $stripcheck, $theme); }
			print RETBLOCK "\$sim: $sim, \$result: $result, \@retrievedata: @retrievedata, \$reporttitle: $reporttitle, \$stripcheck: $stripcheck, \$theme: $theme\n";
			$countersim++;
		}
		$countreport++;
	}
	$countertheme++;
}
#print `rm -f ./results/*.grt`;
#print TOSHELL "rm -f ./results/*.grt\n";
#print `rm -f ./results/*.par`;
#print TOSHELL "rm -f ./results/*.par\n";
}	# END SUB RETRIEVE

##############################################################################
##############################################################################
##############################################################################
# END SUB RETRIEVE

sub report { ; } # NO MORE USED # This function retrieved the results of interest from the text file created by the "retrieve" function

1;