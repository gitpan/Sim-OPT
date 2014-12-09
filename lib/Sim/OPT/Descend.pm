package Sim::OPT::Descend;
# Copyright (C) 2008-2014 by Gian Luca Brunetti and Politecnico di Milano.
# This is the module Sim::OPT::Descend of Sim::OPT, a program for detailed metadesign managing parametric explorations through the ESP-r building performance simulation platform and performing optimization by block coordinate descent.
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
use Sim::OPT::Sim;
use Sim::OPT::Retrieve;
#use Sim::OPT::Report;
use feature 'say';
no strict; 
no warnings;

@ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( descend ); # our @EXPORT = qw( );

$VERSION = '0.39.6_11'; # our $VERSION = '';


#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Descend.pm" - Sim::OPT::Descend
##############################################################################

sub descend 
{
	say "Now in Sim::OPT::Descend.\n";
	my $swap = shift; #say TOSHELL "swapINDESCEND: " . dump($swap);
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
	
	$mypath = $main::mypath;  #say TOSHELL "dumpINDESCEND(\$mypath): " . dump($mypath);
	$exeonfiles = $main::exeonfiles; #say TOSHELL "dumpINDESCEND(\$exeonfiles): " . dump($exeonfiles);
	$generatechance = $main::generatechance; 
	$file = $main::file;
	$preventsim = $main::preventsim;
	$fileconfig = $main::fileconfig; #say TOSHELL "dumpINDESCEND(\$fileconfig): " . dump($fileconfig); # NOW GLOBAL. TO MAKE IT PRIVATE, FIX PASSING OF PARAMETERS IN CONTRAINTS PROPAGATION SECONDARY SUBROUTINES
	$outfile = $main::outfile;
	$toshell = $main::toshell;
	$report = $main::report;
	$simnetwork = $main::simnetwork;
	$reportloadsdata = $main::reportloadsdata;
	
	%dowhat = %main::dowhat;

	@themereports = @main::themereports; #say "dumpINDESCEND(\@themereports): " . dump(@themereports);
	@simtitles = @main::simtitles; #say "dumpINDESCEND(\@simtitles): " . dump(@simtitles);
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

	#my $getpars = shift;
	#eval( $getpars );
	
	my $instance = $instances[0];
	
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
	
	#say "0\$countcase : " . dump($countcase);
	#say "0\@rootnames : " . dump(@rootnames);
	#say "0\$countblock : " . dump($countblock);
	#say "0\@sweeps : " . dump(@sweeps);
	#say "0\@varinumbers : " . dump(@varinumbers);
	#say "0\@miditers : " . dump(@miditers);
	#say "0\@winneritems : " . dump(@winneritems);
	#say "0\@morphcases : " . dump(@morphcases);
	#say "0\@morphstruct : " . dump(@morphstruct);
	
	say "Descending into case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
	say TOSHELL "#Descending into case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";

	my @columns_to_report           = @{ $reporttempsdata[1] };
	my $number_of_columns_to_report = scalar(@columns_to_report);
	my $counterlines;
	my $number_of_dates_to_mix = scalar(@simtitles);
	my @dates                    = @simtitles;
	my $mixfile = "$mypath/$file-mix-$countcase-$countblock";

	sub mix
	{
		say "Merging performances for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		say TOSHELL "#Merging performances for  case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		open (MIXFILE, ">$mixfile"); # or die;
		my @repdata = @mergecases;
		#my @repdata = <$mypath/$file*-summary--$countcase-$countblock.txt>;
		open (FILECASELIST, "$simlist"); # or die;
		my @lines = <FILECASELIST>;
		close FILECASELIST;
		my $counterline = 1;
		foreach my $line (@lines)
		{
			chomp($line);
			my $morphcase = "$line";
			my $reportcase = $morphcase;
			$reportcase =~ s/\/models/\/results/;
			print MIXFILE "CASE$counterline ";
			my $counterouter = 0;
			foreach my $themeref (@themereports)
			{
				my $counterinner = 0;
				my @themes = @{$themeref};
				foreach my $theme (@themes)
				{
					my $simtitle = $simtitles[$counterouter];
					my $reporttitle = $reporttitles[$counterouter][$counterinner]; #print $_outfile_ "FILE: $file, SIMTITLE: $simtitle, REPORTTITLE!: $reporttitle, THEME: $theme\n";
					my $case = "$reportcase-$reporttitle-$theme.grt-"; #print $_outfile_ "\$case $case\n";
					#if (-e $case) { print $_outfile_ "IT EXISTS!\n"; } #print $_outfile_ "$case\n";
					open(OPENTEMP, $case); # or die;
					my @linez = <OPENTEMP>;
					close OPENTEMP;
					chomp($linez[0]);
					print MIXFILE "$case $linez[0] ";
					$counterinner++;
				}
				$counterouter++;
			}
			print MIXFILE "\n";
			$counterline++;
		}
		close MIXFILE;
	}
	&mix();

	my $cleanfile = "$mixfile-clean";
	my $selectmixed = "$cleanfile-select";
	sub cleanselect
	{ # CLEANS THE MIXED FILE AND SELECTS SOME COLUMNS AND COPIES THEM IN ANOTHER FILE
		say "Cleaning results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		say TOSHELL "#Cleaning results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		open ( MIXFILE, $mixfile); # or die;
		my @lines = <MIXFILE>;
		close MIXFILE;
		open ( CLEANMIXED, ">$cleanfile"); # or die;
		foreach my $line (@lines)
		{
			$line =~ s/\n/°/g;
			$line =~ s/\s+/,/g;
			$line =~ s/°/\n/g;
			print CLEANMIXED "$line";
		}
		close CLEANMIXED;
		# END. CLEANS THE MIXED FILE
	
		#SELECTS SOME COLUMNS AND COPIES THEM IN ANOTHER FILE
		open (CLEANMIXED, $cleanfile); # or die;
		my @lines = <CLEANMIXED>;
		close CLEANMIXED;
		open (SELECTEDMIXED, ">$selectmixed"); # or die;
		
		
		foreach my $line (@lines)
		{
			my @elts = split(/\s+|,/, $line);
			my $counterouter = 0;
			foreach my $elmref (@keepcolumns)
			{
				my @cols = @{$elmref};
				my $counterinner = 0;
				foreach my $elm (@cols)
				{
					print  SELECTEDMIXED "$elts[$elm]";
					if ( ( $counterouter < $#keepcolumns  ) or ( $counterinner < $#cols) )
					{
						print  SELECTEDMIXED ",";
					}
					else {print  SELECTEDMIXED "\n";}
					$counterinner++;
				}
				$counterouter++;
			}
		}
		close SELECTEDMIXED;
	} # END. CLEANS THE MIXED FILE AND SELECTS SOME COLUMNS AND COPIES THEM IN ANOTHER FILE
	&cleanselect();
	
	my $weight = "$selectmixed-weight"; # THIS WILL HOST PARTIALLY SCALED VALUES, MADE POSITIVE AND WITH A CELING OF 1
	sub weight
	{
		say "Scaling results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		say TOSHELL "#Scaling results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		open (SELECTEDMIXED, $selectmixed); # or die;
		my @lines = <SELECTEDMIXED>;
		close SELECTEDMIXED;
		my $counterline = 0;
		open (WEIGHT, ">$weight"); # or die;
		
		my @containerone;
		foreach my $line (@lines)
		{
			$line =~ s/^[\n]//;
			my @elts = split(/\s+|,/, $line);
			my $countcol = 0;
			my $countel = 0;
			foreach my $elt (@elts)
			{
				if ( Sim::OPT::odd($countel) )
				{
					push ( @{$containerone[$countcol]}, $elt); #print $_outfile_ "ELT: $elt\n";
					$countcol++;
				}
				$countel++;
			}
		} 
		#print $_outfile_ "CONTAINERONE " . Dumper(@containerone) . "\n";
			
		my @containertwo;
		my @containerthree;
		$countcolm = 0;
		my @optimals;
		foreach my $colref (@containerone)
		{
			my @column = @{$colref}; # DEREFERENCE
			
			if ( $weights[$countcolm] < 0 ) # TURNS EVERYTHING POSITIVE
			{
				foreach $el (@column)
				{
					$el = ($el * -1);
				}
			}
			
			if ( max(@column) != 0) # FILLS THE UNTRACTABLE VALUES
			{
				push (@maxes, max(@column));
			}
			else
			{
				push (@maxes, "NOTHING1");
			}
					
			#print $_outfile_ "MAXES: " . Dumper(@maxes) . "\n";
			#print $_outfile_ "DUMPCOLUMN: " . Dumper(@column) . "\n";
			
			foreach my $el (@column)
			{
				my $eltrans;
				if ( $maxes[$countcolm] != 0 )
				{
					#print $_outfile_ "\$weights[\$countcolm]: $weights[$countcolm]\n";
					$eltrans = ( $el / $maxes[$countcolm] ) ;
				}
				else
				{
					$eltrans = "NOTHING2" ;
				}
				push ( @{$containertwo[$countcolm]}, $eltrans) ; #print $_outfile_ "ELTRANS: $eltrans\n";
			}
			$countcolm++;
		} 
		#print $_outfile_ "CONTAINERTWO " . Dumper(@containertwo) . "\n";
				
		my $countline = 0;
		foreach my $line (@lines)
		{
			$line =~ s/^[\n]//;
			my @elts = split(/\s+|,/, $line);		
			my $countcolm = 0;
			foreach $eltref (@containertwo)
			{
				my @col =  @{$eltref};
				my $max = max(@col); #print $_outfile_ "MAX: $max\n";
				my $min = min(@col); #print $_outfile_ "MIN: $min\n";
				my $floordistance = ($max - $min);
				my $range = ( $min / $max);
				my $el = $col[$countline];
				my $rescaledel;
				if ( $floordistance != 0 )
				{
					$rescaledel = ( ( $el - $min ) / $floordistance ) ;
				}
				else
				{
					$rescaledel = 1;
				}
				if ( $weightsaim[$countcolm] < 0)
				{
					$rescaledel = ( 1 - $rescaledel);
				}
				push (@elts, $rescaledel);
				$countcolm++;
			}
			
			$countline++;
			
			my $counter = 0;
			foreach my $el (@elts)
			{		
				print WEIGHT "$el";
				if ($counter < $#elts)
				{ 
					print WEIGHT ",";
				}
				else
				{
					print WEIGHT "\n";
				}
				$containerthree[$counterline][$counter] = $el;
				$counter++;
			}
			$counterline++;
		}
		close WEIGHT;
		#print $_outfile_ "CONTAINERTHREE: " . Dumper(@containerthree) . "\n";
	}
	&weight(); #
	
	my $weighttwo = "$selectmixed-weighttwo"; # THIS WILL HOST PARTIALLY SCALED VALUES, MADE POSITIVE AND WITH A CELING OF 1
	sub weighttwo
	{
		say "Weighting results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		say TOSHELL "#Weighting results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		open (WEIGHT, $weight); # or die;
		my @lines = <WEIGHT>;
		close WEIGHT;
		open (WEIGHTTWO, ">$weighttwo"); # or die;		
		my $counterline;
		foreach my $line (@lines)
		{
			$line =~ s/^[\n]//;
			my @elts = split(/\s+|,/, $line);
			my $counterelt = 0;
			my $counterin = 0;
			my $sum = 0;
			my $avg;
			my $numberels = scalar(@keepcolumns);
			foreach my $elt (@elts)
			{
				my $newelt;
				if ($counterelt > ( $#elts - $numberels ))
				{
					#print $_outfile_ "ELT: $elt\n";
					$newelt = ( $elt * abs($weights[$counterin]) ); # print $_outfile_ "NEWELT: $newelt\n";
					# print $_outfile_ "ABS" . abs($weights[$counterin]) . "\n";
					$sum = ( $sum + $newelt ) ; # print $_outfile_ "SUM: $sum\n";
					$counterin++;
				}
				$counterelt++;
			}
			$avg = ($sum / scalar(@keepcolumns) );
			push ( @elts, $avg);
			
			my $counter = 0;
			foreach my $elt (@elts)
			{		
				print WEIGHTTWO "$elt";
				if ($counter < $#elts)
				{ 
					print WEIGHTTWO ",";
				}
				else
				{
					print WEIGHTTWO "\n";
				}
				$counter++;
			}
			$counterline++
		}
	}
	&weighttwo();	

	$sortmixed = "$mixfile-sortmixed"; # globsAL!
	sub sortmixed
	{
		say "Processing results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		say TOSHELL "#Processing results for case " . ($countcase + 1) . ", block " . ($countblock + 1) . ".";
		open (WEIGHTTWO, $weighttwo); # or die;
		open (SORTMIXED_, ">$sortmixed"); # or die;
		my @lines = <WEIGHTTWO>;
		close WEIGHTTWO;
		my $line = $lines[0];
		$line =~ s/^[\n]//;
		my @eltstemp = split(/\s+|,/, $line);
		my $numberelts = scalar(@eltstemp);
		if ($numberelts > 0) { print SORTMIXED_ `sort -n -k$numberelts,$numberelts -t , $weighttwo`; }
		# print SORTMIXED_ `sort -n -k$numberelts -n $weighttwo`; 
		close SORTMIXED_;
	}
	&sortmixed();
	
	##########################################################
	
	sub takeoptima
	{
		my $pass_signal = ""; # IF VOID, GAUSS SEIDEL METHOD. IF 0, JACOBI METHOD.
		
		$fileuplift = "$file-uplift-$countcase-$countblock";
		open(UPLIFT, ">$fileuplift"); # or die;

		my (@winnerarray_tested, @winnerarray_nontested, @winnerarray, @nontested, @provcontainer);
		
		if ($pass_signal eq "")
		{
			@uplift = ();
			@downlift = ();
		}
		
		open (SORTMIXED_, $sortmixed); # or die;
		my @lines = <SORTMIXED_>;
		close SORTMIXED_;
		
		my $winnerentry = $lines[0];
		chomp $winnerentry;
		
		my @winnerelms = split(/\s+|,/, $winnerentry);
		my $winnerline = $winnerelms[0];
		
		foreach my $var (@blockelts)
		{	
			if ( $winnerline =~ /($var-\d+)/ )
			{	
				my $fragment = $1; 
				push (@winnerarray_tested, $fragment);
			}
		}	
		
		foreach my $elt (@chancegroup)
		{
			unless ( $elt ~~ @blockelts)
			{
				push (@nontested, $elt);
			}
		}
		@nontested = uniq(@nontested);
		@nontested = sort(@nontested);
		
		foreach my $el ( @nontested )
		{	
			my $item = "$el-" . "$midvalues[$el]";
			push(@winnerarray_nontested, $item);
		}
		@winnerarray = (@winnerarray_tested, @winnerarray_nontested);
		@winnerarray = uniq(@winnerarray);
		@winnerarray = sort(@winnerarray);
		
		$winnermodel = "$filenew"; #BEGINNING # globsAL
		$count = 0;
		foreach $elt (@winnerarray)
		{
			unless ($count == $#winnerarray)
			{
				$winnermodel = "$winnermodel" . "$elt" . "_";
			}
			else
			{
				$winnermodel = "$winnermodel" . "$elt";
			}
			$count++;
		}
			
		unless ( ($countvar == $#blockelts) and ($countblock == $#blocks) )
		{		
			my @overlap = @{$casesoverlaps[$countcase][$countblock]};
			if (@overlap)
			{			
				my @nonoverlap;
				foreach my $elm (@chancegroup)
				{
					unless (  $elm ~~ @overlap)
					{
						push ( @nonoverlap, $elm);
					}
				}
				
				my @present;
				foreach my $elt (@nonoverlap)
				{
					if ( $winnermodel =~ /($elt-\d+)/ )
					{
						push(@present, $1);
					}
				}
				
				my @extraneous;
				foreach my $el (@nonoverlap)
				{	
					my $stepsvarthat = Sim::OPT::getstepsvar( $el, $countcase, \@varinumbers );
					my $step = 1;
					while ( $step <= $stepsvarthat )
					{					
						my $item = "$el" . "-" . "$step";
						unless ( $item ~~ @present )
						{	
							push(@extraneous, $item);
						}
						$step++;
					}
				}
				
				open(MORPHFILE, "$morphlist"); # or die; ### CHECK ZZZ
				my @models = <MORPHLIST>;
				close MORPHLIST;
					
				foreach my $model (@models)
				{
					chomp($model);
					my $counter = 0;
					foreach my $elt (@extraneous)
					{	
						if( $model =~ /$elt/ )
						{
							$counter++;
						}
					}
					if ($counter == 0)
					{
						push(@seedfiles, $model);
					}
				}
			}
			else
			{	
				push(@seedfiles, $winnermodel);
			}
		}
		
		@seedfiles = uniq(@seedfiles);
		@seedfiles = sort { $a <=> $b } @seedfiles;
		
		foreach my $seed (@seedfiles)
		{	
			my $touchfile = $seed;
			$touchfile =~ s/_+$//; 
			$touchfile = "$touchfile" . "_";
			push(@uplift, $touchfile);
			unless (-e "$touchfile")
			{
				if ( $exeonfiles eq "y" ) { print `cp -r $seed $touchfile` ; }
				print TOSHELL "cp -r $seed $touchfile\n\n";
				#if ( $exeonfiles eq "y" ) { print `mv -f $seed $touchfile` ; }
				#print TOSHELL "mv -f $seed $touchfile\n\n";
			}
			else
			{
				#if ( $exeonfiles eq "y" ) { print `rm -R $seed` ; }
				#print TOSHELL "rm -R $seed\n\n";
			}
		}
			
		foreach my $elt ( @uplift )
		{
			print UPLIFT "$elt\n";
		}
		close UPLIFT;
			
			
		push( @{ $winneritems{$countcase} }, $touchfile ); # @downlift HAS STILL TO BE WRITTEN. IT WOULD ASCEND, NOT DESCEND (SEARCHING FOR THE WORSE RESULT. @uplift DESCENDS (SEARCHING FOR THE BEST RESULT.)
		
		my %mids = Sim::OPT::getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids); 
		my $copy = $touchfile;
		$copy =~ s/$mypath\/$file//;
		my @taken = Sim::OPT::extractcase("$copy", \%mids); #say "------->taken: " . dump(@taken);
		my $newtarget = $taken[0]; #say "to--->: $to";
		my %newcarrier = %{$taken[1]}; #say "\%instancecarrier:--------->" . dump(%instancecarrier);
		%{ $miditers[$countcase] } = %newcarrier; #say "->\%miditers: " . dump(%miditers);
		push ( @{ $winneritems[$countcase][$countblock] }, $newtarget);
		
		say "2\$countcase : " . dump($countcase);
		say "2\@rootnames : " . dump(@rootnames);
		say "2\$countblock : " . dump($countblock);
		say "2\@sweeps : " . dump(@sweeps);
		say "2\@varinumbers : " . dump(@varinumbers);
		say "2\@miditers : " . dump(@miditers);
		say "2\@winneritems : " . dump(@winneritems);
		say "2\@morphcases : " . dump(@morphcases);
		say "2\@morphstruct : " . dump(@morphstruct);
		
		Sim::OPT::callcase( { countcase => $countcase, countblock => ($countblock + 1), 
		miditers => \@miditers,  winneritems => \@winneritems, 
		dirfiles => \%dirfiles, uplift => \@uplift } );
	}
	&takeoptima;
}    # END SUB descend

1;
