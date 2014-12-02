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
use feature 'say';
no strict; 
no warnings;

@ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( merge_reports takeoptima ); # our @EXPORT = qw( );

$VERSION = '0.37'; # our $VERSION = '';


#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Descend.pm" and Sim::OPT::Descend
##############################################################################

sub getglobsals
{
	$configfile = shift;
	require $configfile;
}

sub merge_reports 
{
	say "Now in Sim::OPT::Descend.\n";
	my $swap = shift;
	my %dat = %$swap;
	my @instances = @{ $dat{instances} };
	my %vals = %{ $dat{vals} };
	my $countcase = $dat{$countcase};
	my @rootnames = @{ $dat{rootnames} };
	my $countblock = $dat{$countblock};
	my @sweeps = @{ $dat{sweeps} };
	my @varinumbers = @{ $dat{varinumbers} };
	my @miditers = @{ $dat{miditers} };
	my @winneritems = @{ $dat{winneritems} };
	
	my $rootname = Sim::OPT::getrootname(\@rootnames, $countcase); #say "dump(\$rootname): " . dump($rootname);
	my @blockelts = Sim::OPT::getblockelts(\@sweeps, $countcase, $countblock); #say "dumpIN( \@blockelts) " . dump(@blockelts);
	my @blocks = Sim::OPT::getblocks(\@sweeps, $countcase);  #say "dumpIN( \@blocks) " . dump(@blocks);
	my $winneritem = Sim::OPT::getitem(\@winneritems, $countcase, $countblock); #say "dump(\$winneritem): " . dump($winneritem);
	my $winnerline = Sim::OPT::getline($winneritem); #say "dump(\$winnerline): " . dump($winnerline);
	my $from = $winnerline;
	my @winnerlines = Sim::OPT::getlines( \@winneritems ); #say "dump(\@winnerlines): " . dump(@winnerlines);
	my %varnums = Sim::OPT::getcase(\@varinumbers, $countcase); #say "dumpININ---(\%varnums): " . dump(%varnums); 
	my %mids = Sim::OPT::getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids); 
	
	my $configfile = $main::configfile; #say "dump(\$configfile): " . dump($configfile);
		
	my $mypath = $main::mypath;  #say "dumpINDESCEND(\$mypath): " . dump($mypath);
	my $exeonfiles = $main::exeonfiles; #say "dumpINDESCEND(\$exeonfiles): " . dump($exeonfiles);
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
	
	#open ( TOSHELL, ">>$toshell" ); # or die;
	#open ( OUTFILE, ">>$outfile" ); # or die;
		
	my @columns_to_report           = @{ $reporttempsdata[1] };
	my $number_of_columns_to_report = scalar(@columns_to_report);
	my $counterlines;
	my $number_of_dates_to_merge = scalar(@simtitles);
	my @dates                    = @simtitles;
	my $mergefile = "$mypath/$file-merge-$countcase-$countblock";

	sub merge
	{
		open (MERGEFILE, ">$mergefile"); # or die;
		open (FILECASELIST, "$simlistfile"); # or die;
		my @lines = <FILECASELIST>;
		close FILECASELIST;
		my $counterline = 1;
		foreach my $line (@lines)
		{
			chomp($line);
			my $morphcase = "$line";
			my $reportcase = $morphcase;
			$reportcase =~ s/\/models/\/results/;
			print MERGEFILE "CASE$counterline ";
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
					print MERGEFILE "$case $linez[0] ";
					$counterinner++;
				}
				$counterouter++;
			}
			print MERGEFILE "\n";
			$counterline++;
		}
		close MERGEFILE;
	}
	&merge();

	my $cleanfile = "$mergefile-clean";
	my $selectmerged = "$cleanfile-select";
	sub cleanselect
	{ # CLEANS THE MERGED FILE AND SELECTS SOME COLUMNS AND COPIES THEM IN ANOTHER FILE
		open ( MERGEFILE, $mergefile); # or die;
		my @lines = <MERGEFILE>;
		close MERGEFILE;
		open ( CLEANMERGED, ">$cleanfile"); # or die;
		foreach my $line (@lines)
		{
			$line =~ s/\n/°/g;
			$line =~ s/\s+/,/g;
			$line =~ s/°/\n/g;
			print CLEANMERGED "$line";
		}
		close CLEANMERGED;
		# END. CLEANS THE MERGED FILE
	
		#SELECTS SOME COLUMNS AND COPIES THEM IN ANOTHER FILE
		open (CLEANMERGED, $cleanfile); # or die;
		my @lines = <CLEANMERGED>;
		close CLEANMERGED;
		open (SELECTEDMERGED, ">$selectmerged"); # or die;
		
		
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
					print  SELECTEDMERGED "$elts[$elm]";
					if ( ( $counterouter < $#keepcolumns  ) or ( $counterinner < $#cols) )
					{
						print  SELECTEDMERGED ",";
					}
					else {print  SELECTEDMERGED "\n";}
					$counterinner++;
				}
				$counterouter++;
			}
		}
		close SELECTEDMERGED;
	} # END. CLEANS THE MERGED FILE AND SELECTS SOME COLUMNS AND COPIES THEM IN ANOTHER FILE
	&cleanselect();
	
	my $weight = "$selectmerged-weight"; # THIS WILL HOST PARTIALLY SCALED VALUES, MADE POSITIVE AND WITH A CELING OF 1
	sub weight
	{
		open (SELECTEDMERGED, $selectmerged); # or die;
		my @lines = <SELECTEDMERGED>;
		close SELECTEDMERGED;
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
				if ( odd($countel) )
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
	
	my $weighttwo = "$selectmerged-weighttwo"; # THIS WILL HOST PARTIALLY SCALED VALUES, MADE POSITIVE AND WITH A CELING OF 1
	sub weighttwo
	{
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

	$sortmerged = "$mergefile-sortmerged"; # globsAL!
	sub sortmerged
	{
		open (WEIGHTTWO, $weighttwo); # or die;
		open (SORTMERGED_, ">$sortmerged"); # or die;
		my @lines = <WEIGHTTWO>;
		close WEIGHTTWO;
		my $line = $lines[0];
		$line =~ s/^[\n]//;
		my @eltstemp = split(/\s+|,/, $line);
		my $numberelts = scalar(@eltstemp);
		if ($numberelts > 0) { print SORTMERGED_ `sort -n -k$numberelts,$numberelts -t , $weighttwo`; }
		# print SORTMERGED_ `sort -n -k$numberelts -n $weighttwo`; 
		close SORTMERGED_;
	}
	&sortmerged();
}    # END SUB merge_reports

sub takeoptima
{
	my $swap = shift;
	my %dat = %$swap;
	my @instances = @{ $dat{instances} };
	my $countcase = $dat{$countcase};
	my @rootnames = @{ $dat{rootnames} };
	my $countblock = $dat{$countblock};
	my @sweeps = @{ $dat{sweeps} };
	my @varinumbers = @{ $dat{varinumbers} };
	my @miditers = @{ $dat{miditers} };
	my @winneritems = @{ $dat{winneritems} };
	
	my $rootname = Sim::OPT::getrootname(\@rootnames, $countcase); #say "dump(\$rootname): " . dump($rootname);
	my @blockelts = Sim::OPT::getblockelts(\@sweeps, $countcase, $countblock); #say "dumpIN( \@blockelts) " . dump(@blockelts);
	my @blocks = Sim::OPT::getblocks(\@sweeps, $countcase);  #say "dumpIN( \@blocks) " . dump(@blocks);
	my $winneritem = Sim::OPT::getitem(\@winneritems, $countcase, $countblock); #say "dump(\$winneritem): " . dump($winneritem);
	my $winnerline = Sim::OPT::getline($winneritem); #say "dump(\$winnerline): " . dump($winnerline);
	my $from = $winnerline;
	my @winnerlines = Sim::OPT::getlines( \@winneritems ); #say "dump(\@winnerlines): " . dump(@winnerlines);
	my %varnums = Sim::OPT::getcase(\@varinumbers, $countcase); #say "dumpININ---(\%varnums): " . dump(%varnums); 
	my %mids = Sim::OPT::getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids); 
	
	my @simcases = @{ $dat{simcases} };
	my @simstruct = @{ $dat{simstruct} };
	my @morphcases = @{ $dat{morphcase} };
	my @morphstruct = @{ $dat{morphstruct} };
	my @rescases = @{ $dat{rescases} };
	my @resstruct = @{ $dat{resstruct} };
	
	my $configfile = $dat{configfile};
	
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
	
	my %globs = $dat{globs};
	
	my $mypath = $globs{mypath};
	my $exeonfiles = $globs{exeonfiles};
	my $generatechance = $globs{generatechance};
	my $file = $globs{file};
	my $preventsim = $globs{preventsim};
	my $fileconfig = $globs{fileconfig};
	my $outfilerep = $globs{outfile};
	my $toshellrep = $globs{toshell};
	my $report = $globs{report};
	my $simnetwork = $globs{simnetwork};
	my $reportloadsdata = $globs{reportloadsdata};

	my @themereports = @{ $globs{themereports} };
	my @simtitles = @{ $globs{simtitles} };
	my @reporttitles = @{ $globs{reporttitles} };
	my @simdata = @{ $globs{simdata} };
	my @retrievedata = @{ $globs{retrievedata} };
	my @keepcolumns = @{ $globs{keepcolumns} };
	my @weights = @{ $globs{weights} };
	my @weightsaim = @{ $globs{weightsaim} };
	my @varthemes_report = @{ $globs{varthemes_report} };
	my @varthemes_variations = @{ $globs{varthemes_variations} };
	my @varthemes_steps = @{ $globs{varthemes_steps} };
	my @rankdata = @{ $globs{rankdata} };
	my @rankcolumn = @{ $globs{rankcolumn} };
	my @reporttempsdata = @{ $globs{reporttempsdata} };
	my @reportcomfortdata = @{ $globs{reportcomfortdata} };
	my @reportradiationenteringdata = @{ $globs{reportradiationenteringdata} };
	my @reporttempsstats = @{ $globs{reporttempsstats} };
	my @files_to_filter = @{ $globs{files_to_filter} };
	my @filter_reports = @{ $globs{filter_reports} };
	my @base_columns = @{ $globs{base_columns} };
	my @maketabledata = @{ $globs{maketabledata} };
	my @filter_columns = @{ $globs{filter_columns} };	
	
	#open ( TOSHELL, ">>$toshell" ); # or die;
	#open ( OUTFILE, ">>$outfile" ); # or die;
	
	$fileuplift = "$file-uplift-$countcase-$countblock";
	open(UPLIFT, ">$fileuplift"); # or die;

	my (@winnerarray_tested, @winnerarray_nontested, @winnerarray, @nontested, @provcontainer);
	my $pass;
	
	open (SORTMERGED_, $sortmerged); # or die;
	my @lines = <SORTMERGED_>;
	close SORTMERGED_;
	
	my $winnerentry = $lines[0];
	chomp $winnerentry;
	
	#my @winnerelts = split(/\s+|,/, $winnerentry);
	#my $winnerline = $winnerelts[0];
	
	#foreach my $var (@blockelts)
	#{	
	#	if ( $winnerline =~ /($var-\d+)/ )
	#	{	
	#		my $fragment = $1; 
	#		push (@winnerarray_tested, $fragment);
	#	}
	#}	
	#
	#foreach my $elt (@chancegroup)
	#{
	#	unless ( $elt ~~ @blockelts)
	#	{
	#		push (@nontested, $elt);
	#	}
	#}
	#@nontested = uniq(@nontested);
	#@nontested = sort(@nontested);
	#
	#foreach my $el ( @nontested )
	#{	
	#	my $item = "$el-" . "$midvalues[$el]";
	#	push(@winnerarray_nontested, $item);
	#}
	#@winnerarray = (@winnerarray_tested, @winnerarray_nontested);
	#@winnerarray = uniq(@winnerarray);
	#@winnerarray = sort(@winnerarray);
	
	#$winnermodel = "$filenew"; #BEGINNING # globsAL
	#$count = 0;
	#foreach $elt (@winnerarray)
	#{
	#	unless ($count == $#winnerarray)
	#	{
	#		$winnermodel = "$winnermodel" . "$elt" . "_";
	#	}
	#	else
	#	{
	#		$winnermodel = "$winnermodel" . "$elt";
	#	}
	#	$count++;
	#}
	#	
	#unless ( ($countvar == $#blockelts) and ($countblock == $#blocks) )
	#{		
	#	my @overlap = @{$casesoverlaps[$countcase][$countblock]};
	#	if (@overlap)
	#	{			
	#		my @nonoverlap;
	#		foreach my $elm (@chancegroup)
	#		{
	#			unless (  $elm ~~ @overlap)
	#			{
	#				push ( @nonoverlap, $elm);
	#			}
	#		}
	#		
	#		my @present;
	#		foreach my $elt (@nonoverlap)
	#		{
	#			if ( $winnermodel =~ /($elt-\d+)/ )
	#			{
	#				push(@present, $1);
	#			}
	#		}
	#		
	#		my @extraneous;
	#		foreach my $el (@nonoverlap)
	#		{	
	#			my $stepsvarthat = Sim::OPT::getstepsvar( $el, $countcase, \@varinumbers );
	#			my $step = 1;
	#			while ( $step <= $stepsvarthat )
	#			{					
	#				my $item = "$el" . "-" . "$step";
	#				unless ( $item ~~ @present )
	#				{	
	#					push(@extraneous, $item);
	#				}
	#				$step++;
	#			}
	#		}
	#		
	#		open(MORPHFILE, "$morphlist"); # or die; ### CHECK ZZZ
	#		my @models = <MORPHLIST>;
	#		close MORPHLIST;
	#			
	#		foreach my $model (@models)
	#		{
	#			chomp($model);
	#			my $counter = 0;
	#			foreach my $elt (@extraneous)
	#			{	
	#				if( $model =~ /$elt/ )
	#				{
	#					$counter++;
	#				}
	#			}
	#			if ($counter == 0)
	#			{
	#				push(@seedfiles, $model);
	#			}
	#		}
	#	}
	#	else
	#	{	
	#		push(@seedfiles, $winnermodel);
	#	}
	#}
	#
	#@seedfiles = uniq(@seedfiles);
	#@seedfiles = sort { $a <=> $b } @seedfiles;

	push( @{ $winneritems{$countcase} }, $winnerentry ); # @downlift HAS STILL TO BE WRITTEN. IT WOULD ASCEND, NOT DESCEND (SEARCHING FOR THE WORSE RESULT. @uplift DESCENDS (SEARCHING FOR THE BEST RESULT.)
	
	my %mids = Sim::OPT::getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids); 
	my $copy = $winnerentry;
	$copy =~ s/$mypath\/$file//;
	my @taken = Sim::OPT::extractcase("$copy", \%mids); #say "------->taken: " . dump(@taken);
	my $to = $taken[0]; #say "to-------->: $to";
	my %newcarrier = %{$taken[1]}; #say "\%instancecarrier:--------->" . dump(%instancecarrier);
	%{ $miditers[$countcase] } = %newcarrier; #say "->\%miditers: " . dump(%miditers);
	
	Sim::OPT::callcase( { countcase => $countcase, rootnames => \@rootnames, countblock => ($countblock + 1), # INCREMENT
	sweeps => \@sweeps, varinumbers => \@varinumbers, miditers => \@miditers,  winneritems => \@winneritems, 
	morphcases => \@morphcases, morphstruct => \@morphstruct } );
	
} # END OF SUB TAKEOPTIMA

1;
