package Sim::OPT::Takechance;
# Copyright (C) 2014-2015 by Gian Luca Brunetti and Politecnico di Milano.
# This is "Sim::OPT::Takechance", a program that can produce efficient search structures for block coordinate descent given some initialization blocks (subspaces).  
# Its strategy is based on making a search path more efficient than the average randomly chosen ones, by selecting the search moves 
# so that (a) the search wake is fresher than the average random ones and (b) the search moves are more novel than the average random ones. 
# The rationale for the selection of the seach path is explained in detail (with algorithms) in my paper at the following web address: http://arxiv.org/abs/1407.5615 .

use v5.14;
# use v5.20;
use Exporter;
use parent 'Exporter'; # imports and subclasses Exporter

use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Math::Trig;
use Math::Round;
use List::Util qw[ min max reduce shuffle];
use List::MoreUtils qw(uniq);
use List::AllUtils qw(sum);
use Statistics::Basic qw(:all);
use IO::Tee;
use Set::Intersection;
use List::Compare;
use Data::Dumper;
#$Data::Dumper::Indent = 0;
#$Data::Dumper::Useqq  = 1;
#$Data::Dumper::Terse  = 1;
use Data::Dump qw(dump);
use feature 'say';    
#use feature qw(postderef);
#no warnings qw(experimental::postderef);
#use Sub::Signatures;
#no warnings qw(Sub::Signatures); 
#no strict 'refs';
no strict; 
no warnings;

use Sim::OPT;
use Sim::OPT::Morph;
use Sim::OPT::Sim;
use Sim::OPT::Retrieve;
use Sim::OPT::Report;
use Sim::OPT::Descend;

our @ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( takechance ); # our @EXPORT = qw( );
$VERSION = '0.05';

#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Takechance.pm", Sim::OPT::Takechance
#########################################################################################

sub takechance
{	
	if ( not ( @ARGV ) )
	{
		
		$toshell = $main::toshell;
		$tee = new IO::Tee(\*STDOUT, ">>$toshell"); # GLOBAL ZZZ
		say $tee "\n#Now in Sim::OPT::Takechance.\n";
		$configfile = $main::configfile; #say "dump(\$configfile): " . dump($configfile);
		@sweeps = @main::sweeps; #say "dump(\@sweeps): " . dump(@sweeps);
		@varinumbers = @main::varinumbers; say $tee "dump(\@varinumbers): " . dump(@varinumbers);
		@mediumiters = @main::mediumiters;
		@rootnames = @main::rootnames; #say "dump(\@rootnames): " . dump(@rootnames);
		%vals = %main::vals; #say "dump(\%vals): " . dump(%vals);
		@caseseed = @main::caseseed; say $tee "dump(INTAKE\@caseseed): " . dump(@caseseed);
		@chanceseed = @main::chanceseed; say $tee "dump(INTAKE\@chanceseed): " . dump(@chanceseed);
		@chancedata = @main::chancedata; #say $tee "dump(INTAKE\@chancedata): " . dump(@chancedata);
		@pars_tocheck = @main::pars_tocheck; say $tee "dump(INTAKE\@pars_tocheck): " . dump(@pars_tocheck);
		$dimchance = $main::dimchance; #say $tee "dump(INTAKE\$dimchance): " . dump($dimchance);
		
		$mypath = $main::mypath;  #say TOSHELL "dumpINDESCEND(\$mypath): " . dump($mypath);
		$exeonfiles = $main::exeonfiles; #say TOSHELL "dumpINDESCEND(\$exeonfiles): " . dump($exeonfiles);
		$generatechance = $main::generatechance; 
		$file = $main::file;
		$preventsim = $main::preventsim;
		$fileconfig = $main::fileconfig; #say TOSHELL "dumpINDESCEND(\$fileconfig): " . dump($fileconfig); # NOW GLOBAL. TO MAKE IT PRIVATE, FIX PASSING OF PARAMETERS IN CONTRAINTS PROPAGATION SECONDARY SUBROUTINES
		$outfile = $main::outfile;
		$target = $main::target;
		
		$report = $main::report;
		$simnetwork = $main::simnetwork;
		$reportloadsdata = $main::reportloadsdata;
		
		#open ( OUTFILE, ">>$outfile" ) or die "Can't open $outfile: $!"; 
		#open ( TOSHELL, ">>$toshell" ) or die "Can't open $toshell: $!";  
		#$tee = new IO::Tee(\*STDOUT, ">>$toshell"); # GLOBAL ZZZ
			
		#say TOSHELL "dump(\$repfile): " . dump($repfile); 
		%dowhat = %main::dowhat;

		@themereports = @main::themereports; #say "dumpTakechance(\@themereports): " . dump(@themereports);
		@simtitles = @main::simtitles; #say "dumpTakechance(\@simtitles): " . dump(@simtitles);
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
		@pars_tocheck = @main::pars_tocheck; say $tee "BEGINNING dump(\@pars_tocheck): " . dump(@pars_tocheck);
	}
	else
	{
		my $file = $ARGV[0];
		require $file;
	}
	
	my %res;
	my %lab;
	my $countcase = 0;
	my @caseseed_ = @caseseed;
	my @chanceseed_ = @chanceseed;
	foreach my $case (@caseseed_) # In a $casefile one or more searches are described. Here one or more searches are fabricated.
	{	
		
		say $tee "BEGINNING dump(\@varinumbers): " . dump(@varinumbers);
		my @tempvarinumbers = @varinumbers; ###ZZZ				
		foreach my $elt ( keys %{ $varinumbers[$countcase] } ) # THIS STRIPS AWAY THE PARAMETERS THAT ARE NOT CONTAINED IN @pars_tocheck.
		{
			unless ( $elt ~~ @{ $pars_tocheck[$countcase] } )
			{
				delete ${ $tempvarinumbers[$countcase] }{$elt};
			}
		}
		say $tee "BEGINNING AFTER \tempvarinumbers " . dump(@tempvarinumbers);
	
		my $testfile = "$mypath/$file-testfile-$countcase.csv"; say $tee "dump(INTAKE\$testfile): " . dump($testfile);
		open (TEST, ">>$testfile") or die; 
		my @blockrefs = @{$case}; say $tee "dump(INTAKE\@blockrefs): " . dump(@blockrefs);
		my (@varnumbers, @newvarnumbers, @chance, @newchance, @shuffledchanceelms);		
		my @chancerefs = @{$chanceseed_[$countcase]};  say $tee "dump(INTAKE\@chancerefs): " . dump(@chancerefs);	
				
		my %varnums = Sim::OPT::getcase(\@varinumbers, $countcase); #say TOSHELL "dumpIN---(\%varnums): " . dump(%varnums); 
		my @variables;
		if ( not (@{$pars_tocheck->[$countcase]}) )
		{
			@variables = sort { $a <=> $b } keys %varnums; say $tee "dump(INTAKE1\@variables): " . dump(@variables);
		}
		else
		{
			@variables = sort { $a <=> $b } @{ $pars_tocheck[$countcase] }; say $tee "dump(INTAKE2\@variables): " . dump(@variables);
		}
		my $numberof_variables = scalar(@variables); say $tee "dump(INTAKE\$numberof_variables): " . dump($numberof_variables);
		
		my $blocklength = $chancedata[$countcase][0]; say $tee "dump(INTAKE\$blocklength): " . dump($blocklength);
		my $blockoverlap = $chancedata[$countcase][1]; say $tee "dump(INTAKE\$blockoverlap): " . dump($blockoverlap);
		my $numberof_sweepstoadd = $chancedata[$countcase][2]; say $tee "dump(INTAKE\$numberof_sweepstoadd): " . dump($numberof_sweepstoadd);
		my $numberof_seedblocks = scalar(@blockrefs); say $tee "dump(INTAKE\$numberof_seedblocks): " . dump($numberof_seedblocks);
		my $totalnumberof_blocks = ( $numberof_seedblocks + $numberof_sweepstoadd ); say $tee "dump(INTAKE\$totalnumberof_blocks): " . dump($totalnumberof_blocks);
		my (@caserefs_alias, @chancerefs_alias);
		my $countbuild = 1;
		while ( $countbuild <= $numberof_sweepstoadd )
		{
			say $tee "#######################################################################
			ADDING \$countbuild $countbuild";
			
			my $countchance = 1;
			while ($countchance <= $dimchance)
			{
				say $tee"EXPLORING CHANCE, TIME \$countchance $countchance \$countbuild $countbuild";
				my %lab;
				my ($beginning, @shuffledchanceres, @shuffledchanceelms, @overlap);
				my $semaphore = 0;
				my $countshuffle = 1;
				sub _shuffle_
				{
					say $tee "#######################################################################
					SHUFFLING NUMBER $countshuffle, \$countbuild $countbuild \$countchance $countchance";
					@shuffledchanceelms = ();
					@overlap = ();
					@shuffledchanceres = shuffle(@variables); say $tee "dump(INBUILD\@shuffledchanceres): " . dump(@shuffledchanceres);
					######@shuffledchanceres = ( 1, 2, 3, 4, 5);#####
					push (@shuffledchanceelms, @shuffledchanceres, @shuffledchanceres, @shuffledchanceres ); say $tee "dump(INTAKE\@shuffledchanceelms): " . dump(@shuffledchanceelms);
					$beginning = int(rand($blocklength-1) + $numberof_variables); say $tee "dump(INBUILD\$beginning): " . dump($beginning);
					my $endblock = ( $beginninng + $blocklength ); say $tee "dump(INBUILD\$endblock): " . dump($endblock);
					#my @shuffledchanceslice = sort { $a <=> $b } (uniq(@shuffledchanceelms[$beginninng..$endblock])); say $tee "dump(INBUILD\@shuffledchanceslice): " . dump(@shuffledchanceslice); # my @shuffledchanceslice = @shuffledchanceelms[$beginning..$endblock] ;
					@caserefs_alias = @blockrefs; say $tee "dump(INBUILD\@caserefs_alias): " . dump(@caserefs_alias);
					@chancerefs_alias = @chancerefs; say $tee "dump(INBUILD\@chancerefs_alias): " . dump(@chancerefs_alias);
					my @pastsweepblocks = Sim::OPT::fromopt_tosweep_simple( casegroup => [@caserefs_alias], chancegroup => [@chancerefs_alias] ); say $tee "dumpXX(INBUILD-AFTER\@pastsweepblocks): " . dump(@pastsweepblocks);

					push (@caserefs_alias, [ $beginning, $blocklength ]); say $tee "dump(INBUILD-AFTER\@caserefs_alias): " . dump(@caserefs_alias);
					push (@chancerefs_alias, [ @shuffledchanceelms ]); say $tee "dump(INBUILD-AFTER\@chancerefs_alias): " . dump(@chancerefs_alias);
					
					my $pastbeginning = $chancerefs_alias[ $#chancerefs_alias -1 ][ 0] ;
					if ( scalar(@chancerefs_alias) <= 1 )
					{
						$pastbeginning eq ""; 
					}
					
					my $pastendblock;
					if ($pastbeginning)
					{
						$pastendblock = ( $pastbeginning + $blocklength );
					}
					else 
					{
						$pastendblock eq "";
					}
					say $tee "dump(INBUILD-AFTER\$pastbeginning): " . dump($pastbeginning);
					say $tee "dump(INBUILD-AFTER\$pastendblock): " . dump($pastendblock);
					
					my @slice = @{ $chancerefs_alias[$#chancerefs_alias] }[ $beginning..(  $beginning + $blocklength -1  ) ]; say $tee "dump(INTAKE\@slice): " . dump(@slice);
					my @pastslice = @{ $chancerefs_alias[ $#chancerefs_alias -1 ] }[ $pastbeginning..( $pastbeginning + $blocklength -1 ) ]; say $tee "dump(INTAKE\@pastslice): " . dump(@pastslice);
					my $lc = List::Compare->new(\@slice, \@pastslice);
					my @intersection = $lc->get_intersection; say $tee "dump(INBUILD\@intersection): " . dump(@intersection);
				
					#my $res = Sim::OPT::checkduplicates( { slice => \@slice, sweepblocks => \@pastsweepblocks } ); say $tee "dumpXX(INBUILD\$res): " . dump($res);
					
					if 
					#( 
					( scalar( @intersection ) == $blockoverlap ) 
					#and ( $res eq "no" ) 
					#) 
					{ $semaphore = 1; }
					
					if ( not ( $semaphore == 1 ) )
					{
						say $tee "NOT HIT. \$countshuffle: $countshuffle.";
						$countshuffle++;
						&_shuffle_;
					}
					else 
					{ 
						return (\@shuffledchanceres, \@shuffledchanceelms);
						say $tee "HIT. \$countshuffle: $countshuffle."; 
					}
				}
				my @result = _shuffle_;
				@shuffledchanceres = @{$result[0]}; 
				@shuffledchanceelms = @{$result[1]}; 
				say $tee "EXITING SHUFFLE WITH \@shuffledchanceres: @shuffledchanceres, \@shuffledchanceelms, @shuffledchanceelms";
				$lab{$countcase}{$countbuild}{$countchance}{case} = \@caserefs_alias; say $tee "dump(OUTBUILD\$lab{$countcase}{$countbuild}{$countchance}{case}): " . dump($lab{$countcase}{$countbuild}{$countchance}{case}); 
				my @thiscase = @{ $lab{$countcase}{$countbuild}{$countchance}{case} }; say $tee "dump(OUTBUILD\@thiscase): " . dump(@thiscase); 
				
				$lab{$countcase}{$countbuild}{$countchance}{chance} = \@chancerefs_alias; say $tee "dump(OUTBUILD\$lab{$countcase}{$countbuild}{$countchance}{chance}): " . dump($lab{$countcase}{$countbuild}{$countchance}{chance}); 
				my @thischance = @{ $lab{$countcase}{$countbuild}{$countchance}{chance} }; say $tee "dump(OUTBUILD\@thischance): " . dump(@thischance);
				say $tee "dump(OUTBUILD\%lab): " . dump(%lab);
				
				################################	
				#> HERE THE CODE FOLLOWS FOR THE CALCULATION OF HEURISTIC INDICATORS MEASURING THE EFFECTIVENESS OF A SEARCH STRUCTURE FOR SEARCH.
				
				my $countfirstline = 0;
				
				my ( $totalsize, $totaloverlapsize, $totalnetsize, $commonalityflow, $totalcommonalityflow, 
				$cumulativecommonalityflow, $localcommonalityflow, $addcommonalityflow, $remembercommonalityflow, 
				$cumulativecommonalityflow, $localrecombinationratio, $heritageleft, $heritagecentre, 
				$heritageright, $previousblock, $flatoverlapage, $rootexpoverlapage, $expoverlapage,
				$flatweightedoverlapage, $overlap, $iruif, $stdcommonality, $stdrecombination, $stdinformation, 
				$stdfatminus, $stdshadow, $localrecombinalityminusratio,
				$localrecombinalityratio, $localrenewalratio, $infminusflow, $cumulativeinfminusflow, $totalinfminusflow, $infflow,
				$cumulativeinfflow, $totalinfflow, $infoflow, $cumulativeinfoflow, $totalinfoflow,
				$refreshment, $refreshmentminus, $n_basketminus, $n_unionminus, $n_basket, $n_union,
				$recombination_ratio, $proportionhike, $iruifflow, $cumulativeiruif, $totaliruif,
				$commonalityflowproduct, $commonalityflowenhanced, $commonalityflowproductenhanced,
				$cumulativecommonalityflowproduct, $cumulativecommonalityflowenhanced, $cumulativecommonalityflowproductenhanced,
				$averageageexport, $cumulativeage, $refreshratio, $flowratio, $cumulativeflowratio, $flowageratio, 
				$cumulativeflowageratio, $shadowexport, $modiflow, $cumulativemodiflow, $cumulativehike, $cumulativerefreshment,
				$refreshmentperformance, $refreshmentsize, $cumulativerefreshmentperformance, $refreshmentvolume, $IRUIF, $mmIRUIF, $averageage,
				$otherIRUIF, $othermmIRUIF, $mmresult, $mmregen, $score, $sumnovelty,$urr,$IRUIFnovelty,$IRUIFurr,
				$IRUIFnoveltysquare,$IRUIFurrsquare,$IRUIFnoveltycube,$IRUIFurrcube );
				
				my ( @commonalities, @commonalitiespe, @recombinations, @informations, @localcommonances, @commonanceratios, 
				@groupminus, @unionminus, @group, @union, @basketminusnow, @unionminus, @basketnow, @union, @basketageexport,
				@basketlast, @newbasket, @valuebasket, @otherbasket, @basketcount, @finalbasket, @mmbasketresult, @mmbasketregen,
				@pastjump, @pastbunch, @resbunches, @scores );
				
				#>
				######################
				
				my $countblock = 0; 
				my $countblk = 0;
				my $countblockplus1 = 1;
				foreach my $blockref (@caserefs_alias)
				{
					say $tee "################################################################
					NOW DEALING WITH BLOCK $countblockplus1, \$countbuild $countbuild, \$countchance $countchance";
					my @blockelts = @{$blockref}; say $tee "dump(INBLOCKS\@blockelts): " . dump(@blockelts);
					my @presentblockelts = @blockelts;
					my $chanceref = $chancerefs_alias[$countblk]; say $tee "dump(INBLOCK\$chanceref): " . dump($chanceref);
					my @chanceelts = @{$chanceref}; say $tee "dump(INBLOCKS\@chanceelts): " . dump(@chanceelts);
					
					#############################################
					#>

					my $attachment = @blockelts[0]; say $tee "dump(INBLOCK1\$attachment): " . dump($attachment); ###BEWARE. THE VARIABLES @blockelts AND @pastblockelts IN THIS MODULE ARE NOT THE SAME USED IN Sim::OPT. 
					# ANALOGUES OF THE LATTER VARIABLES ARE HERE CALLED @presentslice AND @pastslice.
					my $activeblock = @blockelts[1]; say $tee "dump(INBLOCK1\$activeblock): " . dump($activeblock);
					my $zoneend = ( $numberof_variables - $activeblock ); say $tee "dump(INBLOCK1\$zoneend): " . dump($zoneend);
					my ( $pastattachment, $pastactiveblock, $pastzoneend );
					my $viewextent = $activeblock;	
					my ( @zoneoverlaps, @meanoverlaps, @zoneoverlapextent, @meanoverlapextent );
					my $countops = 1;
					my $counter = 0;
					while ($countops > 0)
					{
						my @pastblockelts = @{$blockrefs[$countblk - $countops]};
						if ($countblk == 0) { @pastblockelts = ""; }		
						$pastattachment = $pastblockelts[0]; say $tee "dump(INBLOCK1\$pastattachment): " . dump($pastattachment);
						$pastactiveblock = $pastblockelts[1]; say $tee "dump(INBLOCK1\$pastactiveblock): " . dump($pastactiveblock);
						$pastzoneend = ( $numberof_variables - $pastactiveblock ); say $tee "dump(INBLOCK1\$pastzoneend): " . dump($pastzoneend);
						my @presentslice = @chanceelts[ $attachment..($attachment+$activeblock-1) ]; say $tee "dump(INBLOCK1\@presentslice): " . dump(@presentslice);
						my @pastslice = @chanceelts[ $pastattachment..($pastattachment+$pastactiveblock-1) ]; say $tee "dump(INBLOCK1\@pastslice): " . dump(@pastslice);
						my $lc = List::Compare->new(\@presentslice, \@pastslice);
						my @intersection = $lc->get_intersection; say $tee "dump(INBLOCK1\@intersection): " . dump(@intersection);
						my $localoverlap = scalar(@intersection); say $tee "dump(INBLOCK1\$localoverlap): " . dump($localoverlap);
						push (@meanoverlapextent, $localoverlap); say $tee "dump(INBLOCK1\@meanoverlapextent): " . dump(@meanoverlapextent);
						my $overlapsum = 0;
						for ( @meanoverlapextent ) { $overlapsum += $_; }
						$overlap = $overlapsum ; say $tee "dump(INBLOCK1\$overlap): " . dump($overlap);
						if ($countblk == 0) { $overlap = 0; }
						$countops--;
						$counter++;
					}
				
					if ("yesgo" eq "yesgo")
					{
						my $countops = 2;
						my $counter = 0;
						my ( @zoneoverlaps, @meanoverlaps, @zoneoverlapextent, @meanoverlapextent, @basketminus );
						while ($countops > 1)
						{
							my @pastblockelts = @{$blockrefs[$countblk - $countops]}; say $tee "dump(INBLOCK2\@pastblockelts): " . dump(@pastblockelts);
							$pastattachment = $pastblockelts[0]; say $tee "dump(INBLOCK2\$pastattachment): " . dump($pastattachment);
							$pastactiveblock = $pastblockelts[1]; say $tee "dump(INBLOCK2\$pastactiveblock): " . dump($pastactiveblock);
							$pastzoneend = ( $numberof_variables - $pastactiveblock ); say $tee "dump(INBLOCK2\$pastzoneend): " . dump($pastzoneend);
							my @presentslice = @chanceelts[ $attachment..($attachment+$activeblock-1) ]; say $tee "dump(INBLOCK2\@presentslice): " . dump(@presentslice); 
							my @pastslice = @chanceelts[ $pastattachment..($pastattachment+$pastactiveblock-1) ]; say $tee "dump(INBLOCK2\@pastslice): " . dump(@pastslice);
							my $lc = List::Compare->new(\@presentslice, \@pastslice);
							my @intersection = $lc->get_intersection; say $tee "dump(INBLOCK2\@intersection): " . dump(@intersection);
							push (@basketminus, @intersection); say $tee "dump(INBLOCK2\@basketminus): " . dump(@basketminus);
							$stdfatminus = stddev(@basketminus);  say $tee "dump(INBLOCK2\$stdfatminus): $stdfatminus";
							my $localoverlap = scalar(@intersection); say $tee "dump(INBLOCK2\$localoverlap): " . dump($localoverlap);
							my $localoverlapextent = $localoverlap; say $tee "dump(INBLOCK2\$localoverlapextent): " . dump($localoverlapextent);
							push (@meanoverlapextent, $localoverlap); say $tee "dump(INBLOCK2\@meanoverlapextent): " . dump(@meanoverlapextent);
							my $overlapsum = 0;
							for ( @meanoverlapextent ) { $overlapsum += $_; }
							$overlapminus = ($overlapsum ); say $tee "dump(INBLOCK2\$overlapminus): " . dump($overlapminus);
							@basketminusnow = @basketminus;
							$countops--;
							$counter++;
						}
					}
					@unionminus = uniq(@basketminusnow); say $tee "ZONE2OUT: \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk:$countblk, \$countops: $countops, \$counter: $counter, \@unionminus: @unionminus\n";
					$n_basketminus = scalar(@basketminusnow); say $tee "dump(INBLOCK2\$n_basketminus): " . dump($n_basketminus);
					$n_unionminus = scalar (@unionminus); say $tee "dump(INBLOCK2\$n_unionminus): " . dump($n_unionminus);
					if ( $n_unionminus == 0) {$n_unionminus = 1;}; say $tee "dump(INBLOCK2-IFZERO\$n_unionminus): " . dump($n_unionminus);
					if ( $n_basketminus == 0) {$n_basketminus = 1;}; say $tee "dump(INBLOCK2-IFZERO\$n_basketminus): " . dump($n_basketminus);
					$refreshmentminus = ( ( $n_unionminus / $n_basketminus )  ); say $tee "dump(INBLOCK2\$refreshmentminus): $refreshmentminus";
					
					if ("yesgo" eq "yesgo")
					{
						my ( @zoneoverlaps, @meanoverlaps, @zoneoverlapextent, @meanoverlapextent, @zoneoverlapweightedextent, @meanoverlapweightedextent);
						my $countops = 1;
						my ( $flatoverlapsum, $expoverlapsum, $flatweightedoverlapsum, $expweightedoverlapsum, $averageage );
						my $counter = 0;
						my $countage = $numberof_variables;
						my ( @basket, @basketage, @freshbasket, @basketnow );
						while ($countops < $numberof_variables)
						{
							my @pastblockelts = @{$blockrefs[$countblk - $countops]}; say $tee "dump(INBLOCK3\@pastblockelts): " . dump(@pastblockelts);
							$pastattachment = $pastblockelts[0]; say $tee "dump(INBLOCK3\$pastattachment): " . dump($pastattachment);
							$pastactiveblock = $pastblockelts[1]; say $tee "dump(INBLOCK3\$pastactiveblock): " . dump($pastactiveblock);
							$pastzoneend = ( $numberof_variables - $pastactiveblock ); say $tee "dump(INBLOCK3\$pastzoneend): " . dump($pastzoneend);
							my @pastslice = @chanceelts[ $pastattachment..($pastattachment+$pastactiveblock-1) ]; say $tee "dump(INBLOCK3\@pastslice): " . dump(@pastslice); 
							#@pastslice = Sim::OPT::_clean_ (\@pastslice); say $tee "dump(INBLOCK3\@pastslice): " . dump(@pastslice);
							my @otherslice = @pastslice;
							
							foreach $int (@pastslice) 
							{ 
								if ($int) 
								{ 
									$int = "$int" . "-" . "$countops"; 
								} 
							}
							
							if ($countops <= $numberof_variables) 
							{ 
								push (@basket, @pastslice); 
							} 
							#@basket = Sim::OPT::_clean_ (\@basket); 
							@basket = sort { $a <=> $b } @basket;							
							say $tee "dump(INBLOCK3\@basket): " . dump(@basket);
							
							if ($countops <= $numberof_variables) 
							{
								 push (@otherbasket, @otherslice); 
							} 
							#@otherbasket = Sim::OPT::_clean_ (\@otherbasket); 
							@otherbasket = sort { $a <=> $b } @otherbasket;	
							say $tee "dump(INBLOCK3\@otherbasket): " . dump(@otherbasket);							
							
							@newbasket = @basket;							
							@basketnow = @newbasket; 
							@transferbasket = @basketnow;
							my @presentslice = @chanceelts[ $attachment..($attachment+$activeblock-1) ]; say $tee "dump(INBLOCK3\@presentslice): " . dump(@presentslice);
							@activeblk = @presentslice; say $tee "dump(INBLOCK3\@activeblk): " . dump(@activeblk);					
							$countops++;
							$counter++;
							$countage--;
						}
					} say $tee "ZONE3: \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk:$countblk, \$countops: $countops, \$counter: $counter, \$countage: $countage, \@transferbasket: @transferbasket\n";						

					my @integralslice = @shuffledchanceelms[ ($numberof_variables) .. (($numberof_variables * 2) - 1) ]; say $tee "AFTERZONE \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$numberof_variables: $numberof_variables, \@variables: @variables, \@shuffledchanceres: @shuffledchanceres, \@shuffledchanceelms: @shuffledchanceelms, \@integralslice-->: @integralslice";
					#my @integralslice = sort { $a <=> $b } @integralslice;
					my @valuebasket;
					foreach my $el (@integralslice)
					{
						my @freshbasket;
						foreach my $elm (@transferbasket)
						{
							my $elmo = $elm;
							$elmo =~ s/(.*)-(.*)/$1/;
							if ($el eq $elmo)
							{
								push (@freshbasket, $elm);
							}
						}
						@freshbasket = sort { $a <=> $b } @freshbasket; say $tee "AFTERZONE \@freshbasket: @freshbasket"; say $tee " \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk:$countblk";
						
						my $winelm = $freshbasket[0];
						push (@valuebasket,$winelm); say $tee "AFTERZONE \@valuebasket: @valuebasket"; say $tee "AFTERZONE \@freshbasket: @freshbasket"; say $tee "ZONE2OUT: \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk:$countblk";
						
						foreach my $elt (@integralslice)
						{	
							foreach my $elem (@valuebasket)
							{
								unless ($elem eq "")
								{
									my $elmo = $elem;
									$elmo =~ s/(.*)-(.*)/$1/;
									if ($elmo ~~ @integralslice)						
									{ 
										;
									}
									else 
									{
										if ($countblk > $$numberof_variables) { my $eltinsert = "$elmo" . "-" . "$numberof_variables"; }
										else {	my $eltinsert = "$elmo" . "-" . "$countblk";}
										push (@valuebasket, $eltinsert);
									} say $tee "AFTERZONE INTERMEDIATE \@valuebasket: @valuebasket";
								}
							}
						}
					} 
					@valuebasket = sort { $a <=> $b } @valuebasket;
					say $tee "AFTERZONE FINAL \@valuebasket: @valuebasket"; say $tee " \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk:$countblk";

					my $sumvalues = 0;
					my @finalbasket;
					foreach my $el (@valuebasket)
					{
						my $elmo = $el;
						$elmo =~ s/(.*)-(.*)/$2/;
						$sumvalues = $sumvalues + $elmo;
						push (@finalbasket, $elmo);
						
					} say $tee "POST AFTERZONE \@finalbasket: @finalbasket\n";
				
					my ( @presentblockelts, @pastblockelts, @presentslice, @pastslice, @intersection, @presentjump, @presentbunch, @resbunch 
					# @pastminusblockelts, @pastminusslice, @intersectionminus, 
					);
					
					if ($countblk > 1)
					{
						@pastblockelts = @{$blockrefs[$countblk - 1]}; say $tee "BEYOND1 @pastblockelts-->: @pastblockelts"; say $tee "AFTERZONE \@freshbasket: @freshbasket"; say $tee " \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk:$countblk";
						@pastminusblockelts = @{$blockrefs[$countblk - 2]}; say $tee "BEYOND1 @pastminusblockelts-->: @pastminusblockelts"; say $tee "AFTERZONE \@freshbasket: @freshbasket"; say $tee " \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk:$countblk";
# @presentblockelts = @{$blockrefs[$countblk]}; # THERE IS ALREADY: @blockelts;
						say $tee "BEYOND1 \@presentblockelts-->: @presentblockelts";
						$pastattachment = $pastblockelts[0]; say $tee "BEYOND1 \$pastattachment-->: $pastattachment";
						$pastactiveblock = $pastblockelts[1]; say $tee "BEYOND1 \$pastactiveblock: $pastactiveblock";
						$pastzoneend = ( $numberof_variables - $pastactiveblock ); say $tee "BEYOND1 \$pastzoneend-->: $pastzoneend";
						#my $pastminusattachment = $pastminusblockelts[0]; say $tee "BEYOND1 \$pastminusattachment-->: $pastminusattachment";############ ZZZZ UNNEEDED
						#my $pastminusactiveblock = $pastminusblockelts[1]; say $tee "BEYOND1 \$pastminusactiveblock $pastminusactiveblock";############ ZZZZ UNNEEDED
						#my $pastminuszoneend = ( $numberof_variables - $pastminusactiveblock ); say $tee "BEYOND1 \$pastminuszoneend-->: $pastminuszoneend";############ ZZZZ UNNEEDED
						@pastslice = @chanceelts[ $pastattachment..($pastattachment + $pastactiveblock-1) ]; say $tee "BEYOND1 \@pastslice-->: @pastslice";
						@pastslice = sort { $a <=> $b } @pastslice; say $tee "BEYOND1-ORDERED \@pastslice-->: @pastslice";
						#@pastminusslice = = @chanceelts[ $pastminusattachment..($pastminusattachment + $pastminusactiveblock-1) ]; say $tee "BEYOND1 \@pastsminuslice-->: @pastsminuslice";############ ZZZZ UNNEEDED
						#@pastsminuslice = sort { $a <=> $b } @pastminusslice; say $tee "BEYOND1-ORDERED \@pastsminuslice-->: @pastsminuslice";############ ZZZZ UNNEEDED
						@presentslice = @chanceelts[ $attachment..($attachment + $activeblock-1) ]; say $tee "BEYOND1 \@presentslice-->: @presentslice";
						@presentslice = sort { $a <=> $b } @presentslice; say $tee "BEYOND1-ORDERED \@presentslice-->: @presentslice";
						my $lc = List::Compare->new(\@presentslice, \@pastslice);
						@intersection = $lc->get_intersection; say $tee "dump(INBLOCK2\@intersection): " . dump(@intersection);
						#my $lc2 = List::Compare->new(\@pastslice, @pastminusslice);############ ZZZZ UNNEEDED
						#@intersectionminus = $lc2->get_intersection; say $tee "dump(INBLOCK2\@intersectionminus): " . dump(@intersectionminus);############ ZZZZ UNNEEDED
						
						my $counter = 0;
						foreach my $presentelm (@presentslice)
						{
							my $pastelm = $pastslice[$counter];
							my $joint = "$pastelm" . "-" . "$presentelm";
							push (@resbunch, $joint);
							$counter++;
						} 
						
						#@resbunch = Sim::OPT::_clean_ (\@resbunch); 
						say $tee "BEYOND AFTERCLEAN: \@resbunch: @resbunch";
						
						push (@resbunches, [@resbunch]); 
						
						#@resbunches = Sim::OPT::_clean_ (\@resbunches); 
						say $tee "BEYOND1 AFTERCLEAN  Dumper(\@resbunches:) " . Dumper(@resbunches) ;
						
						my @presentbunch = @{$resbunches[0]}; 
						#@presentbunch = Sim::OPT::_clean_ (\@presentbunch); 
						say $tee "BEYOND1 AFTERCLEAN: \@presentbunch: @presentbunch";
						
						my $countthis = 0;
						foreach my $elm (@resbunches)
						{
							unless ($countthis == 0)
							{
								my @pastbunch = @{$elm};
								my $lc = List::Compare->new(\@presentbunch, \@pastbunch);
								my @intersection = $lc->get_intersection; say $tee "BEYOND1 \@intersection: @intersection";
								
								push ( @scores, scalar(@intersection) ); say $tee "BEYOND1 INSIDE: \@scores @scores";
							}
							$countthis++;
						}
				
						#@scores = Sim::OPT::_clean_ (\@scores); 
						say $tee "BEYOND1 OUTSIDE AFTERCLEAN \@scores: @scores";
						
						$score = Sim::OPT::max(@scores); say $tee "BEYOND1 \$score: $score";
						my $newoccurrences = $activeblock - $score; say $tee "BEYOND1 \$newoccurrences: $newoccurrences";
						say $tee "BEYOND1 \$numberof_variables $numberof_variables\n"; 
						$novelty = $newoccurrences / $numberof_variables ; say $tee "BEYOND1 \$novelty: $novelty\n"; # NSM, Novelty of the Search Move 
						# my $novelty = ($steps ** $newoccurrences) / ($steps ** $numberof_variables ); #say $tee "BEYOND1  \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk: $countblk, \$novelty: $novelty\n"; # NSM, Novelty of the Search Move 
					}
					my ($averageage, $n1_averageage);
					if ($numberof_variables != 0)
					{
						$averageage = ( $sumvalues / $numberof_variables ); say $tee "BEYOND2 \$averageage: $averageage"; say $tee "AFTERZONE \@freshbasket: @freshbasket"; say $tee " \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk:$countblk";
					}
					else { print "IT WAS ZERO AT DENOMINATOR OF \$averageage.\n"; }
					
					if ($averageage != 0)
					{
						$n1_averageage = 1 / $averageage; say $tee "BEYOND  \$n1_averageage-->: $n1_averageage"; # FSW, Freshness of the Search Wake
					}
					
					my $urr = ($n1_averageage * $novelty); 
					# my $urr = ($n1_averageage * $sumnovelty ) ** ( 1 / 2 ); # ALTERNATIVE. 
					say $tee "BEYOND2 \$urr-->: $urr"; # URR, Usefulness of Recursive Recombination say $tee "AFTERZONE \@freshbasket: @freshbasket"; say $tee "ZONE2OUT: \$countcase: $countcase, \$countbuild: $countbuild, \$countchance: $countchance, \$countblk:$countblk";
				
					my $stddev = stddev(@finalbasket);
					if ($stddev == 0) {$stddev = 0.0001;}
					my $n1_stddev = 1 / $stddev;
					my $mix = $averageage * $stddev;
					
					if ($mix != 0)
					{
						$result = 1 / $mix; say $tee "BEYOND2 \$result-->: $result";
					}
					else { print "IT WAS ZERO AT DENOMINATOR OF \$mix."; }
					
					push (@mmbasketresult, $result); say $tee "BEYOND2 \@mmbasketresult-->: @mmbasketresult";
					$mmresult = mean(@mmbasketresult); say $tee "BEYOND2 \$mmresult-->: $mmresult";
					$regen = $n1_averageage; say $tee "BEYOND2 \$regen-->: $regen";
					push (@mmbasketregen, $regen); say $tee "BEYOND2  \@mmbasketregen-->: @mmbasketregen";
					$mmregen = mean(@mmbasketregen); say $tee "BEYOND2 \$mmregen-->: $mmregen\n";

					say $tee "sequence:$countcase,\$countblk:$countblk,\@valuebasket:@valuebasket,\@finalbasket:@finalbasket,averageage:$averageage,\$stddev:$stddev,\$mix:$mix,\$result:$result,\$mixsize:$mixsize,\$regen:$regen,\$score:$score,novelty:$novelty,\$urr-->: $urr\n\n";
					##################################################################################################################################################
					
					#say 
					#REPORTFILE 
					#$tee "sequence:$countcase,\$countblk:$countblk,\@valuebasket:@valuebasket,\@finalbasket:@finalbasket,averageage:$averageage,\$stddev:$stddev,\$mix:$mix,\$result:$result,\$mixsize:$mixsize,\$regen:$regen,\$score:$score,\$novelty:$novelty,\$urr-->: $urr\n\n";
					
					# END CALCULATION OF THE LOCAL SEARCH AGE.
					#################################################################################################################
					#################################################################################################################
					
					###my $steps = Sim::OPT::getstepsvar($elt, $countcase, \@varinumbers);

					$varsnum = ( $activeblock + $zoneend); say $tee "BEYOND3 \$varsnum: $varsnum";
					$limit = ($attachment + $activeblock + $zoneend); say "BEYOND \$limit: $limit";
					$countafter = 0;
					$counterrank = 0;
					$leftcounter = $attachment; say $tee "BEYOND3 \$leftcounter: $leftcounter";
					$rightcounter = ($attachment + $activeblock); say "BEYOND \$rightcounter: $rightcounter";
					
					say $tee "BEYOND3 dump(\@varinumbers): " . dump(@varinumbers);
					say $tee "BEYOND3 AFTER tempvarinumbers " . dump(@tempvarinumbers);
					
					$countfirstline = 0;
					
					if ($countblk > 0) { $antesize = Sim::OPT::givesize(\@pastslice, $countcase, \@varinumbers); } say $tee "BEYOND3 \$antesize: $antesize";
					
					$postsize = Sim::OPT::givesize(\@presentslice, $countcase, \@varinumbers); say $tee "BEYOND3 \$postsize: $postsize";
					$localsize = $postsize + $antesize; say $tee "BEYOND3 \$localsize: $localsize\n";
					
					if ($countblk == 0)  
					{
						$localsize = $postsize;
						$localsizeproduct = $postsize;
					}
					
					$localsizeproduct = $postsize * $antesize; say $tee "BEYOND3 \$localsizeproduct " . dump($localsizeproduct);
					
					$overlapsize =  Sim::OPT::givesize(\@intersection, $countcase, \@tempvarinumbers); say $tee "BEYOND3 \@intersection @intersection, \$overlapsize $overlapsize";
					###$overlapsize = ($steps ** $overlap); say $tee "BEYOND3 \$overlapsize $overlapsize";###DDD
					
					if ($overlap == 0) {$overlapsize = 1;} 
					
					#if ( ( $countcase == 0) and ($countblk == 0) )
					#{
					#	print 
					#	#OUTFILEWRITE #TABLETITLES
					#	$tee "\$countcase,\$countblk,\$attachment,\$activeblock,\$zoneend,\$pastattachment,\$pastactiveblock,\$pastzoneend,\$antesize,\$postsize,\$overlap,\$overlapsize,\$overlapminus,\$overlapminussize,\$overlapsum,\$overlapsumsize,\$localsize,\$localnetsize,\$totalsize,\$totaloverlapsize,\$totalnetsize,\$commonalityratio,\$commonality_volume,\$commonalityflow,\$recombinationflow,\$informationflow,\$cumulativecommonalityflow,\$cumulativerecombinationflow,\$cumulativeinformationflow,\$totalcommonalityflow,\$totalrecombinationflow,\$totalinformationflow,\$addcommonalityflow,\$addrecombinationflow,\$addinformationflow,\$recombinalityminusflow,\$cumulativerecombinalityminusflow,\$totalrecombinalityminusflow,\$recombinalityflow,\$cumulativerecombinalityflow,\$totalrecombinalityflow,\$renewalflow,\$cumulativerenewalflow,\$totalrenewalflow,\$infoflow,\$cumulativeinfoflow,\$totalinfoflow,\$refreshmentminus,\$recombination_ratio,\$proportionhike,\$hike,\$refreshment,\$infflow,\$cumulativeinfflow,\$totalinfflow,\$iruiflow,\$cumulativeiruif,\$totaliruif,\$averageageexport,\$cumulativeage,\$stdage,\$refreshratio,\$averageagesize,\$flowratio,\$cumulativeflowratio,\$flowageratio,\$cumulativeflowageratio,\$modiflow,\$cumulativemodiflow,\$refreshmentsize,\$refreshmentperformance,\$cumulativerefreshmentperformance,\$refreshmentvolume,\$IRUIF,\$mmIRUIF,\$IRUIFvolume,\$mmIRUIFvolume,\$hikefactor,\$otherIRUIF,\$othermmIRUIF,\$otherIRUIFvolume,\$othermmIRUIFvolume,\$averageage,\$steddev,\$mix,\$result,\$mixsize,\$regen,\$n1_averageage,\$n1_stddev,\$n1_averageagesize,\$mmresult,\$mmregen,\$novelty,\$urr,\$IRUIFnovelty,\$IRUIFurr,\$IRUIFnoveltysquare,\$IRUIFurrsquare,\$IRUIFnoveltycube,\$IRUIFurrcube"; 
					#}
					
					if  ($countblk == 0)
					{
						$antesize = 0;
						$overlap = 0;
						$overlapsize = 0;
						#$overlapminus = 0;  ############ ZZZZ UNNEEDED
						#$overlapminussize = 0;  ############ ZZZZ UNNEEDED
					}
					
					#if ($overlapminussize == 0) {$overlapminussize = 1;} ############ ZZZZ UNNEEDED
					if ($overlapsize == 0){$overlapsize = 1;}
					if ($totaloverlapsize == 0){$totaloverlapsize = 1;} ############ ZZZZ UNNEEDED?
					
					
					#$overlapminussize = Sim::OPT::givesize(\@intersectionminus, $countcase, \@varinumbers); say $tee "BEYOND3 \$overlapsize $overlapsize"; ############ ZZZZ UNNEEDED
					#$overlapminussize = ($steps ** $overlapminus); ############ ZZZZ UNNEEDED
					
					#if ($overlapminussize == 0){$overlapminussize = 1;}  ############ ZZZZ UNNEEDED
					#$overlapsum = ($overlapsize / $overlapminussize ); ############ ZZZZ UNNEEDED
					
					#$overlapsumsize = ($steps ** $overlapsum); ########## ZZZZ UNNEEDED
					
					
					#if ($countblk == 0) {$overlapsumsize = 1;}  ############ ZZZZ UNNEEDED
					
					$localnetsizeproduct = ( $localsizeproduct - $overlapsize );
					if ($localnetsizeproduct == 0) {$localnetsizeproduct = 1;}
					
					if ($totalsize == 0){$totalsize = 1;}
					
					$localnetsize = ( $localsize - $overlapsize ); # OK
					if ($localnetsize == 0) {$localnetsize = 1;}
					$totalsize = $totalsize + $postsize; # OK
					
					$totaloverlapsize = $totaloverlapsize + $overlapsize; #OK
					$totalnetsize = ($totalsize - $totaloverlapsize);  # OK
					if ($totalnetsize == 0) { $localcommonalityratio = 0; }
					
					#$refreshratio = $overlapsize/$overlapminussize; ############ ZZZZ UNNEEDED
					
					if  ($countblk == 0)
					{ 

						$localcommonalityratio = 1; #
						$localiruifratio = 1; # THIS IS THE COMMONALITY OF THE SHADOW AT TIME STEP - 2.
					}
					elsif ($countblk > 0) 
					{ 
						if ( ( ( $antesize * $postsize) ** (1/2)) != 0)
						{
							$localcommonalityratio = (  $overlapsize/ ( ( $antesize * $postsize) ** (1/2))); say $tee "BEYOND4 \$localcommonalityratio: $localcommonalityratio"; #OK
						}
						else { print $tee "IT WAS ZERO AT DENOMINATOR OF \$localcommonalityratio.\n"; }
						
						if ( ( ( $antesize * $postsize) ** (1/2)) != 0)
						{																		
							$localiruifratio = ( $overlapminussize / ( ( $antesize * $postsize) ** (1/2)) ); say $tee "BEYOND4 \$localiruifratio: $localiruifratio"; ############ ZZZZ UNNEEDED # THIS IS THE COMMONALITY OF THE SHADOW AT TIME STEP - 2.																																						
						}
						else { print $tee "IT WAS ZERO AT DENOMINATOR OF \$localiruifratio.\n"; }
					}

					if ($totalnetsize > 0) 
					{ 
						$commonalityratio = ( $totaloverlapsize / $totalnetsize ); #OK
					}
					$commonality_volume = ($totalnetsize * $commonalityratio); #OK
					
					if  ($countblk == 0)
					{ 
						$commonalityflow = $postsize  ** (1/3) ; #OK
						$iruiflow = $postsize ** (1/3) ; #OK
					}
					elsif ($countblk > 0)
					{
							$commonalityflow = (  $commonalityflow * $localcommonalityratio  * $postsize)  ** (1/3) ; say $tee "BEYOND4 \$commonalityflow: $commonalityflow"; #OK # CF, Commonality Flow 
							#$iruiflow = ( $iruifflow * (($localiruifratio * $postsize) ** (1/3))); ############ ZZZZ UNNEEDED 
					}	

					push (@commonalities, $commonalityflow);#
					$stdcommonality = stddev(@commonalities);#	
					$cumulativecommonalityflow = ($cumulativecommonalityflow + $commonalityflow ); say $tee "BEYOND4 \$cumulativecommonalityflow: $cumulativecommonalityflow"; #OK # CCF, Cumulative Commonality FLow
					$IRUIFurrsquare = $IRUIFurrsquare + ( $totalnetsize * ( ( $urr )  ** 2 ) ); say $tee "BEYOND4 \$totalnetsize $totalnetsize, \$urr $urr--->>> \$IRUIFurrsquare: $IRUIFurrsquare"; #OK # IRUIF, Indicator of Recursive Usefulness of the Information Flow				
					#$cumulativeiruif = ($cumulativeiruif + $iruifflow ); say $tee"BEYOND4 \$cumulativeiruif: $cumulativeiruif"; # ############ ZZZZ UNNEEDED 
					
					#if ($countblk == 0) { print OUTFILEWRITE "\n"; }
					
					#print OUTFILEWRITE "$countcase,$countblk,$attachment,$activeblock,$zoneend,$pastattachment,$pastactiveblock,$pastzoneend,$antesize,$postsize,$overlap,$overlapsize,$overlapminus,$overlapminussize,$overlapsum,$overlapsumsize,$localsize,$localnetsize,$totalsize,$totaloverlapsize,$totalnetsize,$commonalityratio,$commonality_volume,$commonalityflow,$recombinationflow,$informationflow,$cumulativecommonalityflow,$cumulativerecombinationflow,$cumulativeinformationflow,$totalcommonalityflow,$totalrecombinationflow,$totalinformationflow,$addcommonalityflow,$addrecombinationflow,$addinformationflow,$recombinalityminusflow,$cumulativerecombinalityminusflow,$totalrecombinalityminusflow,$recombinalityflow,$cumulativerecombinalityflow,$totalrecombinalityflow,$renewalflow,$cumulativerenewalflow,$totalrenewalflow,$infoflow,$cumulativeinfoflow,$totalinfoflow,$refreshmentminus,$recombination_ratio,$proportionhike,$hike,$refreshment,$infflow,$cumulativeinfflow,$totalinfflow,$iruiflow,$cumulativeiruif,$totaliruif,$averageageexport,$cumulativeage,$stdage,$refreshratio,$averageagesize,$flowratio,$cumulativeflowratio,$flowageratio,$cumulativeflowageratio,$modiflow,$cumulativemodiflow,$refreshmentsize,$refreshmentperformance,$cumulativerefreshmentperformance,$refreshmentvolume,$IRUIF,$mmIRUIF,$IRUIFvolume,$mmIRUIFvolume,$hikefactor,$otherIRUIF,$othermmIRUIF,$otherIRUIFvolume,$othermmIRUIFvolume,$averageage,$steddev,$mix,$result,$mixsize,$regen,$n1_averageage,$n1_stddev,$n1_averageagesize,$mmresult,$mmregen,$novelty,$urr,$IRUIFnovelty,$IRUIFurr,$IRUIFnoveltysquare,$IRUIFurrsquare,$IRUIFnoveltycube,$IRUIFurrcube\n"; 
					say $tee "RESULPLOT: \$countcase:$countcase,\$countblk:$countblk,\$countbuild:$countbuild,\$countchance:$countchance,\$attachment:$attachment,
					\$activeblock:$activeblock,\$zoneend:$zoneend,\$pastattachment:$pastattachment,\$pastactiveblock:$pastactiveblock,\$pastzoneend:$pastzoneend,
					\$antesize:$antesize,\$postsize:$postsize,\$overlap:$overlap,\$overlapsize:$overlapsize,\$overlapminus:$overlapminus,
					\$overlapminussize:$overlapminussize,\$overlapsum:$overlapsum,\$overlapsumsize:$overlapsumsize,\$localsize:$localsize,
					\$localnetsize:$localnetsize,\$totalsize:$totalsize,\$totaloverlapsize:$totaloverlapsize,\$totalnetsize:$totalnetsize,
					\$commonalityratio:$commonalityratio,\$commonality_volume:$commonality_volume,\$commonalityflow:$commonalityflow,
					\$cumulativecommonalityflow:$cumulativecommonalityflow,\$n1_averageage:$n1_averageage,\$novelty:$novelty,\$urr:$urr,
					\$IRUIFurrsquare:$IRUIFurrsquare,\$cumulativeiruif:$cumulativeiruif"; 
					
					$res{$countcase}{$countbuild}{$countchance}{$countblk}{IRUIF} = $IRUIFurrsquare;
					$res{$countcase}{$countbuild}{$countchance}{$countblk}{commonality} = $cumulativecommonalityflow;
					$res{$countcase}{$countbuild}{$countchance}{$countblk}{novelty} = $novelty;
					$res{$countcase}{$countbuild}{$countchance}{$countblk}{totalnetsize} = $totalnetsize;
					$res{$countcase}{$countbuild}{$countchance}{$countblk}{freshness} = $n1_averageage;
					$res{$countcase}{$countbuild}{$countchance}{$countblk}{urr} = $urr;
					$res{$countcase}{$countbuild}{$countchance}{$countblk}{newblockrefs} = \@caserefs_alias;
					$res{$countcase}{$countbuild}{$countchance}{$countblk}{newchance} = \@chancerefs_alias;
					
					#>
					####################################################
					
					#print TEST "\$countchance,$countchance,\$countbuild,$countbuild,\$countblockplus1,$countblockplus1,\$countblk,$countblk,\$countcase,$countcase,\$IRUIFurrsquare,$IRUIFurrsquare\n";

					$countblk++;
					$countblock++;
					$countblockplus1++;
				}
				
				$countchance++;
			}
			
			say "I'M IN";
			sub getmax
			{
				my @IRUIFcontainer;
				my $countc = 1;
				while ( $countc <= $dimchance )
				{
					push (@IRUIFcontainer, $res{$countcase}{$countbuild}{$countc}{$#caserefs_alias}{IRUIF}); say $tee "POST-IN\@IRUIFcontainer " . dump(@IRUIFcontainer);
					$countc++;
				}
				my $maxvalue = Sim::OPT::max(@IRUIFcontainer); say $tee "POST-IN\$maxvalue " . dump($maxvalue);
				return ($maxvalue);
			}
			my $maxvalue = getmax; say $tee "POST-OUT\$maxvalue " . dump($maxvalue);
			
			sub pick
			{
				my $maxvalue = shift;
				my ($beststruct, $bestchance);
				my $countc = 1;
				while ( $countc <= $dimchance )
				{
					say $tee "POST-IN2\$maxvalue " . dump($maxvalue);
					say $tee "POST-IN2\$res{\$countcase}{\$countbuild}{\$countc}{ \$#caserefs_alias } " . dump($res{$countcase}{$countbuild}{$countc}{ $#caserefs_alias });
					if( $res{$countcase}{$countbuild}{$countc}{ $#caserefs_alias }{IRUIF} == $maxvalue )
					{
						$beststruct = $res{$countcase}{$countbuild}{$countc}{ $#caserefs_alias }{newblockrefs}; say $tee "FOUND-INWHILE\$beststruct " . dump($beststruct);
						$bestchance = $res{$countcase}{$countbuild}{$countc}{ $#caserefs_alias }{newchance}; say $tee "FOUND-INWHILE\$bestchance " . dump($bestchance);
						last;
					}
					$countc++;
				}
				return ($beststruct, $bestchance);
			}
			my @arr = pick($maxvalue);
			$beststruct = $arr[0]; say $tee "OUTWHILE\$beststruct " . dump($beststruct); 
			$bestchance = $arr[1]; say $tee "OUTWHILE\$bestchance " . dump($bestchance); 

			
			say $tee "PRE\@blockrefs " . dump(@blockrefs);
			@blockrefs = @$beststruct; say $tee "POST\@blockrefs " . dump(@blockrefs); 
			say $tee "PRE\@chancerefs " . dump(@chancerefs); 
			@chancerefs = @$bestchance; say $tee "POST\@chancerefs " . dump(@chancerefs); 
			say $tee "\$res " . dump(%res);
			$chanceseed_[$countcase] = $bestchance; say $tee "POST\@chanceseed_ " . Dumper(@chanceseed_); 
			$caseseed_[$countcase] = $beststruct; say $tee "POST\@caseseed_ " . Dumper(@caseseed_); 
			@sweeps_ = Sim::OPT::fromopt_tosweep( casegroup => \@caseseed_, chancegroup => \@chanceseed_ ); say $tee "POST\@sweeps_ " . Dumper(@sweeps_);
			close TEST;
			close CASEFILE_PROV;
			close CHANCEFILE_PROV;
			
			$countbuild++;
		}
		$countcase++;		
	}
	return (\@sweeps_, \@caseseed_, \@chanceseed_ );
}

1;

=head1 NAME

Sim::OPT::Takechance.

=head1 SYNOPSIS

  use Sim::OPT::Takechance;
  takechance your_configuration_file.pl;

=head1 DESCRIPTION

The "Sim::OPT::Takechance" module can produce efficient search structures for block coordinate descent given some initialization blocks (subspaces).  Its strategy is based on making a search path more efficient than the average randomly chosen ones, by selecting the search moves so that (a) the search wake is fresher than the average random ones and (b) the search moves are more novel than the average random ones. The rationale for the selection of the seach path is explained in detail (with algorithms) in my paper at the following web address: http://arxiv.org/abs/1407.5615 .

"Sim::OPT::Takechance" can be called from Sim::OPT or directly from the command line (after issuing < re.pl > and < use Sim::OPT::Takechance >) with the command < takechance your_configuration_file.pl >.

The variables to be taken into account to describe the initialization blocks of a search in the configuration file are "@chanceseed" (representing the sequence of design variables at each search step) and "@caseseed" (representing the sequence of decompositions to be taken into account). How "@chanceseed" and "@caseseed" should be specified is more quickly described with a couple of examples. 

(In place of the "@chaceseed" and "@caseseed" variables, a "@sweepseed" variable can be specified, written with the same criteria of the variable "@sweeps" described in the documentation of the "Sim::OPT" module; but this possibility has not been throughly tested yet.)

1) If brute force optimization is sought for a case composed by 4 parameters, the following settings should be specified: <@chanceseed = ([1, 2, 3, 4]);> and <@caseseed = ( [ [0, 4] ] ) ;>.

2) If optimization is sought for two cases (brute force, again, for instance, with a different and overlapping set of 5 parameters for the two of them), the two sets of parameters in questions has to be specificied as sublists of the general parameter list: <@chanceseed = ([1, 2, 3, 4, 6, 7, 8], [1, 2, 3, 4, 6, 7, 8]);> and <@caseseed = ( [ [0, 5] , [3, 8] ] ) ;>.

3) If a block search is sought on the basis of 5 parameters, with 4 overlapping active blocks composed by 3 parameters each having the leftmost parameters in position 0, 1, 2 and 4, and two search sweeps are to be performed, with the second sweep having the parameters in inverted order and the leftmost parameters in position 2, 4, 3 and 1, the following settings should be specified: <@chanceseed = ( [ [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [5, 4, 3, 2, 1], [5, 4, 3, 2, 1], [5, 4, 3, 2, 1], [5, 4, 3, 2, 1]] );> and <@caseseed = ( [ [0, 3], [1, 3], [2, 3], [4, 3] ], [2, 3], [4, 3], [3, 3], [1, 3] ] );>.

4) By playing with the order of the parameters' sequence, blocks with non-contiguous parameters can be specified. Example: <@chanceseed = ( [ [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [5, 2, 4, 1, 3], [2, 4, 1, 5, 2], [5, 1, 4, 2, 3], [5, 1, 4, 2, 3] ] );> and <@caseseed = ( [ [0, 3], [1, 3], [2, 3], [4, 3] ], [2, 3], [4, 3], [3, 3], [1, 3] ] );>.

5) The initialization blocks can be of different size. Example: <@chanceseed = ( [ [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [5, 2, 4, 1, 3], [2, 4, 1, 5, 2], [5, 1, 4, 2, 3], [5, 1, 4, 2, 3] ] );> and <@caseseed = ( [ [0, 3], [1, 3], [2, 3], [4, 3] ], [2, 2], [4, 2], [3, 4], [1, 4] ] );>.

Other variables which are necessary to describe the operations to be performed by the "Sim::OPT::Takechance" module are "@chancedata", "$dimchance", "@pars_tocheck" and "@varinumbers".

"@chancedata" is composed by references to arrays (one for each search path to be taken into account, as in all the other cases), each of which composed by three values: the first specifying the length (how many variables) of the blocks to be added; the second specifying the length of the overlap between blocks; the third specifying the number of sweeps to be added. For example, the setting < @chancedata = ([4, 3, 2]); > implies that the blocks to be added to the search path are each 4 parameters long, have each an overlap of 3 parameters with the immediately preceding block, and are 2 in number - that is, 2 sweeps (blocks, seach blocks, subspaces) have to be added to the search path.

"$dimchance" tells the program among how many random samples the blocks to be added to the search path have to be chosen. The higher the value, the most efficient the search structure will turn out to be, the higher the required computation time will be. High values are likely to be required by large search structures.

"@varinumbers" is a variable which is in common with the Sim::OPT module. It specifies the number of iterations to be taken into account for each parameter and each search case. For example, to specifiy that the parameters of a search structure (one case) involving 5 parameters (numbered from 1 to 5) are to be tried for 3 values (iterations) each, "@varinumbers" has to be set to "( { 1 => 3, 2 => 3, 3 => 3, 4 => 3, 5 => 3 } )".

"@pars_tocheck" is a variable in which the parameter numbers to be taken into account in the creation of the added search path have to be listed. If it is not defined, all the available parameters are used.

The response produced by the "Sim::OPT::Takechance" module will be written in a long-name file in the work folder: "./search_structure_that_may_be_adopted.txt".

Gian Luca Brunetti, Politecnico di Milano
gianluca.brunetti@polimi.it

=head2 EXPORT

"takechance".

=head1 SEE ALSO

The available examples are collected in the "example" directory in this distribution.

=head1 AUTHOR

Gian Luca Brunetti, E<lt>gianluca.brunetti@polimi.itE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014-2015 by Gian Luca Brunetti and Politecnico di Milano. This is free software.  You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 or later.


=cut
