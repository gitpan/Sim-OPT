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
use IO::Tee;
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
use Sim::OPT::Report;
#use Sim::OPT::Takechance;
use feature 'say';
no strict; 
no warnings;

@ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( descend ); # our @EXPORT = qw( );

$VERSION = '0.39.6_19'; # our $VERSION = '';


#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Descend.pm" - Sim::OPT::Descend
##############################################################################

sub descend 
{
	my $swap = shift; #say TOSHELL "swapINDESCEND: " . dump($swap);
	my %dat = %$swap;
	my @instances = @{ $dat{instances} }; #say "scalar(\@instances): " . scalar(@instances);
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase); # IT WILL BE SHADOWED. CUT ZZZ
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock); # IT WILL BE SHADOWED. CUT ZZZ		
	my %dirfiles = %{ $dat{dirfiles} }; #say "dump(\%dirfiles): " . dump(%dirfiles); 
	my $repfile = $dat{repfile}; 
		
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
	
	open ( OUTFILE, ">>$outfile" ) or die "Can't open $outfile: $!"; 
	open ( TOSHELL, ">>$toshell" ) or die "Can't open $toshell: $!";  
	$tee = new IO::Tee(\*STDOUT, ">>$toshell"); # GLOBAL ZZZ
	say "\nNow in Sim::OPT::Descend.\n";
	say TOSHELL "\n#Now in Sim::OPT::Descend.\n";
	
	#say TOSHELL "dump(\$repfile): " . dump($repfile); 
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
	my @retcases = @{ $dirfiles{retcases} }; #say TOSHELL "dumpINDESCEND2(\@retcases): " . dump(@retcases); say "dumpINDESCEND(\@retcases): " . dump(@retcases);
	my @retstruct = @{ $dirfiles{retstruct} }; #say "dump(\@retstruct): " . dump(@retstruct);
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

	#my $getpars = shift;
	#eval( $getpars );
	
	my $instance = $instances[0]; # THIS WOULD HAVE TO BE A LOOP HERE TO MIX ALL THE MERGECASES!!! ### ZZZ
	
	my %d = %{$instance};
	my $countcase = $d{countcase}; #say TOSHELL "dump(\$countcase): " . dump($countcase);
	my $countblock = $d{countblock}; #say TOSHELL "dump(\$countblock): " . dump($countblock);
	my @miditers = @{ $d{miditers} }; #say TOSHELL "BEGINDESCENDdump(\@miditers): " . dump(@miditers);
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
	my $contblocksplus = ($countblock + 1);
	my $countcaseplus = ($countcase + 1);
	
	#say "0\$countcase : " . dump($countcase);
	#say "0\@rootnames : " . dump(@rootnames);
	#say "0\$countblock : " . dump($countblock);
	#say "0\@sweeps : " . dump(@sweeps);
	#say "0\@varinumbers : " . dump(@varinumbers);
	#say "0\@miditers : " . dump(@miditers);
	#say "0\@winneritems : " . dump(@winneritems);
	#say "0\@morphcases : " . dump(@morphcases);
	#say "0\@morphstruct : " . dump(@morphstruct);
	
	say "Descending into case $countcaseplus, block $contblocksplus.";
	say TOSHELL "#Descending into case $countcaseplus, block $contblocksplus.";

	my @columns_to_report           = @{ $reporttempsdata[1] };
	my $number_of_columns_to_report = scalar(@columns_to_report);
	my $counterlines;
	my $number_of_dates_to_mix = scalar(@simtitles);
	my @dates                    = @simtitles;

	my $cleanfile = "$repfile-clean.csv"; #say TOSHELL "dump(\$cleanfile): " . dump($cleanfile); 
	my $throw = $cleanfile; $throw =~ s/\.csv//;
	my $selectmixed = "$throw-select.csv"; #say TOSHELL "dump(\$selectmixed): " . dump($selectmixed); 
	sub cleanselect
	{ # CLEANS THE MIXED FILE AND SELECTS SOME COLUMNS AND COPIES THEM IN ANOTHER FILE
		say "Cleaning results for case $countcaseplus, block $contblocksplus.";
		say TOSHELL "#Cleaning results for case $countcaseplus, block $contblocksplus.";
		open ( MIXFILE, $repfile) or die; #say TOSHELL "dump(\$repfile): " . dump($repfile); 
		my @lines = <MIXFILE>; #say TOSHELL "dump(MIXFILE \@lines): " . dump(@lines); 
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
		my @lines = <CLEANMIXED>; #say TOSHELL "dump(CLEANMIXED \@lines): " . dump(@lines); 
		close CLEANMIXED;
		open (SELECTEDMIXED, ">$selectmixed") or die;
		
		
		foreach my $line (@lines)
		{
			my @elts = split(/\s+|,/, $line); ### DDD
			$elts[0] =~ /^(.*)_-(.*)/;
			my $touse = $1; #say "dump(CLEANMIXED \$touse): " . dump($touse); 
			$touse =~ s/$mypath\///;
			print SELECTEDMIXED "$touse,";
			my $countout = 0;
			foreach my $elmref (@keepcolumns)
			{
				my @cols = @{$elmref};
				my $countin = 0;
				foreach my $elm (@cols)
				{
					if ( Sim::OPT::odd($countin) )
					{
						print SELECTEDMIXED "$elts[$elm]";
					}
					else
					{
						print SELECTEDMIXED "$elm";
					}
						
					if ( ( $countout < $#keepcolumns  ) or ( $countin < $#cols) )
					{
						print  SELECTEDMIXED ",";
					}
					else {print  SELECTEDMIXED "\n";}
					$countin++;
				}
				$countout++;
			}
		}
		close SELECTEDMIXED;
	} # END. CLEANS THE MIXED FILE AND SELECTS SOME COLUMNS AND COPIES THEM IN ANOTHER FILE
	&cleanselect();
	
	my $throw = $selectmixed; $throw =~ s/\.csv//;
	my $weight = "$throw-weight.csv"; #say TOSHELL "dump(\$weight): " . dump($weight);  # THIS WILL HOST PARTIALLY SCALED VALUES, MADE POSITIVE AND WITH A CEILING OF 1
	sub weight
	{
		say "Scaling results for case $countcaseplus, block $contblocksplus.";
		say TOSHELL "#Scaling results for case $countcaseplus, block $contblocksplus.";
		open (SELECTEDMIXED, $selectmixed) or die; #say TOSHELL "dump(\$selectmixed): " . dump($selectmixed);
		my @lines = <SELECTEDMIXED>; #say TOSHELL "dump(SELECTEDMIXED \@lines): " . dump(@lines); 
		close SELECTEDMIXED;
		my $counterline = 0;
		open (WEIGHT, ">$weight"); # or die;
		
		my @containerone;
		my @containernames;
		foreach my $line (@lines)
		{
			$line =~ s/^[\n]//;
			my @elts = split(/\s+|,/, $line);
			my $touse = shift(@elts);
			my $countcol = 0;
			my $countel = 0;
			foreach my $elt (@elts)
			{
				if ( Sim::OPT::odd($countel) )
				{
					push ( @{$containerone[$countcol]}, $elt); #print $_outfile_ "ELT: $elt\n";
					$countcol++;
				}
				push (@containernames, $touse);
				$countel++;
			}
		} 
		#say TOSHELL "dump(SELECTEDMIXED \@containernames): " . dump(@containernames); 
			
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
	
	my $throw = $selectmixed; $throw =~ s/\.csv//;
	my $weighttwo = "$throw-weighttwo.csv"; # THIS WILL HOST PARTIALLY SCALED VALUES, MADE POSITIVE AND WITH A CELING OF 1
	sub weighttwo
	{
		say "Weighting results for case $countcaseplus, block $contblocksplus.";
		say TOSHELL "#Weighting results for case $countcaseplus, block $contblocksplus.";
		open (WEIGHT, $weight); #say TOSHELL "dump(\$weight): " . dump($weight);
		my @lines = <WEIGHT>;
		close WEIGHT;
		open (WEIGHTTWO, ">$weighttwo"); #say TOSHELL "dump(\$weighttwo): " . dump($weighttwo);
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
			$counterline++;
		}
	}
	&weighttwo();	
	$sortmixed = "$repfile-sortmixed.csv";
	#if ($repfile) { $sortmixed = "$repfile-sortmixed.csv"; } else { die; } # globsAL!
	sub sortmixed
	{
		say "Processing results for case $countcaseplus, block $contblocksplus.";
		say TOSHELL "#Processing results for case $countcaseplus, block $contblocksplus.";
		open (WEIGHTTWO, $weighttwo)or die; #say TOSHELL "dump(\$weighttwo): " . dump($weighttwo);
		open (SORTMIXED_, ">$sortmixed") or die; #say TOSHELL "dump(\$sortmixed): " . dump($sortmixed);
		my @lines = <WEIGHTTWO>;
		close WEIGHTTWO;
		my $count = 0;
		foreach (@lines)
		{
			$_ = "$containernames[$count]," . "$_";
			$count++;
		}
		#say TOSHELL "TAKEOPTIMA--dump(\@lines): " . dump(@lines);
		
		my $line = $lines[0];
		my @eltstemp = split(/,/, $line);
		my $numberelts = scalar(@eltstemp);
		
		#my @sorted = sort { (split(/,/, $b))[$#eltstemp] <=> (split(/,/, $a))[$#eltstemp] } @lines;
		my @sorted = sort { (split(/,/, $a))[$#eltstemp] <=> (split(/,/, $b))[$#eltstemp] } @lines;
		for (my $h = 0; $h <= $#sorted; ++$h) 
		{
			$sorted[$h] =~ s/^,//;
			print SORTMIXED_ $sorted[$h];
		}
		
		#if ($numberelts > 0) { print SORTMIXED_ `sort -t, -k$numberelts -n $weighttwo`; } 
		
		#my @sorted = sort { $b->[1] <=> $a->[1] } @lines;
		
		#print SORTMIXED_ map $_->[0],
		#sort { $a->[$#eltstemp] <=> $b->[$#eltstemp] }
		#map { [ [ @lines ] , /,/ ] }
		#foreach my $elt (@sorted)
		#{
		#	print SORTMIXED "$elt";
		#}

		#if ($numberelts > 0) { print SORTMIXED_ `sort -n -k$numberelts,$numberelts -t , $weighttwo`; } ### ZZZ
		# print SORTMIXED_ `sort -n -k$numberelts -n $weighttwo`; 
		close SORTMIXED_;
	}
	&sortmixed;
	
	##########################################################
	
	sub takeoptima
	{
		#my $pass_signal = ""; # IF VOID, GAUSS SEIDEL METHOD. IF 0, JACOBI METHOD. ...
		
		#say TOSHELL `cat $sortmixed`;
		#say TOSHELL "TAKEOPTIMA cat \$sortmixed: $sortmixed";
		
		open (SORTMIXED_, $sortmixed); # or die;
		my @lines = <SORTMIXED_>;
		close SORTMIXED_;
		
		my $winnerentry = $lines[0]; #say TOSHELL "dump(TAKEOPTIMA\$winnerentry): " . dump($winnerentry);
		chomp $winnerentry;
		
		my @winnerelms = split(/\s+|,/, $winnerentry);
		my $winnerline = $winnerelms[0]; #say TOSHELL "dump(TAKEOPTIMA\$winnerline): " . dump($winnerline);
		my $winnerval = $winnerelms[$#winnerelms];
		push ( @{ $uplift[$countcase][$countblock] }, $winnerval); #say TOSHELL "TAKEOPTIMA->\@winneritems " . dump(@winneritems);
		
		my $cntelm = 0;
		open ( MESSAGE, ">>$mypath/attention.txt");
		foreach my $elm (@lines)
		{
			my @lineelms = split( /\s+|,/, $elm );
			my $val = $lineelms[$#lineelms];
			my $case = $lineelms[0];
			{
				if ($cnelm > 0)
				{
					if ( $val ==  $winnerval)
					{
						say MESSAGE "Attention. At case $countcaseplus, block $contblocksplus. There is a tie between optimal cases. Besides case $winnerline, producing a compound objective function of $winnerval, there is the case $case producing the same objective function value. Case $winnerline has been used for the search procedures which follow.\n";
					}
				}
			}
			$cnelm++;
		}
		close (MESSAGE);
		
		my $copy = $winnerline;
		$copy =~ s/$mypath\/$file//;
		my @taken = Sim::OPT::extractcase("$copy", \%mids); #say TOSHELL "TAKEOPTIMA--->taken: " . dump(@taken);
		my $newtarget = $taken[0]; #say TOSHELL "TAKEOPTIMA\$newtarget--->: $newtarget";
		$newtarget =~ s/$mypath\///;
		my %newcarrier = %{$taken[1]}; #say TOSHELL "TAKEOPTIMA\%newcarrier--->" . dump(%newcarrier);
		#say TOSHELL "TAKEOPTIMA BEFORE->\@miditers: " . dump(@miditers);
		%{ $miditers[$countcase] } = %newcarrier; #say TOSHELL "TAKEOPTIMA AFTER->\@miditers: " . dump(@miditers);
		
		#say "2\$countcase : " . dump($countcase);
		#say "2\@rootnames : " . dump(@rootnames);
		#say "2\$countblock : " . dump($countblock);
		#say "2\@sweeps : " . dump(@sweeps);
		#say "2\@varinumbers : " . dump(@varinumbers);
		#say "2\@miditers : " . dump(@miditers);
		#say "2\@winneritems : " . dump(@winneritems);
		#say "2\@morphcases : " . dump(@morphcases);
		#say "2\@morphstruct : " . dump(@morphstruct);
		
		#say TOSHELL "TAKEOPTIMA FINAL ->\$countcase " . dump($countcase);
		#say TOSHELL "TAKEOPTIMA FINAL ->\$countblock " . dump($countblock);
		#say TOSHELL "TAKEOPTIMA FINAL ->\@miditers " . dump(@miditers);
		#say TOSHELL "TAKEOPTIMA FINAL ->\@winneritems " . dump(@winneritems);
		#say TOSHELL "TAKEOPTIMA FINAL ->\%dirfiles " . dump(%dirfiles);
		#say TOSHELL "TAKEOPTIMA FINAL ->\@uplift " . dump(@uplift);
		
		$countblock++; ### !!!
		
		#say $tee "TAKEOPTIMA FINAL ->\$countblock " . dump($countblock);
		#say $tee "TAKEOPTIMA FINAL ->\scalar( \@blocks ) " . dump( scalar( @blocks ) );
		
		# STOP CONDITION
		if ( $countblock == scalar( @blocks ) ) # NUMBER OF BLOCK OF THE CURRENT CASE
		{ 
			#say $tee "TAKEOPTIMA FINAL ->\$countblock " . dump($countblock);
			#say $tee "TAKEOPTIMA FINAL ->\$countblock " . dump($countblock);
			my @morphcases = grep -d, <$mypath/$file_*>;
			say $tee "#Optimal option for case  $countcaseplus: $newtarget";
			#my $instnum = Sim::OPT::countarray( @{ $morphstruct[$countcase] } );
			#say $tee "#Gross number of instances: $instnum." ;
			my $netinstnum = scalar(@morphcases);
			say $tee "#Net number of instances: $netinstnum." ;
			open( RESPONSE , ">$mypath/response.txt");
			say RESPONSE "#Optimal option for case  $countcaseplus: $newtarget";
			#say RESPONSE "#Gross number of instances: $instnum." ;
			say RESPONSE "#Net number of instances: $netinstnum." ;
				
			$countblock = 0;
			$countcase = $countcase++;
			if ( $countcase == scalar( @sweeps ) )# NUMBER OF CASES OF THE CURRENT PROBLEM
			{
				exit (say $tee "#END RUN.");					
			}
		}
		else
		{
			push ( @{ $winneritems[$countcase][$countblock] }, $newtarget); #say TOSHELL "TAKEOPTIMA->\@winneritems " . dump(@winneritems);
			Sim::OPT::callcase( { countcase => $countcase, countblock => $countblock, 
			miditers => \@miditers,  winneritems => \@winneritems, 
			dirfiles => \%dirfiles, uplift => \@uplift } );
		}
	}
	&takeoptima();
	close OUTFILE;
	close TOSHELL;
}    # END SUB descend

1;
