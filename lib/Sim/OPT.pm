package Sim::OPT;
# Copyright (C) 2008-2014 by Gian Luca Brunetti and Politecnico di Milano.
# This is Sim::OPT, a program for detailed metadesign managing parametric explorations through the ESP-r building performance simulation platform and performing optimization by block coordinate descent.
# This is free software.  You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.

use v5.14;
use Exporter;
use parent 'Exporter'; # imports and subclasses Exporter

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
#use experimental 'postderef';
#use Sub::Signatures;
use feature 'say';    

# use feature qw(postderef); 
#no warnings qw(experimental::postderef);
#no strict 'refs';
no strict; 
no warnings;

use Sim::OPT::Morph;
use Sim::OPT::Sim;
use Sim::OPT::Retrieve;
use Sim::OPT::Report;
use Sim::OPT::Descend;
#use Sim::OPT::Pursue;

our @ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( 
opt odd even _mean_ flattenvariables count_variables fromopt_tosweep fromsweep_toopt convcaseseed 
convchanceseed makeflatvarnsnum calcoverlaps calcmiditers getitersnum definerootcases
callcase callblocks deffiles makefilename extractcase setlaunch exe start
_clean_ getblocks getblockelts getrootname definerootcases populatewinners 
getitem getline getlines getcase getstepsvar 
$mypath $exeonfiles $generatechance $file $preventsim $fileconfig $outfile $toshell $report 
$simnetwork $reportloadsdata @themereports @simtitles @reporttitles @simdata @retrievedata 
@keepcolumns @weights @weightsaim @varthemes_report @varthemes_variations @varthemes_steps 
@rankdata @rankcolumn @reporttempsdata @reportcomfortdata @reportradiationenteringdata 
@reporttempsstats @files_to_filter @filter_reports @base_columns @maketabledata @filter_columns
@files_to_filter @filter_reports @base_columns @maketabledata @filter_columns
); # our @EXPORT = qw( );


our ( $mypath, $exeonfiles, $generatechance, $file, $preventsim, $fileconfig, $outfile, $toshell, $report, 
$simnetwork, $reportloadsdata, @themereports, @simtitles, @reporttitles, @simdata, @retrievedata, 
@keepcolumns, @weights, @weightsaim, @varthemes_report, @varthemes_variations, @varthemes_steps, 
@rankdata, @rankcolumn, @reporttempsdata, @reportcomfortdata, @reportradiationenteringdata, 
@reporttempsstats, @files_to_filter, @filter_reports, @base_columns, @maketabledata, @filter_columns, 
@files_to_filter, @filter_reports, @base_columns, @maketabledata, @filter_columns );

$VERSION = '0.39.3_01'; # our $VERSION = '';
$ABSTRACT = 'Sim::OPT it a tool for detailed metadesign. It manages parametric explorations through the ESP-r building performance simulation platform and performs optimization by block coordinate descent.';

#################################################################################
# Sim::OPT 
#################################################################################

# FUNCTIONS' SPACE
###########################################################
###########################################################

sub odd 
{
    my $number = shift;
    return !even ($number);
}

sub even 
{
    my $number = abs shift;
    return 1 if $number == 0;
    return odd ($number - 1);
}

sub _mean_ { return @_ ? sum(@_) / @_ : 0 }


sub countarray
{
	$c = 1;
	foreach (@_)
	{
		foreach (@$_)
		{
			$c++;
		}
	}
	return ($c);
}

sub _clean_
{ # IT CLEANS A BASKET FROM CASES LIKE "-", "1-", "-1", "".
	my $swap = shift;
	my @arraytoclean = @$swap;
	my @storeinfo;
	foreach (@arraytoclean) 
	{ 
		$_ =~ s/ //;
		unless ( !( defined $_) or ($_ =~ /^-/) or ($_ =~ /-$/) or ($_ =~ /^-$/) or ($_ eq "") or ($_ eq "-") )
		{
			push(@storeinfo, $_)
		}
	}
	return  @storeinfo; # HOW TO CALL THIS FUNCTION: clean(\@arraytoclean). IT IS DESTRUCTIVE.
}

sub flattenvariables # IT LISTS THE NUMBER OF VARIABLES PLAY IN A LIST OF BLOCK SEARCHES. ONE COUNT FOR EACH LIST ELEMENT.
{		
	my @array = @_;
	foreach my $case (@array)
	{
		@casederef = @$case;
		my @basket;
		foreach my $block (@casederef)
		{
			@blockelts = @$block;
			push (@basket, @blockelts);
		}
		my @basket = sort { $a <=> $b} uniq(@basket);
		push ( @flatvarns, \@basket ); ###
		# IT HAS TO BE CALLED WITH: flatten_variables(@treeseed);
	} # say "\@NUMVARNS!: " . dump(@numvarns);
}

sub count_variables # IT COUNTS THE FLATTENED VARIABLES
{
	my @flatvarns = @_;
	foreach my $group (@flatvarns)
	{
		my @array = @$group;
		push ( @flatvarnsnum, scalar(@array) );
		# IT HAS TO BE CALLED WITH: count_variables(@flatvarns);
	}
}

# flatten_variables ( [ [1, 2, 3] , [2, 3, 4] , [3, 4, 5] ], [ [1, 2], [2, 3] ] );
#count_variables ([1, 2, 3, 4, 5], [1, 2, 3]);
#say "COUNTFLATTENEDVARNS: @countflattenedvarns";

sub fromopt_tosweep # IT CONVERTS A TREE BLOCK SEARCH FORMAT IN THE ORIGINAL OPT'S BLOCKS SEARCH FORMAT.
{
	my %thishash = @_; #say "dump(%thishash): " . dump(%thishash);
	my $casegroupref = $thishash{casegroup};
	my @casegroup = @$casegroupref; #say "dump(\@casegroup): " . dump(@casegroup);
	my $chancegroupref = $thishash{chancegroup};
	my @chancegroup = @$chancegroupref; #say "dump(\@chancegroup): " . dump(@chancegroup);
	my $countcase = 0;
	foreach my $case (@casegroup)
	{
		my @blocks = @$case; #say "dump(\@blocks): " . dump(@blocks);
		my $chancesref = $chancegroup[$countcase];
		my @chances = @$chancesref; #say "dump(\@chances): " . dump(@chances);
		my $countblock = 0;
		foreach my $elt (@blocks)
		{
			my @blockelts = @$elt; #say "dump(\@blockelts): " . dump(@blockelts);
			my $attachpoint = $blockelts[0]; #say "attachpoint: $attachpoint";
			my $blocklength = $blockelts[1]; #say "blocklength: $blocklength";
			my $chancesref = $chances[$countblock]; # say "dump(\$chancesref): " . dump($chancesref);
			my @chances = @$chancesref; #say "dump(\@chances): " . dump(@chances);
			my @sweepblock = @chances[ $attachpoint .. ($attachpoint + $blocklength - 1) ];	#say "dump(\@sweepblock): " . dump(@sweepblock);
			push (@sweepblocks, [@sweepblock]);
		}
		push (@sweeps, [ @sweepblocks ] );
	}	
	# IT HAS TO BE CALLED THIS WAY: fromopt_tosweep(%hash); WHERE: %hash = ( casegroup => [@caseseed], chancegroup => [@chanceseed] );
}

sub fromsweep_toopt # IT CONVERTS THE ORIGINAL OPT'S BLOCKS SEARCH FORMAT IN A TREE BLOCK SEARCH FORMAT.
{
	my $countcase = 0;
	my @bucket;
	my @secondbucket;
	foreach (@_) # CASES
	{
		my @blocks;
		my @chances;
		my $countblock = 0;
		foreach(@$_) # BLOCKS
		{
			#say "dump(\@\$_): " . dump(@$_);
			my $swap = $flatvarns[$countcase];
			my @varns = @$swap; #say "dump(\@varns): " . dump(@varns);
			my @block = @$_;
			my $blocksize = scalar(@block);
			my $lc = List::Compare->new(\@varns, \@block);
			my @intersection = $lc->get_intersection; #say "dump(\@intersection): " . dump(@intersection);
			my @nonbelonging;
			foreach (@varns)
			{
				my @parlist;
				unless ($_ ~~ @intersection)
				{
					push (@nonbelonging, $_);
				}
			}
			#say "dump(\@nonbelonging): " . dump(@nonbelonging);
			push (@blocks, [@intersection, @nonbelonging] ); # say "dump(\@blocks): " . dump(@blocks);
			push (@chances, [0, $blocksize] );
			$countblock++;
		}
		push (@bucket, [ @blocks ] );
		push (@secondbucket, [@chances]);
		$countcase++;
	}
	@chanceseed = @bucket;
	@caseseed = @secondbucket;
	# IT HAS TO BE CALLED THIS WAY: fromsweep_toopt(@sweep);
}

sub convcaseseed # IT ADEQUATES THE POINT OF ATTACHMENT OF EACH BLOCK TO THE FACT THAT THE LISTS CONSTITUING THEM ARE THREE, JOINED.
{
	my $countcase = 0;
	foreach $case (@caseseed)
	{
		my @blockrfs = @$case;
		foreach (@blockrfs)
		{
			@{$_}[0] = @{$_}[0] + $flatvarnsnum[$countcase];
		}
		$countcase++;
	} # TO BE CALLED WITH: convcaseseed. @caseseed IS globsAL.
}

sub convchanceseed # IT EXTENDS @chancegroup BY JOINING EACH PARAMETERS SEQUENCE WITH TWO COPIES OF ITSELF, TO IMITATE CIRCULAR LISTS.
{
	foreach (@chanceseed)
	{
		foreach (@$_)
		{
			push (@$_, @$_, @$_);
		}
	} # IT ACTS ON @chanceseed, WHICH IS globsAL.
}

sub makeflatvarnsnum # IT COUNTS HOW MANY PARAMETERS THERE ARE IN A SEARCH STRUCTURE,
{
	foreach (@_)
	{
		my @basket;
		foreach (@$_)
		{
			my @block = @$_; #say "\@blockkkkk: @block";
			push (@basket, @block); #say "\@basket1: @basket";
		}
		@basket = uniq(@basket); #say "\@basket2: @basket";
		push ( @flatvarnsnum, scalar ( @basket ) ); #say "\@flatvarnsnum: @flatvarnsnum";
	} # IT ACTS ON @chanceseed, WHICH IS globsAL.
}

sub calcoverlaps
{
	my $countcase = 0;
	foreach my $case(@sweeps)
	{
		my @caseelts = @{$case};
		my $contblock = 0;
		my @overlaps;
		foreach my $block (@caseelts)
		{
			my @pasttblock = @{$block[ $contblock - 1 ]};
			my @presentblock = @{$block[ $contblock ]};
			my $lc = List::Compare->new(\@pasttblock, \@presentblock);
			my @intersection = $lc->get_intersection; #say "dump(\@intersection): " . dump(@intersection);
			push (@caseoverlaps, [ @intersection ] );
			$countblock++;
		}
		push (@casesoverlaps, [@overlaps]); # globsAL!
		$countcase++;
	}
}

sub calcmiditers
{
	my @varinumbers = @_;
	my $countcase = 0;
	foreach (@varinumbers)
	{
		my $countblock = 0;
		foreach (keys %$_)
		{
			#say "inner dump (\$_): " . dump ($_);
			#say "dumpalias (\$varinumbers[\$countcase]{\$_}): " . dump ($varinumbers[$countcase]{$_});
			unless (defined $miditers[$countcase]{$_})
			{
				#say "dump (\$miditers[\$countcase][\$countblock]{\$_}): " . dump ($miditers[$countcase][$countblock]{$_}); 
				$miditers[$countcase]{$_} = ( round($varinumbers[$countcase]{$_}/2) );
			}
		}
		$countcase++;
	}
}
	
sub getitersnum
{ # IT GETS THE NUMBER OF ITERATION. UNUSED. CUT
	my $countcase = shift;
	my $varinumber = shift;
	my @varinumbers = @_;
	my $itersnum = $varinumbers[$countcase]{$varinumber};
	#say "\$itersnum IN = $itersnum";
	return $itersnum;
	# IT HAS TO BE CALLED WITH getitersnum($countcase, $varinumber, @varinumbers);
}

sub makefilename # IT DEFINES A FILE NAME GIVEN A %carrier.
{
	my %carrier = @_;
	my $filename = "$mypath/$filenew";
	my $countcase = 0;
	foreach $key (sort {$a <=> $b} (keys %carrier) )
	{
		$filename = $filename . $key . "-" . $carrier{$key} . "_"; #say "filename: $filename";
	} 
	return ($filename); # IT HAS TO BE CALLED WITH: makefilename(%carrier);
}

sub getblocks
{ # IT GETS @blocks. TO BE CALLED WITH getblocks(\@sweeps, $countcase)
	my $swap = shift; 
	my @sweeps = @$swap;
	my $countcase = shift;
	my @blocks = @{ $sweeps[$countcase]};
	return (@blocks);
}

#@blocks = getblocks(\@sweeps, 0);  say "dumpA( \@blocks) " . dump(@blocks);

sub getblockelts
{ # IT GETS @blockelts. TO BE CALLED WITH getblockelts(\@sweeps, $countcase, $countblock)
	my $swap = shift;
	my @sweeps = @$swap;
	my $countcase = shift;
	my $countblock = shift;
	my @blockelts = sort { $a <=> $b } @{ $sweeps[$countcase][$countblock] };
	return (@blockelts);
}

sub getrootname
{
	my $swap = shift;
	my @rootnames = @$swap;
	my $countcase = shift;
	my $rootname = $rootnames[$countcase];
	return ($rootname);
}

sub extractcase # IT EXTRACTS THE ITEMS TO BE CHANCED FROM A  %carrier, UPDATES THE FILE NAME AND CREATES THE NEW ITEM'S CARRIER
{
	my $file = shift; #say "file: $file";
	my $carrierref = shift; #say "\$carrierref: " . dump($carrierref);
	my @carrierarray = %$carrierref; #say "\@carrierarray: " .  dump(@carrierarray);
	my %carrier = %$carrierref;  #say "\%carrier: " . dump(%carrier);
	my $num = ( scalar(@carrierarray) / 2 ); #say "\$num: $num";
	my $transfile = $file;
	$transfile = "_" . "$transfile";
	my $counter = 0;
	my %provhash;
	while ($counter < $num)
	{	#say "\$counter: $counter";
		$transfile =~ /_(\d+)-(\d+)_/; #say "\$1: $1, \$2: $2"; #say "\$transfileBEFORE: $transfile";
		if ( ($1) and ($2) )
		{
			$provhash{$1} = "$2"; 
		}
		$transfile =~ s/$1-$2//; #say "\$transfileAFTER: $transfile";
		$counter++;
	} #say "provhash: " . dump(%provhash);
	foreach my $key (keys %provhash)
	{
		$carrier{$key} = $provhash{$key}; #say "carrier: " . dump(%carrier);
	}
	my $to = makefilename(%carrier); # say "\$to: $to"; say "carrier: " . dump(%carrier);
	return($to, \%carrier); # IT HAS TO BE CALLED WITH: extractcase("$string", \%carrier), WHERE STRING IS A PIECE OF FILENAME WITH PARAMETERS.
}

sub definerootcases #### DEFINES THE ROOT-CASE'S NAME.
{
	my @sweeps = @{ $_[0] }; #say "dump( \@sweeps) PRE: " . dump(@sweeps); 
	my @miditers = @{ $_[1] }; #say "dump( \@miditers) PRE: " . dump(@miditers); 
	my @rootnames;
	my $countcase = 0;
	foreach my $sweep (@sweeps)
	{
		my $case = $miditers[$countcase];
		my %casetopass;
		my $rootname;
		foreach $key (sort {$a <=> $b} (keys %$case) )
		{
			$casetopass{$key} = $miditers[$countcase]{$key};
		}
		foreach $key (sort {$a <=> $b} (keys %$case) )
		{
			$rootname = $rootname . $key . "-" . $miditers[$countcase]{$key} . "_";
		}
		$rootname = $filenew . $rootname; 
		$casetopass{rootname} = $rootname;
		chomp $rootname;
		push ( @rootnames, $rootname);
		$countcase++;
	}
	
	return (@rootnames); # IT HAS TO BE CALLED WITH: definerootcase(@miditers).
}

sub populatewinners
{
	my $countcase = 0;
	foreach $case (@rootnames)
	{
		push ( @{ $winneritems[$countcase] }, $case ); #globsAL
		$countcase++;
	}
	return(@winneritems);
}

sub getitem
{ # IT GETS THE WINNER OR LOSER LINE. To be called with getitems(\@winner_or_loser_lines, $countcase)
	my $swap = shift;
	my @items = @$swap;
	my $countcase = shift;
	my $item = $items[$countcase][0];
	return ($item);
}
	
sub getline
{
	my $item = shift;
	my $file = "$mypath/" . "$item";
	return ($file);
}

sub getlines
{
	my $swap = shift;
	my @items = @$swap;
	my @arr;
	my $countcase = 0;
	foreach (@items)
	{
		foreach ( @{ $_ } )
		{
			push ( @{ $arr[$countcase] } , getline($_) );
		}
		$countcase++;
	}
	return (@arr);
}


sub getcase
{
	my $swap = shift;
	my @items = @$swap;
	my $countcase = shift;
	my $itemref = $items[$countcase];
	my %item = %{ $itemref };
	return ( %item );
}

sub getstepsvar
{ 	# IT EXTRACTS $stepsvar
	my $countvar = shift;
	my $countcase = shift;
	my $swap = shift;
	my @varinumbers = @$swap; 
	my $varnumsref = $varinumbers[ $countcase ]; 
	my %varnums = %{ $varnumsref };
	my $stepsvar = $varnums{$countvar};
	return ($stepsvar)
} #getstepsvar($countvar, $countcase, \@varinumbers);

sub callcase # IT PROCESSES THE CASES.
{
	my $swap = shift;
	my %dat = %{$swap};
	my @rootnames = @{ $dat{rootnames} }; #say \"dump(\@rootnames): " . dump(@rootnames);
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase);
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock);
	my @sweeps = @{ $dat{sweeps} }; #say "dump(\@sweeps): " . dump(@sweeps);
	my @varinumbers = @{ $dat{varinumbers} }; #say "dump(\@varinumbers): " . dump(@varinumbers);
	my @miditers = @{ $dat{miditers} }; #say "dump(\@miditers): " . dump(@miditers); # IT BECOMES THE CARRIER. INITIALIZED AT FIRST BLOCKS; INHERITED AFTER.
	my @winneritems = @{ $dat{winneritems} }; #say "dumpIN( \@winneritems) " . dump(@winneritems);
	my @morphcases = @{ $dat{morphcases} }; #say "dumpIN( \@morphcases) " . dump(@morphcases);
	my @morphstruct = @{ $dat{morphstruct} }; #say "dumpIN( \@morphstruct) " . dump(@morphstruct);
	my %vals = %{ $dat{ vals} };
	#eval($getparshere);
	
	my $rootname = getrootname(\@rootnames, $countcase); #say "dump(\$rootname): " . dump($rootname);
	my @blockelts = getblockelts(\@sweeps, $countcase, $countblock); #say "dumpIN( \@blockelts) " . dump(@blockelts);
	my @blocks = getblocks(\@sweeps, $countcase);  #say "dumpIN( \@blocks) " . dump(@blocks);
	my $winneritem = getitem(\@winneritems, $countcase, $countblock); #say "dump(\$winneritem): " . dump($winneritem);
	my $winnerline = getline($winneritem); #say "dump(\$winnerline): " . dump($winnerline);
	my $from = $winnerline;
	my @winnerlines = getlines( \@winneritems ); #say "dump(\@winnerlines): " . dump(@winnerlines);
	my %varnums = getcase(\@varinumbers, $countcase); #say "dumpININ---(\%varnums): " . dump(%varnums); 
	my %mids = getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids); 
	#eval($getfly);
	
	# STOP CONDITION
	if ( $counblock >= scalar( @{ $sweeps[$countcase] } ) ) # NUMBER OF BLOCK OF THE CURRENT CASE
	{ 
		my $cn = 0;
		foreach my $e (@winneritems)
		{
			say "Optimal option for case number $countcase: $winneritems[$countcase][$#$winneritems]";
			say makefilename(%mids);
			say "Gross number of instances: " . scalar ( countarray( @morphstruct ) ) ;
			say "Net number of instances: " . scalar ( @{ $morphcases[$countcase] } ) ;
			$cn++;
		}
			
		$countblock = 0;
		$countcase = $countcase++;
		if ( $countcase >= scalar( @sweeps ) )# NUMBER OF CASES OF THE CURRENT PROBLEM
		{
			say "END RUN.";
			exit;
		}
	}

	#my @taken = extractcase("$winneritem", \%mids); #say "------->taken: " . dump(@taken);
	#my $to = $taken[0]; #say "to-------->: $to";
	#my %carrier = %{$taken[1]}; #say "\%instancecarrier:--------->" . dump(%instancecarrier);

	my $casedata = { countcase => $countcase, rootnames => \@rootnames, countblock => $countblock, 
	sweeps => \@sweeps, varinumbers => \@varinumbers, miditers => \@miditers,  winneritems => \@winneritems, 
	instancecarrier => \%instancecarrier, to => $to, basket => \@basket, morphcases => \@morphcases, 
	morphstruct => \@morphstruct, vals => \%vals }; #say "\n\dumpCASE(\$casedata): " . dump($casedata) . "\n\n";
	callblocks( $casedata ); 
}

sub callblocks # IT CALLS THE SEARCH ON BLOCKS.
{	
	my $swap = shift;
	my %dat = %{$swap};
	my @rootnames = @{ $dat{rootnames} }; #say \"dump(\@rootnames): " . dump(@rootnames);
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase);
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock);
	my @sweeps = @{ $dat{sweeps} }; #say "dump(\@sweeps): " . dump(@sweeps);
	my @varinumbers = @{ $dat{varinumbers} }; #say "dump(\@varinumbers): " . dump(@varinumbers);
	my @miditers = @{ $dat{miditers} }; #say "dump(\@miditers): " . dump(@miditers);
	my @winneritems = @{ $dat{winneritems} }; #say "dumpIN( \@winneritems) " . dump(@winneritems);
	my @morphcases = @{ $dat{morphcases} }; #say "dumpIN( \@morphcases) " . dump(@morphcases);
	my @morphstruct = @{ $dat{morphstruct} }; #say "dumpIN( \@morphstruct) " . dump(@morphstruct);
	my %vals = %{ $dat{ vals} };
	#eval($getparshere);
	
	my $rootname = getrootname(\@rootnames, $countcase); #say "dump(\$rootname): " . dump($rootname);
	my @blockelts = getblockelts(\@sweeps, $countcase, $countblock); #say "dumpIN( \@blockelts) " . dump(@blockelts);
	my @blocks = getblocks(\@sweeps, $countcase);  #say "dumpIN( \@blocks) " . dump(@blocks);
	my $winneritem = getitem(\@winneritems, $countcase, $countblock); #say "dump(\$winneritem): " . dump($winneritem);
	my $winnerline = getline($winneritem); #say "dump(\$winnerline): " . dump($winnerline);
	my $from = $winnerline;
	my @winnerlines = getlines( \@winneritems ); #say "dump(\@winnerlines): " . dump(@winnerlines);
	my %varnums = getcase(\@varinumbers, $countcase); #say "dumpININ---(\%varnums): " . dump(%varnums); 
	my %mids = getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids); 
	#eval($getfly);
	
	my $blockdata = { countcase => $countcase, rootnames => \@rootnames, countblock => $countblock, 
	sweeps => \@sweeps, varinumbers => \@varinumbers, miditers => \@miditers,  winneritems => \@winneritems, 
	morphcases => \@morphcases, morphstruct => \@morphstruct, vals => \%vals }; #say "\ndumpBLOCK($blockdata): " . dump($blockdata) . "\n\n";
	deffiles( $blockdata );
}
	
sub deffiles # IT DEFINED THE FILES TO BE CALLED. 
{
	my $swap = shift;
	my %dat = %{$swap};
	my @rootnames = @{ $dat{rootnames} }; #say \"dump(\@rootnames): " . dump(@rootnames);
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase);
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock);
	my @sweeps = @{ $dat{sweeps} }; #say "dump(\@sweeps): " . dump(@sweeps);
	my @varinumbers = @{ $dat{varinumbers} }; #say "dump(\@varinumbers): " . dump(@varinumbers);
	my @miditers = @{ $dat{miditers} }; #say "dump(\@miditers): " . dump(@miditers);
	my @winneritems = @{ $dat{winneritems} }; #say "dumpIN( \@winneritems) " . dump(@winneritems);
	my @morphcases = @{ $dat{morphcases} }; #say "dumpIN( \@morphcases) " . dump(@morphcases);
	my @morphstruct = @{ $dat{morphstruct} }; #say "dumpIN( \@morphstruct) " . dump(@morphstruct);
	my %vals = %{ $dat{ vals} };
	#eval($getparshere);
	
	my $rootname = getrootname(\@rootnames, $countcase); #say "dump(\$rootname): " . dump($rootname);
	my @blockelts = getblockelts(\@sweeps, $countcase, $countblock); #say "dumpIN( \@blockelts) " . dump(@blockelts);
	my @blocks = getblocks(\@sweeps, $countcase);  #say "dumpIN( \@blocks) " . dump(@blocks);
	my $winneritem = getitem(\@winneritems, $countcase, $countblock); #say "dump(\$winneritem): " . dump($winneritem);
	my $winnerline = getline($winneritem); #say "dump(\$winnerline): " . dump($winnerline);
	my $from = $winnerline;
	my @winnerlines = getlines( \@winneritems ); #say "dump(\@winnerlines): " . dump(@winnerlines);
	my %varnums = getcase(\@varinumbers, $countcase); #say "dumpININ---(\%varnums): " . dump(%varnums); 
	my %mids = getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids);
	#eval($getfly);
	
	my $rootitem = "$mypath/$filenew"; #say "\$rootitem $rootitem";
	my (@basket, @box);
	push (@basket, $rootitem); 
	
	foreach my $var (@blockelts)
	{
		my $maxvalue = $varnums{$var}; #say "\$countblock $countblock, var: $var, maxvalue: $maxvalue";
		my @bucket;
		my $countbasket = 0;
		foreach my $item (@basket)
		{
			# my $item = $basket[$countbasket];
			my $countstep = 1;
			while ( $countstep <= $maxvalue)
			{
				my $to = "$item" . "$var" . "-" . "$countstep" . "_" ; #say "\@blockelts: @blockelts, \$countblock $countblock, var: $var, maxvalue: $maxvalue, \$countstep: $countstep, \$item: $item, \DUMP\$to: " . Dumper($to);
				push (@bucket, $to, ); #say "bucket: " . dump(@bucket);
				push ( @box, [ $var, $countstep ] );  #say "box: " . dump(@box); 
				$countstep++;
			} #say "bucketOUT: " . dump(@bucket);
			$countbasket++;
		}
		@basket = ();
		@basket = @bucket; #say "bucketOUT: " . dump(@bucket); say "boxOUT: " . dump(@box);
	}
	my @newbasket;
	$cn = 0;
	foreach (@basket)
	{
		unshift ( @{$box[$cn]} , $_ );
		push ( @newbasket, $box[$cn] ); #say "newbasketOUT: " . dump(@newbasket);
		$cn++;
	} 
	my @basket = @newbasket; #say "newbasketOUTOUT: " . dump(@newbasket);
	my $datatowork = { countcase => $countcase, rootnames => \@rootnames, countblock => $countblock, 
	sweeps => \@sweeps, varinumbers => \@varinumbers, miditers => \@miditers,  winneritems => \@winneritems, 
	basket => \@basket, morphcases => \@morphcases, morphstruct => \@morphstruct, vals => \%vals } ; #say "\ndumper-datatowork: " . dump($datatowork) . "\n\n";
	setlaunch( $datatowork );
}	

sub setlaunch # IT SETS THE DATA FOR THE SEARCH ON THE ACTIVE BLOCK.
{
	my $swap = shift;
	my %dat = %{$swap};
	my @rootnames = @{ $dat{rootnames} }; #say \"dump(\@rootnames): " . dump(@rootnames);
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase);
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock);
	my @sweeps = @{ $dat{sweeps} }; #say "dump(\@sweeps): " . dump(@sweeps);
	my @varinumbers = @{ $dat{varinumbers} }; #say "dump(\@varinumbers): " . dump(@varinumbers);
	my @miditers = @{ $dat{miditers} }; #say "dump(\@miditers): " . dump(@miditers);
	my @winneritems = @{ $dat{winneritems} }; #say "dumpIN( \@winneritems) " . dump(@winneritems);
	my @morphcases = @{ $dat{morphcases} }; #say "dumpIN( \@morphcases) " . dump(@morphcases);
	my @morphstruct = @{ $dat{morphstruct} }; #say "dumpIN( \@morphstruct) " . dump(@morphstruct);
	my %vals = %{ $dat{ vals} };
	#eval($getparshere);
	
	my @basket = @{ $dat{basket} }; #say "dump(\@basket): " . dump(@basket);
		
	my $rootname = getrootname(\@rootnames, $countcase); #say "dump(\$rootname): " . dump($rootname);
	my @blockelts = getblockelts(\@sweeps, $countcase, $countblock); #say "dumpIN( \@blockelts) " . dump(@blockelts);
	my @blocks = getblocks(\@sweeps, $countcase);  #say "dumpIN( \@blocks) " . dump(@blocks);
	my $winneritem = getitem(\@winneritems, $countcase, $countblock); #say "dump(\$winneritem): " . dump($winneritem);
	my $winnerline = getline($winneritem); #say "dump(\$winnerline): " . dump($winnerline);
	my $from = $winnerline;
	my @winnerlines = getlines( \@winneritems ); #say "dump(\@winnerlines): " . dump(@winnerlines);
	my %varnums = getcase(\@varinumbers, $countcase); #say "dumpININ---(\%varnums): " . dump(%varnums); 
	my %mids = getcase(\@miditers, $countcase); #say "dumpININ---(\%mids): " . dump(%mids); 
	#eval($getfly);
	
	my ( @instances, %carrier);
	if ($countblock == 0)
	{
		%carrier = %mids; #say "\%carrierA:--->" . dump(%carrier);
	}
	else 
	{
		my $prov = "_" . "$winnerline";
		%carrier = extractcase( $prov , \%carrier ); #say "\%carrierB:--->" . dump(%carrier);
	}

	foreach my $elt ( @basket )
	{
		
		my $string = $$elt[0]; #say "string : $string"; 
		my $countvar = $$elt[1]; #say "\$countvar : $countvar"; 
		my $countstep = $$elt[2]; #say "\$countstep : $countstep"; 
		my @taken = extractcase("$string", \%carrier); #say "------->taken: " . dump(@taken);
		my $to = $taken[0]; #say "to-------->: $to";
		my %instancecarrier = %{$taken[1]}; #say "\%instancecarrier:--------->" . dump(%instancecarrier);
		push (@instances, { countcase => $countcase, rootnames => \@rootnames, countblock => $countblock, 
					sweeps => \@sweeps, varinumbers => \@varinumbers, miditers => \@miditers,  winneritems => \@winneritems, 
					to => $to, instancecarrier => \%instancecarrier, countvar => $countvar, countstep => $countstep, 
					morphcases => \@morphcases, morphstruct => \@morphstruct, vals => \%vals } );
	} 
	#say "\ninstances: " . Dumper(@instances). "\n\n"; ### ZZZ
	exe( @instances ); # IT HAS TO BE CALLED WITH: setlaunch(@datatowork). @datatowork ARE CONSTITUTED BY AN ARRAY OF: ( [ \@blocks, \%varnums, \%bases, $name, $countcase, \@blockelts, $countblock ], ... )
}	
		
sub exe
{     
	#say "EXE!";
	my @instances = @_;
	
	my $firstinst = $instances[0];
	my %dat = %{ $firstinst };
	my $countcase = $dat{countcase}; #say "dump(\$countcase): " . dump($countcase);
	my $countblock = $dat{countblock}; #say "dump(\$countblock): " . dump($countblock);
	my %vals = %{ $dat{ vals} };

	my $simlist = "$mypath/$file-simlist-$countcase";
	my $simblock = "$mypath/$file-simblock-$countcase-$countblock";
	my $morphlist = "$mypath/$file-morphlist-$countcase";
	my $morphblock = "$mypath/$file-morphblock-$countcase-$countblock";
	my $reslist = "$mypath/$file-reslist-$countcase"; 
	my $resblock = "$mypath/$file-resblock-$countcase-$countblock";
	my $retlist = "$mypath/$file-retlist-$countcase"; # # FOR RETRIEVAL
	my $retblock = "$mypath/$file-retother-$countcase"; # FOR RETRIEVAL
	my $mergecase = "$mypath/$file-mergecase-$countcase"; # UNUSED FOR NOW
	my $mergeblock = "$mypath/$file-mergeblock-$countcase-$countblock"; # UNUSED FOR NOW
	
	if ( ( $councase == 0 ) and ($countblock == 0 ) )
	{
		(@simcases, @simstruct, @morphcases, @morphstruct, @rescases, @resstruct);
	}
	
	if ( $dowhat{morph} eq "y" ) 
	{ 
		Sim::OPT::Morph::morph( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	}

	if ( $dowhat{simulate} eq "y" )
	{ 
		Sim::OPT::Sim::sim( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	}
	if ( $dowhat{retrieve} eq "y" )
	{ 
		Sim::OPT::Retrieve::retrieve( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	}
	
	if ( $dowhat{eraseres} eq "y" ) 
	{ 
		Sim::OPT::Report::report( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	}
	if ( $dowhat{mergeresults} eq "y" )
	{ 
		 Sim::OPT::Descend::merge_reports( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	}
	if ( $dowhat{report} eq "y" )
	{
		 Sim::OPT::Report::convert_report( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	}
	if ( $dowhat{substitutenames} eq "y" )
	{
		 Sim::OPT::Report::filter_reports( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	}
	if ( $dowhat{filterconverted} eq "y" )
	{
		 Sim::OPT::Report::convert_filtered_reports( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	}
	if ( $dowhat{make3dtable} eq "y" )
	{
		 Sim::OPT::Report::maketable( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	}
	if ( $dowhat{takeoptima} eq "y" )
	{
		Sim::OPT::Descend::takeoptima( 
		{ 
			instances => \@instances, vals => \%vals, countcase => $countcase, countblock => $countblock, configfile => $configfile,
			simlist => $simlist, simstruct => $simstruct, morphlist => $morphlist,  morphstruct => $morphstruct, 
			simcases => @simcases, simstruct => \@simstruct, morphcases => \@morphcases, morphstruct => \@morphstruct, 
			simlist => $simlist, simblock => $simblock, morphlist => $morphlist, morphblock => $morphblock,
			rescases => @rescases, resblock => @resstruct, reslist => $reslist, resblock => $resblock,
			retlist => $reslist, retblock => $resblock, mergecase => $mergecase, mergeblock => $mergeblock, 
			morphcases => \@morphcases, morphstruct => \@morphstruct
		} );
	} #say "getexe: " . dump(@instances);
} # END SUB exe
	
sub start
{
###########################################
print "THIS IS OPT.
Copyright by Gian Luca Brunetti and Politecnico di Milano, 2008-14.
{ DAStU Department, Polytechnic of Milan }

.  .  .  .  .  .  .  .  .  .  .  .  .

Please insert the name of a configuration file for OPT (Unix path)\n\n";
###########################################
	$configfile = <STDIN>;
	chomp $configfile;
	if (-e $configfile ) { ; }
	else { &start; }
}

###########################################################################################
		
sub opt
{
	
	###############################################################

	
	&start;
	# eval `cat $configfile`; # The file where the program data are
	
	require $configfile;

#	if ($casefile) { eval `cat $casefile` or die; }
#	if ($chancefile) { eval `cat $chancefile` or die; }

	print "\nNow in Sim::OPT.\n";
	
	my $filenew = "$file"."_";
	
	if ( ($outfile) and (-e $outfile) ) { open ( OUTFILE, ">$outfile" ) or die "Can't open $outfile: $!"; }
	if ( ($toshell) and (-e $toshell) ) { open ( TOSHELL, ">$toshell" ) or die "Can't open $toshell: $!"; }	
	
	unless (-e "$mypath") 
	{ 
		if ($exeonfiles eq "y") 
		{
			`mkdir $mypath`; 
		} 
	}
	unless (-e "$mypath") 
	{ 
		print TOSHELL "mkdir $mypath\n\n"; 
	}
	
	#####################################################################################
	# INSTRUCTIONS THAT LAUNCH OPT AT EACH SWEEP (SUBSPACE SEARCH) CYCLE
	
	if (@sweeps) # IF THIS VALUE IS DEFINED
	{
		fromsweep_toopt(@sweeps); #say "Dumper(\@chanceseed): " . Dumper(@chanceseed); say "Dumper(\@caseseed): " . Dumper(@caseseed) ;
	}
	
	makeflatvarnsnum(@chanceseed); # say "\@flatvarnsnum: @flatvarnsnum";
	convchanceseed(@chanceseed); # say "Dumper(\@chanceseed): " . Dumper(@chanceseed);	
	convcaseseed(@caseseed); #say "Dumper(\@caseseed): " . Dumper(@caseseed) ;
		
	unless (@sweeps)
	{
		fromopt_tosweep( { casegroup => [@caseseed], chancegroup => [@chanceseed] } ); # say "\@tree: " . Dumper(@tree);
	}
	
	#my  $itersnum = $varinumbers[$countcase]{$varinumber}; say "\$itersnum: $itersnum"; 
	#say "dump(\@varinumbers), " . dump(@varinumbers); #say "dumpBEFORE(\@miditers), " . dump(@miditers);
	calcoverlaps(@sweeps); # PRODUCES @calcoverlaps WHICH IS globsAL. ZZZ
	
	calcmiditers(@varinumbers); #say "dumpAFTER(\@miditers), " . dump(@miditers); # globsALS. ZZZ
	#$itersnum = getitersnum($countcase, $varinumber, @varinumbers); #say "\$itersnum OUT = $itersnum";
	
	@rootnames = definerootcases(\@sweeps, \@miditers); 
	
	my $countcase = 0;
	my $countblock = 0;

	my @winneritems = populatewinners(@rootnames);
	
	callcase( { countcase => $countcase, rootnames => \@rootnames, countblock => $countblock, 
	sweeps => \@sweeps, varinumbers => \@varinumbers, miditers => \@miditers,  winneritems => \@winneritems, vals => \%vals } );
	

	close(OUTFILE);
	close(TOSHELL);
	exit;
} # END 

#############################################################################

1;

__END__

=head1 NAME

Sim::OPT is a tool for detailed metadesign managing parametric explorations through the ESP-r building performance simulation platform and performing optimization by block coordinate descent.

=head1 SYNOPSIS

  use Sim::OPT;
  opts;

=head1 DESCRIPTION

Sim::OPT it a tool for detailed metadesign of buildings. It morphs models by propagation of constraints through the ESP-r building performance simulation platform and performs optimization by overlapping block coordinate descent.

A working knowledge of ESP-r is necessary to use OPT. Information about ESP-r can be found at http://www.esru.strath.ac.uk/Programs/ESP-r.htm.

To install OPT, the command <cpanm Sim::OPT> has to be issued. Perl will take care to install all dependencies. OPT can be loaded through the command <use Sim::OPT> in Perl. For that purpose, the "Devel::REPL" module can be used. As an alternative, the batch file "opt" (which can be found packed in the "optw.tar.gz" file in "example" folder in this distribution) may be copied in a work directory and the command <opt> may be issued. That command will activate the OPT's functions, following the settings specified in a previously prepared configuration file. When launched, OPT will ask the path to that file. Its activity will start after receiving that information. 
That file must contain a suitable description of the operations to be accomplished pointing to an existing ESP-r model.

In "optw.tar.gz" there is an example of OPT configuration file. An example of configuration file for an earlier version of the program may be downloaded at http://figshare.com/authors/Gian_luca_Brunetti/624879 .

To run OPT without making it launch ESP-r, the setting <$exeonfiles = "n";> should be specified in the configuration file. Note that this can only be aimed to inspect the command that OPTS will give to ESP-r through the shell. The search obtained will be very likely to be different from that driven by simulation results. If simulations are not launched, the optimal instance  at each subspace search cannot indeed be selected. In its place, the base case will be kept by the program, just to bring the process to completion. A sequential block search (Gauss-Seidel method) cannot indeed be run "dry". The variable "$toshell" specifies the path to a file that will receive the shell commands in place of the shell.

If $exeonfiles is set to "y", OPT will give instruction to ESP-r via shell to make it modify the building base model in different copies. Then, if asked, it will run simulations, retrieve the results, extract some information from them and order it as requested.

Besides an OPT configuration file, configuration files for propagation of constraints may be created. This would give to the morphing operations greater flexibility. Propagation of constraints can regard the geometry of a model, solar shadings, mass/flow network, and/or controls; and also, how those pieces of information affect each other and daylighting. Example of configuration files for propagation of constraints are included in this distribution.

The ESP-r model folders and the result files that will be created in a parametric search will be named as the base building model, numbers and other characters to described an instance. For example, the instance produced in the first iteration for a root model named "model" in a search constituted by 3 morphing phases and 5 iteration steps each will be named "model_1-1_2-1_3-1"; and the last one "model_1-5_2-5_3-5". 

The structure of block searches is described through the variable "@sweeps" . Each case is listed inside square brackets. And each search subspace (block) in them is listed inside square brakets, nested in cases. For example: a sequence constituted by two brute force searches, one regarding parameters 1, 2 3 and the other regarding parameters 1, 4, 5, 7 would be described with: @sweeps = ( [ [ 1, 2, 3 ] ] , [ 1, 4, 5, 7 ] ] ). And a block search with the first subspace regarding parameters 1, 2, 3 and the second subspace regarding parameters 3, 4, 5, 6 would be described with: @sweeps = ( [ [ 1, 2, 3 ] , [ 3, 4, 5, 6 ] ] ). 

The number of iterations to be taken into account for each parameter for each case is specified in the "@varinumbers" variable. To specifiy that the parameters of the last example are tried for three values (iterations) each, @varinumbers = ( { 1 => '3', 2 => '3', 3 => '3', 4 => '3', 5 => '3', 6 => '3' } ).

OPT is a program I have begun to write as a side project in 2008 with no funding. It is still in alpha stage though. It is the first real program I attempted to write. From time to time I add some parts to it. The parts of it that have been written earlier or later are the ones that are coded in the strangest manner.

Gian Luca Brunetti, Politecnico di Milano
gianluca.brunetti@polimi.it

=head2 EXPORT

"opts".

=head1 SEE ALSO

The available examples are collected in the "example" directory in this distribution and at the figshare address specified above.

=head1 AUTHOR

Gian Luca Brunetti, E<lt>gianluca.brunetti@polimi.itE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008-2014 by Gian Luca Brunetti and Politecnico di Milano. This is free software.  You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 or later.


=cut
