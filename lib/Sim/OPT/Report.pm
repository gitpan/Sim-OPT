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

@EXPORT = qw( report retrieve merge rank_reports filter_reports maketable ); # our @EXPORT = qw( );

$VERSION = '0.37'; # our $VERSION = '';

#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Sim.pm", Sim::OPT::Sim
##############################################################################

sub getglobsals
{
	$configfile = shift;
	require $configfile;
}


sub report # This function retrieves the results of interest from the text file created by the "retrieve" function
{
	say "Now in Sim::OPT::Report.";
	my $swap = shift;
	my %dat = %$swap;
	my @instances = @{ $dat{instances} };
	my %vals = %{ $dat{vals} };
	
	my @rootnames = @{ $dat{rootnames} }; #say \"dump(\@rootnames): " . dump(@rootnames);
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase);
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock);
	my @sweeps = @{ $dat{sweeps} }; #say "dump(\@sweeps): " . dump(@sweeps);
	my @varinumbers = @{ $dat{varinumbers} }; #say "dump(\@varinumbers): " . dump(@varinumbers);
	my @miditers = @{ $dat{miditers} }; #say "dump(\@miditers): " . dump(@miditers);
	my @winneritems = @{ $dat{winneritems} }; #say "dumpIN( \@winneritems) " . dump(@winneritems);
	#eval($getparshere);
	
	my %instancecarrier = %{ $dat{instancecarrier} }; #say "dump(\%instancecarrier): " . dump(%instancecarrier);
	my $to = $dat{to}; #say "dump(\$to): " . dump($to);
	
	my $rootname =  Sim::OPT::getrootname(\@rootnames, $countcase); #say "dump(\$rootname): " . dump($rootname);
	my @blockelts =  Sim::OPT::getblockelts(\@sweeps, $countcase, $countblock); #say "dumpIN( \@blockelts) " . dump(@blockelts);
	my @blocks =  Sim::OPT::getblocks(\@sweeps, $countcase);  #say "dumpIN( \@blocks) " . dump(@blocks);
	my $winneritem =  Sim::OPT::getitem(\@winneritems, $countcase, $countblock); #say "dump(\$winneritem): " . dump($winneritem);
	my $winnerline =  Sim::OPT::getline($winneritem); #say "dump(\$winnerline): " . dump($winnerline);
	my $from = $winnerline;
	my @winnerlines =  Sim::OPT::getlines( \@winneritems ); #say "dump(\@winnerlines): " . dump(@winnerlines);
	my %varnums =  Sim::OPT::getcase(\@varinumbers, $countcase); #say "dumpININ---(\%varnums): " . dump(%varnums); 
	my %mids =  Sim::OPT::getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids); 
	#eval($getfly);
	
	my $configfile = $main::configfile; #say "dump(\$configfile): " . dump($configfile);
		
	my $mypath = $main::mypath;  #say "dumpREPORT(\$mypath): " . dump($mypath);
	my $exeonfiles = $main::exeonfiles; #say "dumpINREPORT(\$exeonfiles): " . dump($exeonfiles);
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
	
	my $filenew = "file" . "_";
		
	#open ( TOSHELLREP, ">>$toshell" ) or die;
	#open ( OUTFILE, ">>$outfile" ) or die;
	
	my $toshellrep = "$toshell" . "-4rep.txt";
	my $outfilerep = "$outfile" . "-4rep.txt";
		
	open ( TOSHELLREP, ">>$toshellrep" );
	open ( OUTFILEREP, ">>$outfilerep" );

	$" = "";

	sub strip_files_temps
	{
		my $themereport = $_[0];
		my @measurements_to_report      = @{ $reporttempsdata[0] };
		my @columns_to_report           = @{ $reporttempsdata[1] };
		my $number_of_columns_to_report = $#{ $reporttempsdata[1] };
		my $counterreport               = 0;
		my $dates_to_report             = $simtitle[$counterreport];
		my @files_to_report             = <"$mypath/$filenew*temperatures.grt>;

		foreach my $file_to_report (@files_to_report)
		{    #
			$file_to_report =~ s/\.\/$file\///;
			my $counterline    = 0;
			my @countercolumns = undef;
			my $infile         = "$file_to_report";
			my $outfilerep        = "$file_to_report-stripped";
			open( INFILEREPORT,  "$infile" )   or die "Can't open infile $infile 3: $!";
			open( OUTFILEREPORT, ">$outfilerep" ) or die "Can't open outfile $outfilerep: $!";
			my @lines_to_report = <INFILEREPORT>;

			foreach $line_to_report (@lines_to_report)
			{
				my @roww = split( /\s+/, $line_to_report );
				if ( $counterline == 1 )
				{
					$file_and_period = $roww[5];
				} elsif ( $counterline == 3 )
				{
					my $countercolumn = 0;
					foreach $element_of_row (@roww)
					{    #
						foreach $column (@columns_to_report)
						{
							if ( $element_of_row eq $column )
							{
								push @countercolumns, $countercolumn;
								if ( $element_of_row eq $columns_to_report[0] )
								{
									$title_of_column = "$element_of_row";
								} else
								{
									$title_of_column =  "$element_of_row-" . "$file_and_period";
								}
								print OUTFILEREPORT "$title_of_column\t";
							}
						}
						$countercolumn = $countercolumn + 1;
					}
					print OUTFILEREPORT "\n";
				} elsif ( $counterline > 3 )
				{
					foreach $columnumber (@countercolumns)
					{
						if ( $columnumber =~ /\d/ )
						{
							print OUTFILEREPORT "$roww[$columnumber]\t";
						}
					}
					print OUTFILEREPORT "\n";
				}
				$counterline++;
			}
			$counterreport++;
		}
		close(INFILEREPORT);
		close(OUTFILEREPORT);
	}

	sub strip_files_comfort
	{
		my $themereport = $_[0];
		my @measurements_to_report      = @{ reportcomfortdata->[0] };
		my @columns_to_report           = @{ reportcomfortdata->[1] };
		my $number_of_columns_to_report = $#{ reportcomfortdata->[1] };
		my $counterreport               = 0;

		#
		my $dates_to_report = $simtitle[$counterreport];
		my @files_to_report = <$mypath/$filenew*comfort.grt>;
		my $file_to_report;
		foreach $file_to_report (@files_to_report)
		{    #
			$file_to_report =~ s/\.\/$file\///;
			my $counterline = 0;
			my @countercolumns;
			my $infile  = "$file_to_report";
			my $outfilerep = "$file_to_report-stripped";
			open( INFILEREPORT,  "$infile" )   or die "Can't open infile $infile 4: $!";
			open( OUTFILEREPORT, ">$outfilerep" ) or die "Can't open outfile $outfilerep: $!";
			my @lines_to_report = <INFILEREPORT>;

			foreach $line_to_report (@lines_to_report)
			{
				my @roww = split( /\s+/, $line_to_report );

				#
				if ( $counterline == 1 )
				{
					$file_and_period = $roww[5];
				} elsif ( $counterline == 3 )
				{

					#
					my $countercolumn = 0;
					foreach $element_of_row (@roww)
					{    #
						foreach $column (@columns_to_report)
						{
							if ( $element_of_row eq $column )
							{
								push @countercolumns, $countercolumn;
								if ( $element_of_row eq $columns_to_report[0] )
								{
									$title_of_column = "$element_of_row";
								} else
								{
									$title_of_column =
									  "$element_of_row-" . "$file_and_period";
								}
								print OUTFILEREPORT "$title_of_column\t";
							}
						}
						$countercolumn = $countercolumn + 1;
					}
					print OUTFILEREPORT "\n";
				} elsif ( $counterline > 3 )
				{
					foreach $columnumber (@countercolumns)
					{
						if ( $columnumber =~ /\d/ )
						{
							print OUTFILEREPORT "$roww[$columnumber]\t";
						}
					}
					print OUTFILEREPORT "\n";
				}
				$counterline++;
			}
		}

		#
		close(INFILEREPORT);
		close(OUTFILEREPORT);
	}

	sub strip_files_loads_no_transpose
	{
		my $themereport = $_[0];
		my @measurements_to_report = @{ reportloadsdata->[0] };
		my @rows_to_report =
		  @{ reportloadsdata->[1] };    # in this case, they are rows
		my $number_of_rows_to_report =
		  ( 1 + $#{ reportloadsdata->[1] } );    # see above: rows
		                                         #
		my $dates_to_report = $simtitle[$counterreport];
		my @files_to_report = <$mypath/$filenew*loads.grt>;
		my $tofilter = $$reportloadsdata[1];
		foreach my $file_to_report (@files_to_report)
		{                                        #
			$file_to_report =~ s/\.\/$file\///;
			my $infile           = "$file_to_report";
			my $outfilerep          = "$file_to_report-";
			my $fullpath_outfile = "$outfilerep";
			my $fullpath_infile  = "$infile";
			open( INFILEREPORT,  "$infile" )   or die "Can't open $infile: $!";
			open( OUTFILEREPORT, ">$outfilerep" ) or die "Can't open $outfilerep: $!";
			my @lines_to_report = <INFILEREPORT>;
			
			$" = " ";
			foreach my $line_to_report (@lines_to_report)
			{
				my @roww = split( /\s+/, $line_to_report );
				foreach my $roww (@roww)
				{
					if ($roww eq $tofilter )
					{
						print OUTFILEREPORT  "$file_to_report @roww\n";
					}
				}
			}

			close(INFILEREPORT);
			close(OUTFILEREPORT);
		}
	}

	sub transposefileloads
	{
		my $themereport = $_[0];
		my @files_to_transpose = <$mypath/$filenew*loads.grt->;
		foreach $file_to_transpose (@files_to_transpose)
		{
			print `chmod -R 755 $file_to_transpose`;
			print TOSHELLREP "chmod -R 755 $file_to_transpose\n";
			open( INPUT_FILE, "$file_to_transpose" )
			  or die
			  "Something's wrong with the input file $file_to_transpose: !\n";
			my $line = <INPUT_FILE>;

			#$line =~ s/All zones/All_zones/;
			my @AoA;
			while ( defined $line )
			{
				chomp $line;
				push @AoA, [ split /\s+/, $line ];
				$line = <INPUT_FILE>;
			}
			close(INPUT_FILE);
			my $outfiletranspose = "$file_to_transpose" . "stripped";
			open RESULT, ">$outfiletranspose"
			  or die "Can't open $outfiletranspose: $!\n";
			my $countthis = 0;
			$" = "";
			for $i ( 0 ... $#{ $AoA[0] } )
			{

				for $j ( 0 ... $#AoA )
				{
					if ( $j == $#AoA )
					{
						print RESULT
						  "$loads_resulted[$countthis]  $AoA[$j][$i]\n";
					} elsif ( $AoA[$j][$i] eq "" )
					{
						print RESULT " \n";
						last;
					} else
					{
						print RESULT "$AoA[$j][$i] \t ";
					}
				}
				if ( $AoA[$j][$i] eq "" ) { last; }
				$countthis++;
			}
		}
		close(RESULT);
	}

	sub strip_files_tempsstats_no_transpose
	{
		my $themereport = $_[0];
		my @measurements_to_report = @{ reporttempsstats->[0] };
		my @rows_to_report =
		  @{ reporttempsstats->[1] };    # in this case, they are rows
		my $number_of_rows_to_report =
		  ( 1 + $#{ reporttempsstats->[1] } );    # see above: rows
		my $tofilter = $reporttempsstats[1];
		my $dates_to_report = $simtitle[$counterreport];
		my @files_to_report = <$mypath/$filenew*tempsstats.grt>;
		foreach my $file_to_report (@files_to_report)
		{
			$file_to_report =~ s/\.\/$file\///;
			my $infile           = "$file_to_report";
			my $outfilerep          = "$file_to_report-";
			my $fullpath_outfile = "$outfilerep";
			my $fullpath_infile  = "$infile";
			open( INFILEREPORT,  "$infile" )   or die "Can't open $infile 6: $!";
			open( OUTFILEREPORT, ">$outfilerep" ) or die "Can't open $outfilerep: $!";
			my $countzones    = 0;
			my @lines_to_report = <INFILEREPORT>;

			foreach $line_to_report (@lines_to_report)
			{
				$line_to_report =~ s/\:\s/\:/g;
				my @roww = split( /\s+/, $line_to_report );
				if (    $roww[1] eq "1"
					 or "2"
					 or "3"
					 or "4"
					 or "5"
					 or "6"
					 or "6"
					 or "7"
					 or "8"
					 or "9" )
				{
					$countzones = $countzones + 1;
				}
				if ( $roww[1] eq $tofilter
				  )
				{
					$" = " ";
					print OUTFILEREPORT
					  "$file_to_report\t @roww\n";
				}
			}
			close(INFILEREPORT);
			close(OUTFILEREPORT);
			
		}
	}
			
			
			
			
			


	sub transposefiletempsstats
	{
		my $themereport = $_[0];
		my @files_to_transpose = <$mypath/$filenew*tempsstats.grt->;
		foreach $file_to_transpose (@files_to_transpose)
		{
			print `chmod -R 755 $file_to_transpose`;
			print TOSHELLREP "chmod -R 755 $file_to_transpose\n";
			open( INPUT_FILE, "$file_to_transpose" )
			  or die
			  "Something's wrong with the input file $file_to_transpose: !\n";
			my $line = <INPUT_FILE>;

			my @AoA;
			while ( defined $line )
			{
				chomp $line;
				push @AoA, [ split /\s+/, $line ];
				$line = <INPUT_FILE>;
			}
			close(INPUT_FILE);
			my $outfiletranspose = "$file_to_transpose" . "stripped";
			open RESULT, ">$outfiletranspose"
			  or die "Can't open $outfiletranspose: $!\n";
			my $countthis = 0;
			for $i ( 0 ... $#{ $AoA[0] } )
			{
				for $j ( 0 ... $#AoA )
				{
					if ( $j == $#AoA )
					{
						print RESULT
						  "$tempsstats_resulted[$countthis]  $AoA[$j][$i]\n";
					} elsif ( $AoA[$j][$i] eq "" )
					{
						print RESULT "\n";
						last;
					} else
					{
						print RESULT "$AoA[$j][$i]\t";
					}
				}
				if ( $AoA[$j][$i] eq "" ) { last; }
				$countthis++;
			}
		}
		close(RESULT);
	}

	sub strip_files_loads
	{
		my $themereport = $_[0];
		strip_files_loads_no_transpose($themereport);
	}

	sub strip_files_tempsstats
	{
		my $themereport = $_[0];
		strip_files_tempsstats_no_transpose($themereport);
	}
	
	foreach my $themereport (@themereports)
	{
		if ( $themereport eq "temps" ) { strip_files_temps($themereport); }
		if ( $themereport eq "comfort" ) { strip_files_comfort($themereport); }
		if ( $themereport eq "loads" ) 
		{
			strip_files_loads($themereport);
		}
		if ( $themereport eq "tempsstats" ) { strip_files_tempsstats($themereport); }
	}
}    # END SUB report;

sub merge_reports    # Self-explaining
{
	my $swap = shift;
	my %dat = %$swap;
	my $getpars = shift;
	eval( $getpars );	
	my @columns_to_report           = @{ reporttempsdata->[1] };
	my $number_of_columns_to_report = $#{ reporttempsdata->[1] };
	my $counterlines;
	my $number_of_dates_to_merge = $#simtitle;
	my @dates                    = @simtitle;

	sub merge_reports_temps
	{       
		my $themereport = $_[0];       
		my $counterdate = 0;
		foreach my $date (@dates)
		{
			my @return_lines;
			my @resultingfile;
			my @lines_to_merge;
			my $date_to_merge  = $simtitle[$counterdate];
			my @files_to_merge = <$mypath/$filenew*$date*temperatures.grt->;
			my $counterfiles   = 0;
			foreach my $file_to_merge (@files_to_merge)
			{          #
				open( INFILEMERGE, "$file_to_merge" )
				  or die "Can't open $file_to_merge: $!";
				my @lines_to_merge = <INFILEMERGE>;
				my $counterlines   = 0;
				foreach $line_to_merge (@lines_to_merge)
				{      #
					my @roww = split( /\s+/, $line_to_merge );
					my $counterelements = 0;
					foreach $element (@roww)
					{    #
						unless (
								( $counterfiles != 0 )
								and (    ( $counterelements == 0 )
									  or ( $counterelements == 1 ) )
								or ( ( $element eq "" ) or ( $element eq " " ) )
						  )
						{
							push @{ $resultingfile[$counterlines] },
							  "$element\t";
						}
						$counterelements = $counterelements + 1;
					}
					$counterlines = $counterlines + 1;
				}
				$counterfiles = $counterfiles + 1;
				close(INFILEMERGE);
			}

			my $outfilerep = "$mypath/$filenew-$date-temperatures-sum-up.txt";
			if (-e $outfilerep) { `chmod 777 $outfilerep\n`; `mv -b $outfilerep-bak\n`;};
			print TOSHELLREP "chmod 777 $outfilerep\n"; print TOSHELLREP "mv -b $outfilerep-bak\n";
			open( OUTFILEMERGE, ">$outfilerep" ) or die "Can't open $outfilerep: $!";
			my $newcounterlines = 0;
			my $numberrow       = $#resultingfile;
			while ( $newcounterlines <= $numberrow )
			{
				$" = " ";
				print OUTFILEMERGE "@{$resultingfile[$newcounterlines]}\n";
				$newcounterlines++;
			}
			close(OUTFILEMERGE);
			my @files_to_erase = <$mypath/$filenew*$date*temperatures.grt->;
			foreach my $file_to_erase (@files_to_erase)
			{
				print "rm -r $file_to_erase";
			}
			my @files_to_erase = <$mypath/$filenew*$date*temperatures.grt.par>;
			foreach my $file_to_erase (@files_to_erase)
			{
				print "rm -r $file_to_erase";
			}
			$counterdate++;
		}
	}

	sub merge_reports_comfort
	{    #
		my $themereport = $_[0];
		my $counterdate = 0;
		foreach my $date (@dates)
		{
			my @return_lines;
			my @resultingfile;
			my @lines_to_merge;
			my $date_to_merge  = $simtitle[$counterdate];
			my @files_to_merge = <$mypath/$filenew*$date*comfort.grt->;
			my $counterfiles   = 0;
			foreach my $file_to_merge (@files_to_merge)
			{    #
				open( INFILEMERGE, "$file_to_merge" )
				  or die "Can't open file_to_merge $file_to_merge: $!";
				my @lines_to_merge = <INFILEMERGE>;
				my $counterlines   = 0;
				foreach $line_to_merge (@lines_to_merge)  #if ($roww[0] eq 1)  #
				{                                         #
					my @roww = split( /\s+/, $line_to_merge );
					my $counterelements = 0;
					foreach $element (@roww)
					{                                     #
						unless (     ( $counterfiles != 0 )
								 and ( $counterelements == 0 ) )
						{
							push @{ $resultingfile[$counterlines] },
							  "$element\t";
						}
						$counterelements = $counterelements + 1;
					}
					$counterlines = $counterlines + 1;
				}
				$counterfiles = $counterfiles + 1;
				close(INFILEMERGE);
			}

			my $outfilerep = "$mypath/$filenew-$date-comfort-sum-up.txt";
			if (-e $outfilerep) { `chmod 777 $outfilerep\n`; `mv -b $outfilerep-bak\n`;}
			print TOSHELLREP "chmod 777 $outfilerep\n"; print TOSHELLREP "mv -b $outfilerep-bak\n"; 
			open( OUTFILEMERGE, ">$outfilerep" ) or die "Can't open $outfilerep: $!";
			my $newcounterlines = 0;
			my $numberrow       = $#resultingfile;
			while ( $newcounterlines <= $numberrow )
			{
				$" = " ";
				print OUTFILEMERGE "@{$resultingfile[$newcounterlines]}\n";
				$newcounterlines = $newcounterlines + 1;

			}
			close(OUTFILEMERGE);
			my @files_to_erase = <$mypath/$filenew*$date*comfort.grt->;
			foreach my $file_to_erase (@files_to_erase)
			{
				print "rm -r $file_to_erase";
			}
			my @files_to_erase = <$mypath/$filenew*$date*comfort.grt.par>;
			foreach my $file_to_erase (@files_to_erase)
			{
				print "rm -r $file_to_erase";
			}
			$counterdate++;

			#
		}
	}

	sub merge_reports_loads
	{    #
		my $themereport = $_[0];
		my $counterdate = 0;
		foreach my $date (@dates)
		{
			my @return_lines;
			my @resultingfile;
			my @lines_to_merge;
			my $date_to_merge  = $simtitle[$counterdate];
			my @files_to_merge = <$mypath/$filenew*$date*loads.grt->;
			my $counterfiles = 0;
			foreach my $file_to_merge (@files_to_merge)
			{    #
				open( INFILEMERGE, "$file_to_merge" )
				  or die "Can't open file_to_merge $file_to_merge: $!";
				my @lines_to_merge = <INFILEMERGE>;
				my $counterlines   = 0;
				foreach $line_to_merge (@lines_to_merge)
				{    #
					my @roww = split( /\s+/, $line_to_merge );
					my $counterelements = 0;
					foreach $element (@roww)
					{    #
						unless ( ( ( $element eq "" ) or ( $element eq " " ) ) )
						{
							push @{ $resultingfile[$counterlines] },
							  "$element\t";
						}
						$counterelements = $counterelements + 1;
					}
					push @{ $resultingfile[$counterlines] }, "\n";
					$counterlines = $counterlines + 1;
				}
				$counterfiles = $counterfiles + 1;
				close(INFILEMERGE);
			}

			#
			my $outfile0 = "$mypath/$filenew-$date-loads-sum-up-transient.txt";
			if (-e $outfilerep) { `chmod 777 $outfilerep\n`; `mv -b $outfilerep-bak\n`;};
			print TOSHELLREP "chmod 777 $outfilerep\n"; print TOSHELLREP "mv -b $outfilerep-bak\n";
			open( OUTFILEMERGE0, ">$outfile0" )
			  or die "Can't open outfile0 $outfile0: $!";
			my $newcounterlines = 0;
			my $numberrow       = $#resultingfile;
			while ( $newcounterlines <= $numberrow )
			{
				print OUTFILEMERGE0 "@{$resultingfile[$newcounterlines]}";
				$newcounterlines++;
			}
			close(OUTFILEMERGE0);
			my $infile0 = "$mypath/$filenew-$date-loads-sum-up-transient.txt";
			my $outfilerep = "$mypath/$filenew-$date-loads-sum-up.txt";
			open( INFILEMERGE0, "$infile0" )  or die "Can't open infile0 $infile0: $!";
			open( OUTFILEMERGE, ">$outfilerep" ) or die "Can't open $outfilerep: $!";
			my @lines_to_merge = <INFILEMERGE0>;
			foreach my $line_to_merge (@lines_to_merge)
			{
				$line_to_merge =~ s/^\s*//;      #remove leading whitespace
				$line_to_merge =~ s/\s*$//;      #remove trailing whitespace
				$line_to_merge =~ s/\ {2,}/ /g;  #remove multiple literal spaces
				$line_to_merge =~
				  s/\t{2,}/\t/g;   #remove excess tabs (is this what you meant?)
				 #$line_to_merge =~ s/(?<=\t)\ *//g; #remove any spaces after a tab
				push @return_lines, $line_to_merge
				  unless $line_to_merge =~ /^\s*$/;    #remove empty lines
			}
			my $return_txt = join( "\n", @return_lines ) . "\n";
			print OUTFILEMERGE "$return_txt";
			close(INFILEMERGE0);
			if (-e $outfilerep) { print `rm $infile0\n`;}
			print TOSHELLREP "rm $infile0\n";
			close(OUTFILEMERGE);
			my @files_to_erase = <$mypath/$filenew*$date*loads.grt->;

			foreach my $file_to_erase (@files_to_erase)
			{
				print "rm -r $file_to_erase";
			}
			my @files_to_erase = <$mypath/$filenew*$date*loads.grt.par>;
			foreach my $file_to_erase (@files_to_erase)
			{
				print "rm -r $file_to_erase";
			}
			$counterdate++;
		}
	}

	sub merge_reports_tempsstats
	{
		my $themereport = $_[0];
		my $counterdate = 0;
		foreach my $date (@dates)
		{
			my @return_lines;
			my @resultingfile;
			my @lines_to_merge;
			my $date_to_merge  = $simtitle[$counterdate];
			my @files_to_merge = <$mypath/$filenew*$date*tempsstats.grt-> ; # my @files_to_merge = <./$file*$date*loads.grt-stripped.reversed.txt>;
			my $counterfiles = 0;
			foreach my $file_to_merge (@files_to_merge)
			{    #
				open( INFILEMERGE, "$file_to_merge" )
				  or die "Can't open file_to_merge $file_to_merge: $!";
				my @lines_to_merge = <INFILEMERGE>;
				my $counterlines   = 0;
				foreach $line_to_merge (@lines_to_merge)
				{    #
					my @roww = split( /\s+/, $line_to_merge );
					my $counterelements = 0;
					foreach $element (@roww)
					{    #
						unless ( ( ( $element eq "" ) or ( $element eq " " ) ) )
						{
							push @{ $resultingfile[$counterlines] },
							  "$element\t";
						}
						$counterelements = $counterelements + 1;
					}
					push @{ $resultingfile[$counterlines] }, "\n";
					$counterlines = $counterlines + 1;
				}
				$counterfiles = $counterfiles + 1;
				close(INFILEMERGE);
			}

			#
			my $outfile0 = "$mypath/$filenew-$date-tempsstats-sum-up-transient.txt";
			if (-e $outfilerep) { `chmod 777 $outfilerep\n`; `mv -b $outfilerep-bak\n`;};
			print TOSHELLREP "chmod 777 $outfilerep\n"; print TOSHELLREP "mv -b $outfilerep-bak\n";
			open( OUTFILEMERGE0, ">$outfile0" ) or die "Can't open $outfile0: $!";
			my $newcounterlines = 0;
			my $numberrow = $#resultingfile;
			while ( $newcounterlines <= $numberrow )
			{
				print OUTFILEMERGE0 "@{$resultingfile[$newcounterlines]}";
				$newcounterlines++;
			}
			close(OUTFILEMERGE0);
			my $infile0 =
			  "$mypath/$filenew-$date-tempsstats-sum-up-transient.txt";
			my $outfilerep = "$mypath/$filenew-$date-tempsstats-sum-up.txt";
			open( INFILEMERGE0, "$infile0" )  or die "Can't open infile0 $infile0: $!";
			open( OUTFILEMERGE, ">$outfilerep" ) or die "Can't open $outfilerep: $!";
			my @lines_to_merge = <INFILEMERGE0>;
			foreach my $line_to_merge (@lines_to_merge)
			{
				$line_to_merge =~ s/^\s*//;      #remove leading whitespace
				$line_to_merge =~ s/\s*$//;      #remove trailing whitespace
				$line_to_merge =~ s/\ {2,}/ /g;  #remove multiple literal spaces
				$line_to_merge =~
				  s/\t{2,}/\t/g;   #remove excess tabs (is this what you meant?)
				 #$line_to_merge =~ s/(?<=\t)\ *//g; #remove any spaces after a tab
				push @return_lines, $line_to_merge
				  unless $line_to_merge =~ /^\s*$/;    #remove empty lines
			}
			my $return_txt = join( "\n", @return_lines ) . "\n";
			print OUTFILEMERGE "$return_txt";
			close(INFILEMERGE0);
			if (-e $outfilerep) { print `rm $infile0\n`;}
			print TOSHELLREP "rm $infile0\n";
			close(OUTFILEMERGE);
			my @files_to_erase = <$mypath/$filenew*$date*tempsloads.grt->;

			foreach my $file_to_erase (@files_to_erase)
			{
				print "rm -r $file_to_erase";
			}
			my @files_to_erase = <$mypath/$filenew*$date*tempsloads.grt.par>;
			foreach my $file_to_erase (@files_to_erase)
			{
				print "rm -r $file_to_erase";
			}
			$counterdate++;
		}
	}
	
	foreach my $themereport (@themereports)
	{
	if ( $themereport eq "temps" ) { merge_reports_temps($themereport); }
		if ( $themereport eq "comfort" ) { merge_reports_comfort($themereport); }
		if ( $themereport eq "loads" )
		{
			merge_reports_loads($themereport);
		}
		if ( $themereport eq "tempsstats" ) { merge_reports_tempsstats($themereport); }
	}
	close TOSHELLREP;
	close OUTFILEREP;
}    # END SUB merge_reports

sub enrich_reports
{ ; } # TO DO.




