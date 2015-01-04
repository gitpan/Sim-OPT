package Sim::OPT::Report;
# Copyright (C) 2008-2012 by Gian Luca Brunetti and Politecnico di Milano.
# This is the module Sim::OPT::Report of Sim::OPT, a program for detailed metadesign managing parametric explorations through the ESP-r building performance simulation platform and performing optimization by block coordinate descent.
# This is free software.  You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
# The content of this module is stale. It has to be entirely re-checked.

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
use Sim::OPT;
use Sim::OPT::Morph;
use Sim::OPT::Sim;
use Sim::OPT::Retrieve;
use Sim::OPT::Descend;
use Sim::OPT::Takechance;
use Data::Dumper;
#$Data::Dumper::Indent = 0;
#$Data::Dumper::Useqq  = 1;
#$Data::Dumper::Terse  = 1;
use Data::Dump qw(dump);
use Sub::Signatures;
use feature 'say';
no strict; 
no warnings;

@ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( report mergereports ); # our @EXPORT = qw( );

$VERSION = '0.40.0'; # our $VERSION = '';

#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Sim.pm", Sim::OPT::Sim
##############################################################################

sub report # This function retrieves the results of interest from the text file created by the "retrieve" function
{
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
	
	$tee = new IO::Tee(\*STDOUT, ">>$toshell"); # GLOBAL ZZZ
	
	open ( OUTFILE, ">>$outfile" ) or die "Can't open $outfile: $!"; 
	open ( TOSHELL, ">>$toshell" ) or die "Can't open $toshell: $!";  
	say "\nNow in Sim::OPT::Report::report.\n";
	say TOSHELL "\n#Now in Sim::OPT::Report::report.\n";
	
	%dowhat = %main::dowhat;

	@themereports = @main::themereports; #say TOSHELL "dumpINDESCEND(\@themereports): " . dump(@themereports);
	@simtitles = @main::simtitles; #say TOSHELL "dumpINDESCEND(\@simtitles): " . dump(@simtitles);
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
	@reportradiation = @main::reportradiation;
	@reporttempsstats = @main::reporttempsstats;
	@files_to_filter = @main::files_to_filter;
	@filter_reports = @main::filter_reports;
	@base_columns = @main::base_columns;
	@maketabledata = @main::maketabledata;
	@filter_columns = @main::filter_columns;
	
	my @simcases = @{ $dirfiles{simcases} }; #say "dump(\@simcases): " . dump(@simcases);
	my @simstruct = @{ $dirfiles{simstruct} }; #say "dump(\@simstruct): " . dump(@simstruct);
	my @INREPORT = @{ $dirfiles{morphcases} };
	my @morphstruct = @{ $dirfiles{morphstruct} };
	my @retcases = @{ $dirfiles{retcases} }; #say TOSHELL "dumpINREPORT::report(\@retcases): " . dump(@retcases); say "dumpINDESCEND(\@retcases): " . dump(@retcases);
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
	
	my @repfilemem;
	$" = " ";
	my $repfile;
	my $countinstance = 0;
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

		say TOSHELL "#Processing reports for case " . ($countcase + 1) . ", block " . ($countblock + 1);
		#say "THEMEREPORTS::report: " . dump (@themereports);
		#say TOSHELL "THEMEREPORTS::report: " . dump (@themereports);
		
		open ( REPLIST, ">>$replist" ) or die;
		open ( REPBLOCK, ">>$repblock" ) or die;
		$repfile = "$file-report-$countcase-$countblock.txt";
		
		push ( @{ $repstruct[$countcase][$countblock] }, $repfile );
		say REPBLOCK "$repfile";
		if ( not ( $repfile ~~ @repcases ) )
		{
			push ( @repcases, $repfile );
			say REPLIST "$repfile";
		}

		open ( REPFILE, ">>$repfile") or die "Can't open $repfile $!";
		
		my $counttheme = 0;
		foreach my $themeref (@themereports)
		{			
			my $simtitle = $simtitles[$counttheme]; say TOSHELL "\$simtitle " . dump($simtitle); ### 
						
			my $countreport = 0;
			my @themes = @$themeref; #say TOSHELL "#THEMES: " . dump(@themes);
			foreach my $themereport (@themes) ###
			{
				my @themes = @$themeref; #say TOSHELL "#IN: THEMES: " . dump(@themes);
				$" = " ";
				
				my $reporttitle = $reporttitles[$counttheme][$countreport]; #say TOSHELL "CALLING-PRE\$reporttitle " . dump($reporttitle);
				my $simdatum = $reporttitles[$counttheme][0]; #say TOSHELL "CALLING-PRE\$simdatum " . dump($simdatum);
				my @retrievs = @{ $retrievedata[$counttheme][$countreport] }; #say TOSHELL "CALLING-PRE\@retrievs " . dump(@retrievs);
				
				my $retfile = $retstruct[$countcase][$countblock][$counttheme][$countreport][$countinstance] ; #say TOSHELL "#\$retfile " . dump($retfile);
				#say TOSHELL "#CALLING-REPSTRUCT " . dump(@repstruct); # ZZZ
				
				#say TOSHELL "CALLING-\$themereport: " . dump($themereport);
				#say TOSHELL "CALLING-\$countcase: " . dump($countcase);
				#say TOSHELL "CALLING-\$countblock: " . dump($countblock);
				#say TOSHELL "CALLING-\$themereport " . dump($themereport);
				#say TOSHELL "CALLING-\$counttheme " . dump($counttheme);
				#say TOSHELL "CALLING-\$countreport " . dump($countreport);
				#say TOSHELL "CALLING-\$retfile: " . dump($retfile);
				#say TOSHELL "CALLING-\$repfile: " . dump($repfile);
			
				@repfilemem = get_files($themereport, $countcase, $countblock, $counttheme, $countreport, $retfile, $repfile, $simtitle, $reporttitle, $simdatum, \@retrievs, $countinstance, \@repfilemem ); 
				$countreport++;
			}
			$counttheme++;
		}
		$countinstance++;
	}
	
	push ( @{ $mergestruct[$countcase][$countblock] },  @repfilemem ); say TOSHELL "EXITING dump(\@mergestruct): " . dump(@mergestruct);
	say TOSHELL "EXITING dump(\@mergestruct): " . dump(@mergestruct);
	
	if ( @repfilemem ~~ @mergecases ) 
	{ 
		push ( @mergecases,  @repfilemem );
	}
	say TOSHELL "EXITING dump(\@mergecases): " . dump(@mergecases);
		
	foreach my $instref ( @{ $mergestruct[$countcase][$countblock] } )
	{
		my @instance = @{ $instref };
		foreach (@instance)
		{
			print REPFILE "$_"; say TOSHELL " EXITING dump(\$el): " . dump($_);
		}
		print REPFILE "\n";
	}
	close REPFILE;
		
	say TOSHELL "EXITING dump(\$repfile): " . dump($repfile);
	close TOSHELL;
	close OUTFILE;
	return ( \@repcases, \@repstruct, \@mergestruct, \@mergecases, $repfile ); 
} # END SUB report;


sub get_files
{
	say "Extracting temperatures statistics for case " . ($countcase + 1) . ", block " . ($countblock + 1) ;
	say TOSHELL "
	#Extracting temperatures statistics for case " . ($countcase + 1) . ", block " . ($countblock + 1) ;
	my $themereport = shift; #say TOSHELL "CALLED-\$themereport: " . dump($themereport);
	my $countcase = shift; #say TOSHELL "CALLED-\$countcase: " . dump($countcase);
	my $countblock = shift; #say TOSHELL "CALLED-\$countblock: " . dump($countblock);
	my $counttheme = shift; #say TOSHELL "CALLED-\$counttheme " . dump($counttheme);
	my $countreport = shift; #say TOSHELL "CALLED-\$countreport " . dump($countreport);
	my $retfile = shift; #say TOSHELL "CALLED-\$retfile: " . dump($retfile);
	my $repfile = shift; #say TOSHELL "CALLED-\$repfile: " . dump($repfile);
	my $simtitle = shift; #say TOSHELL "CALLED-\$simtitle " . dump($simtitle);
	my $reporttitle = shift; #say TOSHELL "CALLED-\$reporttitle " . dump($reporttitle);
	my $simdatum = shift; #say TOSHELL "CALLED-\$simdatum " . dump($simdatum);
	my @retrievs = shift; #say TOSHELL "CALLED-\@retrievs " . dump(@retrievs);
	my $countinstance = shift; #say TOSHELL "CALLED-\$countinstance " . dump($countinstance);
	my $swap = shift;
	my @repfilemem = @$swap; #say TOSHELL "CALLED-\@repfilemem " . dump(@repfilemem);
	
	my @measurements_to_report = $retrievs[0]; #say TOSHELL "CALLED-\@measurements_to_report " . dump(@measurements_to_report);
	my $dates_to_report = $simtitle; #say TOSHELL "CALLED-\$dates_to_report " . dump($dates_to_report);
	my $tofilter = $reporttempsstats[1]; #say TOSHELL "CALLED-\$tofilter " . dump($tofilter); # , $reportloadsdata[1], @reporttempsstats, @reportradiation, @reportcomfortdata, @reporttempsdata
	
	open( RETFILE,  "$retfile" ) or die "Can't open $retfile $!";
	my @lines_to_inspect = <RETFILE>; #say TOSHELL "CALLED-\@lines_to_inspect " . dump(@lines_to_inspect);

	my @countcolumns;
	my $countzones = 0;
	my $countlines = 0;
	foreach my $line_to_inspect (@lines_to_inspect) 
	{
		if ( $line_to_inspect )
		{
			
			$line_to_inspect =~ s/^\s+//;### DO THIS? ZZZ
			$line_to_inspect =~ s/\s*$//;      #remove trailing whitespace
			$line_to_inspect =~ s/\ {2,}/ /g;  #remove multiple literal spaces
			$line_to_inspect =~ s/\t{2,}/\t/g; 
			my $line_to_report = "$retfile " . "$line_to_inspect"; #say TOSHELL "CALLED-\$line_to_report " . dump($line_to_report); #remove excess tabs  
			$line_to_report =~ s/--//; 
			
			if ( $themereport eq "temps" )
			{
				my @roww = split( /\s+/, $line_to_report );
				if ( $countlines == 1 )
				{
					$file_and_period = $roww[5];
				} 
				elsif ( $countlines == 3 )
				{
					my $countcolumn = 0;
					foreach $elt_of_row (@roww)
					{    #
						foreach $column (@columns_to_report)
						{
							if ( $elt_of_row eq $column )
							{
								push @countcolumns, $countcolumn;
								if ( $elt_of_row eq $columns_to_report[0] )
								{
									$title_of_column = "$elt_of_row";
								} else
								{
									$title_of_column =  "$elt_of_row-" . "$file_and_period";
								}
								push ( @{ $repfilemem[$countinstance] }, "$title_of_column\t" );
							}
						}
						$countcolumn = $countcolumn + 1;
					}
					#push ( @{ $repfilemem[$countlines] }, "\n" );
				} 
				elsif ( $countlines > 3 )
				{
					foreach $columnumber (@countcolumns)
					{
						if ( $columnumber =~ /\d/ )
						{
							push ( @{ $repfilemem[$countinstance] }, "$roww[$columnumber]\t" );
						}
					}
					#push ( @{ $repfilemem[$countlines] }, "\n" );
				}
				$countlines++;
			}
			
			if ( $themereport eq "comfort" )
			{				
				my @roww = split( /\s+/, $line_to_report );

				if ( $countlines == 1 )
				{
					$file_and_period = $roww[5];
				} 
				elsif ( $countlines == 3 )
				{
					my $countcolumn = 0;
					foreach $elt_of_row (@roww)
					{    #
						foreach $column (@columns_to_report)
						{
							if ( $elt_of_row eq $column )
							{
								push @countcolumns, $countcolumn;
								if ( $elt_of_row eq $columns_to_report[0] )
								{
									$title_of_column = "$elt_of_row";
								} else
								{
									$title_of_column =
									  "$elt_of_row-" . "$file_and_period";
								}
								push ( @{ $repfilemem[$countinstance] }, "$title_of_column\t" );
							}
						}
						$countcolumn = $countcolumn + 1;
					}
					#push ( @{ $repfilemem[$countlines] }, "\n" );
				} 
				elsif ( $countlines > 3 )
				{
					foreach $columnumber (@countcolumns)
					{
						if ( $columnumber =~ /\d/ )
						{
							push ( @{ $repfilemem[$countinstance] }, "$roww[$columnumber]\t" );
						}
					}
					#push ( @{ $repfilemem[$countlines] }, "\n" );
				}
				$countlines++;
			}
			
			if ( $themereport eq "loads" )
			{	
				if ( $line_to_report =~ /$tofilter/ )
				{
					push ( @{ $repfilemem[$countinstance] }, $line_to_report );
				}
				$countlines++;
			}
			
			if ( $themereport eq "tempsstats" )
			{
				if ( $line_to_report )
				{
					"CALLED-\$line_to_report " . dump($line_to_report);
					#my @roww = split( /\s+/, $line_to_report ); say TOSHELL "CALLED-\@roww " . dump(@roww);
					#if ( $roww[1] eq "1" or "2" or "3" or "4" or "5" or "6" or "7" or "8" or "9" )
					#{
					#	$countzones = $countzones + 1;
					#}
					if ( $line_to_report =~ /$tofilter/ )
					{
						#say TOSHELL "CALLED-FILTERED-\$line_to_report " . dump($line_to_report);
						push ( @{ $repfilemem[$countinstance] }, $line_to_report ); say TOSHELL "CALLED-IN-\@repfilemem " . dump(@repfilemem); say TOSHELL "CALLED-IN-\$countinstance " . dump($countinstance);
					}
					$countlines++;
				}
			}
		}
	}
	say TOSHELL "CALLED-OUT-\@repfilemem " . dump(@repfilemem);
	return (@repfilemem); 
} # END SUB get_files

1;
