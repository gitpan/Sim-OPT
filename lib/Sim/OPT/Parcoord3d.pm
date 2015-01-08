package Sim::OPT::Parcoord3d;
# Copyright (C) 2015 by Gian Luca Brunetti and Politecnico di Milano.
# This is Sim::OPT::Parcoord3d, a program that can receive as input the data for a bi-dimensional parallel coordinate plot in cvs format to produce as output an Autolisp file that can be used from Autocad or Intellicad-based 3D CAD programs to obtain 3D parallel coordinate plots.
# This is free software.  You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.

use v5.14;
# use v5.20;
use Exporter;
use parent 'Exporter'; # imports and subclasses Exporter

use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Math::Trig;
use Math::Round;
use Math::Round 'nlowmult';
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
use Sim::OPT::Takechance;

our @ISA = qw(Exporter); # our @adamkISA = qw(Exporter);
#%EXPORT_TAGS = ( DEFAULT => [qw( &opt &prepare )]); # our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
#@EXPORT_OK   = qw(); # our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( parcoord3d ); # our @EXPORT = qw( );
$VERSION = '0.01'; 

#########################################################################################
# HERE FOLLOWS THE CONTENT OF "Parcoord3d.pm", Sim::OPT::Parcoord3d
#########################################################################################

sub parcoord3d
{
	if ( not ( @ARGV ) )
	{
		$toshell = $main::toshell;
		#$tee = new IO::Tee(\*STDOUT, ">>$toshell"); # GLOBAL ZZZ
		say $tee "\n#Now in Sim::OPT::Takechance.\n";
		$configfile = $main::configfile; #say "dump(\$configfile): " . dump($configfile);
		@sweeps = @main::sweeps; #say "dump(\@sweeps): " . dump(@sweeps);
		@varinumbers = @main::varinumbers; say $tee "dump(\@varinumbers): " . dump(@varinumbers);
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
		$target = $main::target;
		
		$convertfile = $main::convertfile;
		$pick = $main::pick; 
		$numof_pars = $main::numof_pars;
		$xspacing = $main::xspacing; 
		$yspacing = $main::yspacing;
		$zspacing = $main::zspacing;
		$ob_column = $main::ob_column; 
		$numof_layers = $main::numof_layers;
		$otherob_column = $main::otherob_column;
		$cut_column = $main::cut_column;
		$writefile = $main::writefile;
		$writefile_pretreated = $main::writefile_pretreated;
		$transitional = $main::transitional;
		$newtransitional = $main::newtransitional;
		$lispfile = $main::lispfile;
		@layercolours = @main::layercolours;
		$offset = $main::offset;
		$brushspacing = $main::brushspacing;
	}
	else
	{
		my $file = $ARGV[0];
		require $file;
	}

	

	my $scale_xspacing = ( $numof_pars / $xspacing );

	open ( CONVERTFILE, $convertfile ) or die;
	my @lines = <CONVERTFILE>;
	close CONVERTFILE;

	if ($pick)
	{ 
		$convertedfile = "$convertfile" . "filtered.csv";
		open ( CONVERTEDFILE, ">$convertedfile" ) or die;
		my $countline = 0;
		while ( $countline < $pick )
		{
			print CONVERTEDFILE "$lines[$countline]";
			$countline++;
		}
	
		$countline = ($#lines - $pick) ;
		while ( $countline  < $#lines ) 
		{
			print CONVERTEDFILE "$lines[$countline]";
			$countline++;
		}
		close CONVERTEDFILE;
	
		open (CONVERTEDFILE, "$convertedfile" );
		@lines = <CONVERTEDFILE>;
		close CONVERTEDFILE;
	}

	my $numof_layerelts = ( scalar(@lines) / $numof_layers ); # scalar(@lines = num of trials

	my @newdata;
	sub makedata
	{
		my $swap = shift; my @lines = @$swap;
	
		my $countline = 0;
		foreach my $line (@lines)
		{
			my @linedata;
			chomp($line);
			my @rowelts = split(/,/ , $line);
			my $ob_fun;
			if ($ob_column)
			{
				$ob_fun = $rowelts[$ob_column];
			}
			else
			{
				$ob_fun = $rowelts[$#rowelts];
			}
		
			my $otherob_fun = $rowelts[$otherob_column];
			if ( $otherob_fun =~ /-/ )
			{
				my @thesedata = split( /-/ , $otherob_fun );
				$otherob_fun = $thesedata[1];
			}
		
			my $countvar = 0;
			foreach my $rowelt (@rowelts)
			{
				if ( $countvar < $numof_pars )
				{
					if ( $rowelt =~ /-/ )
					{
						my @vardata = split( /-/ , $rowelt );
						#say "VARDATA: " . Dumper(@vardata);
						push ( @linedata, [ @vardata ] );
					}
					else
					{
						push ( @linedata, [ $countvar, $rowelt ] );
					}
					$countvar++;
				}
			}		
			push ( @newdata, [ @linedata, $otherob_fun, $ob_fun ] );
			$countline++;
		}
	}
	makedata(\@lines);

	my ( @pars, @obfun, @otherobfun, $maxobfun, $minobfun, @maxpars, @minpars, $othermaxobfun, $otherminobfun, $countmaxobfun, $countminobfun, $countmaxotherobfun, $countminotherobfun ) ;
	sub makestats
	{
		my $swap = shift; my @newdata = @$swap;
		foreach my $line (@newdata)
		{
			chomp($line);
			my @elts = @{$line};
		
			my $elm1 = pop(@elts);
			push ( @obfun, $elm1 );
			my $elm2 = pop(@elts);
			push ( @otherobfun, $elm2 );

			my $count = 0;
			foreach my $elt (@elts)
			{
				my @pair = @{$elt};
				my $value = $pair[1];
				push ( @{$pars[$count]}, $value );
				$count++;
			}	
		}
	
		$maxobfun = max(@obfun);
		$minobfun = min(@obfun);	
		$maxotherobfun = max(@otherobfun);
		$minotherobfun = min(@otherobfun);
	
		$countel = 0;
		foreach my $e (@obfun)
		{
			if ($e eq $maxobfun )
			{
				$countmaxobfun = $countel;
			}
			if ($e eq $minobfun )
			{
				$countminobfun = $countel;
			}
			$countel++;
		}
	
		my $countel2 = 0;
		foreach my $e (@otherobfun)
		{
			if ($e eq $maxotherobfun )
			{
				$countmaxotherobfun = $countel2;
			}
			if ($e eq $minotherobfun )
			{
				$countminotherobfun = $countel2;
			}
			$countel2++;
		}

		sub printpar
		{
			foreach my $par (@pars)
			{
				print WRITEFILE "PAR: @$par \n";
			}
		}
	}
	makestats(\@newdata);

	sub writeminmaxpars
	{
		my $swap = shift; my @pars = @$swap;
		my $countpar = 0;
		foreach my $par (@pars)
		{
			my @elts = @$par;
			push ( @maxpars, max(@elts) );
			push ( @minpars, min(@elts) );
			$countpar++;
		}
	}
	writeminmaxpars(\@pars);

	my ( @plotdata, @newplotdata, @newnewdata );
	sub plotdata
	{
		my $case_per_layer = ( scalar(@newdata) / $numof_layers );
		$countcase = 0;
		foreach my $el ( @{$pars[0]} )
		{	
			my @provbowl;	
			my $scaled_zvalue = ( ( $newdata[$countcase][($#{$newdata[$countcase]}-1)] - $minotherobfun ) / ( $maxotherobfun - $minotherobfun ) );
			my $countvar = 0;
			while ($countvar < $numof_pars)
			{
				my $layer_num = ( int( $countcase / $case_per_layer ) + 1) ; 
				my $scaled_xvalue = ( $countvar / $scale_xspacing );
				my $scaled_yvalue = ( ( $pars[$countvar][$countcase] - $minpars[$countvar] ) / ( $maxpars[$countvar] - $minpars[$countvar] ) );
				$scaled_yvalue = ($scaled_yvalue * $yspacing);
				$scaled_zvalue = ($scaled_zvalue * $zspacing);
				if ($otherob_column)
				{
					push (@provbowl, [ $scaled_xvalue, $scaled_yvalue, $scaled_zvalue, $layer_num ] );
				}
				else
				{
					push (@provbowl, [ $scaled_xvalue, $scaled_yvalue, 0, $layer_num ] );
				}
				$countvar++;			
			}
			push (@plotdata, [ @provbowl ]);
			$countcase++;
		}
	}
	plotdata;

	sub cutcoordinates
	{
		foreach (@plotdata)
		{
			splice( @{$_}, $cut_column, 1);
		}
	}
	if ($cut_column)
	{
		cutcoordinates; # CUTS SPECIFIED COORDINATES
	}

	sub printplotdata_pretreated
	{
		open (WRITEFILE_PRETREATED, ">$writefile_pretreated") or die;
		print WRITEFILE_PRETREATED dump(@plotdata); #CONTROL!!!
		close WRITEFILE_PREATREATED;
	}
	printplotdata_pretreated;

	sub solidify
	{print "BEGUN\n";
		my $swap = shift; my @plotdata = @$swap;
		open (WRITEFILE, ">$writefile") or die;
		my $countgroup = 0;
		foreach my $e (@plotdata)
		{#print "INLEVEL2\n";
			my @elts = @{$e};
			my @newnewbag;
			my $counter = 0;
			foreach my $elm (@elts)
			{#print "INLEVEL3\n";
				my @elms = @{$elm};
				my @cutelms = @elms[0..2]; # PUT ..2 IF ALSO THE THIRD AXIS HAS TO BE CHECKED FOR NON-REPETITIONS, PUT 1 OTHERWISE.
				my $counthit = -1;
				foreach my $el (@plotdata)
				{#print "INLEVEL4\n";
					my @els = @{$el};
					foreach my $elem (@els)
					{#print "INLEVEL5,6\n";
						my @elems = @{$elem};
						my @cutelems = @elems[0..2]; # PUT ..2 IF ALSO THE THIRD AXIS HAS TO BE CHECKED FOR NON-REPETITIONS, PUT 1 OTHERWISE.
						if (@cutelms ~~ @cutelems)
						{#print "INLEVEL7\n";
							#print "CUTELMS: " . dump(@cutelms) . "\nCUTELEMS: " . dump(@cutelems) . "\n";
							$counthit++;
							print "COUNTGROUP: $countgroup, HIT! $counthit\n";
						
							if ($counthit > 0)
							{
								print "COUNTHITNOW: $counthit\n";
								if ( $counthit % 2 == 1) # odd
								{
									$elms[0] = ( $elms[0] - ( $brushspacing * $counthit ) );
								}
								else
								{
									$elms[0] = ( $elms[0] + ( $brushspacing * $counthit ) );
								}
								push ( @newnewbag, [ nlowmult(0.0001, $elms[0]), nlowmult(0.0001, $elms[1]), nlowmult(0.0001, $elms[2]), nlowmult(0.0001, $elms[3]) ]);
							}
							else
							{
								push(@newnewbag, [ nlowmult(0.0001, $elms[0]), nlowmult(0.0001, $elms[1]), nlowmult(0.0001, $elms[2]), nlowmult(0.0001, $elms[3]) ]);
							}
						}
					}	
				}
			
				$counter++
			}
			push( @newplotdata, [ @newnewbag ] );
			$countgroup++;
		}
		print WRITEFILE dump(@newplotdata);
		close WRITEFILE;
	}
	solidify(\@plotdata);


	#my @plotdata = eval `cat $writefile`;

	sub prepare
	{
		open( TRANSITIONAL, ">$transitional" ) or die;
		my $countgroup = 0;
		foreach my $group (@newplotdata)
		{
			my @elts = @{$group};
			my $countpar = 0;
			my ( @newplotdatabottom, @newplotdatafront, @newplotdataback, @newplotdataright, @newplotdataleft );
			foreach my $elt (@elts)
			{
				my @coords = @{$elt};
				my @nextcoords = @{$elts[$countpar+1]};
				#print "COORDS: " . dump(@coords);
				#print "NEXTCOORDS: " . dump(@nextcoords);
				my @newcoords;
				push( @newcoords, [ @coords ] );
				push( @newcoords, [ ($coords[0] - ($yspacing * $offset ) ) , $coords[1] , $coords[2], $coords[3] ] );
				push( @newcoords, [ ($coords[0] - ($yspacing * $offset ) ) , $coords[1] , ( $coords[2] - ($yspacing * $offset ) ) , $coords[3] ] );
				push( @newcoords, [ $coords[0], $coords[1] , ( $coords[2] - ($yspacing * $offset ) ) , $coords[3] ] );
				push( @newplotdatabottom, [ @newcoords ] );
				#print "DONE1 BOTTOM COUNTGROUP $countgroup COUNTPAR $countpar\n";
			
				my @newcoords;
				unless ($countpar == $#elts)
				{			
					push( @newcoords, [ @coords ] );
					push( @newcoords, [ ($coords[0] - ($yspacing * $offset ) ) , $coords[1] , $coords[2], $coords[3] ] );
					push( @newcoords, [ ($nextcoords[0] - ($yspacing * $offset ) ) , $nextcoords[1] , $nextcoords[2], $nextcoords[3] ] );
					push( @newcoords, [ @nextcoords] );
					push( @newplotdatafront, [ @newcoords ] );
				}
				#print "DONE2 FRONT COUNTPAR $countpar\n";

				my @newcoords;
				unless ($countpar == $#elts)
				{
					push( @newcoords, [ ($coords[0] - ($yspacing * $offset ) ) , $coords[1] , $coords[2], $coords[3] ] );
					push( @newcoords, [ ($coords[0] - ($yspacing * $offset ) ) , $coords[1] , ( $coords[2] - ($yspacing * $offset ) ) , $coords[3] ] );
					push( @newcoords, [ ($nextcoords[0] - ($yspacing * $offset ) ) , $nextcoords[1] , ( $nextcoords[2] - ($yspacing * $offset ) ) , $nextcoords[3] ] );
					push( @newcoords, [ ($nextcoords[0] - ($yspacing * $offset ) ) , $nextcoords[1] , $nextcoords[2], $nextcoords[3] ] );
					push( @newplotdataleft, [ @newcoords ] );
				}
				#print "DONE3 LEFT COUNTPAR $countpar\n";

				my @newcoords;
				unless ($countpar == $#elts)
				{
					push( @newcoords, [ ($coords[0] - ($yspacing * $offset ) ) , $coords[1] , ( $coords[2] - ($yspacing * $offset ) ) , $coords[3] ] );
					push( @newcoords, [ $coords[0], $coords[1] , ( $coords[2] - ($yspacing * $offset ) ) , $coords[3] ] );
					push( @newcoords, [ $nextcoords[0], $nextcoords[1] , ( $nextcoords[2] - ($yspacing * $offset ) ) , $nextcoords[3] ] );
					push( @newcoords, [ ($nextcoords[0] - ($yspacing * $offset ) ) , $nextcoords[1] , ( $nextcoords[2] - ($yspacing * $offset ) ) , $nextcoords[3] ] );
					push( @newplotdataback, [ @newcoords ] );
				}
				#print "DONE4 BACK COUNTPAR $countpar\n";

				my @newcoords;
				unless ($countpar == $#elts)
				{
					push( @newcoords, [ $coords[0], $coords[1] , ( $coords[2] - ($yspacing * $offset ) ) , $coords[3] ] );
					push( @newcoords, [ @coords ] );
					push( @newcoords, [ @nextcoords ] );
					push( @newcoords, [ $nextcoords[0], $nextcoords[1] , ( $nextcoords[2] - ($yspacing * $offset ) ) , $nextcoords[3] ] );
					push( @newplotdataright, [ @newcoords ] );
				}
				#print "DONE5 RIGHT COUNTPAR $countpar\n";
				# print "COUNTPAR: $countpar\n";
				$countpar++;
			}
		
			if (@newplotdatafront)
			{
				push(@newnewdata, @newplotdatabottom , @newplotdatafront,  @newplotdataleft, @newplotdataback, @newplotdataright );
			}
			else
			{
				push(@newnewdata, @newplotdatabottom );
			}

			# print "COUNTGROUP: $countgroup\n";
			$countgroup++;
		}
		print TRANSITIONAL dump(@newnewdata);
		close TRANSITIONAL;
	}
	prepare;


	sub writelisp
	{
		open(LISPFILE, ">$lispfile");
		my $counter = 1;
		foreach my $colour (@layercolours)
		{
			print LISPFILE "\( command \"layer\" \"m\" \"$counter\" \"c\" \"$colour\" \"\" \"\" \)\n";
			$counter++;
		}
		foreach my $series (@newnewdata)
		{
			my @vs = @{$series};
			print LISPFILE "\( command \"layer\" \"s\" \"$vs[0][3]\" \"\" \)\n";
			print LISPFILE "\( command \"3dface\" \"$vs[0][0],$vs[0][2],$vs[0][1]\" \"$vs[1][0],$vs[1][2],$vs[1][1]\" \"$vs[2][0],$vs[2][2],$vs[2][1]\" \"$vs[3][0],$vs[3][2],$vs[3][1]\" \"\" \)\n";
		}
		close LISPFILE;
	}
	writelisp;
}

1;


__END__

=head1 NAME

Sim::OPT::Parcoord3d.

=head1 SYNOPSIS

  use Sim::OPT::Parcoord3d;
  parcoord3d your_configuration_file.pl;

=head1 DESCRIPTION

Sim::OPT::Parcoord3d is a program that can receive as input the data for a bi-dimensional parallel coordinate plot in CVS format and produce as output an Autolisp file (that can be used from inside Autocad or Intellicad-based 3D CAD programs) to obtain a 3D parallel coordinate plot made with surfaces.

The objective function to be represented through colours in the parallel coordinate plot has to be put in the last (right) column in the CVS file.

"Sim::OPT::Parcoord3d" can be called from !Sim::OPT! or directly from the command line (after issuing < re.pl > and < use Sim::OPT::Parcoord3d >) with the command < parcoord3d your_configuration_file.pl >.

The variables to be specified in the configuration file are described in the comments in the "Sim::OPT" configuration file included in the "examples" folder in this distribution. 

Gian Luca Brunetti, Politecnico di Milano
gianluca.brunetti@polimi.it

=head2 EXPORT

"parcoord3d".

=head1 SEE ALSO

The available examples are collected in the "example" directory in this distribution.

=head1 AUTHOR

Gian Luca Brunetti, E<lt>gianluca.brunetti@polimi.itE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Gian Luca Brunetti and Politecnico di Milano. This is free software.  You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 or later.


=cut

