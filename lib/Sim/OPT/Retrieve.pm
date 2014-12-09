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
#use Sim::OPT::Report;
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

$VERSION = '0.39.6_11'; # our $VERSION = '';


#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Retrieve.pm", Sim::OPT::Retrieve
##############################################################################

sub retrieve
{	
	say "\nNow in Sim::OPT::Retrieve.\n";
	say TOSHELL "\nNow in Sim::OPT::Retrieve.\n";
	my $swap = shift; #say TOSHELL "swapINRETRIEVE: " . dump($swap);
	my %dat = %$swap;
	my @instances = @{ $dat{instances} }; #say "scalar(\@instances): " . scalar(@instances);
	my $countcase = $dat{countcase}; say TOSHELL "dump(\$countcase): " . dump($countcase); # IT WILL BE SHADOWED. CUT ZZZ
	my $countblock = $dat{countblock}; say TOSHELL "dump(\$countblock): " . dump($countblock); # IT WILL BE SHADOWED. CUT ZZZ		
	my %dirfiles = %{ $dat{dirfiles} }; #say "dump(\%dirfiles): " . dump(%dirfiles); 
		
	$configfile = $main::configfile; #say "dump(\$configfile): " . dump($configfile);
	@sweeps = @main::sweeps; say TOSHELL "dump(\@sweeps): " . dump(@sweeps);
	@varinumbers = @main::varinumbers; #say "dump(\@varinumbers): " . dump(@varinumbers);
	@mediumiters = @main::mediumiters;
	@rootnames = @main::rootnames; #say "dump(\@rootnames): " . dump(@rootnames);
	%vals = %main::vals; #say "dump(\%vals): " . dump(%vals);
	
	$mypath = $main::mypath;  #say TOSHELL "dumpINRETRIEVE(\$mypath): " . dump($mypath);
	$exeonfiles = $main::exeonfiles; say TOSHELL "dumpINRETRIEVE(\$exeonfiles): " . dump($exeonfiles);
	$generatechance = $main::generatechance; 
	$file = $main::file;
	$preventsim = $main::preventsim;
	$fileconfig = $main::fileconfig; say TOSHELL "dumpINRETRIEVE(\$fileconfig): " . dump($fileconfig); # NOW GLOBAL. TO MAKE IT PRIVATE, FIX PASSING OF PARAMETERS IN CONTRAINTS PROPAGATION SECONDARY SUBROUTINES
	$outfile = $main::outfile;
	$toshell = $main::toshell;
	$report = $main::report;
	$simnetwork = $main::simnetwork;
	$reportloadsdata = $main::reportloadsdata;
	
	%dowhat = %main::dowhat;

	@themereports = @main::themereports; say TOSHELL "dumpINRETRIEVE(\@themereports): " . dump(@themereports);
	@simtitles = @main::simtitles; say TOSHELL "dumpINRETRIEVE(\@simtitles): " . dump(@simtitles);
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
	
	my @simcases = @{ $dirfiles{simcases} }; say TOSHELL "dump(\@simcases): " . dump(@simcases);
	my @simstruct = @{ $dirfiles{simstruct} }; say TOSHELL "dump(\@simstruct): " . dump(@simstruct);
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
	
	my $morphlist = $dirfiles{morphlist}; say TOSHELL "dump(\$morphlist): " . dump($morphlist);
	my $morphblock = $dirfiles{morphblock};
	my $simlist = $dirfiles{simlist}; say TOSHELL "dump(\$simlist): " . dump($simlist);
	my $simblock = $dirfiles{simblock};
	my $retlist = $dirfiles{retlist};
	my $retblock = $dirfiles{retblock};
	my $replist = $dirfiles{retpist};
	my $repblock = $dirfiles{repblock};
	my $mergelist = $dirfiles{mergelist};
	my $mergeblock = $dirfiles{mergeblock};
	my $descendlist = $dirfiles{descendlist};
	my $descendblock = $dirfiles{descendblock};
	
	#my $getpars = shift;
	#eval( $getpars );

	#if ( fileno (MORPHLIST) 
	
	open ( OUTFILE, ">>$outfile" ) or die "Can't open $outfile: $!"; 
	open ( TOSHELL, ">>$toshell" ) or die "Can't open $toshell: $!"; 
	
	
	foreach my $instance (@instances)
	{
		say TOSHELL "\nNow in Sim::OPT::Retrieve. INSTANCES\n";
		my %d = %{$instance};
		my $countcase = $d{countcase}; #say TOSHELL "dump(\$countcase): " . dump($countcase);
		my $countblock = $d{countblock}; #say TOSHELL "dump(\$countblock): " . dump($countblock);
		my @miditers = @{ $d{miditers} }; say TOSHELL "dump(\@miditers): " . dump(@miditers);
		my @winneritems = @{ $d{winneritems} }; #say TOSHELL "dumpIN( \@winneritems) " . dump(@winneritems);
		my $countvar = $d{countvar}; #say TOSHELL "dump(\$countvar): " . dump($countvar);
		my $countstep = $d{countstep}; #say TOSHELL "dump(\$countstep): " . dump($countstep);						
		my $to = $d{to}; say TOSHELL "dump(\$to): " . dump($to);
		my $origin = $d{origin}; #say TOSHELL "dump(\$origin): " . dump($origin);
		my @uplift = @{ $d{uplift} }; #say TOSHELL "dump(\@uplift): " . dump(@uplift);
		#eval($getparshere);
		
		my $rootname = Sim::OPT::getrootname(\@rootnames, $countcase); #say TOSHELL "dump(\$rootname): " . dump($rootname);
		my @blockelts = Sim::OPT::getblockelts(\@sweeps, $countcase, $countblock); #say TOSHELL "dumpIN( \@blockelts) " . dump(@blockelts);
		my @blocks = Sim::OPT::getblocks(\@sweeps, $countcase);  #say TOSHELL "dumpIN( \@blocks) " . dump(@blocks);
		my $toitem = Sim::OPT::getitem(\@winneritems, $countcase, $countblock); #say TOSHELL "dump(\$toitem): " . dump($toitem);
		my $from = Sim::OPT::getline($toitem); say TOSHELL "dumpIN(\$from): " . dump($from);
		my %varnums = Sim::OPT::getcase(\@varinumbers, $countcase); #say TOSHELL "dumpIN---(\%varnums): " . dump(%varnums); 
		my %mids = Sim::OPT::getcase(\@miditers, $countcase); #say TOSHELL "dumpIN---(\%mids): " . dump(%mids); 
		#eval($getfly);
		
		my $stepsvar = Sim::OPT::getstepsvar($countvar, $countcase, \@varinumbers); #say TOSHELL "dump(\$stepsvar): " . dump($stepsvar); 
		my $varnumber = $countvar; #say TOSHELL "dump---(\$varnumber): " . dump($varnumber) . "\n\n";  # LEGACY VARIABLE
		
		#say "INRETRIEVE0\$countcase : " . dump($countcase);
		#say "INRETRIEVE0\@rootnames : " . dump(@rootnames);
		#say "INRETRIEVE0\$countblock : " . dump($countblock);
		#say "INRETRIEVE0\@sweeps : " . dump(@sweeps);
		#say "INRETRIEVE0\@varinumbers : " . dump(@varinumbers);
		#say "INRETRIEVE0\@miditers : " . dump(@miditers);
		#say "INRETRIEVE0\@winneritems : " . dump(@winneritems);
		#say "INRETRIEVE0\@morphcases : " . dump(@morphcases);
		#say "INRETRIEVE0\@morphstruct : " . dump(@morphstruct);
		

		
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
			my $counttheme = shift;
			my $countreport = shift;
			my $retfile = shift;
			#my $existingfile = "$resfile-$theme.grt";
			#if (-e $existingfile) { print `chmod 777 $existingfile\n`;} 
			#print $_toshell_ "chmod 777 $existingfile\n";
			#if (-e $existingfile) { print `rm $existingfile\n` ;}
			#print $_toshell_ "rm $existingfile\n";
			#if ($exeonfiles eq "y") { print `rm -f $existingfile*par\n`; }
			#print $_toshell_ "rm -f $existingfile*par\n";
			
			say "INRETRIEVE0\$countcase : " . dump($countcase);
			say "INRETRIEVE1\@rootnames : " . dump(@rootnames);
			say "INRETRIEVE1\$countblock : " . dump($countblock);
			say "INRETRIEVE1\@sweeps : " . dump(@sweeps);
			say "INRETRIEVE1\@varinumbers : " . dump(@varinumbers);
			say "INRETRIEVE1\@miditers : " . dump(@miditers);
			say "INRETRIEVE1\@winneritems : " . dump(@winneritems);
			say "INRETRIEVE1\@morphcases : " . dump(@morphcases);
			say "INRETRIEVE1\@morphstruct : " . dump(@morphstruct);

			unless (-e "$retfile-")
			{
				my $printthis = 
"res -file $resfile -mode script<<YYY

3
$retrdata[0]
$retrdata[1]
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
$retfile
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
	#Retrieving results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", simulation period $counttheme, retrieve period $countreport\n
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
			my $counttheme = shift;
			my $countreport = shift;
			my $retfile = shift;
			#my $existingfile = "$resfile-$theme.grt"; 
			#if (-e $existingfile) { print `chmod 777 $existingfile\n`;} 
			#print $_toshell_ "chmod 777 $existingfile\n";
			#if (-e $existingfile) { print `rm $existingfile\n` ;}
			#print $_toshell_ "rm $existingfile\n";
			#if ($exeonfiles eq "y") { print `rm -f $existingfile*par\n`;}
			#print $_toshell_ "rm -f $existingfile*par\n";

			unless (-e "$retfile-")
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
$retfile
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
	#Retrieving results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", simulation period $counttheme, retrieve period $countreport\n
	$printthis";
					#if (-e $existingfile) { print `rm -f $existingfile*par\n`;}
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
				my $counttheme = shift;
				my $countreport = shift;
				my $retfile = shift;
				#my $existingfile = "$resfile-$theme.grt";
				#if (-e $existingfile) { print `chmod 777 $existingfile\n`;}
				#print $_toshell_ "chmod 777 $existingfile\n";
				#if (-e $existingfile) { print `rm $existingfile\n` ;}
				#print $_toshell_ "rm $existingfile\n";

				unless (-e "$retfile-")
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
$retfile
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
#Retrieving results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", simulation period $counttheme, retrieve period $countreport\n
$printthis
";

				print RETLIST "$retfile ";
				if ($stripcheck)
				{
					open (CHECKDATUM, "$retfile") or die;
					open (STRIPPED, ">$retfile-") or die;
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
				say TOSHELL "\nNow in Sim::OPT::Retrieve. IN TEMPSSTATS";
				my $result = shift; say "$result: " . dump($result); 
				my $resfile = shift; say "$resfile " . dump($resfile); 
				my $swap = shift; say "$swap " . dump($swap); 
				my @retrdata = @$swap; say "@retrdata " . dump(@retrdata); 
				my $reporttitle = shift; say "$reporttitle " . dump($reporttitle); 
				my $theme = shift; say "$theme " . dump($theme); 
				my $counttheme = shift; say "$counttheme " . dump($counttheme); 
				my $countreport = shift; say "$countreport " . dump($countreport); 
				my $retfile = shift; say "$retfile " . dump($retfile); 
				#my $existingfile = "$resfile-$theme.grt";
				#if (-e $existingfile) { print `chmod 777 $existingfile\n`; }
				#print $_toshell_ "chmod 777 $existingfile\n";
				#if (-e $existingfile) { print `rm $existingfile\n` ;}
				#print $_toshell_ "rm $existingfile\n";
				#if (-e $existingfile) { print `rm -f $existingfile*par\n`;}
				#print $_toshell_ "rm -f $existingfile*par\n";

				unless (-e "$retfile-")
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
$retfile
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
#Retrieving results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ", simulation period $counttheme, retrieve period $countreport\n
$printthis";

				#if ($exeonfiles eq "y") { print `rm -f $existingfile*par\n`;}
				#print $_toshell_ "rm -f $existingfile*par\n";
				#print RETLIST "$resfile-$reporttitle-$theme--$countcase-$countblock.grt ";
				if ($stripcheck) ### ZZZ
				{
					open (CHECKDATUM, "$retfile") or die;
					open (STRIPPED, ">$retfile-") or die;
					my @lines = <CHECKDATUM>;
					foreach my $line (@lines)
					{
						$line =~ s/^\s+//;
						#@lineelms = split(/\s+|,/, $line);
						#if ($lineelms[0] eq $stripcheck) 
						#{
							print STRIPPED "$line";
						#}
					}
					close STRIPPED;
					close CHECKDATUM;
				}
				#print RETBLOCK "$resfile-$reporttitle-$theme--$countcase-$countblock.grt ";
				if ($stripcheck) ### ZZZ
				{
					open (CHECKDATUM, "$retfile") or die;
					open (STRIPPED, ">$retfile-") or die;
					my @lines = <CHECKDATUM>;
					foreach my $line (@lines)
					{
						$line =~ s/^\s+//;
						#@lineelms = split(/\s+|,/, $line);
						#if ($lineelms[0] eq $stripcheck) 
						#{
							print STRIPPED "$line";
						#}
					}
					close STRIPPED;
					close CHECKDATUM;
				}
			}
		}
		
		
		say TOSHELL "\nNow in Sim::OPT::Retrieve. INSIDE";
		say TOSHELL "\@simcases " . dump( @simcases );
		
		my $resfile;
		foreach (@simcases)
		{
			if ( $_  =~ /$toitem/ )
			{
				$resfile = $_; #say TOSHELL "\$resfile " . dump($resfile);
			}
		} #say TOSHELL "\$resfile " . dump($resfile);	
			
		my $counttheme = 0;
		foreach my $retrievedatum (@retrievedata)
		{
			say TOSHELL "\nNow in Sim::OPT::Retrieve. IN THEMES";
			
			say TOSHELL "dumpINRETRIEVE(\@themereports): " . dump(@themereports);
			say TOSHELL "dumpINRETRIEVE(\@simtitles): " . dump(@simtitles);
			say TOSHELL "dump(\$dat{morphlist}): " . dump($dat{morphlist});
			say TOSHELL "dump(\$simlist): " . dump($simlist);


			# print OUTFILE "SIMS: \n";
			my @themereports = @{$themereports[$counttheme]}; say TOSHELL "\@themereports " . dump(@themereports);
			my $reporttitlesref = $reporttitles[$counttheme];
			my @reporttitles = @{$reporttitlesref}; say TOSHELL "\@reporttitles " . dump(@reporttitles);
			my $retrievedatarefsdeep = $retrievedata[$counttheme];
			my @retrievedatarefs = @{$retrievedatum};
			my $simtitle = $simtitles[$counttheme]; say TOSHELL "\$simtitle " . dump($simtitle);
			my @sims = @{$simdata[$countheme]}; say TOSHELL "\@sims " . dump(@sims);
			
			
			
			my $countreport = 0;
			foreach my $retrievedataref (@retrievedatarefs)
			{
				say TOSHELL "\nNow in Sim::OPT::Retrieve. IN RESULTS";
				my $theme = $themereports[$countreport]; say TOSHELL "\$theme: " . dump($theme);
				my $reporttitle = $reporttitles[$countreport]; say TOSHELL "\$reporttitle " . dump($reporttitle);
				my @retrdata = @$retrievedataref; say TOSHELL "\@retrdata " . dump(@retrdata);
				my $sim = $sims[$countreport]; say TOSHELL "\$sim-RESFILE" . dump($sim); 
				my $targetprov = $sim;
				$targetprov =~ s/$mypath\///;
				my $result = "$mypath" . "/results/$targetprov"; say TOSHELL "\$result " . dump($result); 
				
				#if ( fileno (RETLIST) )
				#if (not (-e $retlist ) )
				#{
				#	if ( $countblock == 0 )
				#	{
						open ( RETLIST, ">>$retlist"); # or die;
				#	}
				#	else 
				#	{
				#		open ( RETLIST, ">>$retlist"); # or die;
				#	}
				#}
				
				#if ( fileno (RETLIST) ) # SAME LEVEL OF RETLIST. JUST ANOTHER CONTAINER.
				#if (not (-e $retblock ) )
				#{
				#	if ( $countblock == 0 )
				#	{
						open ( RETBLOCK, ">>$retblock"); # or die;
				#	}
				#	else 
				#	{
				#		open ( RETBLOCK, ">>$retblock"); # or die;
				#	}
				#}
				
				my $retfile = "$to-t$counttheme-r$countreport.grt";
				$retfile =~ s/ /_/ ; say TOSHELL "\$retfile " . dump($retfile);
				
				push ( @{ $retstruct[$countcase][$countblock][$counttheme][$countreport] }, $retfile );
				print RETBLOCK "$retfile\n";
				
				#if ( not ($retfile ~~ @retcases ) )
				#{
					push ( @retcases, $retfile );
					say RETLIST "$retfile";
					
					if ( $theme eq "temps" ) { &retrieve_temperatures_results($result, $resfile, \@retrdata, $reporttitle, $theme, $counttheme, $countreport, $retfile ); }
					if ( $theme eq "comfort"  ) { &retrieve_comfort_results($result, $resfile, \@retrdata, $reporttitle, $theme, $counttheme, $countreport, $retfile ); }
					if ( $theme eq "loads" ) 	{ &retrieve_loads_results($result, $resfile, \@retrdata, $reporttitle, $theme, $counttheme, $countreport, $retfile ); }
					if ( $theme eq "tempsstats"  ) { &retrieve_temps_stats($result, $resfile, \@retrdata, $reporttitle, $theme, $counttheme, $countreport, $retfile ); }
					print OUTFILE "\$sim: $sim, \$resfile: $resfile, \$result: $result, \@retrievedata: @retrievedata, \$reporttitle: $reporttitle, \$theme: $theme, \$counttheme: $counttheme, \$countreport, $countreport, \$retfile : $retfile \n";
				#}
				$countreport++;
			}
			$counttheme++;
		}
	}
#print `rm -f ./results/*.grt`;
#print TOSHELL "rm -f ./results/*.grt\n";
#print `rm -f ./results/*.par`;
#print TOSHELL "rm -f ./results/*.par\n";
#close OUTFILE;
#close TOSHELL;
	close RETLIST;
	close RETBLOCK;
	return (\@retcases, \@retstruct);
}	# END SUB RETRIEVE

##############################################################################
##############################################################################
##############################################################################
# END SUB RETRIEVE

sub report { ; } # NO MORE USED # This function retrieved the results of interest from the text file created by the "retrieve" function

1;